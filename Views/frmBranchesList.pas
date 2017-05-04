unit frmBranchesList;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.StdCtrls, Vcl.ExtCtrls,
  whizaxe.VSTHelper,
  Models.LogInfo;

type
  TBranchesListForm = class(TForm)
    branchesTree: TVirtualStringTree;
    Panel1: TPanel;
    btnCancel: TButton;
    btnOK: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FVSTHelper: TVSTHelper<TBranchFilterItem>;
    FWorkModel: TBranchFilter;
    procedure updateModel(srcModel, destModel: TBranchFilter);
    procedure hndCompareNodes(Item1, Item2: TBranchFilterItem; Column: TColumnIndex; var Result: Integer);
  public
    { Public declarations }
    class function Execute(model: TBranchFilter): boolean;
  end;

implementation

{$R *.dfm}

uses
  whizaxe.serialization;

{ TBranchesListForm }

class function TBranchesListForm.Execute(model: TBranchFilter): boolean;
var
  form: TBranchesListForm;
  rc: integer;
begin
  form := TBranchesListForm.Create(nil);
  try
    form.updateModel(model, form.FWorkModel);
    form.FVSTHelper.Model := form.FWorkModel;
    rc := form.ShowModal;
    result := (rc = mrOK);
    if result then
      form.updateModel(form.FWorkModel, model);
  finally
    form.Free;
  end;
end;

procedure TBranchesListForm.FormCreate(Sender: TObject);
begin
  FVSTHelper := TVSTHelper<TBranchFilterItem>.Create;
  FVSTHelper.TreeView := branchesTree;
  FVSTHelper.OnCompareNodes := hndCompareNodes;
  FVSTHelper.CheckType := ctCheckBox;
  FVSTHelper.CheckBindColumn := 'isSelected';
  FVSTHelper.CheckDisplayColumn := 'branch';
  FWorkModel := TBranchFilter.Create;
end;

procedure TBranchesListForm.FormDestroy(Sender: TObject);
begin
  FWorkModel.Free;
  FVSTHelper.Free;
end;

procedure TBranchesListForm.hndCompareNodes(Item1, Item2: TBranchFilterItem; Column: TColumnIndex; var Result: Integer);
begin
  case Column of
    0: Result := AnsiCompareStr(item1.branch, item2.branch);
    1: Result := round(item1.lastActivity - item2.lastActivity);
  end;
end;

procedure TBranchesListForm.updateModel(srcModel, destModel: TBranchFilter);
var
  item: TBranchFilteritem;
begin
  destmodel.Clear;
  for item in srcModel do
    destModel.add(TSerializer.CloneObject<TBranchFilterItem>(item));
end;

end.
