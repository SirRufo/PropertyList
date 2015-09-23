(*****************************************************************************
 Copyright {2015} Oliver Münzberg (aka Sir Rufo)

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
unit PropertyList.XML;

interface

uses
  System.Generics.Collections,
  System.DateUtils,
  System.NetEncoding,
  System.StrUtils,
  System.SysUtils,
  PropertyList,
  XML.XmlIntf;

type
  TPListXmlWriter = class
  private
    procedure DoWrite( const Node: IXMLNode; const Value: IPListArray ); overload;
    procedure DoWrite( const Node: IXMLNode; const Value: IPListBool ); overload;
    procedure DoWrite( const Node: IXMLNode; const Value: IPListDate ); overload;
    procedure DoWrite( const Node: IXMLNode; const Value: IPListData ); overload;
    procedure DoWrite( const Node: IXMLNode; const Value: IPListDict ); overload;
    procedure DoWrite( const Node: IXMLNode; const Value: IPListInteger ); overload;
    procedure DoWrite( const Node: IXMLNode; const Value: IPListReal ); overload;
    procedure DoWrite( const Node: IXMLNode; const Value: IPListString ); overload;
    procedure DoWrite( const Node: IXMLNode; const Value: TPListValue ); overload;
  public
    procedure Write( const PList: IPList; const Filename: string );
  end;

  TPListXmlReader = class
  private
    function DoReadArray( const Node: IXMLNode ): IPListArray; overload;
    function DoReadData( const Node: IXMLNode ): IPListData; overload;
    function DoReadDate( const Node: IXMLNode ): IPListDate; overload;
    function DoReadDict( const Node: IXMLNode ): IPListDict; overload;
    function DoReadInteger( const Node: IXMLNode ): IPListInteger; overload;
    function DoReadReal( const Node: IXMLNode ): IPListReal; overload;
    function DoReadString( const Node: IXMLNode ): IPListString; overload;
    function DoRead( const Node: IXMLNode ): TPListValue; overload;
  public
    procedure Read( const PList: IPList; const Filename: string );
  end;

implementation

uses
  XML.XMLDoc,
  XML.xmldom,
{$IFDEF MSWINDOWS}
  XML.Win.msxmldom,
{$ENDIF}
  XML.adomxmldom;

const
  PLIST_DOM_QUALIFIEDNAME = 'plist';
  PLIST_DOM_PUBLICID      = '-//Apple//DTD PLIST 1.0//EN';
  PLIST_DOM_SYSTEMID      = 'http://www.apple.com/DTDs/PropertyList-1.0.dtd';
  PLIST_DOM_NAMESPACEURI  = '';
  PLIST_DOC_ENCODING      = 'UTF-8';
  PLIST_ATTRIBUTE_VERSION = 'version';
  PLIST_VERSION           = '1.0';

  PLIST_NODENAME_ARRAY      = 'array';
  PLIST_NODENAME_BOOL_TRUE  = 'true';
  PLIST_NODENAME_BOOL_FALSE = 'false';
  PLIST_NODENAME_DATA       = 'data';
  PLIST_NODENAME_DATE       = 'date';
  PLIST_NODENAME_DICT       = 'dict';
  PLIST_NODENAME_DICT_KEY   = 'key';
  PLIST_NODENAME_INTEGER    = 'integer';
  PLIST_NODENAME_REAL       = 'real';
  PLIST_NODENAME_STRING     = 'string';

  PLIST_FORMATSETTINGS: TFormatSettings = ( DecimalSeparator: '.' );

  { TPListXmlWriter }

procedure TPListXmlWriter.DoWrite(
  const Node : IXMLNode;
  const Value: TPListValue );
begin
  if Value.IsArray
  then
    DoWrite( Node, Value.A )
  else if Value.IsBool
  then
    DoWrite( Node, Value.B )
  else if Value.IsData
  then
    DoWrite( Node, Value.Data )
  else if Value.IsDate
  then
    DoWrite( Node, Value.Date )
  else if Value.IsDict
  then
    DoWrite( Node, Value.Dict )
  else if Value.IsInteger
  then
    DoWrite( Node, Value.I )
  else if Value.IsReal
  then
    DoWrite( Node, Value.R )
  else if Value.IsString
  then
    DoWrite( Node, Value.S )
  else
    raise ENotImplemented.Create( 'Value type not implemented' );
end;

procedure TPListXmlWriter.DoWrite(
  const Node : IXMLNode;
  const Value: IPListDate );
begin
  Node.AddChild( PLIST_NODENAME_DATE ).Text := DateToISO8601( Value.Value, False );
end;

procedure TPListXmlWriter.DoWrite(
  const Node : IXMLNode;
  const Value: IPListBool );
begin
  if Value.Value
  then
    Node.AddChild( PLIST_NODENAME_BOOL_TRUE )
  else
    Node.AddChild( PLIST_NODENAME_BOOL_FALSE );
end;

procedure TPListXmlWriter.DoWrite(
  const Node : IXMLNode;
  const Value: IPListArray );
var
  LNode: IXMLNode;
  LItem: TPListValue;
begin
  LNode := Node.AddChild( PLIST_NODENAME_ARRAY );
  for LItem in Value do
    begin
      DoWrite( LNode, LItem );
    end;
end;

procedure TPListXmlWriter.DoWrite(
  const Node : IXMLNode;
  const Value: IPListReal );
begin
  Node.AddChild( PLIST_NODENAME_REAL ).Text := FloatToStr( Value.Value, PLIST_FORMATSETTINGS );
end;

procedure TPListXmlWriter.DoWrite(
  const Node : IXMLNode;
  const Value: IPListString );
begin
  Node.AddChild( PLIST_NODENAME_STRING ).Text := Value.Value;
end;

procedure TPListXmlWriter.DoWrite(
  const Node : IXMLNode;
  const Value: IPListInteger );
begin
  Node.AddChild( PLIST_NODENAME_INTEGER ).Text := IntToStr( Value.Value );
end;

procedure TPListXmlWriter.DoWrite( const Node: IXMLNode;
  const Value: IPListData );
begin
  Node.AddChild( PLIST_NODENAME_DATA ).Text := TNetEncoding.Base64.EncodeBytesToString( Value.Value );
end;

procedure TPListXmlWriter.DoWrite( const Node: IXMLNode;
  const Value: IPListDict );
var
  LNode: IXMLNode;
  LItem: TPListKeyValuePair;
begin
  LNode := Node.AddChild( PLIST_NODENAME_DICT );
  for LItem in Value do
    begin
      LNode.AddChild( PLIST_NODENAME_DICT_KEY ).Text := LItem.Key;
      DoWrite( LNode, LItem.Value );
    end;
end;

procedure TPListXmlWriter.Write( const PList: IPList; const Filename: string );
var
  LDom    : IDOMImplementation;
  LDocType: IDOMDocumentType;
  LDoc    : IXMLDocument;
  LNode   : IXMLNode;
begin
  LDom     := GetDOM( sAdom4XmlVendor );
  LDocType := LDom.createDocumentType(
    PLIST_DOM_QUALIFIEDNAME,
    PLIST_DOM_PUBLICID,
    PLIST_DOM_SYSTEMID );

  LDoc             := NewXMLDocument( );
  LDoc.DOMDocument := LDom.createDocument(
    PLIST_DOM_NAMESPACEURI,
    PLIST_DOM_QUALIFIEDNAME,
    LDocType );
  LDoc.Encoding := PLIST_DOC_ENCODING;
  LDoc.Options  := LDoc.Options + [ doNodeAutoIndent ];

  LNode                                       := LDoc.DocumentElement;
  LNode.Attributes[ PLIST_ATTRIBUTE_VERSION ] := PLIST_VERSION;

  if not PList.Root.IsEmpty
  then
    DoWrite( LNode, PList.Root );

  LDoc.SaveToFile( Filename );
end;

{ TPListXmlReader }

function TPListXmlReader.DoReadArray( const Node: IXMLNode ): IPListArray;
var
  LIdx  : Integer;
  LValue: IXMLNode;
begin
  Result := TPList.CreateArray;
  LIdx   := 0;
  while LIdx < Node.ChildNodes.Count do
    begin
      LValue := Node.ChildNodes.Get( LIdx );
      Result.Add( DoRead( LValue ) );
      Inc( LIdx );
    end;
end;

function TPListXmlReader.DoReadData( const Node: IXMLNode ): IPListData;
begin
  Result := TPList.CreateData( TNetEncoding.Base64.DecodeStringToBytes( Node.Text ) );
end;

function TPListXmlReader.DoReadDate( const Node: IXMLNode ): IPListDate;
begin
  Result := TPList.CreateDate( ISO8601ToDate( Node.Text, False ) );
end;

function TPListXmlReader.DoReadDict( const Node: IXMLNode ): IPListDict;
var
  LIdx        : Integer;
  LKey, LValue: IXMLNode;
begin
  Result := TPList.CreateDict;
  LIdx   := 0;
  while LIdx + 1 < Node.ChildNodes.Count do
    begin
      LKey   := Node.ChildNodes.Get( LIdx );
      LValue := Node.ChildNodes.Get( LIdx + 1 );

      if not SameText( PLIST_NODENAME_DICT_KEY, LKey.NodeName )
      then
        raise EPListFileException.CreateFmt( 'Key-Node expected but %s found', [ LKey.NodeName ] );

      Result.Add( LKey.Text, DoRead( LValue ) );

      Inc( LIdx, 2 );
    end;
end;

function TPListXmlReader.DoReadInteger( const Node: IXMLNode ): IPListInteger;
begin
  Result := TPList.CreateInteger( StrToInt( Node.Text ) );
end;

function TPListXmlReader.DoReadReal( const Node: IXMLNode ): IPListReal;
begin
  Result := TPList.CreateReal( StrToFloat( Node.Text, PLIST_FORMATSETTINGS ) );
end;

function TPListXmlReader.DoReadString( const Node: IXMLNode ): IPListString;
begin
  Result := TPList.CreateString( Node.Text );
end;

procedure TPListXmlReader.Read(
  const PList   : IPList;
  const Filename: string );
var
  LDoc    : IXMLDocument;
  LNode   : IXMLNode;
  LVersion: string;
begin
  LDoc := NewXMLDocument( );
  LDoc.LoadFromFile( Filename );

  LNode := LDoc.DocumentElement;

  if LNode.NodeName <> PLIST_DOM_QUALIFIEDNAME
  then
    raise EPListFileException.CreateFmt( 'First node should read "%s"', [ PLIST_DOM_QUALIFIEDNAME ] );

  if not LNode.HasAttribute( PLIST_ATTRIBUTE_VERSION )
  then
    raise EPListFileException.CreateFmt( 'Node attribute "%s" is missing', [ PLIST_ATTRIBUTE_VERSION ] );

  LVersion := LNode.Attributes[ PLIST_ATTRIBUTE_VERSION ];

  if LVersion <> PLIST_VERSION
  then
    raise EPListFileException.CreateFmt( 'Version "%s" expected but "%s" found', [ PLIST_VERSION, LVersion ] );

  if LNode.HasChildNodes
  then
    begin
      if LNode.ChildNodes.Count > 1
      then
        raise EPListFileException.CreateFmt( 'Excpected %d node but found %d', [ 1, LNode.ChildNodes.Count ] );

      PList.Root := DoRead( LNode.ChildNodes.First );
    end
  else
    PList.Root := nil;
end;

function TPListXmlReader.DoRead( const Node: IXMLNode ): TPListValue;
begin
  case IndexText( Node.NodeName, [
    {0} PLIST_NODENAME_ARRAY,
    {1} PLIST_NODENAME_BOOL_TRUE,
    {2} PLIST_NODENAME_BOOL_FALSE,
    {3} PLIST_NODENAME_DATA,
    {4} PLIST_NODENAME_DATE,
    {5} PLIST_NODENAME_DICT,
    {6} PLIST_NODENAME_INTEGER,
    {7} PLIST_NODENAME_REAL,
    {8} PLIST_NODENAME_STRING ] ) of
    0:
      Result := DoReadArray( Node );
    1:
      Result := TPList.CreateBool( True );
    2:
      Result := TPList.CreateBool( False );
    3:
      Result := DoReadData( Node );
    4:
      Result := DoReadDate( Node );
    5:
      Result := DoReadDict( Node );
    6:
      Result := DoReadInteger( Node );
    7:
      Result := DoReadReal( Node );
    8:
      Result := DoReadString( Node );
  else
    raise EPListFileException.CreateFmt( 'Not supported node type %s', [ Node.NodeName ] );
  end;
end;

initialization

{$IFDEF MSWINDOWS}
  XML.Win.msxmldom.MSXMLDOMDocumentFactory.AddDOMProperty( 'ProhibitDTD', False );
{$ENDIF}

end.
