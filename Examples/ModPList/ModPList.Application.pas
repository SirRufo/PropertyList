unit ModPList.Application;

interface

uses
  Winapi.ActiveX,
  System.SysUtils,
  PropertyList;

type
  TApplication = class abstract
  private
    class function GetArgs: TArray<string>;
    class procedure HandleArray( const Value: IPListArray );
    class procedure HandleDict( const Value: IPListDict );
    class procedure HandleString( const Value: IPListString; const ModifyCallback: TProc<TPListValue> );
    class procedure HandleValue( const Value: TPListValue; const ModifyCallback: TProc<TPListValue> );

    class procedure FixTWebBrowserIssueForIOS9( const PList: IPList );
  protected
    class procedure Main( const Args: TArray<string> );
  public
    class procedure Init( );
    class procedure Run( );
  end;

implementation

uses
  System.IOUtils,
  System.StrUtils;

{ TApplication }

class procedure TApplication.FixTWebBrowserIssueForIOS9( const PList: IPList );
const
  NSAppTransportSecurity       = 'NSAppTransportSecurity';
  NSAllowsArbitraryLoads       = 'NSAllowsArbitraryLoads';
  NSAllowsArbitraryLoads_Value = True;
var
  LDict: IPListDict;
begin
  // Fixing the FMX TWebBrowser issue on iOS9
  LDict := PList.Root.Dict;
  if not LDict.ContainsKey( NSAppTransportSecurity )
  then
    LDict.Add( NSAppTransportSecurity, TPList.CreateDict );
  if not LDict[ NSAppTransportSecurity ].IsDict
  then
    raise EPListFileException.CreateFmt( 'Key "%s" is not a dictionary', [ NSAppTransportSecurity ] );
  LDict := LDict[ NSAppTransportSecurity ].Dict;
  LDict.AddOrSet( NSAllowsArbitraryLoads, True );
end;

class function TApplication.GetArgs: TArray<string>;
var
  LIdx: Integer;
begin
  SetLength( Result, ParamCount );
  for LIdx := low( Result ) to high( Result ) do
    begin
      Result[ LIdx ] := ParamStr( LIdx + 1 );
    end;
end;

class procedure TApplication.HandleArray( const Value: IPListArray );
var
  LIdx: Integer;
begin
  for LIdx := 0 to Value.Count - 1 do
    begin
      HandleValue( Value[ LIdx ],
        procedure( v: TPListValue )
        begin
          Value[ LIdx ] := v;
        end );
    end;
end;

class procedure TApplication.HandleDict( const Value: IPListDict );
var
  LItem: TPListKeyValuePair;
begin
  for LItem in Value do
    begin
      HandleValue( LItem.Value,
        procedure( v: TPListValue )
        begin
          Value.Items[ LItem.Key ] := v;
        end );
    end;
end;

class procedure TApplication.HandleString( const Value: IPListString; const ModifyCallback: TProc<TPListValue> );
begin
  if SameStr( Value.Value, 'YES' )
  then
    ModifyCallback( True )
  else if SameStr( Value.Value, 'NO' )
  then
    ModifyCallback( False );
end;

class procedure TApplication.HandleValue( const Value: TPListValue; const ModifyCallback: TProc<TPListValue> );
begin
  if Value.IsArray
  then
    HandleArray( Value.A )
  else if Value.IsDict
  then
    HandleDict( Value.Dict )
  else if Value.IsString
  then
    HandleString( Value.S, ModifyCallback );
end;

class procedure TApplication.Init;
begin
end;

class procedure TApplication.Main( const Args: TArray<string> );
var
  LPlatform  : string;
  LConfig    : string;
  LSourceFile: string;
  LSource    : IPList;
begin
  if not FindCmdLineSwitch( 'p=', LPlatform, True, [ clstValueAppended ] ) and not FindCmdLineSwitch( 'platform', LPlatform, True, [ clstValueNextParam ] )
  then
    raise EArgumentException.Create( 'Platform is missing' );

  if not FindCmdLineSwitch( 'c=', LConfig, True, [ clstValueAppended ] ) and not FindCmdLineSwitch( 'config', LConfig, True, [ clstValueNextParam ] )
  then
    raise EArgumentException.Create( 'Config is missing' );

  if not FindCmdLineSwitch( 'f=', LSourceFile, True, [ clstValueAppended ] ) and not FindCmdLineSwitch( 'file', LSourceFile, True, [ clstValueNextParam ] )
  then
    raise EArgumentException.Create( 'file is missing' );

  if not TFile.Exists( LSourceFile )
  then
    raise EFileNotFoundException.Create( LSourceFile );

  LSource := TPList.CreatePList( LSourceFile );
  if not LSource.Root.IsDict
  then
    raise EInvalidOpException.CreateFmt( 'Root item in "%s" is not a dictionary', [ LSourceFile ] );

  HandleDict( LSource.Root.Dict );

  if LPlatform.StartsWith( 'iOS', True )
  then
    FixTWebBrowserIssueForIOS9( LSource );

  LSource.SaveToFile( LSourceFile );
end;

class procedure TApplication.Run;
begin
  CoInitialize( nil );
  try
    Main( GetArgs( ) );
  finally
    CoUninitialize;
  end;
end;

end.
