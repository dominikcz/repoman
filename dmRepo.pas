//TODO:
// - obs³uga FIgnoreList z poziomu Commit
// - dodawanie, usuwanie, update, commit, import
// - code review
// - edycja plików przy porównaniu (akcje nawigacyjne, przenoszenie bloków)
// - pokazywanie ró¿nic na poziomie s³ów/znaków (w³asny highlighter/markup?)
// ~ pokazywanie tylko ró¿nic przy porównaniu
// ~ log
// - tryb git
// - trzeba za³o¿yæ watchera na plikach do wykrywania zmian i czêœciowej reinicjalizacji CVS/plików, na razie trzeba nacisn¹æ Ctrl+F5/F5
// - operacje asychroniczne na repo i mo¿liwoœæ przerwania
// - annotate z szukaniem w historii
// - obs³uga git'a
// - sprawdzanie pisowni
// - zabezpieczenie plików (dla GIT) przed omy³kow¹ modyfikacj¹ coœ jak .#* w CVS na zmodyfikowanych plikach?
// - BUG: powolne sortowanie: poprawiæ generics.sort lub inicjowaæ node i niech VST sortuje?
// - BUG: po w³¹czeniu treeOptions.SelectionOptions.toRightClickSelect na liœcie plików mo¿na klikn¹c (lewym!) przez popup zmieniaj¹c selekcjê XD
// - BUG: uzale¿nianie kolorów kolumn na grafie od column.Position jest tak samo bez sensu jak od column.Index. Przyda³by siê column.VisibleIndex.. mo¿e jest?
// - BUG: przy rysowaniu headerka w VSTHelperze gubimy ewentualne checkboxy (jak w frmBranchesList.pas)
// - BUG?: do przemyœlenia graph w CVS pokazywa³ branche jako dzieci, podczas gdy tak naprawdê to merge.
//      Poza tym miejscami jest niespójnie: nie ma ani parenta ani merge... np. whizaxe.common - branch PROGRESS

// DONE:
// + porównanie plików
// + zewnêtrzna edycja
// + prosty annotate
// + historia z filtrami na: branch/usera/od daty/modu³
// + graf w stylu GIT
// + graf w stylu CVS
// + BUG: status plików jest czasem niepoprawny (np. dmMainFormPosBase.pas - entries.Extra?)

unit dmRepo;

interface

