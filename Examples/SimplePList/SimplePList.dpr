program SimplePList;

uses
  System.StartUpCopy,
  FMX.Forms,
  Forms.MainForm in '..\Forms.MainForm.pas' {Form3};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
