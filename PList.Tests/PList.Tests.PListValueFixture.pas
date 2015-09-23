unit PList.Tests.PListValueFixture;

interface

uses
  DUnitX.TestFramework,
  PList;

type

  [ TestFixture ]
  TPListValueFixture = class( TObject )
  private
    FValue: TPListValue;
  public
    [ Test ]
    procedure GivenValueIsNotInitialized_ThenTheValueIsEmpty;
    [ Test ]
    procedure GivenAssignArrayToValue_TheValueIsOnlyArrayAndNotEmpty;
    [ Test ]
    procedure GivenAssignStringToValue_TheValueIsOnlyStringAndNotEmpty;
  end;

implementation

{ TPListValueFixture }

procedure TPListValueFixture.GivenAssignArrayToValue_TheValueIsOnlyArrayAndNotEmpty;
begin
  FValue := TPList.CreateArray;
  Assert.IsTrue( not FValue.IsEmpty );
  Assert.IsTrue( FValue.IsArray );
  Assert.IsTrue( not FValue.IsBool );
  Assert.IsTrue( not FValue.IsData );
  Assert.IsTrue( not FValue.IsDate );
  Assert.IsTrue( not FValue.IsDict );
  Assert.IsTrue( not FValue.IsInteger );
  Assert.IsTrue( not FValue.IsReal );
  Assert.IsTrue( not FValue.IsString );
end;

procedure TPListValueFixture.GivenAssignStringToValue_TheValueIsOnlyStringAndNotEmpty;
begin
  FValue := 'string';
  Assert.IsTrue( not FValue.IsEmpty );
  Assert.IsTrue( not FValue.IsArray );
  Assert.IsTrue( not FValue.IsBool );
  Assert.IsTrue( not FValue.IsData );
  Assert.IsTrue( not FValue.IsDate );
  Assert.IsTrue( not FValue.IsDict );
  Assert.IsTrue( not FValue.IsInteger );
  Assert.IsTrue( not FValue.IsReal );
  Assert.IsTrue( FValue.IsString );
end;

procedure TPListValueFixture.GivenValueIsNotInitialized_ThenTheValueIsEmpty;
begin
  Assert.IsTrue( FValue.IsEmpty );
  Assert.IsTrue( not FValue.IsArray );
  Assert.IsTrue( not FValue.IsBool );
  Assert.IsTrue( not FValue.IsData );
  Assert.IsTrue( not FValue.IsDate );
  Assert.IsTrue( not FValue.IsDict );
  Assert.IsTrue( not FValue.IsInteger );
  Assert.IsTrue( not FValue.IsReal );
  Assert.IsTrue( not FValue.IsString );
end;

initialization

TDUnitX.RegisterTestFixture( TPListValueFixture );

end.
