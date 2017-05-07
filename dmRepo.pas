//TODO:
// - edycja plików przy porównaniu (akcje nawigacyjne, przenoszenie bloków)
// - pokazywanie ró¿nic na poziomie s³ów/znaków (w³asny highlighter?)
// ~ pokazywanie tylko ró¿nic przy porównaniu
// ~ log
// ~ graf w stylu CVS
// - dodawanie, usuwanie, update, commit, import
// - tryb git
// - code review
// - operacje asychroniczne na repo
// - annotate z szukaniem w historii
// - obs³uga git'a
// - sprawdzanie pisowni
// - BUG: powolne sortowanie: poprawiæ generics.sort lub inicjowaæ node i niech VST sortuje?
// - BUG: status plików jest czasem niepoprawny (np. dmMainFormPosBase.pas - entries.Extra?)
// - BUG: po w³¹czeniu treeOptions.SelectionOptions.toRightClickSelect na liœcie plików mo¿na klikn¹c (lewym!) przez popup zmieniaj¹c selekcjê XD
// - BUG: uzale¿nianie kolorów kolumn na grafie od column.Position jest tak samo bez sensu jak od column.Index. Przyda³by siê column.VisibleIndex.. mo¿e jest?
// - BUG: przy rysowaniu headerka w VSTHelperze gubimy ewentualne checkboxy (jak w frmBranchesList.pas)

