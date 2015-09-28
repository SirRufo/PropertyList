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
    class procedure HandleIncludeFile( const ADict: IPListDict; const AIncludeFile: string );
  protected
    class procedure Main( const Args: TArray<string> );
  public
    class procedure Init( );
    class procedure Run( );
  end;

implementation

uses
  ModPList.Consts,
  System.IOUtils,
  System.StrUtils;

const
  SIncludeFilePrefix = 'Include';
  SIncludeFileName = 'Info';
  SIncludeFileType = 'plist';
  SBoolStringValueTrue = 'bool:true';
  SBoolStringValueFalse = 'bool:false';

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
  LIncludeFile : string;
begin
  LIncludeFile := SIncludeFilePrefix;

  if not APlatform.IsEmpty
  then
    LIncludeFile := string.Join( '.', [ LIncludeFile, APlatform ] );

  if not AConfig.IsEmpty
  then
    LIncludeFile := string.Join( '.', [ LIncludeFile, AConfig ] );

  LIncludeFile := string.Join( '.', [ LIncludeFile, SIncludeFileName, SIncludeFileType ] );
  LIncludeFile := TPath.Combine( APath, LIncludeFile );

  if TFile.Exists( LIncludeFile )
  then
    HandleIncludeFile( ADict, LIncludeFile );
end;

class procedure TApplication.HandleIncludeFile(
  const ADict       : IPListDict;
  const AIncludeFile: string );
var
  LInclude     : IPList;
  LKeyValuePair: TPListKeyValuePair;
begin
  if not TFile.Exists( AIncludeFile )
  then
    raise EFileNotFoundException.Create( AIncludeFile );

  LInclude := TPList.CreatePList( AIncludeFile );
  if not LInclude.Root.IsDict
  then
    raise EInvalidOpException.CreateResFmt( @SRootItemInFileIsNotADictionary, [ AIncludeFile ] );

  for LKeyValuePair in LInclude.Root.Dict do
    begin
      ADict.AddOrSet( LKeyValuePair.Key, LKeyValuePair.Value.Clone );
    end;
end;

class procedure TApplication.HandleString( const Value: IPListString; const ModifyCallback: TProc<TPListValue> );
begin
  if SameText( Value.Value, SBoolStringValueTrue )
  then
    ModifyCallback( True )
  else if SameText( Value.Value, SBoolStringValueFalse )
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
  LCheckTargetExists: Boolean;
  LPlatform         : string;
  LConfig           : string;
  LTargetFile       : string;
  LTarget           : IPList;
  LIncludePaths     : string;
  LIncludePath      : string;
begin
  if not FindCmdLineSwitch( 'f=', LTargetFile, True, [ clstValueAppended ] ) and not FindCmdLineSwitch( 'file', LTargetFile, True, [ clstValueNextParam ] )
  then
    raise EArgumentException.CreateRes( @SFileArgumentIsMissing );

  LCheckTargetExists := not FindCmdLineSwitch( 'ct', True ) and not FindCmdLineSwitch( 'checktarget', True );

  if not FindCmdLineSwitch( 'p=', LPlatform, True, [ clstValueAppended ] ) and not FindCmdLineSwitch( 'platform', LPlatform, True, [ clstValueNextParam ] )
  then
    LPlatform := '';

  if not FindCmdLineSwitch( 'c=', LConfig, True, [ clstValueAppended ] ) and not FindCmdLineSwitch( 'config', LConfig, True, [ clstValueNextParam ] )
  then
    LConfig := '';

  if not FindCmdLineSwitch( 'i=', LIncludePaths, True, [ clstValueAppended ] ) and not FindCmdLineSwitch( 'include', LIncludePaths, True,
    [ clstValueNextParam ] )
  then
    LIncludePaths := '';

  if not TFile.Exists( LTargetFile )
  then
    if LCheckTargetExists
    then
      raise EFileNotFoundException.Create( LTargetFile )
    else
      Exit;

  LTarget := TPList.CreatePList( );
  // see https://quality.embarcadero.com/browse/RSP-12407
  // Duplicate key CFBundleResourceSpecification in *.info.plist
  LTarget.FileOptions := LTarget.FileOptions + [ TPListFileOption.IgnoreDictDuplicates ];
  LTarget.LoadFromFile( LTargetFile );

  if not LTarget.Root.IsDict
  then
    raise EInvalidOpException.CreateResFmt( @SRootItemInFileIsNotADictionary, [ LTargetFile ] );

  HandleDict( LTarget.Root.Dict );

  if not LIncludePaths.IsEmpty
  then
    begin
      for LIncludePath in LIncludePaths.Split( [ ',' ], '"', '"', TStringSplitOptions.ExcludeEmpty ) do
        begin
          if TDirectory.Exists( LIncludePath )
          then
            begin
              HandleInclude( LTarget.Root.Dict, LIncludePath ); // include for all platforms
              if not LConfig.IsEmpty
              then
                HandleInclude( LTarget.Root.Dict, LIncludePath, '', LConfig ); // include for all platforms, config
              if not LPlatform.IsEmpty
              then
                begin
                  HandleInclude( LTarget.Root.Dict, LIncludePath, LPlatform.Remove( 3 ) ); // include for general platform (first 3 chars)
                  if not LConfig.IsEmpty
                  then
                    HandleInclude( LTarget.Root.Dict, LIncludePath, LPlatform.Remove( 3 ), LConfig ); // include for general platform (first 3 chars), config
                  HandleInclude( LTarget.Root.Dict, LIncludePath, LPlatform );                        // include for platform
                  if not LConfig.IsEmpty
                  then
                    HandleInclude( LTarget.Root.Dict, LIncludePath, LPlatform, LConfig ); // include for platform, config
                end;
            end
          else if TFile.Exists( LIncludePath )
          then
            begin
              HandleIncludeFile( LTarget.Root.Dict, LIncludePath );
            end;
        end;
    end;

  LTarget.SaveToFile( LTargetFile );
end;

class procedure TApplication.Run;
begin
  Main( GetArgs( ) );
end;

end.
