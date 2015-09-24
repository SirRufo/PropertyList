(*****************************************************************************
 Copyright 2015 Oliver Münzberg (aka Sir Rufo)

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 *****************************************************************************)
unit PropertyList;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils;

type
  CFBool = Boolean;
  CFData = TArray<Byte>;

  CFDate = record
  private
    FValue: TDateTime;
  public
    class operator Explicit( const A: TDateTime ): CFDate;
    class operator Implicit( const A: TDateTime ): CFDate;
    class operator Implicit( const A: CFDate ): TDateTime;
  end;

  CFInteger = Integer;
  CFReal    = Extended;
  CFString  = string;

type
  EPListException     = class( Exception );
  EPListFileException = class( EPListException );

type
  IPListValue   = interface;
  IPListArray   = interface;
  IPListBool    = interface;
  IPListData    = interface;
  IPListDate    = interface;
  IPListDict    = interface;
  IPListInteger = interface;
  IPListReal    = interface;
  IPListString  = interface;
  IPList        = interface;

  TPListValue = record
  private
    FValue: IPListValue;
    procedure CastValue( IID: TGUID; out Value );
    function CanCastValue( IID: TGUID ): Boolean;
  public
    class operator Implicit( const A: CFBool ): TPListValue;
    class operator Implicit( const A: CFData ): TPListValue;
    class operator Implicit( const A: CFInteger ): TPListValue;
    class operator Implicit( const A: CFReal ): TPListValue;
    class operator Implicit( const A: CFString ): TPListValue;
    class operator Implicit( const A: CFDate ): TPListValue;
    class operator Implicit( const A: TArray<TPListValue> ): TPListValue;

    class operator Implicit( const A: IPListValue ): TPListValue;
    class operator Implicit( const A: TPListValue ): IPListValue;
    class operator Equal( const L, R: TPListValue ): Boolean;
    class operator NotEqual( const L, R: TPListValue ): Boolean;

    function A: IPListArray;
    function B: IPListBool;
    function Data: IPListData;
    function Date: IPListDate;
    function Dict: IPListDict;
    function I: IPListInteger;
    function R: IPListReal;
    function S: IPListString;

    function IsEmpty: Boolean;
    function IsArray: Boolean;
    function IsBool: Boolean;
    function IsData: Boolean;
    function IsDate: Boolean;
    function IsDict: Boolean;
    function IsInteger: Boolean;
    function IsReal: Boolean;
    function IsString: Boolean;

    function Clone: TPListValue;
    function ToString: string;
  end;

  IPListValue = interface
    [ '{D28C4CE6-6129-4F6C-B3F8-F9A2B31EACCE}' ]
    function Clone: IPListValue;
    function ToString( ): string;
  end;

  IPListValueEnumerator = interface
    [ '{E9D8CEE0-4D0F-4BE7-BA07-1B49A48964A8}' ]
    function GetCurrent: TPListValue;
    property Current: TPListValue read GetCurrent;
    function MoveNext: Boolean;
  end;

  IPListArray = interface( IPListValue )
    [ '{8EB6EEC0-B500-4670-8CCF-0B239AE98041}' ]
    function GetEnumerator: IPListValueEnumerator;
    function GetCount: Integer;
    property Count: Integer read GetCount;
    function GetItem( const Idx: Integer ): TPListValue;
    procedure SetItem( const Idx: Integer; const Value: TPListValue );
    property Items[ const Idx: Integer ]: TPListValue read GetItem write SetItem; default;

    function Add( const Value: TPListValue ): Integer;
    procedure Delete( const Idx: Integer );
    procedure Clear;
  end;

  IPListBool = interface( IPListValue )
    [ '{094D7DBF-EC22-46E3-A934-2E5E068593D1}' ]
    function GetValue: CFBool;
    procedure SetValue( const Value: CFBool );
    property Value: CFBool read GetValue write SetValue;
  end;

  IPListData = interface( IPListValue )
    [ '{82D7E58A-FED3-4EB4-9BBB-BFFC95B1CE6B}' ]
    function GetValue: CFData;
    procedure SetValue( const Value: CFData );
    property Value: CFData read GetValue write SetValue;
  end;

  IPListDate = interface( IPListValue )
    [ '{53477DFC-D577-4284-869A-CA1B167F5D23}' ]
    function GetValue: CFDate;
    procedure SetValue( const Value: CFDate );
    property Value: CFDate read GetValue write SetValue;
  end;

  TPListKeyValuePair = TPair<string, TPListValue>;

  IPListKeyValueEnumerator = interface
    [ '{448CB2B6-4390-41A9-AC7A-F64FE20C8D70}' ]
    function GetCurrent: TPListKeyValuePair;
    property Current: TPListKeyValuePair read GetCurrent;
    function MoveNext: Boolean;
  end;

  IPListDict = interface( IPListValue )
    [ '{550AA2FC-7161-483D-8B6B-4D5601097E7B}' ]
    function GetEnumerator: IPListKeyValueEnumerator;
    function GetCount: Integer;
    property Count: Integer read GetCount;
    function GetItem( const Key: string ): TPListValue;
    procedure SetItem( const Key: string; const Value: TPListValue );
    property Items[ const Key: string ]: TPListValue read GetItem write SetItem; default;

    function Add( const Key: string; const Value: TPListValue ): IPListDict;
    function AddOrSet( const Key: string; const Value: TPListValue ): IPListDict;
    function ContainsKey( const Key: string ): Boolean;
    function Delete( const Key: string ): IPListDict;
    function Clear: IPListDict;
  end;

  IPListInteger = interface( IPListValue )
    [ '{5A6B91B0-0715-47FA-B1AE-6FF4E035D511}' ]
    function GetValue: CFInteger;
    procedure SetValue( const Value: CFInteger );
    property Value: CFInteger read GetValue write SetValue;
  end;

  IPListReal = interface( IPListValue )
    [ '{51FE6EF9-87B3-40D4-ADA0-136B49B76ADF}' ]
    function GetValue: CFReal;
    procedure SetValue( const Value: CFReal );
    property Value: CFReal read GetValue write SetValue;
  end;

  IPListString = interface( IPListValue )
    [ '{724CC20A-D909-459B-8B0F-154883E1F6B7}' ]
    function GetValue: CFString;
    procedure SetValue( const Value: CFString );
    property Value: CFString read GetValue write SetValue;
  end;

  TPListFileType = ( XML, Binary );

  IPList = interface
    [ '{22FCC553-33CF-42E2-9CD7-921E298C545A}' ]
    function GetFileType: TPListFileType;
    procedure SetFileType( const Value: TPListFileType );
    property FileType: TPListFileType read GetFileType write SetFileType;

    function GetRoot: TPListValue;
    procedure SetRoot( const Value: TPListValue );
    property Root: TPListValue read GetRoot write SetRoot;

    procedure LoadFromFile( const Filename: string );
    procedure SaveToFile( const Filename: string ); overload;
    procedure SaveToFile( const Filename: string; FileType: TPListFileType ); overload;

    procedure LoadFromStream( Stream: TStream );
    procedure SaveToStream( Stream: TStream ); overload;
    procedure SaveToStream( Stream: TStream; FileType: TPListFileType ); overload;
  end;

  TPList = class( TInterfacedObject, IPList, IStreamPersist )
  private
    FRoot: IPListValue;
    FType: TPListFileType;
    function GetFileType: TPListFileType;
    procedure SetFileType( const Value: TPListFileType );
    function GetRoot: TPListValue;
    procedure SetRoot( const Value: TPListValue );
    procedure LoadFromFile( const Filename: string );
    procedure SaveToFile( const Filename: string ); overload;
    procedure SaveToFile( const Filename: string; FileType: TPListFileType ); overload;
    procedure SaveToStream( Stream: TStream; FileType: TPListFileType ); overload;
  private { IStreamPersist }
    procedure LoadFromStream( Stream: TStream );
    procedure SaveToStream( Stream: TStream ); overload;
  private
    constructor Create;
  public
    class function CreateArray: IPListArray; overload;
    class function CreateArray( const Values: array of TPListValue ): IPListArray; overload;
    class function CreateBool( const Value: CFBool ): IPListBool;
    class function CreateDate( const Value: CFDate ): IPListDate;
    class function CreateData( const Value: CFData ): IPListData; overload;
    class function CreateData( const Value: array of Byte ): IPListData; overload;
    class function CreateData( const Stream: TStream ): IPListData; overload;
    class function CreateDict: IPListDict;
    class function CreateInteger( const Value: CFInteger ): IPListInteger;
    class function CreateReal( const Value: CFReal ): IPListReal;
    class function CreateString( const Value: CFString ): IPListString;
    class function CreatePList( ): IPList; overload;
    class function CreatePList( const Filename: string ): IPList; overload;
  end;

