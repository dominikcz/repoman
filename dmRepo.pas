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
//    FDirHelper: TVSTHelper<TDirInfo>;
    FFileListHelper: TVSTHelper<TFileInfo>;
    procedure hndVstFiltered(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; var Abort, Visible: boolean);
    procedure RebuildDirTree;
    procedure dirTreeInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure dirTreeInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
      var InitialStates: TVirtualNodeInitStates);
    procedure dirTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure dirTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: string);
    function HasChildren(const Folder: string): Boolean;

  public
    { Public declarations }
    procedure ReloadFiles(rootPath: string);
    procedure hndOnChangeDir(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode);
    procedure hndOnChangeDir2(Sender: TBaseVirtualTree; Node: PVirtualNode);
  end;

function Repo: TRepo;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  frmMain,
  whizaxe.vclHelper;

var
  vRepo: TRepo;

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

//  FDirHelper := TVSTHelperTree<TDirInfo>.Create;
//  FDirHelper.Model := FDirs;
//  FDirHelper.TreeView := MainForm.ViewFilesBrowser1.dirTree;
//  FDirHelper.OnChange := hndOnChangeDir;
  MainForm.ViewFilesBrowser1.dirTree.OnInitNode := dirTreeInitNode;
  MainForm.ViewFilesBrowser1.dirTree.OnInitChildren := dirTreeInitChildren;
  MainForm.ViewFilesBrowser1.dirTree.OnFreeNode := dirTreeFreeNode;
  MainForm.ViewFilesBrowser1.dirTree.OnGetText := dirTreeGetText;
  MainForm.ViewFilesBrowser1.dirTree.OnChange := hndOnChangeDir2;

  FRootPath := 'c:\mccomp\NewPos2014';
  MainForm.ViewFilesBrowser1.RootPath := FRootPath;
  MainForm.ViewFilesBrowser1.OnRootChange := hndChangeRootDir;

  FIgnoreList := TStringList.Create;
  fileName := FRootPath + '\ignorelist.repoman';
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
  end;

  FFileListHelper.OnFiltered := hndVstFiltered;
  RebuildDirTree;
end;

procedure TRepo.DataModuleDestroy(Sender: TObject);
begin
  FDirs.Free;
  FFiles.Free;

  FFileListHelper.Free;
//  FDirHelper.Free;

  FIgnoreList.Free;
end;

procedure TRepo.dirTreeFreeNode(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  Finalize(Data^); // Clear string data.
end;

procedure TRepo.dirTreeGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  CellText := data.dir;
end;

procedure TRepo.dirTreeInitChildren(Sender: TBaseVirtualTree; Node: PVirtualNode; var ChildCount: Cardinal);
var
  Data,
  ChildData: PShellObjectData;
  SR: TSearchRec;
  ChildNode: PVirtualNode;
  NewName: String;
begin
  Data := Sender.GetNodeData(Node);
  if FindFirst(IncludeTrailingBackslash(Data.FullPath) + '*', faDirectory, SR) = 0 then
  begin
    try
      repeat
        if (SR.Name <> '.') and (SR.Name <> '..') then
        begin
          NewName := IncludeTrailingBackslash(Data.FullPath) + SR.Name;
          if (SR.Attr and faDirectory <> 0) and _FilterModel(Data.FullPath) then
          begin
            ChildNode := Sender.AddChild(Node);
            ChildData := Sender.GetNodeData(ChildNode);
            ChildData.FullPath := NewName;
            ChildData.dir := SR.Name;

            Sender.ValidateNode(Node, False);
          end;
        end;
      until FindNext(SR) <> 0;
      ChildCount := Sender.ChildCount[Node];

      // finally sort node
      if ChildCount > 0 then
        Sender.Sort(Node, 0, TVirtualStringTree(Sender).Header.SortDirection, False);
    finally
      FindClose(SR);
    end;
  end;

end;

procedure TRepo.dirTreeInitNode(Sender: TBaseVirtualTree; ParentNode, Node: PVirtualNode;
  var InitialStates: TVirtualNodeInitStates);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  if (ParentNode = nil) then
  begin
    Data.fullPath := FRootPath;
    data.dir := 'root';
  end;
  if HasChildren(Data.FullPath) then
    Include(InitialStates, ivsHasChildren);
end;

function TRepo.HasChildren(const Folder: string): Boolean;
var
  SR: TSearchRec;

begin
  Result := FindFirst(IncludeTrailingBackslash(Folder) + '*.*', faReadOnly or faHidden or faSysFile or faArchive, SR) = 0;
  if Result then
    FindClose(SR);
end;

procedure TRepo.hndChangeRootDir(Sender: TObject);
begin
  FRootPath := MainForm.ViewFilesBrowser1.RootPath;
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

procedure TRepo.hndOnChangeDir2(Sender: TBaseVirtualTree; Node: PVirtualNode);
var
  Data: PShellObjectData;
begin
  Data := Sender.GetNodeData(Node);
  FFiles.Reload(data.fullPath, actFlatMode.Checked);
  FFileListHelper.RefreshView;
end;

procedure TRepo.hndVstFiltered(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; var Abort,
  Visible: boolean);
begin
  Visible := hndFilterModel(item);
end;

procedure TRepo.RebuildDirTree;
begin
  MainForm.ViewFilesBrowser1.dirTree.NodeDataSize := SizeOf(TShellObjectData);
  MainForm.ViewFilesBrowser1.dirTree.RootNodeCount := 1;  // sztuczny root
end;

procedure TRepo.refreshView(Sender: TObject);
begin
  FDirs.Reload(FRootPath);
  RebuildDirTree;
  //  FDirHelper.RefreshView;

  FFiles.Reload(FRootPath, actFlatMode.Checked);
  FFileListHelper.RefreshView;
end;

procedure TRepo.ReloadFiles(rootPath: string);
begin

end;

function TRepo._FilterModel(path: string): boolean;
var
  i: Integer;
  s: string;
begin
  result := true;
  if actShowIgnored.Checked then
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
