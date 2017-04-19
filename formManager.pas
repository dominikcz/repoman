unit formManager;

interface

uses
  Forms,
  Classes,
  Generics.Collections;

type
  TFormWithEvents = class
  public
    form: TForm;
    isClosed: boolean;
    onDestroy: TNotifyEvent;
    onClose: TCloseEvent;
  end;

  TFormManager = class(TObjectList<TFormWithEvents>)
  private
    procedure hndOnFormDestroy(Sender: TObject);
    procedure hndOnFormClose(Sender: TObject; var Action: TCloseAction);
    function findForm(Sender: TObject): integer;
    procedure doFormClose(idx: integer);
  public
    function Add(item: TForm; caption: string = ''): TForm;
    procedure Clear;
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
var
  rec: TFormWithEvents;
begin
  rec := TFormWithEvents.Create;
  rec.form := item;
  rec.onClose := item.OnClose;
  rec.onDestroy := item.OnDestroy;
  rec.isClosed := false;
  inherited Add(rec);
  item.OnClose := hndOnFormClose;
  item.OnDestroy := hndOnFormDestroy;
  if caption <> '' then
    item.Caption := caption;
  result := item;
end;

procedure TFormManager.Clear;
var
  i: integer;
  rec: TFormWithEvents;
  item: TForm;
begin
  for i := Count - 1 downto 0 do
  begin
    rec := items[i];
    item := rec.form;
    doFormClose(i);
    item.OnDestroy := rec.onDestroy;
    item.Free;
    delete(i);
  end;
end;

constructor TFormManager.Create;
begin
  inherited Create(true);
end;

destructor TFormManager.Destroy;
begin
  Clear;
  inherited;
end;

procedure TFormManager.doFormClose(idx: integer);
var
  dummyAction: TCloseAction;
begin
  with items[idx] do
  begin
    dummyAction := caFree;
    if (not isClosed) and Assigned(onClose) then
      onClose(form, dummyAction);
    isClosed := true;
  end;
end;

function TFormManager.findForm(Sender: TObject): integer;
var
  i: Integer;
begin
  result := -1;
  for i := 0 to Count - 1 do
    if items[i].form = TForm(Sender) then
      exit(i);
end;

procedure TFormManager.hndOnFormClose(Sender: TObject; var Action: TCloseAction);
var
  idx: Integer;
begin
  idx := findForm(Sender);
  if idx >= 0 then
  begin
    doFormClose(idx);
    Action := caFree;
  end;
end;

procedure TFormManager.hndOnFormDestroy(Sender: TObject);
var
  idx: Integer;
  rec: TFormWithEvents;
begin
  idx := findForm(Sender);
  if idx >= 0 then
  begin
    rec := items[idx];
    if Assigned(rec.onDestroy) then
      rec.onDestroy(rec.form);
    Delete(idx);
  end;
end;

initialization
  vFormManager := nil;

finalization
  vFormManager.Free;

end.