implementation

uses
  System.TypInfo,
  PropertyList.XML;

type
  TPListValueBase = class abstract( TInterfacedObject, IPListValue )
  protected
    function Clone: IPListValue; virtual; abstract;
  end;

  TPListValueBase<T> = class abstract( TPListValueBase )
  private
    FValue: T;
  protected
    function GetValue: T;
    procedure SetValue( const Value: T );
  public
    constructor Create( const Value: T );
  end;

  TPListBool = class( TPListValueBase<CFBool>, IPListBool )
  protected
    function Clone: IPListValue; override;
    function ToString: string; override;
  end;

  TPListData = class( TPListValueBase<CFData>, IPListData )
  protected
    function Clone: IPListValue; override;
    function ToString: string; override;
  end;

  TPListDate = class( TPListValueBase<CFDate>, IPListDate )
  protected
    function Clone: IPListValue; override;
    function ToString: string; override;
  end;

  TPListInteger = class( TPListValueBase<CFInteger>, IPListInteger )
  protected
    function Clone: IPListValue; override;
    function ToString: string; override;
  end;

  TPListReal = class( TPListValueBase<CFReal>, IPListReal )
  protected
    function Clone: IPListValue; override;
    function ToString: string; override;
  end;

  TPListString = class( TPListValueBase<CFString>, IPListString )
  protected
    function Clone: IPListValue; override;
    function ToString: string; override;
  end;

  TPListArray = class( TPListValueBase, IPListArray )
  private
    FItems: TList<IPListValue>;
  private
    function Add( const Value: TPListValue ): Integer;
    procedure Clear;
    procedure Delete( const Idx: Integer );
    function GetCount: Integer;
    function GetEnumerator: IPListValueEnumerator;
    function GetItem( const Idx: Integer ): TPListValue;
    procedure SetItem( const Idx: Integer; const Value: TPListValue );
  protected
    function Clone: IPListValue; override;
  public
    constructor Create( );
    destructor Destroy; override;
    function ToString: string; override;
  end;

  TPListArrayEnumerator = class( TInterfacedObject, IPListValueEnumerator )
  private
    FSource: IPListArray;
    FIndex : Integer;
  private
    function GetCurrent: TPListValue;
    function MoveNext: Boolean;
  public
    constructor Create( const Source: IPListArray );
  end;

  TPListDict = class( TPListValueBase, IPListDict )
  private
    FItems: TDictionary<string, IPListValue>;
  protected
    function Add( const Key: string; const Value: TPListValue ): IPListDict;
    function AddOrSet( const Key: string; const Value: TPListValue ): IPListDict;
    function Clear: IPListDict;
    function ContainsKey( const Key: string ): Boolean;
    function Delete( const Key: string ): IPListDict;
    function GetCount: Integer;
    function GetEnumerator: IPListKeyValueEnumerator;
    function GetItem( const Key: string ): TPListValue;
    procedure SetItem( const Key: string; const Value: TPListValue );
    function Clone: IPListValue; override;
  public
    constructor Create;
    destructor Destroy; override;

    function ToString: string; override;
  end;

  TPListDictEnumerator = class( TInterfacedObject, IPListKeyValueEnumerator )
  private type
    TKeyValue = TPair<string, IPListValue>;
  private
    FSource    : IPListDict;
    FEnumerator: TEnumerator<TKeyValue>;
  private
    function GetCurrent: TPListKeyValuePair;
    function MoveNext: Boolean;
  public
    constructor Create( const Source: IPListDict; Enumerator: TEnumerator<TKeyValue> );
  end;

  { TPList }

