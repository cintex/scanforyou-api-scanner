 ///////////  VERZIJA 1.0
///
///  Scan4You API scanner with context menu ///
///    bosko@globalnet.ba                  ///
///                                       ///
///  ///////////////////////////////////////
///
///  parts of code in uFunctions.pas taken from:
///  yOpenFiles.pas and tokens.pas
///  created by: Psychlo @ HackHound
///

unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants,  Graphics, Controls, Forms,
  Dialogs, bsSkinData, BusinessSkinForm, ComCtrls, StdCtrls, bsSkinCtrls,
  IniFiles, Clipbrd, Classes, MMsystem;

type
  TFMain = class(TForm)
    bskndt1: TbsSkinData;
    bscmprsdstrdskn1: TbsCompressedStoredSkin;
    edtURL: TEdit;
    lv1: TListView;
    btnLoad: TbsSkinButton;
    btnScan: TbsSkinButton;
    btnOptions: TbsSkinButton;
    bsbsnsknfrm1: TbsBusinessSkinForm;
    btnBuildAbout: TbsSkinButton;
    procedure FormCreate(Sender: TObject);
    procedure lv1CustomDrawItem(Sender: TCustomListView; Item: TListItem;
                                State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure btnOptionsClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnScanClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnBuildAboutClick(Sender: TObject);
  private
    itm: TListItem;
  public
    ini: TIniFile;
    APIToken: string;
    ProfilID: string;
    Autocp: Boolean;
    sFile: string;
    procedure addok(AV: string);
    procedure addfl(AV,Detection: string);
  end;
  TTscan = class(TThread)
  public
   procedure Execute; override;
  end;
  
var
  FMain: TFMain;

implementation

uses uSettings, uFunctions, uAbout;

{$R *.dfm}

procedure TTscan.execute;
var
 rURL     : string;
 oresult   : string;
 vDetected : integer;
 i         : integer;
begin
 FMain.lv1.items.clear;
 FMain.edtURL.Text:='Please wait until results are received...';
 FMain.caption:=extractfilename(FMain.sFile)+': ';
 if (PostFile('http://scan4you.net/remote.php', FMain.sFile, oResult)) then
 begin
  vDetected := 0;
  oResult := StringReplace(oResult, '{"', '', [rfReplaceAll]);
  oResult := StringReplace(oResult, '"}', '', [rfReplaceAll]);
  oResult := StringReplace(oResult, '\/', '/', [rfReplaceAll]);
  for i := 1 to Numtok(oResult, '","')-1 do
  begin
   if (Gettok(Gettok(oResult, i, '","'), 2, '":"') <> 'OK') then
   begin
    FMain.Addfl(Gettok(Gettok(oResult, i, '","'), 1, '":"'), Gettok(Gettok(oResult, i, '","'), 2, '":"'));
    vDetected := vDetected + 1;
   end else FMain.Addok(Gettok(Gettok(oResult, i, '","'), 1, '":"'));
  end;
  sndPlaySound('C:\Windows\Media\Tada.wav', SND_NODEFAULT Or SND_ASYNC);
  FMain.Caption:=extractfilename(FMain.sFile)+': '+ IntToStr(vDetected) + ' / ' + IntToStr(Numtok(oResult, '","')-1);
  rURL:=Gettok(Gettok(oResult, Numtok(oResult, '","'), '","'), 2, '":"');
  rURL:=StringReplace(rURL, 'URL=','',[rfReplaceAll]);
  FMain.edtURL.enabled:=True;
  FMain.edtURL.Text:=rURL;
  if FMain.Autocp then Clipboard.AsText:=rURL;
 end else
 begin
  sndPlaySound('C:\Windows\Media\Tada.wav', SND_NODEFAULT Or SND_ASYNC);
  FMain.edtURL.Text:='scanning failed';
  FMain.Caption:=extractfilename(FMain.sFile)+': 0/0';
 end;
end;

procedure TFMain.addok(AV: string);
begin
 itm:=lv1.Items.Add;
 itm.Caption:=AV;
 itm.SubItems.Add('CLEAN');
end;

procedure TFMain.AddFL(AV,Detection: string);
begin
 itm:=lv1.Items.Add;
 itm.Caption:=AV;
 itm.SubItems.Add(Detection);
end;

procedure TFMain.btnBuildAboutClick(Sender: TObject);
begin
 FAbout.Show;
end;

procedure TFMain.btnLoadClick(Sender: TObject);
var
 od1: TOpenDialog;
begin
 edtURL.Enabled:=False;
 od1:=TOpenDialog.Create(Self);
 od1.InitialDir:=ExtractFilePath(ParamStr(0));
 od1.Options := [ofFileMustExist];
 od1.Filter := 'All files|*.*';
 if od1.Execute then begin
  sFile:=od1.FileName;
  edtURL.Text:='selected: '+extractfilename(sfile);
 end else begin
  sFile:='none';
 end;
 od1.Free;
end;

procedure TFMain.btnOptionsClick(Sender: TObject);
begin
 FSettings.Show;
end;

procedure TFMain.btnScanClick(Sender: TObject);
begin
 if not FileExists(sFile) then begin
  edtURL.Text:='ERR: No file selected';
  Exit;
 end;
 edtURL.Enabled:=False;
 edtURL.Text:='Preparing...';
 TTscan.Create(false);
end;

procedure TFMain.FormCreate(Sender: TObject);
begin
 Position:=poScreenCenter;
 ini := TIniFile.Create(extractfilepath(paramstr(0))+'settings.ini');
 ProfilID:=ini.ReadString('main','id','ProfileID');
 APIToken:=ini.ReadString('main','token','ApiToken');
 if ini.ReadString('main','autocopy','yes') = 'yes' then Autocp:=true else Autocp:=False;
end;

procedure TFMain.FormShow(Sender: TObject);
begin
 if not FileExists(extractfilepath(paramstr(0))+'settings.ini') then
 begin
  MessageBox(0,'Settings not found! (this is normal if this is a first run)'+#13#10
              +'Please update your configuration.','API Scanner',0);
  FSettings.Show;
  Exit;
 end;
 if ParamCount > 0 then
 begin
  if FileExists(paramstr(1)) then
  begin
   sFile:=ParamStr(1);
   edtURL.Text:='selected: '+ExtractFileName(sfile);
   TTscan.Create(false);
  end;
 end;
end;

procedure TFMain.lv1CustomDrawItem(Sender: TCustomListView; Item: TListItem;
  State: TCustomDrawState; var DefaultDraw: Boolean);
begin
 if item.SubItems.Count > 0 then begin
  if item.SubItems[0] <> 'CLEAN' then begin
   Sender.Canvas.Brush.Color := clRed;
   Sender.Canvas.Font.Color := clBlack;
  end else begin
   Sender.Canvas.Brush.Color := clGreen;
   Sender.Canvas.Font.Color := clWhite;
  end;
 end;
end;
end.
