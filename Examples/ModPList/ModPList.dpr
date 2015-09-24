program ModPList;

{$APPTYPE CONSOLE}
{$R *.res}

uses
  System.IOUtils,
  System.SysUtils,
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
    on E: EFileNotFoundException do
      begin
        Writeln( E.ClassName, ': ', E.Message );
        ExitCode := 2;
      end;
    on E: EArgumentException do
      begin
        Writeln( E.ClassName, ': ', E.Message );
        ExitCode := 3;
      end;
    on E: Exception do
      begin
        Writeln( E.ClassName, ': ', E.Message );
        ExitCode := 9999;
        TFile.WriteAllText( TPath.ChangeExtension( ParamStr( 0 ), '.log' ), E.ClassName + ': ' + E.Message, TEncoding.UTF8 );
      end;
  end;
{$IFDEF DEBUG}
  ReadLn;
{$ENDIF}

end.