constructor TPList.Create;
begin
  inherited;
end;

class function TPList.CreateArray: IPListArray;
begin
  Result := TPListArray.Create;
end;

class function TPList.CreateArray( const Values: array of TPListValue ): IPListArray;
var
  LIdx: Integer;
begin
  Result := TPListArray.Create;

  for LIdx := low( Values ) to high( Values ) do
    begin
      Result.Add( Values[ LIdx ] );
    end;
end;

class function TPList.CreateBool( const Value: CFBool ): IPListBool;
begin
  Result := TPListBool.Create( Value );
end;

class function TPList.CreateData( const Stream: TStream ): IPListData;
var
  LSize: Int64;
  LData: CFData;
begin
  LSize := Stream.Size;
  SetLength( LData, LSize );
  Stream.Position := 0;
  Stream.Read( LData, LSize );
  Result := CreateData( LData );
end;

class function TPList.CreateData( const Value: CFData ): IPListData;
begin
  Result := TPListData.Create( Value );
end;

class function TPList.CreateData( const Value: array of Byte ): IPListData;
var
  LValue: CFData;
  LIdx  : Integer;
begin
  SetLength( LValue, Length( Value ) );
  for LIdx := low( Value ) to high( Value ) do
    begin
      LValue[ LIdx ] := Value[ LIdx ];
    end;
  Result := CreateData( LValue );
