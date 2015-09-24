program ModPList;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.IOUtils,
  System.SysUtils,
  PropertyList,
  ModPList.Application in 'ModPList.Application.pas';

begin
  try
    TApplication.Init( );
    TApplication.Run( );
  except
    on E: EInvalidOpException do
      begin
        Writeln( E.ClassName, ': ', E.Message );
        ExitCode := 1;
      end;
    on E: EPListFileException do
      begin
        Writeln( E.ClassName, ': ', E.Message );
        ExitCode := 2;
      end;
    on E: EFileNotFoundException do
      begin
        Writeln( E.ClassName, ': ', E.Message );
        ExitCode := 3;
      end;
    on E: EArgumentException do
      begin
        Writeln( E.ClassName, ': ', E.Message );
        ExitCode := 4;
      end;
    on E: Exception do
      begin
        Writeln( E.ClassName, ': ', E.Message );
        ExitCode := 9999;
      end;
  end;
{$IFDEF DEBUG}
  ReadLn;
{$ENDIF}

end.
