unit dmCommonResources;

interface

uses
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Controls, PngImageList;

type
  TCommonResources = class(TDataModule)
    repoIcons: TPngImageList;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function CommonResources: TCommonResources;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

var
  vCommonResources: TCommonResources;

function CommonResources: TCommonResources;
begin
  if not Assigned(vCommonResources) then
    vCommonResources := TCommonResources.Create(nil);
  Result := vCommonResources;
end;

initialization
  vCommonResources := CommonResources;

finalization
  vCommonResources.Free;

end.