// DONE:
// + porównanie plików
// + zewnêtrzna edycja
// + prosty annotate
// + historia z filtrami na: branch/usera/od daty/modu³
// + graf w stylu GIT

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
  VirtualTrees,
  Vcl.PlatformDefaultStyleActnCtrls,
  Vcl.ActnMan,
  Vcl.Menus,
  Vcl.ActnPopup,
  repoManConfig
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
    actShowUnversioned: TAction;
    ActionManager1: TActionManager;
    toolbarIcons: TPngImageList;
    actDiff: TAction;
    actGraph: TAction;
    actLog: TAction;
    actAnnotate: TAction;
    actAdd: TAction;
    actRemove: TAction;
    actEdit: TAction;
    popupRepoActions: TPopupActionBar;
    diff1: TMenuItem;
    graph1: TMenuItem;
    log1: TMenuItem;
    annotateblame1: TMenuItem;
    N1: TMenuItem;
    add1: TMenuItem;
    remove1: TMenuItem;
    edit1: TMenuItem;
    actHistory: TAction;
    history1: TMenuItem;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure hndChangeRootDir(Sender: TObject);
    function  _FilterModelByPath(path: string): boolean;
    procedure refreshView(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure SingleFileActionUpdate(Sender: TObject);
    procedure actAddUpdate(Sender: TObject);
    procedure actDiffExecute(Sender: TObject);
    procedure actRemoveUpdate(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure alRepoActionsExecute(Action: TBasicAction; var Handled: Boolean);
    procedure actHistoryExecute(Sender: TObject);

    function tryGetSelectedItem(out item: TFileInfo): boolean;
    procedure actAnnotateExecute(Sender: TObject);
    procedure actGraphExecute(Sender: TObject);
  private
    { Private declarations }
    FRootPath, FCurrRootPath: string;
    FFiles: TFilesList;
    FDirs: TDirsList;
    FIgnoreList: TStringList;
    FCmdResult: TStringList;
    FRepoHelper: IRepoHelper;
    FDirHelper: TVSTHelperTree<TDirInfo>;
    FFileListHelper: TVSTHelper<TFileInfo>;
    FConfig: TRepoManCfg;
    FShiftPressed: Boolean;
    function isShiftPressed: boolean;
    procedure hndFilesGetImageIndex(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure hndFilesCompareNodes(Item1, Item2: TFileInfo; Column: TColumnIndex; var Result: Integer);
    procedure hndDirsGetImageIndex(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure hndVstFiltered(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; var Abort, Visible: boolean);
    procedure hndDirInitChildren(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure hndDirInitNode(Sender: TBaseVirtualTree; Item: TDirInfo; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure hndDirGetText(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: string);
    procedure hndOnChangeDir(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode);
    
    procedure PrepareIgnoreList(const dir: string);

    procedure RefreshCurrentListing;
    function isVisible(item: TFileInfo): boolean;
  public
    { Public declarations }
    procedure CloseAllChildForms;
  end;

function Repo: TRepo;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  System.IOUtils,
  Windows,
  frmMain,
  whizaxe.vclHelper,
  whizaxe.processes,
  formManager,
  frmDiff,
  frmHistoryQuery,
  frmHistory,
  frmGraph,
  Models.logInfo;

var
  vRepo: TRepo;

const
  cIgnoreListFileName = 'ignorelist.repoman'; // DONT LOCALIZE
  cUsingCacheMsg = '*** %s: Using cache if available. Press Shift to bypass cache ***'#13#10;

function Repo: TRepo;
begin
  if not Assigned(vRepo) then
    vRepo := TRepo.Create(nil);
  Result := vRepo;
end;

procedure TRepo.actAddUpdate(Sender: TObject);
var
  item: TFileInfo;
begin
  // TODO: multiselekcja

  item := FFileListHelper.SelectedItem;
  TAction(Sender).Enabled := (item <> nil) and (item.state = fsUnversioned);
end;

procedure TRepo.actAnnotateExecute(Sender: TObject);
var
  item: TFileInfo;
  outputFileName: string;
begin
  if not tryGetSelectedItem(item) then
    exit;
  if FRepoHelper.annotateFile(item, '', outputFileName, not FShiftPressed) = 0 then
    TProcesses.ExecBatch(FConfig.ExternalEditor, '"'+outputFileName + '" "', '', 1);
end;

procedure TRepo.actDiffExecute(Sender: TObject);
var
  item: TFileInfo;
  outputFileName: string;
  diffForm: TDiffForm;
begin
  if not tryGetSelectedItem(item) then
    exit;
  if FRepoHelper.diffFile(item, outputFileName, not FShiftPressed) = 0 then
  begin
    if FConfig.UseExternalDiff then
      TProcesses.ExecBatch(FConfig.ExternalDiffPath, '"'+outputFileName + '" "' + item.fullPath+'"', '', 1)
    else
    begin
      FCmdResult.LoadFromFile(outputFileName);
      diffForm := TDiffForm.Create(nil);
      diffForm.Load(outputFileName, item.fullPath);
      forms.add(diffForm, 'Diff '+ExtractFileName(outputFileName)).Show;
    end;

  end;
end;

procedure TRepo.actEditExecute(Sender: TObject);
var
  item: TFileInfo;
begin
  if not tryGetSelectedItem(item) then
    exit;

  if FConfig.ExternalEditor <> '' then
    TProcesses.ExecBatch(FConfig.ExternalEditor, '"'+item.fullPath+'"', '', 1, false);
end;

procedure TRepo.actGraphExecute(Sender: TObject);
var
  item: TFileInfo;
  graphForm: TGraphForm;
  logNodes: TLogNodes;
begin
  if not tryGetSelectedItem(item) then
    exit;
  if FRepoHelper.logFile(item, logNodes, not FShiftPressed) = 0 then
  begin
    graphForm := TGraphForm.Create(nil);
    graphForm.Execute(logNodes);
    forms.add(graphForm, 'Graph '+item.fileName).Show;
  end;
end;

procedure TRepo.actHistoryExecute(Sender: TObject);
var
  hist: TRepoHistory;
  params: THistoryParams;
  histForm: THistoryForm;
begin
  if histDialog.Execute(params) then
  begin
    if FRepoHelper.getHistory(params.date, params.userName, params.branch, hist, not FShiftPressed) <> 0 then
      exit;
    histForm := THistoryForm.Create(nil);
    forms.Add(histForm, 'History :: '+params.AsString);
    histForm.Execute(hist);
  end;
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

procedure TRepo.actRemoveUpdate(Sender: TObject);
var
  item: TFileInfo;
begin
  // TODO: multiselekcja

  item := FFileListHelper.SelectedItem;
  TAction(Sender).Enabled := (item <> nil) and (item.state = fsUnversioned);
end;

procedure TRepo.alRepoActionsExecute(Action: TBasicAction; var Handled: Boolean);
begin
  FShiftPressed := isShiftPressed;
  if not FShiftPressed then
    MainForm.ViewFilesBrowser1.AddToLog(Format(cUsingCacheMsg, [TAction(Action).Caption]));
end;

procedure TRepo.CloseAllChildForms;
begin
  forms.Clear;
end;

procedure TRepo.DataModuleCreate(Sender: TObject);
var
  lAction: TContainedAction;
  lShortCut: TShortCut;
begin
  FConfig := TRepoManCfg.Create;

  FFiles := TFilesList.Create;
  FDirs := TDirsList.Create;
  FIgnoreList := TStringList.Create;

  FFileListHelper := TVSTHelper<TFileInfo>.Create;
  FFileListHelper.OnGetImageIndex := hndFilesGetImageIndex;
  FFileListHelper.OnCompareNodes := hndFilesCompareNodes;

  FFileListHelper.ZebraColor := clNone;

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
  FRepoHelper.OnLogging := procedure(buff: string)
  begin
    with MainForm.ViewFilesBrowser1 do
    begin
      AddToLog(buff);
    end;
  end;
  FRepoHelper.Init(FRootPath);

  MainForm.ViewFilesBrowser1.RootPath := FRootPath;
  MainForm.ViewFilesBrowser1.OnRootChange := hndChangeRootDir;

  PrepareIgnoreList(ExtractFileDir(paramStr(0)));
  FFileListHelper.OnFiltered := hndVstFiltered;

  FCmdResult := TStringList.Create;

  for lAction in alRepoActions do
    if lAction.ShortCut <> 0 then
    begin
      lShortCut := lAction.ShortCut + scShift;
      lAction.SecondaryShortCuts.Add(ShortCutToText(lShortCut))
    end;

end;

procedure TRepo.DataModuleDestroy(Sender: TObject);
begin
  FDirs.Free;
  FFiles.Free;

  FFileListHelper.Free;
  FDirHelper.Free;

  FIgnoreList.Free;

  FCmdResult.Free;
  FConfig.Free;
end;

procedure TRepo.SingleFileActionUpdate(Sender: TObject);
var
  item: TFileInfo;
begin
  item := FFileListHelper.SelectedItem;
  TAction(Sender).Enabled := (item <> nil) and (item.state <> fsUnversioned);
end;

function TRepo.tryGetSelectedItem(out item: TFileInfo): boolean;
begin
  item := FFileListHelper.SelectedItem;
  result := Assigned(item);
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

procedure TRepo.hndFilesCompareNodes(Item1, Item2: TFileInfo; Column: TColumnIndex; var Result: Integer);
begin
  case Column of
    0: Result := AnsiCompareStr(item1.fileName, item2.fileName);
    1: Result := AnsiCompareStr(item1.ext, item2.ext);
    2: Result := AnsiCompareStr(item1.fullPath, item2.fullPath);
    3: Result := Ord(item1.state) - Ord(item2.state);
    4: Result := AnsiCompareStr(item1.revision, item2.revision);
    5: Result := AnsiCompareStr(item1.branch, item2.branch);
  end;
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
begin
  Visible := isVisible(item);
end;

function TRepo.isVisible(item: TFileInfo): boolean;
var
  allowedStates: set of TFileState;
begin
  // ignored...
  Result := _FilterModelByPath(item.fullPath);
  allowedStates := [fsNormal, fsAdded, fsRemoved, fsModified, fsConflict];
  // unversioned...
  if actShowUnversioned.Checked then
    Include(allowedStates, fsUnversioned);
  // modified...
  if actModifiedOnly.Checked and (not actShowIgnored.Checked) then
    Exclude(allowedStates, fsNormal);
  Result := Result and (item.state in allowedStates);
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

function TRepo.isShiftPressed: boolean;
var
  virtKey: SmallInt;
begin
  virtKey := GetKeyState(VK_LSHIFT);
  result := (virtKey and $8000) <> 0;
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
