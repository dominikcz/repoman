unit formManager;

interface

uses
  Forms,
  Generics.Collections;

type
  TFormManager = class(TObjectList<TForm>)
  private
    procedure hndOnFormClose(Sender: TObject; var Action: TCloseAction);
  public
    function Add(item: TForm; caption: string = ''): TForm;
    constructor Create;
    destructor Destroy; override;
  end;

function forms: TFormManager;

implementation

var
  vFormManager: TFormManager;

function forms: TFormManager;
begin
  if not Assigned(vFormManager) then
    vFormManager := TFormManager.Create;
  Result := vFormManager;
end;

{ TFormManager }

function TFormManager.Add(item: TForm; caption: string): TForm;
begin
  inherited Add(item);
  item.OnClose := hndOnFormClose;
  if caption <> '' then
    item.Caption := caption;
  result := item;
end;

constructor TFormManager.Create;
begin
  inherited Create(true);
end;

destructor TFormManager.Destroy;
var
  i: integer;
  item: TForm;
begin
  for i := Count - 1 downto 0 do
  begin
    item := items[i];
    item.OnClose := nil;
    item.Close;
    delete(i);
  end;
  inherited;
end;

procedure TFormManager.hndOnFormClose(Sender: TObject; var Action: TCloseAction);
var
  idx: Integer;
begin
  idx := IndexOf(TForm(Sender));
  if idx >=0 then
    Delete(idx);
end;

initialization
  vFormManager := nil;

finalization
  vFormManager.Free;

end.
