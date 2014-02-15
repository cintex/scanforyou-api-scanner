///////////        VERZIJA 1.0
///
///  Scan4You API scanner with context menu ///
///    bosko@globalnet.ba                  ///
///                                       ///
///  ///////////////////////////////////////

unit uSettings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BusinessSkinForm, bsSkinData, StdCtrls, Mask, bsSkinBoxCtrls,
  bsSkinCtrls;

type
  TFSettings = class(TForm)
    bscmprsdstrdskn1: TbsCompressedStoredSkin;
    bskndt1: TbsSkinData;
    bsbsnsknfrm1: TbsBusinessSkinForm;
    edtID: TbsSkinEdit;
    edtToken: TbsSkinEdit;
    bsknlbl1: TbsSkinLabel;
    bsknlbl2: TbsSkinLabel;
    chk1: TCheckBox;
    btnBuildSave: TbsSkinButton;
    procedure FormCreate(Sender: TObject);
    procedure btnBuildSaveClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FSettings: TFSettings;

implementation

uses uMain;

{$R *.dfm}


procedure TFSettings.btnBuildSaveClick(Sender: TObject);
begin
 FMain.ini.WriteString('main','id',edtID.Text);
 FMain.ProfilID:=edtID.Text;
 FMain.ini.WriteString('main','token',edtToken.Text);
 FMain.APIToken:=edtToken.Text;
 if chk1.checked then begin
  FMain.ini.WriteString('main','autocopy','yes');
  FMain.Autocp:=True;
 end else begin
  FMain.ini.WriteString('main','autocopy','no');
  FMain.Autocp:=False;
 end;
 Hide;
end;


procedure TFSettings.FormCreate(Sender: TObject);
begin
 Position:=poScreenCenter;
 edtID.Text:=FMain.ProfilID;
 edtToken.Text:=FMain.APIToken;
 if FMain.Autocp then chk1.checked:=true else chk1.checked:=false;
end;

end.