end;

class function TPList.CreateDate( const Value: CFDate ): IPListDate;
begin
  Result := TPListDate.Create( Value );
end;

class function TPList.CreateDict: IPListDict;
begin
  Result := TPListDict.Create;
end;

class function TPList.CreateInteger( const Value: CFInteger ): IPListInteger;
begin
  Result := TPListInteger.Create( Value );
end;

class function TPList.CreatePList: IPList;
begin
  Result := TPList.Create( );
end;

class function TPList.CreatePList( const Filename: string ): IPList;
begin
  Result := TPList.Create( );
  Result.LoadFromFile( Filename );
end;

class function TPList.CreateReal( const Value: CFReal ): IPListReal;
begin
  Result := TPListReal.Create( Value );
end;

class function TPList.CreateString( const Value: CFString ): IPListString;
begin
  Result := TPListString.Create( Value );
end;

function TPList.GetFileType: TPListFileType;
begin
  Result := FType;
end;

function TPList.GetRoot: TPListValue;
begin
  Result := FRoot;
end;

procedure TPList.LoadFromFile( const Filename: string );
var
  LStream: TStream;
begin
  LStream := TFileStream.Create( Filename, fmOpenRead or fmShareDenyWrite );
  try
    LoadFromStream( LStream );
  finally
    LStream.Free;
  end;
end;

procedure TPList.LoadFromStream( Stream: TStream );
var
  LPlistReader: TPListXmlReader;
begin
  LPlistReader := TPListXmlReader.Create;
  try
    LPlistReader.Read( Self, Stream );
  finally
    LPlistReader.Free;
  end;
end;

procedure TPList.SaveToFile( const Filename: string; FileType: TPListFileType );
var
  LStream: TStream;
begin
  LStream := TFileStream.Create( Filename, fmCreate or fmShareDenyWrite );
  try
    SaveToStream( LStream, FileType );
  finally
    LStream.Free;
  end;
end;

procedure TPList.SaveToStream( Stream: TStream; FileType: TPListFileType );
var
  LPlistWriter: TPListXmlWriter;
begin
  LPlistWriter := nil;
  try
    case FileType of
      XML:
        LPlistWriter := TPListXmlWriter.Create;
    else
      raise ENotImplemented.Create( 'Filetype' );
    end;
    LPlistWriter.Write( Self, Stream );
  finally
    LPlistWriter.Free;
  end;
