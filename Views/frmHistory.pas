unit frmHistory;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.ComCtrls, System.Actions, Vcl.ActnList,
  Vcl.StdActns, Vcl.Menus, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnPopup,
  System.UITypes,
  repoHelper,
  whizaxe.vstHelper;

type
  THistoryForm = class(TForm)
    history: TVirtualStringTree;
    StatusBar: TStatusBar;
    ActionList1: TActionList;
    EditCopy1: TEditCopy;
    PopupActionBar1: TPopupActionBar;
    Copy1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure EditCopy1Execute(Sender: TObject);
  private
    { Private declarations }
    FHistoryHelper: TVSTHelper<TRepoHistoryItem>;
    procedure hndHistoryGetImageIndex(Sender: TBaseVirtualTree; Item: TRepoHistoryItem; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure hndHistoryCompareNodes(Item1, Item2: TRepoHistoryItem; Column: TColumnIndex; var Result: Integer);

  public
    { Public declarations }
    procedure Execute(AModel: TRepoHistory);
  end;

implementation

{$R *.dfm}

uses
  ClipBrd;

procedure THistoryForm.EditCopy1Execute(Sender: TObject);
var
  s: string;
  item: TRepoHistoryItem;
begin
  s := 'op;date;user;object;revision/branch;host'+#13#10;
  for item in FHistoryHelper.Model do
    s := s + format('%s;%s;%s;%s;%s;%s', [item.operationAsStr, item.dtAsIso, item.user, item.filePath, item.revisionOrBranch, item.host]) + #13#10;

  Clipboard.AsText := s;
end;

procedure THistoryForm.Execute(AModel: TRepoHistory);
begin
  FHistoryHelper.Model.Free;
  FHistoryHelper.Model := AModel;
  StatusBar.SimpleText := format('%d operatons', [AModel.Count]);
  ShowModal;
end;

procedure THistoryForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FHistoryHelper.Model.OwnsObjects := true;
  FHistoryHelper.Model.Free;
  FHistoryHelper.Model := nil;
  FHistoryHelper.Free;
end;

procedure THistoryForm.FormCreate(Sender: TObject);
begin
  FHistoryHelper := TVSTHelper<TRepoHistoryItem>.Create;
  FHistoryHelper.OnGetImageIndex := hndHistoryGetImageIndex;
  FHistoryHelper.OnCompareNodes := hndHistoryCompareNodes;
  FHistoryHelper.TreeView :=  history;
end;

procedure THistoryForm.hndHistoryCompareNodes(Item1, Item2: TRepoHistoryItem; Column: TColumnIndex;
  var Result: Integer);
begin
  case Column of
    0: Result := Ord(item1.operation) - Ord(item2.operation);
    1: Result := round(item1.dt - item2.dt);
    2: Result := AnsiCompareStr(item1.user, item2.user);
    3: Result := AnsiCompareStr(item1.filePath, item2.filePath);
    4: Result := AnsiCompareStr(item1.revisionOrBranch, item2.revisionOrBranch);
    5: Result := AnsiCompareStr(item1.host, item2.host);
  end;
  if (Result = 0) and (Column <> 1) then
  begin
    Result := round(item1.dt - item2.dt);
    if Result = 0 then
      Result := AnsiCompareStr(item1.revisionOrBranch, item2.revisionOrBranch);
  end;
end;

procedure THistoryForm.hndHistoryGetImageIndex(Sender: TBaseVirtualTree; Item: TRepoHistoryItem; Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
begin
  if (column > 0) or not (Kind in [ikNormal, ikSelected]) then
    exit;

  case item.operation of
    hoAdd: ImageIndex := 12;
    hoDel: ImageIndex := 13;
    hoMerge: ImageIndex := 5;
    hoTag: ImageIndex := 20;
    else
      ImageIndex := 0;
  end;
end;

end.
