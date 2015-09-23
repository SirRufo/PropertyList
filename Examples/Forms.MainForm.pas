unit Forms.MainForm;

interface

uses
  PList,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.ScrollBox, FMX.Memo, FMX.Layouts;

type
  TForm3 = class( TForm )
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    Memo2: TMemo;
    Layout1: TLayout;
    Layout2: TLayout;
    procedure Button1Click( Sender: TObject );
    procedure Button3Click( Sender: TObject );
    procedure Button2Click( Sender: TObject );
  private
    FPList   : IPList;
    FFilename: string;
  public
    procedure AfterConstruction; override;

  end;

var
  Form3: TForm3;

implementation

{$R *.fmx}

uses
  System.IOUtils;

procedure TForm3.AfterConstruction;
begin
  inherited;
  FFilename := TPath.Combine( TPath.GetDocumentsPath, 'test.plist' );
  FPList    := TPList.CreatePList;
end;

procedure TForm3.Button1Click( Sender: TObject );
begin
  if TFile.Exists( FFilename )
  then
    begin
      FPList.LoadFromFile( FFilename );
      Memo2.Lines.LoadFromFile( FFilename );
    end
  else
    Memo2.Lines.Clear;
  Memo1.Text := FPList.Root.ToString;
end;

procedure TForm3.Button2Click( Sender: TObject );
var
  LDict: IPListDict;
  LData: TArray<Byte>;
  LIdx : Integer;
begin
  LDict := TPList.CreateDict;
  LDict.AddOrSet( 'Array', TArray<TPlistValue>.Create( True, False, CFDate( Now( ) ), Random( 42 ), Random * 42 ) );
  LDict.AddOrSet( 'Bool_True', True );
  LDict.AddOrSet( 'Bool_False', False );
  LDict.AddOrSet( 'Date', CFDate( Now( ) ) );

  SetLength( LData, Random( 5 ) + 5 );
  for LIdx := low( LData ) to high( LData ) do
    begin
      LData[ LIdx ] := Random( 256 );
    end;

  LDict.AddOrSet( 'Data', LData );
  LDict.AddOrSet( 'Integer', Random( 42 ) );
  LDict.AddOrSet( 'Real', Random * 42 );
  LDict.AddOrSet( 'String', 'foo' );

  FPList.Root := LDict;
  Memo1.Text  := FPList.Root.ToString;
  Memo2.Lines.Clear;
end;

procedure TForm3.Button3Click( Sender: TObject );
begin
  FPList.SaveToFile( FFilename );
  Memo2.Lines.LoadFromFile( FFilename );
end;

end.
