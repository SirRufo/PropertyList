unit PropertyList.Tests.PListXmlReaderFixture;

interface

uses
  DUnitX.TestFramework,
  System.Classes,
  PropertyList,
  PropertyList.XML;

type

  [ TestFixture ]
  TPListXmlReaderFixture = class( TObject )
  private const
    PListXmlDataString =
    {} '<?xml version="1.0" encoding="UTF-8"?>' + sLineBreak +
    {} '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd" >' + sLineBreak +
    {} '<plist version="1.0">' + sLineBreak +
    {} '  <dict>' + sLineBreak +
    {} '    <key>Integer</key>' + sLineBreak +
    {} '    <integer>8</integer>' + sLineBreak +
    {} '  </dict>' + sLineBreak +
    {} '</plist> ';
  private
    FPListXmlDataStream: TStream;
    FReader            : TPListXmlReader;
  public
    [ Setup ]
    procedure Setup;
    [ TearDown ]
    procedure TearDown;
  public
    [ TestCase ]
    procedure WhenLoadPListDataFromStream_ThenThePListIsLoaded;
  end;

implementation

procedure TPListXmlReaderFixture.Setup;
begin
  FPListXmlDataStream          := TStringStream.Create( UTF8Encode( PListXmlDataString ) );
  FPListXmlDataStream.Position := 0;
  FReader                      := TPListXmlReader.Create;
end;

procedure TPListXmlReaderFixture.TearDown;
begin
  FReader.Free;
  FPListXmlDataStream.Free;
end;

procedure TPListXmlReaderFixture.WhenLoadPListDataFromStream_ThenThePListIsLoaded;
var
  LPList: IPList;
begin
  LPList := TPList.CreatePList( );
  FReader.Read( LPList, FPListXmlDataStream );

  Assert.IsTrue( LPList.Root.IsDict );
  Assert.IsTrue( LPList.Root.Dict.ContainsKey( 'Integer' ) );
  Assert.IsTrue( LPList.Root.Dict[ 'Integer' ].IsInteger );
  Assert.AreEqual( 8, LPList.Root.Dict[ 'Integer' ].I.Value );
end;

initialization

TDUnitX.RegisterTestFixture( TPListXmlReaderFixture );

end.
