unit dmRepo;

interface

uses
  System.SysUtils, System.Classes, System.Actions, System.Types,
  Vcl.ActnList, Vcl.Graphics,
  VirtualTrees,
  Models.FileInfo,
  whizaxe.vstHelper,
  whizaxe.vstHelper.Tree;

type
  TMatchType = (mtContains, mtEndsWith, mtStartsWith);

  TRepo = class(TDataModule)
    alRepoActions: TActionList;
    alViewActions: TActionList;
    actFlatMode: TAction;
    actModifiedOnly: TAction;
    actIgnore: TAction;
    actShowIgnored: TAction;
    actRefresh: TAction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure hndChangeRootDir(Sender: TObject);
    function  hndFilterModel(item: TFileInfo): boolean;
    function  _FilterModel(path: string): boolean;
    procedure refreshView(Sender: TObject);
    procedure actShowIgnoredExecute(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
  private
    { Private declarations }
    FRootPath: string;
    FFiles: TFilesList;
    FDirs: TDirsList;
    FIgnoreList: TStringList;
    FDirHelper: TVSTHelperTree<TDirInfo>;
    FFileListHelper: TVSTHelper<TFileInfo>;
    procedure hndVstFiltered(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; var Abort, Visible: boolean);
    procedure hndDirInitChildren(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure hndDirInitNode(Sender: TBaseVirtualTree; Item: TDirInfo; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure hndDirGetText(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: string);

    procedure PrepareIgnoreList(const dir: string);
  public
    { Public declarations }
    procedure hndOnChangeDir(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode);
  end;

function Repo: TRepo;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  System.IOUtils,
  frmMain,
  whizaxe.vclHelper;

var
  vRepo: TRepo;

const
  cIgnoreListFileName = 'ignorelist.repoman'; // DONT LOCALIZE

function Repo: TRepo;
begin
  if not Assigned(vRepo) then
    vRepo := TRepo.Create(nil);
  Result := vRepo;
end;

procedure TRepo.actRefreshExecute(Sender: TObject);
begin
  refreshView(Sender);
end;

procedure TRepo.actShowIgnoredExecute(Sender: TObject);
begin
  FFileListHelper.Filtered := not actShowIgnored.Checked;
  FDirHelper.RefreshView;
end;

procedure TRepo.DataModuleCreate(Sender: TObject);
var
  fileName: string;
  i: Integer;
  s: string;
begin
  FFiles := TFilesList.Create;
  FDirs := TDirsList.Create;

  FFileListHelper := TVSTHelper<TFileInfo>.Create;
  FFileListHelper.Model := FFiles;
  FFileListHelper.TreeView :=  MainForm.ViewFilesBrowser1.fileList;

  FDirHelper := TVSTHelperTree<TDirInfo>.Create;
  FDirHelper.OnInitNode := hndDirInitNode;
  FDirHelper.OnInitChildren := hndDirInitChildren;
  FDirHelper.OnGetText := hndDirGetText;
  FDirHelper.OnChange := hndOnChangeDir;
  FDirHelper.Model := FDirs;
  FDirHelper.TreeView := MainForm.ViewFilesBrowser1.dirTree;

  FRootPath := 'x:\mccomp\NewPos2014';
  MainForm.ViewFilesBrowser1.RootPath := FRootPath;
  MainForm.ViewFilesBrowser1.OnRootChange := hndChangeRootDir;

  FIgnoreList := TStringList.Create;
  PrepareIgnoreList(ExtractFileDir(paramStr(0)));
  FFileListHelper.OnFiltered := hndVstFiltered;
end;

procedure TRepo.DataModuleDestroy(Sender: TObject);
begin
  FDirs.Free;
  FFiles.Free;

  FFileListHelper.Free;
  FDirHelper.Free;

  FIgnoreList.Free;
end;

procedure TRepo.hndChangeRootDir(Sender: TObject);
begin
  FRootPath := MainForm.ViewFilesBrowser1.RootPath;
end;

procedure TRepo.hndDirGetText(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);
begin
  CellText := Item.dir;
end;

procedure TRepo.hndDirInitChildren(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode;
  var ChildCount: Cardinal);
var
  ChildNode: PVirtualNode;
  child: TDirInfo;
begin
  for child in FDirs.GetChildrenIterator(Item) do
  begin
    if _FilterModel(child.FullPath) then
    begin
      ChildNode := Sender.AddChild(Node, child);
      Sender.ValidateNode(Node, False);
    end;
    ChildCount := Sender.ChildCount[Node];
    if ChildCount > 0 then
      Sender.Sort(Node, 0, TVirtualStringTree(Sender).Header.SortDirection, False);
  end;
end;

procedure TRepo.hndDirInitNode(Sender: TBaseVirtualTree; Item: TDirInfo; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
begin
  if FDirs.HasChildren(Item) then
    Include(InitialStates, ivsHasChildren);
end;

function TRepo.hndFilterModel(item: TFileInfo): boolean;
begin
  result := _FilterModel(item.fullPath);
end;

procedure TRepo.hndOnChangeDir(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode);
begin
  FFiles.Reload(item.fullPath, actFlatMode.Checked);
  FFileListHelper.RefreshView;
end;

procedure TRepo.hndVstFiltered(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; var Abort,
  Visible: boolean);
begin
  Visible := hndFilterModel(item);
end;

procedure TRepo.PrepareIgnoreList(const dir: string);
var
  fileName: string;
  i: Integer;
  s: string;
begin
  fileName := TPath.Combine(dir, cIgnoreListFileName);
  if not FileExists(fileName) then
    fileName := TPath.Combine(ExtractFilePath(paramStr(0)), cIgnoreListFileName);

  if FileExists(fileName) then
  begin
    FIgnoreList.LoadFromFile(fileName);
    // "kompilujemy" filtry:
    // *... => mtEndsWith
    // ...* => mrStartsWith
    // ... => mtContains
    // konstrukcje typu ...*... czy *...* nie s¹ obslugiwane
    for i := 0 to FIgnoreList.Count - 1 do
    begin
      s := FIgnoreList[i];
      if s.StartsWith('*') then
        FIgnoreList.Objects[i] := TObject(ord(mtEndsWith))
      else if s.EndsWith('*') then
        FIgnoreList.Objects[i] := TObject(ord(mtStartsWith))
      else
        FIgnoreList.Objects[i] := TObject(ord(mtContains));
      FIgnoreList[i] := StringReplace(s, '*', '', [rfReplaceAll]);
    end;
  end
  else
    FIgnoreList.clear;
end;

procedure TRepo.refreshView(Sender: TObject);
var
  child: TDirInfo;
begin
  FDirs.Reload(FRootPath);
  FFileListHelper.RefreshView;

  FFiles.Reload(FRootPath, actFlatMode.Checked);
  FFileListHelper.RefreshView;
end;

function TRepo._FilterModel(path: string): boolean;
var
  i: Integer;
  s: string;
begin
  result := true;
  if not actShowIgnored.Checked then
    exit;
  for i := 0 to FIgnoreList.Count - 1 do
  begin
    s := FIgnoreList[i];
    case TMatchType(FIgnoreList.Objects[i]) of
      mtContains:
        result := not path.ToLower.Contains(s.ToLower);
      mtEndsWith:
        result := not path.EndsWith(s, true);
      mtStartsWith:
        result := not path.StartsWith(s, true);
    end;
    if not result then
      exit;
  end;
end;

initialization
  vRepo := nil;

finalization
  vRepo.Free;

end.
