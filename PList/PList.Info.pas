unit PList.Info;

interface

uses
  PList;

type
  TInfoPList = class abstract
  private
    function GetCFInfoDictionaryVersion: string;
  protected
    FPList: IPList;
  public
    property CFInfoDictionaryVersion: string read GetCFInfoDictionaryVersion;
  end;

  TInfoPList_6_0 = class( TInfoPList )
  public

  end;

implementation

{ TInfoPList }

function TInfoPList.GetCFInfoDictionaryVersion: string;
begin
  Result := FPList.Root.Dict.Items[ 'CFInfoDictionaryVersion' ].S.Value;
end;

end.