uses
  Vcl.Forms,
  System.SysUtils, System.Classes, System.Actions, System.Types,
  Vcl.ActnList, Vcl.Graphics,
  Generics.Collections,
  dmCommonResources,
  Models.IgnoreList,
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
  TRepo = class(TDataModule)
    alRepoActions: TActionList;
    ActionManager1: TActionManager;
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
    actUpdateSelected: TAction;
    actCommitSelected: TAction;
    actUpdateAll: TAction;
    actUpdateClean: TAction;
    actCommitAll: TAction;
    actImport: TAction;
    update1: TMenuItem;
    commit1: TMenuItem;
    N2: TMenuItem;
    updateall1: TMenuItem;
    cleancopy1: TMenuItem;
    commitall1: TMenuItem;
    import1: TMenuItem;
    actStop: TAction;
    popupDirsActions: TPopupActionBar;
    MenuItem9: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem16: TMenuItem;
    actFlatMode: TAction;
    actModifiedOnly: TAction;
    actShowUnversioned: TAction;
    actShowIgnored: TAction;
    actRefresh: TAction;
    popupRepoActionsSmall: TPopupActionBar;
    MenuItem14: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem19: TMenuItem;
    N3: TMenuItem;
    actIgnore: TAction;
    addtoignored1: TMenuItem;
    addtoignored2: TMenuItem;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure hndChangeRootDir(Sender: TObject);
    function  _FilterModelByPath(path: string; const showIgnored: boolean): boolean;
    procedure refreshView(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure SingleFileActionUpdate(Sender: TObject);
    procedure MultiSelectActionUpdate(Sender: TObject);
    procedure actAddUpdate(Sender: TObject);
    procedure actDiffExecute(Sender: TObject);
    procedure actRemoveUpdate(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure alRepoActionsExecute(Action: TBasicAction; var Handled: Boolean);
    procedure actHistoryExecute(Sender: TObject);

    function tryGetSelectedItem(out item: TFileInfo): boolean;
    procedure actAnnotateExecute(Sender: TObject);
    procedure actGraphExecute(Sender: TObject);
    procedure actUpdateSelectedExecute(Sender: TObject);
    procedure actCommitSelectedUpdate(Sender: TObject);
    procedure actCommitSelectedExecute(Sender: TObject);
    procedure actUpdateAllExecute(Sender: TObject);
    procedure actUpdateCleanExecute(Sender: TObject);
    procedure actCommitAllExecute(Sender: TObject);
    procedure actImportExecute(Sender: TObject);
    procedure actLogExecute(Sender: TObject);
    procedure actIgnoreExecute(Sender: TObject);
  private
    { Private declarations }
    FRootPath, FCurrRootPath: string;
    FFiles: TFilesList;
    FDirs: TDirsList;
    FIgnoreList: TIgnoreList;
    FCmdResult: TStringList;
    FRepoHelper: IRepoHelper;
    FVstDirHelper: TVSTHelperTree<TDirInfo>;
    FVstFileListHelper: TVSTHelper<TFileInfo>;
    FConfig: TRepoManCfg;
    FStagedFiles: TStagedFileList;
    FShiftPressed: Boolean;

    function isShiftPressed: boolean;
    function isAltPressed: boolean;
    function isCtrlPressed: boolean;
    procedure hndFilesGetImageIndex(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure hndFilesCompareNodes(Item1, Item2: TFileInfo; Column: TColumnIndex; var Result: Integer);
    procedure hndDirsGetImageIndex(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
    procedure hndVstFiltered(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; var Abort, Visible: boolean);
    procedure hndDirInitChildren(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; var ChildCount: Cardinal);
    procedure hndDirInitNode(Sender: TBaseVirtualTree; Item: TDirInfo; ParentNode, Node: PVirtualNode; var InitialStates: TVirtualNodeInitStates);
    procedure hndDirGetText(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: string);

    procedure hndGetAvailableFiles(out list: TFilesList; const allowedStates: TFileStates);
    procedure hndGetStagedFiles(out list: TFilesList);
    procedure hndAddToIgnored(const mask: string);
    procedure hndOnGetIgnorePreview(filter: TStrings; out list: TFilesList);

    procedure hndOnChangeDir(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode);

    procedure hndGetAnnotate(AFilename, ARevision: string; out annFileName: string);

    procedure RefreshCurrentListing;
    function getAllowedStates: TFileStates;
    function doIsVisible(item: TFileInfo; allowedStates: TFileStates): boolean;
    function isVisible(item: TFileInfo): boolean;
    function ExecDefaultAction(AValue: boolean): boolean;
    procedure DoActUpdate(ACleanCopy: boolean);
    procedure doAddToIgnoreExecute(list: TObjectList<TFileInfo>);

    procedure backupFile(fileInfo: TFileInfo);
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
  frmBlame,
  Models.logInfo,
  frmCommit,
  frmAddtoIgnored;

var
  vRepo: TRepo;

const
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

  item := FVstFileListHelper.SelectedItem;
  TAction(Sender).Enabled := (item <> nil) and (item.state = fsUnversioned);
end;

procedure TRepo.actAnnotateExecute(Sender: TObject);
var
  item: TFileInfo;
  outputFileName: string;
begin
  {$IFDEF ANNOTATE_TEST}
    FFiles.tryToFind('c:\mccomp\NewPos2014\Whizaxe\whizaxe.common.pas', item);
  {$ELSE}
  if not tryGetSelectedItem(item) then
    exit;
  {$ENDIF}
  if FRepoHelper.annotateFile(item, '', outputFileName, not FShiftPressed) = 0 then
  begin
    if ExecDefaultAction(FConfig.UseExternalAnnotateEditor) then
      TProcesses.ExecBatch(FConfig.ExternalEditor, '"'+outputFileName + '" "', '', 1)
    else
    begin
      blameForm := TBlameForm.Create(nil);
      blameForm.OnGetAnnotate := hndGetAnnotate;
      blameForm.Load(item.fullPath, outputFileName, item.revision);

      forms.add(blameForm, 'Blame '+ExtractFileName(outputFileName)).Show;
    end;
  end;
end;

procedure TRepo.actCommitAllExecute(Sender: TObject);
var
  commitForm: TFormCommit;
  lStagedFiles: TFilesList;
  allowedStates: TFileStates;
begin
  commitForm := TFormCommit.Create(nil);
  try
    FStagedFiles.Load(FFiles);
    commitForm.OnGetAvailableFiles := hndGetAvailableFiles;
    commitForm.OnGetStagedFiles := hndGetStagedFiles;
    commitForm.OnAddToIgnored := hndAddToIgnored;

    if commitForm.Execute then
      FRepoHelper.commit(lStagedFiles);
  finally
    FStagedFiles.Save;
    commitForm.Free;
  end;
end;

procedure TRepo.actCommitSelectedExecute(Sender: TObject);
begin
//
end;

procedure TRepo.actCommitSelectedUpdate(Sender: TObject);
begin
//
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
    if ExecDefaultAction(FConfig.UseExternalDiff) then
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

procedure TRepo.actIgnoreExecute(Sender: TObject);
begin
  doAddToIgnoreExecute(FVstFileListHelper.SelectedItems);
end;

procedure TRepo.actImportExecute(Sender: TObject);
begin
//
end;

procedure TRepo.actLogExecute(Sender: TObject);
begin
//
end;

procedure TRepo.actRefreshExecute(Sender: TObject);
begin
  FCurrRootPath := FRootPath;
  FDirs.Reload(FRootPath);
  if isCtrlPressed then
    FRepoHelper.Init(FRootPath);

  FRepoHelper.updateDirsState(FDirs);

  FVstDirHelper.TreeView.Clear;
  FVstDirHelper.TreeView.RootNodeCount := 1;
  RefreshCurrentListing;
  FVstDirHelper.TreeView.Expanded[FVstDirHelper.TreeView.GetFirst] := true;
end;

procedure TRepo.actRemoveUpdate(Sender: TObject);
var
  item: TFileInfo;
begin
  // TODO: multiselekcja

  item := FVstFileListHelper.SelectedItem;
  TAction(Sender).Enabled := (item <> nil) and (item.state = fsNormal);
end;

procedure TRepo.actUpdateAllExecute(Sender: TObject);
begin
  FRepoHelper.updateAll(false);
end;

procedure TRepo.actUpdateCleanExecute(Sender: TObject);
begin
  DoActUpdate(true);
end;

procedure TRepo.actUpdateSelectedExecute(Sender: TObject);
begin
  DoActUpdate(false);
end;

procedure TRepo.alRepoActionsExecute(Action: TBasicAction; var Handled: Boolean);
begin
  FShiftPressed := isShiftPressed;
  if (not FShiftPressed) and (TAction(Action).Category = 'repo') then
    MainForm.repoBrowser.AddToLog(Format(cUsingCacheMsg, [TAction(Action).Caption]));
end;

procedure TRepo.backupFile(fileInfo: TFileInfo);
var
  path: string;
begin
  path := fileInfo.path + '.#'+fileInfo.fileName+'.'+fileInfo.revision;
  RenameFile(fileInfo.fullPath, path);
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
  FIgnoreList := TIgnoreList.Create;

  FVstFileListHelper := TVSTHelper<TFileInfo>.Create;
  FVstFileListHelper.OnGetImageIndex := hndFilesGetImageIndex;
  FVstFileListHelper.OnCompareNodes := hndFilesCompareNodes;

  FVstFileListHelper.ZebraColor := clNone;

  FVstFileListHelper.Filtered := not actShowIgnored.Checked;
  FVstFileListHelper.Model := FFiles;
  FVstFileListHelper.TreeView :=  MainForm.repoBrowser.fileList;

  FVstDirHelper := TVSTHelperTree<TDirInfo>.Create;
  FVstDirHelper.OnInitNode := hndDirInitNode;
  FVstDirHelper.OnInitChildren := hndDirInitChildren;
  FVstDirHelper.OnGetText := hndDirGetText;
  FVstDirHelper.OnChange := hndOnChangeDir;
  FVstDirHelper.OnGetImageIndex := hndDirsGetImageIndex;
  FVstDirHelper.Model := FDirs;
  FVstDirHelper.TreeView := MainForm.repoBrowser.dirTree;

  FRootPath := FConfig.RootPath;
  FCurrRootPath := FRootPath;
  FIgnoreList.Load(FRootPath);

  FRepoHelper := TRepoHelperCVS.Create;
  FRepoHelper.OnLogging := procedure(buff: string)
  begin
    with MainForm.repoBrowser do
    begin
      AddToLog(buff);
    end;
  end;
  FRepoHelper.Init(FRootPath);

  MainForm.repoBrowser.RootPath := FRootPath;
  MainForm.repoBrowser.OnRootChange := hndChangeRootDir;

  FIgnoreList.Load;
  FVstFileListHelper.OnFiltered := hndVstFiltered;

  FCmdResult := TStringList.Create;

  FStagedFiles := TStagedFileList.Create;

  for lAction in alRepoActions do
  begin
    if lAction.Hint = '' then
      lAction.Hint := lAction.Caption;
    if lAction.ShortCut <> 0 then
    begin
      lAction.SecondaryShortCuts.Add(ShortCutToText(lAction.ShortCut + scShift));
      lAction.SecondaryShortCuts.Add(ShortCutToText(lAction.ShortCut + scAlt));
      lAction.SecondaryShortCuts.Add(ShortCutToText(lAction.ShortCut + scShift + scAlt));
    end;
  end;

  if not FConfig.ShowToolbarCaptions then
    ActionManager1.ActionBars[0].Items.CaptionOptions := coNone;
end;

procedure TRepo.DataModuleDestroy(Sender: TObject);
begin
  FDirs.Free;
  FFiles.Free;

  FVstFileListHelper.Free;
  FVstDirHelper.Free;

  FIgnoreList.Free;

  FCmdResult.Free;
  FConfig.Free;

  FStagedFiles.Free;
end;

procedure TRepo.DoActUpdate(ACleanCopy: boolean);
begin
  if MainForm.ActiveControl = Mainform.repoBrowser.dirTree then
    FRepoHelper.updateDir(FVstDirHelper.SelectedItem, ACleanCopy)
  else
    FRepoHelper.updateFiles(TFilesList(FVstFileListHelper.SelectedItems), ACleanCopy);
end;

procedure TRepo.doAddToIgnoreExecute(list: TObjectList<TFileInfo>);
var
  AddIgnoredForm: TAddToIgnoreForm;
  filter: string;
  item: TFileInfo;
begin
  AddIgnoredForm := TAddToIgnoreForm.Create(nil);
  try
    AddIgnoredForm.mPatterns.Lines.BeginUpdate;
    AddIgnoredForm.mPatterns.Clear;
    for item in list do
      AddIgnoredForm.mPatterns.Lines.Add(item.fullPath);
    AddIgnoredForm.OnGetPreview := hndOnGetIgnorePreview;
    if AddIgnoredForm.ShowModal = mrOk then
    begin
      FIgnoreList.AddStrings(AddIgnoredForm.mPatterns.Lines);
      FIgnoreList.Compile;
      FIgnoreList.Save;
    end;
  finally
    AddIgnoredForm.Free;
  end;
end;

function TRepo.doIsVisible(item: TFileInfo; allowedStates: TFileStates): boolean;
begin
  // ignored...
  if not (fsIgnored in allowedStates) then
    Result := FIgnoreList.Allows(item.fullPath);
  Result := Result and (item.state in allowedStates);
end;

function TRepo.ExecDefaultAction(AValue: boolean): boolean;
begin
  if isAltPressed then result := not AValue
  else result := AValue;
end;

function TRepo.getAllowedStates: TFileStates;
begin
  Result := [fsNormal, fsAdded, fsRemoved, fsModified, fsConflict];
  // unversioned...
  if actShowUnversioned.Checked then
    Include(Result, fsUnversioned);
  // modified...
  if actModifiedOnly.Checked and (not actShowIgnored.Checked) then
    Exclude(Result, fsNormal);
  // ignored...
  if actShowIgnored.Checked then
    include(Result, fsIgnored);
end;

procedure TRepo.SingleFileActionUpdate(Sender: TObject);
var
  item: TFileInfo;
begin
  item := FVstFileListHelper.SelectedItem;
  TAction(Sender).Enabled := (item <> nil) and (item.state <> fsUnversioned);
end;

function TRepo.tryGetSelectedItem(out item: TFileInfo): boolean;
begin
  item := FVstFileListHelper.SelectedItem;
  result := Assigned(item);
end;

procedure TRepo.hndAddToIgnored(const mask: string);
begin
  FIgnoreList.Add(mask);
end;

procedure TRepo.hndChangeRootDir(Sender: TObject);
begin
  FRootPath := MainForm.repoBrowser.RootPath;
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
  allowedSatates: TFileStates;
begin
  allowedSatates := getAllowedStates;
  for child in FDirs.GetChildrenIterator(Item) do
  begin
    if FIgnoreList.Allows(child.fullPath) then
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

procedure TRepo.hndGetAnnotate(AFilename, ARevision: string; out annFileName: string);
var
  item: TFileInfo;
  rev: string;
begin
  item := TFileInfo.Create(AFileName, FRootPath, fsNormal);
  if not FRepoHelper.tryGetPrevRevision(ARevision, rev) then
  begin
    annFileName := '';
    exit;
  end;
  if FRepoHelper.annotateFile(item, rev, annFileName, true) <> 0 then
    annFileName := '';
  item.Free;
end;

procedure TRepo.hndGetAvailableFiles(out list: TFilesList; const allowedStates: TFileStates);
var
  item: TFileInfo;
begin
  list := TFilesList.Create(false);
  for item in FFiles do
    if doIsVisible(item, allowedStates) and (not FStagedFiles.contains(item.fullPath)) then
      list.Add(item);
end;

procedure TRepo.hndGetStagedFiles(out list: TFilesList);
begin
  list := FStagedFiles;
end;

procedure TRepo.hndOnChangeDir(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode);
begin
  FCurrRootPath := item.fullPath;
  RefreshCurrentListing;
end;

procedure TRepo.hndOnGetIgnorePreview(filter: TStrings; out list: TFilesList);
var
  item: TFileInfo;
  myIgnore: TIgnoreList;
  i: Integer;
begin
  myIgnore := TIgnoreList.Create;
  try
    myIgnore.AddStrings(filter);
    myIgnore.Compile;
    list := TFilesList.Create(false);
    i := 0;
    for item in FFiles do
    begin
      if not myIgnore.Allows(item.fullPath) then
      begin
        inc(i);
        list.Add(item);
      end;
      if i >= 100 then
        exit;
    end;
  finally
    myIgnore.Free;
  end;
end;

procedure TRepo.hndVstFiltered(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; var Abort,
  Visible: boolean);
begin
  Visible := IsVisible(item);
end;

function TRepo.isVisible(item: TFileInfo): boolean;
begin
  result := doIsVisible(item, getAllowedStates);
end;

procedure TRepo.MultiSelectActionUpdate(Sender: TObject);
var
  tree: TVirtualStringTree;
begin
  if not (Screen.ActiveForm.ActiveControl is TVirtualStringTree) then
    exit;
  tree := TVirtualStringTree(Screen.ActiveForm.ActiveControl);
  TAction(Sender).Enabled := tree.SelectedCount > 0;
end;

procedure TRepo.RefreshCurrentListing;
begin
  FFiles.Reload(FCurrRootPath, actFlatMode.Checked);
  FRepoHelper.updateFilesState(FFiles);
  FVstFileListHelper.Filtered := (not actShowIgnored.Checked) or actModifiedOnly.Checked;
  FVstFileListHelper.RefreshView;
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

function TRepo.isAltPressed: boolean;
var
  virtKey: SmallInt;
begin
  virtKey := GetKeyState(VK_MENU);
  result := (virtKey and $8000) <> 0;
end;

function TRepo.isCtrlPressed: boolean;
var
  virtKey: SmallInt;
begin
  virtKey := GetKeyState(VK_CONTROL);
  result := (virtKey and $8000) <> 0;
end;

function TRepo._FilterModelByPath(path: string; const showIgnored: boolean): boolean;
begin
  // zwracamy false aby ukyæ bie¿¹cy element
  result := true;
  if showIgnored then
    exit;
  result := FIgnoreList.Allows(path);
end;

initialization
  vRepo := nil;

finalization
  vRepo.Free;

end.