end;

procedure TPList.SaveToStream( Stream: TStream );
begin
  SaveToStream( Stream, GetFileType );
end;

procedure TPList.SaveToFile( const Filename: string );
begin
  SaveToFile( Filename, GetFileType );
end;

procedure TPList.SetFileType( const Value: TPListFileType );
begin
  FType := Value;
end;

procedure TPList.SetRoot( const Value: TPListValue );
begin
  if FRoot <> Value
  then
    begin
      FRoot := Value;
    end;
end;

{ TPListValueBase<T> }

constructor TPListValueBase<T>.Create( const Value: T );
begin
  inherited Create;
  FValue := Value;
end;

function TPListValueBase<T>.GetValue: T;
begin
  Result := FValue;
end;

procedure TPListValueBase<T>.SetValue( const Value: T );
begin
  FValue := Value;
end;

{ TPListBool }

function TPListBool.Clone: IPListValue;
begin
  Result := TPListBool.Create( GetValue );
end;

function TPListBool.ToString: string;
begin
  Result := BoolToStr( FValue, True );
end;

{ TPListData }

function TPListData.Clone: IPListValue;
begin
  Result := TPListData.Create( GetValue );
end;

function TPListData.ToString: string;
var
  LValues: TArray<string>;
  LIdx   : Integer;
begin
  SetLength( LValues, Length( FValue ) );
  for LIdx := low( FValue ) to high( FValue ) do
    begin
      LValues[ LIdx ] := '$' + IntToHex( FValue[ LIdx ], 2 );
    end;
  Result := '[' + string.Join( FormatSettings.ListSeparator, LValues ) + ']';
end;

{ TPListDate }

function TPListDate.Clone: IPListValue;
begin
  Result := TPListDate.Create( GetValue );
end;

function TPListDate.ToString: string;
begin
  Result := DateTimeToStr( FValue );
end;

{ TPListInteger }

function TPListInteger.Clone: IPListValue;
begin
  Result := TPListInteger.Create( GetValue );
end;

function TPListInteger.ToString: string;
begin
  Result := IntToStr( FValue );
end;

{ TPListReal }

function TPListReal.Clone: IPListValue;
begin
  Result := TPListReal.Create( GetValue );
end;

function TPListReal.ToString: string;
begin
  Result := FloatToStr( FValue );
end;

{ TPListString }

function TPListString.Clone: IPListValue;
begin
  Result := TPListString.Create( GetValue );
end;

function TPListString.ToString: string;
begin
  Result := FValue.QuotedString;
end;

{ TPListArray }

function TPListArray.Add( const Value: TPListValue ): Integer;
begin
  Result := FItems.Add( Value );
end;

procedure TPListArray.Clear;
begin
  FItems.Clear;
end;

function TPListArray.Clone: IPListValue;
var
  LClone: TPListArray;
  LIdx  : Integer;
begin
  LClone   := TPListArray.Create;
  for LIdx := 0 to FItems.Count - 1 do
    begin
      LClone.FItems.Add( GetItem( LIdx ).Clone );
    end;
  Result := LClone;
end;

constructor TPListArray.Create;
begin
  inherited Create;
  FItems := TList<IPListValue>.Create;
end;

procedure TPListArray.Delete( const Idx: Integer );
begin
  FItems.Delete( Idx );
end;

destructor TPListArray.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TPListArray.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TPListArray.GetEnumerator: IPListValueEnumerator;
begin
  Result := TPListArrayEnumerator.Create( Self );
end;

function TPListArray.GetItem( const Idx: Integer ): TPListValue;
begin
  Result := FItems[ Idx ];
end;

procedure TPListArray.SetItem( const Idx: Integer; const Value: TPListValue );
begin
  if FItems[ Idx ] <> Value
  then
    begin
      FItems[ Idx ] := Value
    end;
end;

function TPListArray.ToString: string;
var
  LValues: TArray<string>;
  LIdx   : Integer;
