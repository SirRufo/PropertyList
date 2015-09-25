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
    class procedure HandleInclude( const ADict: IPListDict; const APath: string; const APlatform: string = ''; const AConfig: string = '' );
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

class procedure TApplication.HandleInclude(
  const ADict    : IPListDict;
  const APath    : string;
  const APlatform: string;
  const AConfig  : string );
var
  LInclude     : IPList;
  LIncludeFile : string;
  LKeyValuePair: TPListKeyValuePair;
begin
  LIncludeFile := 'Include';

  if not APlatform.IsEmpty
  then
    LIncludeFile := string.Join( '.', [ LIncludeFile, APlatform ] );

  if not AConfig.IsEmpty
  then
    LIncludeFile := string.Join( '.', [ LIncludeFile, AConfig ] );

  LIncludeFile := string.Join( '.', [ LIncludeFile, 'Info', 'plist' ] );
  LIncludeFile := TPath.Combine( APath, LIncludeFile );

  if TFile.Exists( LIncludeFile )
  then
    begin
      LInclude := TPList.CreatePList( LIncludeFile );
      if not LInclude.Root.IsDict
      then
        raise Exception.Create( 'Fehlermeldung' );

      for LKeyValuePair in LInclude.Root.Dict do
        begin
          ADict.AddOrSet( LKeyValuePair.Key, LKeyValuePair.Value.Clone );
        end;
    end;
end;

class procedure TApplication.HandleString( const Value: IPListString; const ModifyCallback: TProc<TPListValue> );
begin
  if SameText( Value.Value, 'bool:true' )
  then
    ModifyCallback( True )
  else if SameText( Value.Value, 'bool:false' )
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
  LPlatform    : string;
  LConfig      : string;
  LSourceFile  : string;
  LSource      : IPList;
  LIncludePaths: string;
  LIncludePath : string;
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

  if not FindCmdLineSwitch( 'i=', LIncludePaths, True, [ clstValueAppended ] ) and not FindCmdLineSwitch( 'include', LIncludePaths, True,
    [ clstValueNextParam ] )
  then
    LIncludePaths := '';

  if not TFile.Exists( LSourceFile )
  then
    raise EFileNotFoundException.Create( LSourceFile );

  LSource := TPList.CreatePList( LSourceFile );
  if not LSource.Root.IsDict
  then
    raise EInvalidOpException.CreateFmt( 'Root item in "%s" is not a dictionary', [ LSourceFile ] );

  HandleDict( LSource.Root.Dict );

  if not LIncludePaths.IsEmpty
  then
    begin
      for LIncludePath in LIncludePaths.Split( [ ',' ], ExcludeEmpty ) do
        begin
          HandleInclude( LSource.Root.Dict, LIncludePath );                                 // include for all platforme
          HandleInclude( LSource.Root.Dict, LIncludePath, '', LConfig );                    // include for all platforme, config
          HandleInclude( LSource.Root.Dict, LIncludePath, LPlatform.Remove( 3 ) );          // include for general platform (first 3 chars)
          HandleInclude( LSource.Root.Dict, LIncludePath, LPlatform.Remove( 3 ), LConfig ); // include for general platform (first 3 chars), config
          HandleInclude( LSource.Root.Dict, LIncludePath, LPlatform );                      // include for platform
          HandleInclude( LSource.Root.Dict, LIncludePath, LPlatform, LConfig );             // include for platform, config
        end;
    end;

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
