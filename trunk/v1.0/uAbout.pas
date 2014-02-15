///////////        VERZIJA 1.0
///
///  Scan4You API scanner with context menu ///
///    bosko@globalnet.ba                  ///
///                                       ///
///  ///////////////////////////////////////

unit uAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BusinessSkinForm, bsSkinData, StdCtrls, bsSkinBoxCtrls;

type
  TFAbout = class(TForm)
    bscmprsdstrdskn1: TbsCompressedStoredSkin;
    bskndt1: TbsSkinData;
    bsbsnsknfrm1: TbsBusinessSkinForm;
    mmo1: TbsSkinMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FAbout: TFAbout;

implementation

{$R *.dfm}

procedure TFAbout.FormCreate(Sender: TObject);
begin
 mmo1.lines.add('F R E E W A R E');
 mmo1.lines.add('----------------');
 mmo1.lines.add('copyright (c) 2014, BSKO');
 mmo1.lines.add('   bosko@globalnet.ba   ');
end;

end.
