unit whizaxe.VSTHelper.Tree;

interface

uses
  System.Generics.Collections,
  VirtualTrees,
  whizaxe.VSTHelper;

type
  PTreeData = ^TTreeData;
  TTreeData = record
    obj: TObject;
  end;

//  PShellObjectData = ^TShellObjectData;
//  TShellObjectData = record
//    dir: string;
//    fullPath: string;
//    shortPath: string;
//    isDir: boolean;
//  end;

  TVSTHelperTree<T: class> = class(TVSTHelperBase<T>)
  public
    type
      TGetTextEvent = procedure(Sender: TBaseVirtualTree; Item: T; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string) of object;
      TInitChildrenEvent = procedure(Sender: TBaseVirtualTree; Item: T; Node: PVirtualNode; var ChildCount: Cardinal) of object;
      TInitNodeEvent = procedure(Sender: TBaseVirtualTree; Item: T; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates) of object;

  private
    FModel: TObjectList<T>;
    FOnGetText: TGetTextEvent;
    FOnInitChildren: TInitChildrenEvent;
    FOnInitNodeEvent: TInitNodeEvent;
    procedure SetModel(const Value: TObjectList<T>);
  protected
    function GetOffset: Int64; override;
    procedure SetOffset(const Value: Int64); override;
    function RowCount: int64; override;
    function GetModel: TObjectList<T>; override;
    function DoTryGetModelItem(Model: TObjectList<T>;Node: PVirtualNode; out item: T): boolean; override;

//    function DoTryGetModelItem(Node: PVirtualNode; out item: T): boolean; override;
    function Init: boolean; override;

    procedure vstTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure vstTreeInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure vstTreeInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);

    procedure RebuildTree;

  public
    property Model: TObjectList<T> read FModel write SetModel;
    property OnGetText: TGetTextEvent read FOnGetText write FOnGetText;
    property OnInitChildren: TInitChildrenEvent read FOnInitChildren write FOnInitChildren;
    property OnInitNode: TInitNodeEvent read FOnInitNodeEvent write FOnInitNodeEvent;
  end;

implementation

{ TVSTHelperTree<T> }

function TVSTHelperTree<T>.DoTryGetModelItem(Model: TObjectList<T>; Node: PVirtualNode; out item: T): boolean;
var
  Data: PTreeData;
begin
  result := false;
  Data := FTreeView.GetNodeData(Node);
  if (data <> nil) and (Data.obj <> nil) then
  begin
    item := T(Data.obj);
    result := true;
  end;
end;

function TVSTHelperTree<T>.GetModel: TObjectList<T>;
begin
  result := FModel;
end;

function TVSTHelperTree<T>.GetOffset: Int64;
begin

end;

function TVSTHelperTree<T>.Init: boolean;
var
  Column: TVirtualTreeColumn;
  i: Integer;
begin
  result := false;
  if (GetModel = nil) or (FTreeView = nil) then
    exit;

  FTreeView.OnChange := vstChange;

  FTreeView.TreeOptions.SelectionOptions := FTreeView.TreeOptions.SelectionOptions + [toFullRowSelect];
  FTreeView.TreeOptions.PaintOptions := FTreeView.TreeOptions.PaintOptions + [toHideFocusRect] - [toShowRoot, toShowTreeLines, toHideSelection, toUseBlendedSelection];
  FTreeView.TreeOptions.MiscOptions := FTreeView.TreeOptions.MiscOptions - [toGridExtensions] - [toVariableNodeHeight, toReadOnly];

  FTreeView.OnInitNode := vstTreeInitNode;
  FTreeView.OnInitChildren := vstTreeInitChildren;
  FTreeView.OnGetText := vstTreeGetText;

  RebuildTree;
  result := true;

end;

procedure TVSTHelperTree<T>.RebuildTree;
begin
  FTreeView.NodeDataSize := SizeOf(TTreeData);
  FTreeView.RootNodeCount := 1;  // sztuczny root
end;

function TVSTHelperTree<T>.RowCount: int64;
begin
// DC: celowo puste
end;

procedure TVSTHelperTree<T>.SetModel(const Value: TObjectList<T>);
begin
  FModel := Value;
  Init;
end;

procedure TVSTHelperTree<T>.SetOffset(const Value: Int64);
begin
// DC: celowo puste
end;

procedure TVSTHelperTree<T>.vstTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);
var
  lItem: T;
begin
  if not TryGetModelItem(Node, lItem) then
    exit;

  if Assigned(OnGetText) then
    OnGetText(Sender, lItem, Node, Column, TextType, CellText);
end;

procedure TVSTHelperTree<T>.vstTreeInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  lItem: T;
begin
  if not TryGetModelItem(Node, lItem) then
    exit;
  if Assigned(OnInitChildren) then
    OnInitChildren(Sender, lItem, Node, ChildCount);
end;

procedure TVSTHelperTree<T>.vstTreeInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  lItem: T;
  Data: PTreeData;
begin
  Data := FTreeView.GetNodeData(Node);
  if data.obj = nil then
    lItem := FModel.First
  else
    lItem := T(data.obj);
  if lItem = nil then
    exit;

  if Assigned(OnInitNode) then
    OnInitNode(Sender, lItem, ParentNode, Node, InitialStates);
  Data.obj := lItem;
end;

end.