begin
  SetLength( LValues, FItems.Count );
  for LIdx := 0 to Self.GetCount - 1 do
    begin
      LValues[ LIdx ] := GetItem( LIdx ).ToString;
    end;
  Result := '[' + string.Join( FormatSettings.ListSeparator, LValues ) + ']';
end;

{ TPListValue }

function TPListValue.A: IPListArray;
begin
  CastValue( IPListArray, Result );
end;

function TPListValue.B: IPListBool;
begin
  CastValue( IPListBool, Result );
end;

function TPListValue.CanCastValue( IID: TGUID ): Boolean;
begin
  Result := Assigned( FValue ) and Supports( FValue, IID );
end;

procedure TPListValue.CastValue( IID: TGUID; out Value );
begin
  if not Assigned( FValue )
  then
    raise EInvalidOpException.Create( 'No value assigned' );

  if not Supports( FValue, IID, Value )
  then
    raise EInvalidCast.CreateFmt( 'Cannot cast to interface %s', [ IID.ToString ] );
end;

function TPListValue.Clone: TPListValue;
begin
  if Assigned( FValue )
  then
    Result := FValue.Clone
  else
    Result := nil;
end;

function TPListValue.Data: IPListData;
begin
  CastValue( IPListData, Result );
end;

function TPListValue.Date: IPListDate;
begin
  CastValue( IPListDate, Result );
end;

function TPListValue.Dict: IPListDict;
begin
  CastValue( IPListDict, Result );
end;

class operator TPListValue.Equal( const L, R: TPListValue ): Boolean;
begin
  Result := L.FValue = R.FValue;
end;

function TPListValue.I: IPListInteger;
begin
  CastValue( IPListInteger, Result );
end;

class operator TPListValue.Implicit( const A: TPListValue ): IPListValue;
begin
  Result := A.FValue;
end;

class operator TPListValue.Implicit( const A: TArray<TPListValue> ): TPListValue;
begin
  Result.FValue := TPList.CreateArray( A );
end;

class operator TPListValue.Implicit( const A: CFReal ): TPListValue;
begin
  Result.FValue := TPList.CreateReal( A );
end;

class operator TPListValue.Implicit( const A: CFData ): TPListValue;
begin
  Result.FValue := TPList.CreateData( A );
end;

class operator TPListValue.Implicit( const A: CFBool ): TPListValue;
begin
  Result.FValue := TPList.CreateBool( A );
end;

class operator TPListValue.Implicit( const A: CFDate ): TPListValue;
begin
  Result.FValue := TPList.CreateDate( A );
end;

class operator TPListValue.Implicit( const A: CFString ): TPListValue;
begin
  Result.FValue := TPList.CreateString( A );
end;

class operator TPListValue.Implicit( const A: CFInteger ): TPListValue;
begin
  Result.FValue := TPList.CreateInteger( A );
end;

class operator TPListValue.Implicit( const A: IPListValue ): TPListValue;
begin
  Result.FValue := A;
end;

function TPListValue.IsArray: Boolean;
begin
  Result := CanCastValue( IPListArray );
end;

function TPListValue.IsBool: Boolean;
begin
  Result := CanCastValue( IPListBool );
end;

function TPListValue.IsData: Boolean;
begin
  Result := CanCastValue( IPListData );
end;

function TPListValue.IsDate: Boolean;
begin
  Result := CanCastValue( IPListDate );
end;

function TPListValue.IsDict: Boolean;
begin
  Result := CanCastValue( IPListDict );
end;

function TPListValue.IsEmpty: Boolean;
begin
  Result := not Assigned( FValue );
end;

function TPListValue.IsInteger: Boolean;
begin
  Result := CanCastValue( IPListInteger );
end;

function TPListValue.IsReal: Boolean;
begin
  Result := CanCastValue( IPListReal );
end;

function TPListValue.IsString: Boolean;
begin
  Result := CanCastValue( IPListString );
end;

class operator TPListValue.NotEqual( const L, R: TPListValue ): Boolean;
begin
  Result := L.FValue <> R.FValue;
