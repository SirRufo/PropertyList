program ModPList;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.IOUtils,
  System.SysUtils,
  PropertyList,
  ModPList.Application in 'ModPList.Application.pas',
  ModPList.Consts in 'ModPList.Consts.pas';

begin
  try
    TApplication.Init( );
    TApplication.Run( );
  except
    on E: Exception do
      begin
        Writeln( E.ClassName, ': ', E.Message );
        ExitCode := 1;
      end;
  end;
{$IFDEF DEBUG}
  ReadLn;
{$ENDIF}

end.
