///////////        VERZIJA 1.0
///
///  Scan4You API scanner with context menu ///
///    bosko@globalnet.ba                  ///
///                                       ///
///  ///////////////////////////////////////


program scanner;

uses
  Forms,
  uMain in 'uMain.pas' {FMain},
  uFunctions in 'uFunctions.pas',
  uSettings in 'uSettings.pas' {FSettings},
  uAbout in 'uAbout.pas' {FAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'AVscanner';
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFSettings, FSettings);
  Application.CreateForm(TFAbout, FAbout);
  Application.Run;
end.