end;

function TPListValue.R: IPListReal;
begin
  CastValue( IPListReal, Result );
end;

function TPListValue.S: IPListString;
begin
  CastValue( IPListString, Result );
end;

function TPListValue.ToString: string;
begin
  if Assigned( FValue )
  then
    Result := FValue.ToString
  else
    Result := 'nil';
end;

{ CFDate }

class operator CFDate.Explicit( const A: TDateTime ): CFDate;
begin
  Result.FValue := A;
end;

class operator CFDate.Implicit( const A: CFDate ): TDateTime;
begin
  Result := A.FValue;
end;

class operator CFDate.Implicit( const A: TDateTime ): CFDate;
begin
  Result.FValue := A;
end;

{ TPListArrayEnumerator }

constructor TPListArrayEnumerator.Create( const Source: IPListArray );
begin
  inherited Create;
  FSource := Source;
  FIndex  := -1;
end;

function TPListArrayEnumerator.GetCurrent: TPListValue;
begin
  Result := FSource.Items[ FIndex ];
end;

function TPListArrayEnumerator.MoveNext: Boolean;
begin
  Inc( FIndex );
  Result := FIndex < FSource.Count;
end;

{ TPListDict }

function TPListDict.Add( const Key: string; const Value: TPListValue ): IPListDict;
begin
  Result := Self;
  FItems.Add( Key, Value.Clone );
end;

function TPListDict.AddOrSet( const Key: string; const Value: TPListValue ): IPListDict;
begin
  Result := Self;
  FItems.AddOrSetValue( Key, Value.Clone );
end;

function TPListDict.Clear: IPListDict;
begin
  Result := Self;
  FItems.Clear;
end;

function TPListDict.Clone: IPListValue;
var
  LClone: IPListDict;
  LPair : TPair<string, IPListValue>;
  LValue: TPListValue;
begin
  LClone := TPListDict.Create;
  for LPair in FItems do
    begin
      LValue := LPair.Value;
      LClone.Add( LPair.Key, LValue.Clone );
    end;
  Result := LClone;
end;

function TPListDict.ContainsKey( const Key: string ): Boolean;
begin
  Result := FItems.ContainsKey( Key );
end;

constructor TPListDict.Create;
begin
  inherited Create;
  FItems := TDictionary<string, IPListValue>.Create;
end;

function TPListDict.Delete( const Key: string ): IPListDict;
begin
  Result := Self;
  FItems.Remove( Key );
end;

destructor TPListDict.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TPListDict.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TPListDict.GetEnumerator: IPListKeyValueEnumerator;
begin
  Result := TPListDictEnumerator.Create( Self, FItems.GetEnumerator );
end;

function TPListDict.GetItem( const Key: string ): TPListValue;
begin
  Result := FItems[ Key ];
end;

procedure TPListDict.SetItem( const Key: string; const Value: TPListValue );
begin
  FItems[ Key ] := Value;
end;

function TPListDict.ToString: string;
var
  LValues: TArray<string>;
  LIdx   : Integer;
  LKey   : string;
begin
  SetLength( LValues, FItems.Count );
  LIdx := 0;
  for LKey in FItems.Keys do
    begin
      LValues[ LIdx ] := string.Format( '"%s"=%s', [ LKey, GetItem( LKey ).ToString ] );
      Inc( LIdx );
    end;
  Result := '[' + string.Join( FormatSettings.ListSeparator, LValues ) + ']';
end;

{ TPListDictEnumerator }

constructor TPListDictEnumerator.Create(
  const Source: IPListDict;
  Enumerator  : TEnumerator<TKeyValue> );
begin
  inherited Create;
  FSource     := Source;
  FEnumerator := Enumerator;
end;

function TPListDictEnumerator.GetCurrent: TPListKeyValuePair;
begin
  Result.Key   := FEnumerator.Current.Key;
  Result.Value := FEnumerator.Current.Value;
end;

function TPListDictEnumerator.MoveNext: Boolean;
begin
  Result := FEnumerator.MoveNext;
end;

end.
