////////////////////////////////////////////////  VERZIJA 1.0
///  Scan4You API Scanner - Functions module
///  bosko@globalnet.ba
///
///  parts of this file contain code from:
///  yOpenFiles.pas and tokens.pas
///  created by: Psychlo @ HackHound
///



unit uFunctions;

interface

uses
  Windows, Classes, SysUtils, IdHTTP, uMain;

function __OpenFile(szFileName: String; var hFile, fSize: Cardinal): Pointer;
function __CloseFile(hFile: Cardinal; lpBuffer: Pointer): Boolean;
function __SaveFile(FileName: String; pFile: Pointer; fSize: Cardinal): Boolean;
function Numtok(S: string; const Separator: string = ' '): Integer;
function Gettok(S: string; Index: Integer; const Separator: string = ' '; bContinue: Boolean = False): string;
function GetTagValue(S, tagName: string; const tagOpenChar: string = '['; const tagCloseChar: string = ']'): string;
function PostFile(URL, Filename: string; var oResult: string): Boolean;

implementation

//openfiles
function __OpenFile(szFileName: String; var hFile, fSize: Cardinal): Pointer;
var
 lpOutput : Pointer;
 nBytes   : Cardinal;
begin
 Result := nil;
 hFile := CreateFile(PChar(szFileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
 if (hFile = 0) then Exit;
 fSize := GetFileSize(hFile, nil);
 if (fSize = 0) then
 begin
  CloseHandle(hFile);
  Exit;
 end;
 lpOutput := VirtualAlloc(nil, fSize, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);
 if not (ReadFile(hFile, lpOutput^, fSize, nBytes, nil)) then
 begin
  CloseHandle(hFile);
  VirtualFree(lpOutput, 0, MEM_RELEASE);
  Exit;
 end;
 Result := lpOutput;
end;

function __CloseFile(hFile: Cardinal; lpBuffer: Pointer): Boolean;
begin
 Result := (VirtualFree(lpBuffer, 0, MEM_RELEASE) and CloseHandle(hFile));
end;

function __SaveFile(FileName: String; pFile: Pointer; fSize: Cardinal): Boolean;
var
 hFile, nBytes : Cardinal;
begin
 Result := False;
 if ((pFile = nil) or (fSize = 0)) then Exit;
 hFile := CreateFile(PChar(FileName), GENERIC_WRITE, FILE_SHARE_READ, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);
 if (hFile <> INVALID_HANDLE_VALUE) then
 begin
  Result := WriteFile(hFile, pFile^, fSize, nBytes, nil);
  CloseHandle(hFile);
 end;
end;

///tokens
function StrLen(const Str: PChar): Cardinal; assembler;
asm
 MOV     EDX,EDI
 MOV     EDI,EAX
 MOV     ECX,0FFFFFFFFH
 XOR     AL,AL
 REPNE   SCASB
 MOV     EAX,0FFFFFFFEH
 SUB     EAX,ECX
 MOV     EDI,EDX
end;

function Numtok(S: string; const Separator: string = ' '): Integer;
var
 pStr       : PChar;
 i, max_addr: Integer;
begin
 Result := 0;
 if (S = '') then Exit;
 if (Pos(Separator, S) = 0) then Exit;
 if (Pos(Separator, S) = 1) then Delete(S, 1, Length(Separator));
 if (Copy(S, Length(S) - Length(Separator) + 1, Length(Separator)) <> Separator) then S := S + Separator;
 pStr := PChar(S);
 max_addr := Integer(pStr) + Integer(StrLen(pStr)) + 1;
 i := 0;
 repeat
  if (Pos(Separator, string(pStr)) > 0) then
   if (Integer(pStr) + Pos(Separator, string(pStr)) <= max_addr) then
    pStr := PChar(Integer(pStr) + Pos(Separator, string(pStr)) + Length(Separator) - 1);
  Inc(i, 1);
 until (pStr[0] = #0);
 Result := i;
end;

function Gettok(S: string; Index: Integer; const Separator: string = ' ';
  bContinue: Boolean = False): string;
var
 pStr         : PChar;
 i, max_addr  : Integer;
 bFinishAdded : Boolean;
begin
  Result := S;
  if (Index <= 0) then Exit;
  if (S = '') then Exit;
  if (Pos(Separator, S) = 0) then Exit;
  if (Pos(Separator, S) = 1) then Delete(S, 1, Length(Separator));
  bFinishAdded := False;
  if (Copy(S, Length(S) - Length(Separator) + 1, Length(Separator)) <> Separator) then
  begin
   S := S + Separator;
   bFinishAdded := True;
  end;
  pStr := PChar(S);
  max_addr := Integer(pStr) + Integer(StrLen(pStr)) + 1;
  i := 0;
  repeat
   if (bContinue) then Result := string(pStr)
    else Result := Copy(string(pStr), 1, Pos(Separator, String(pStr)) - 1);
    if (Pos(Separator, string(pStr)) > 0) then
      if (Integer(pStr) + Pos(Separator, String(pStr)) <= max_addr) then
        pStr := PChar(Integer(pStr) + Pos(Separator, String(pStr)) + Length(Separator) - 1);
    Inc(i, 1);
  until ((i = Index) or (pStr[0] = #0));
  if ((bContinue) and (bFinishAdded)) then
    if (Copy(Result, Length(Result) - Length(Separator) + 1, Length(Separator)) = Separator) then
      Delete(Result, Length(Result) - Length(Separator) + 1, Length(Separator));
end;

function GetTagValue(S, tagName: string; const tagOpenChar: string = '['; const tagCloseChar: string = ']'): string;
begin
  Result := Gettok(Gettok(S, 1, tagOpenChar + '/' + tagName + tagCloseChar), 2, tagOpenChar + tagName + tagCloseChar);
end;

// additional
function RandString(s: string; Min, Max: Integer): string;
var
 count, i, r : Integer;
begin
 Result := '';
 if ((Max - Min) > 0) then
 begin
  count := Random(Max - Min + 1) + Min;
  for i := 0 to count - 1 do
  begin
   r := Random(Length(s)) + 1;
   Result := Result + s[r];
  end;
 end;
end;


function PostFile(URL, Filename: string; var oResult: string): Boolean;
var
  IdHTTP1        : TIdHTTP;
  MS             : TMemoryStream;
  pBuffer, pFile : Pointer;
  hFile, fSize   : Cardinal;
  sBoundary, sPostHeaderBefore, sPostHeaderAfter: string;
const
  ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  CRLF = #13#10;
begin
  Result := False;
  IdHTTP1 := TIdHTTP.Create(nil);
  MS := TMemoryStream.Create;
  try
    sBoundary := RandString(ALPHABET, 30, 30);
    IdHTTP1.Request.ContentType := 'multipart/form-data; boundary=' + sBoundary;

    sPostHeaderBefore :=
      '' +
    '--' + sBoundary + CRLF + 'Content-Disposition: form-data; name="token"' + CRLF + CRLF + FMain.APIToken  + CRLF
  + '--' + sBoundary + CRLF + 'Content-Disposition: form-data; name="id"'    + CRLF + CRLF + FMain.ProfilID  + CRLF
  + '--' + sBoundary + CRLF + 'Content-Disposition: form-data; name="uppload"; filename="' +extractfilename(Filename)+ '"' + CRLF + 'Content-Type: application/octet-stream' + CRLF + CRLF
  + '';
    sPostHeaderAfter :=
      '' +
      CRLF +
      '--' + sBoundary + CRLF + 'Content-Disposition: form-data; name="action"' + CRLF + CRLF + 'file' + CRLF
    + '--' + sBoundary + CRLF + 'Content-Disposition: form-data; name="frmt"'   + CRLF + CRLF + 'json' + CRLF
    + '--' + sBoundary + CRLF + 'Content-Disposition: form-data; name="link"'   + CRLF + CRLF + '1' + CRLF
    + '';
    pFile := __OpenFile(Filename, hFile, fSize);
    if (pFile <> nil) then
    begin
      pBuffer := VirtualAlloc(nil, Cardinal(fSize) + Cardinal(Length(sPostHeaderBefore)) + Cardinal(Length(sPostHeaderAfter)), MEM_COMMIT or MEM_RESERVE, PAGE_READWRITE);
      if (pBuffer <> nil) then
      begin
       ZeroMemory(pBuffer, Cardinal(fSize) + Cardinal(Length(sPostHeaderBefore)) + Cardinal(Length(sPostHeaderAfter)));
       CopyMemory(pBuffer, PChar(sPostHeaderBefore), Length(sPostHeaderBefore));
       CopyMemory(Ptr(Integer(pBuffer) + Length(sPostHeaderBefore)), pFile, fSize);
       CopyMemory(Ptr(Cardinal(pBuffer) + Cardinal(Length(sPostHeaderBefore)) + Cardinal(fSize)), PChar(sPostHeaderAfter), Length(sPostHeaderAfter));
       MS.Write(pBuffer^, Cardinal(fSize) + Cardinal(Length(sPostHeaderBefore)) + Cardinal(Length(sPostHeaderAfter)));
       oResult := IdHTTP1.Post(URL, MS);
       Result := True;
       VirtualFree(pBuffer, 0, MEM_RELEASE);
      end;
      __CloseFile(hFile, pFile);
    end;
  finally
    FreeAndNil(IdHTTP1);
    FreeAndNil(MS);
  end;
end;

end.
