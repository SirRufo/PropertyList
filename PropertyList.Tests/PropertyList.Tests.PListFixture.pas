unit PropertyList.Tests.PListFixture;

interface

uses
  DUnitX.TestFramework,
  PropertyList;

type

  [ TestFixture ]
  TPListFixture = class( TObject )
  private
    FPList: IPList;
  public
    [ Setup ]
    procedure Setup;
    [ TearDown ]
    procedure TearDown;
  end;

implementation

procedure TPListFixture.Setup;
begin
  FPList := TPList.CreatePList;
end;

procedure TPListFixture.TearDown;
begin
  FPList := nil;
end;

initialization

TDUnitX.RegisterTestFixture( TPListFixture );

end.
