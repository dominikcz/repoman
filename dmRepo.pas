unit dmRepo;

interface

uses
  System.SysUtils, System.Classes, System.Actions, System.Types,
  Vcl.ActnList, Vcl.Graphics,
  Models.FileInfo,
  repoHelper,
  repoHelper.CVS,
  whizaxe.vstHelper,
  whizaxe.vstHelper.Tree,
  System.ImageList,
  Vcl.ImgList,
  Vcl.Controls,
  PngImageList,
  VirtualTrees
  ;

type
  TMatchType = (mtContains, mtEndsWith, mtStartsWith);

  TRepo = class(TDataModule)
    alRepoActions: TActionList;
    alViewActions: TActionList;
    actFlatMode: TAction;
    actModifiedOnly: TAction;
    actShowIgnored: TAction;
    actRefresh: TAction;
    repoIcons: TPngImageList;
    toolbarIcons: TImageList;
    actShowUnversioned: TAction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure hndChangeRootDir(Sender: TObject);
    function  _FilterModelByPath(path: string): boolean;
    procedure refreshView(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
  private
    { Private declarations }
    FRootPath, FCurrRootPath: string;
    FFiles: TFilesList;
    FDirs: TDirsList;
    FIgnoreList: TStringList;
    FRepoHelper: IRepoHelper;
    FDirHelper: TVSTHelperTree<TDirInfo>;
    FFileListHelper: TVSTHelper<TFileInfo>;
    procedure hndFilesGetImageIndex(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure hndDirsGetImageIndex(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure hndVstFiltered(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; var Abort, Visible: boolean);
    procedure hndDirInitChildren(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure hndDirInitNode(Sender: TBaseVirtualTree; Item: TDirInfo; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure hndDirGetText(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: string);
    procedure hndOnChangeDir(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode);

    procedure PrepareIgnoreList(const dir: string);

    procedure RefreshCurrentListing;
  public
    { Public declarations }
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
  FCurrRootPath := FRootPath;
  FDirs.Reload(FRootPath);
  FRepoHelper.updateDirsState(FDirs);

  FDirHelper.TreeView.Clear;
  FDirHelper.TreeView.RootNodeCount := 1;
  RefreshCurrentListing;
  FDirHelper.TreeView.Expanded[FDirHelper.TreeView.GetFirst] := true;
end;

procedure TRepo.DataModuleCreate(Sender: TObject);
begin
  FFiles := TFilesList.Create;
  FDirs := TDirsList.Create;
  FIgnoreList := TStringList.Create;

  FFileListHelper := TVSTHelper<TFileInfo>.Create;
  FFileListHelper.OnGetImageIndex := hndFilesGetImageIndex;
  FFileListHelper.Filtered := not actShowIgnored.Checked;
  FFileListHelper.Model := FFiles;
  FFileListHelper.TreeView :=  MainForm.ViewFilesBrowser1.fileList;

  FDirHelper := TVSTHelperTree<TDirInfo>.Create;
  FDirHelper.OnInitNode := hndDirInitNode;
  FDirHelper.OnInitChildren := hndDirInitChildren;
  FDirHelper.OnGetText := hndDirGetText;
  FDirHelper.OnChange := hndOnChangeDir;
  FDirHelper.OnGetImageIndex := hndDirsGetImageIndex;
  FDirHelper.Model := FDirs;
  FDirHelper.TreeView := MainForm.ViewFilesBrowser1.dirTree;

  {$IFDEF XPS}
  FRootPath := 'c:\mccomp\NewPos2014';
  {$ELSE}
  FRootPath := 'x:\mccomp\NewPos2014';
  {$ENDIF}

  FCurrRootPath := FRootPath;

  FRepoHelper := TRepoHelperCVS.Create;
  FRepoHelper.Init(FRootPath);

  MainForm.ViewFilesBrowser1.RootPath := FRootPath;
  MainForm.ViewFilesBrowser1.OnRootChange := hndChangeRootDir;

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
  FCurrRootPath := FRootPath;
end;

procedure TRepo.hndDirGetText(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType; var CellText: string);
begin
  CellText := Item.dir;
end;

procedure TRepo.hndDirInitChildren(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode;
  var ChildCount: Cardinal);
var
  child: TDirInfo;
begin
  for child in FDirs.GetChildrenIterator(Item) do
  begin
    if _FilterModelByPath(child.FullPath) then
    begin
      Sender.AddChild(Node, child);
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

procedure TRepo.hndDirsGetImageIndex(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
begin
  if (column > 0) or not (Kind in [ikNormal, ikSelected]) then
    exit;

  if item.state = dsVersioned then
    ImageIndex := 8
  else
    ImageIndex := 9;
end;

procedure TRepo.hndFilesGetImageIndex(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; Kind: TVTImageKind;
  Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
begin
  if (column > 0) or not (Kind in [ikNormal, ikSelected]) then
    exit;

  case item.state of
    fsNormal: ImageIndex := 0;
    fsAdded: ImageIndex := 2;
    fsRemoved: ImageIndex := 6;
    fsModified: ImageIndex := 5;
    fsConflict: ImageIndex := 3;
    else
      ImageIndex := 1;
  end;
end;

procedure TRepo.hndOnChangeDir(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode);
begin
  FCurrRootPath := item.fullPath;
  RefreshCurrentListing;
end;

procedure TRepo.hndVstFiltered(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; var Abort,
  Visible: boolean);
var
  allowedStates: set of TFileState;
begin
  // ignored...
  Visible := _FilterModelByPath(item.fullPath);
  allowedStates := [fsNormal, fsAdded, fsRemoved, fsModified, fsConflict];
  // unversioned...
  if actShowUnversioned.Checked then
    Include(allowedStates, fsUnversioned);
  // modified...
  if actModifiedOnly.Checked then
    Exclude(allowedStates, fsNormal);
  Visible := Visible and (item.state in allowedStates);
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

procedure TRepo.RefreshCurrentListing;
begin
  FFiles.Reload(FCurrRootPath, actFlatMode.Checked);
  FRepoHelper.updateFilesState(FFiles);
  FFileListHelper.Filtered := (not actShowIgnored.Checked) or actModifiedOnly.Checked;
  FFileListHelper.RefreshView;
end;

procedure TRepo.refreshView(Sender: TObject);
begin
  RefreshCurrentListing;
end;

function TRepo._FilterModelByPath(path: string): boolean;
var
  i: Integer;
  s: string;
begin
  // zwracamy false aby ukyæ bie¿¹cy element
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
