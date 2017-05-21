unit frmCommit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, PngSpeedButton, VirtualTrees, Vcl.ExtCtrls,
  System.Actions, Vcl.ActnList, PngBitBtn, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.PlatformDefaultStyleActnCtrls,
  Models.FileInfo,
  whizaxe.VSTHelper, Vcl.Menus, Vcl.ActnPopup;

type
  TGetAvailableFilesListEvent = procedure(out list: TFilesList; const allowedStates: TFileStates) of object;
  TGetStagedFilesListEvent = procedure(out list: TFilesList) of object;
  TAddToIgnoredEvent = procedure(const mask: string) of object;

  TFormCommit = class(TForm)
    alStaggingActions: TActionList;
    actUnstageSelected: TAction;
    actUnstageAll: TAction;
    actStageSelected: TAction;
    actStageAll: TAction;
    actCommit: TAction;
    leftPanel: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    pnlUnstaged: TPanel;
    vstAvailableFiles: TVirtualStringTree;
    pnlStaged: TPanel;
    stagingPanel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    PngSpeedButton1: TPngSpeedButton;
    PngSpeedButton2: TPngSpeedButton;
    PngSpeedButton3: TPngSpeedButton;
    PngSpeedButton4: TPngSpeedButton;
    vstStagedFiles: TVirtualStringTree;
    pnlCommit: TPanel;
    commitMsg: TMemo;
    cbPrevMessages: TComboBox;
    PngBitBtn1: TPngBitBtn;
    alFilterActions: TActionList;
    actModifiedOnly: TAction;
    actShowUnversioned: TAction;
    actShowIgnored: TAction;
    actRefresh: TAction;
    ActionManager1: TActionManager;
    ActionToolBar2: TActionToolBar;
    actAddToIgnored: TAction;
    PopupActionBar1: TPopupActionBar;
    addtoignored1: TMenuItem;
    procedure actUnstageSelectedExecute(Sender: TObject);
    procedure actUnstageAllExecute(Sender: TObject);
    procedure actStageSelectedExecute(Sender: TObject);
    procedure actCommitExecute(Sender: TObject);
    procedure actStageAllExecute(Sender: TObject);
    procedure actUnstageSelectedUpdate(Sender: TObject);
    procedure actStageSelectedUpdate(Sender: TObject);
    procedure actCommitUpdate(Sender: TObject);
    procedure cbPrevMessagesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure refreshAvailable(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actAddToIgnoredUpdate(Sender: TObject);
  private
    { Private declarations }
    FVstAvailableHelper: TVSTHelper<TFileInfo>;
    FVstStagedHelper: TVSTHelper<TFileInfo>;
    FOnGetAvailableFiles: TGetAvailableFilesListEvent;
    FOnGetStagedFiles: TGetStagedFilesListEvent;
    FAllowedStates: TFileStates;
    FOnAddToIgnored: TAddToIgnoredEvent;
    procedure Refresh;
    procedure hndCompareNodes(Item1, Item2: TFileInfo; Column: TColumnIndex; var Result: Integer);
    function getAllowedStates: TFileStates;
    procedure hndGetImageIndex(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);

  public
    { Public declarations }
    function Execute: boolean;
    property OnGetAvailableFiles: TGetAvailableFilesListEvent read FOnGetAvailableFiles write FOnGetAvailableFiles;
    property OnGetStagedFiles: TGetStagedFilesListEvent read FOnGetStagedFiles write FOnGetStagedFiles;
    property OnAddToIgnored: TAddToIgnoredEvent read FOnAddToIgnored write FOnAddToIgnored;
  end;

implementation

{$R *.dfm}

uses
  dmCommonResources,
  Generics.Collections;

procedure TFormCommit.actAddToIgnoredUpdate(Sender: TObject);
begin
  actAddToIgnored.Enabled := vstAvailableFiles.SelectedCount > 0;
end;

procedure TFormCommit.actCommitExecute(Sender: TObject);
begin
//
end;

procedure TFormCommit.actCommitUpdate(Sender: TObject);
begin
  actCommit.Enabled := (trim(commitMsg.Text) <> '') and (FVstStagedHelper.SelectedCount > 0);
end;

procedure TFormCommit.actRefreshExecute(Sender: TObject);
begin
//  OnGetAvailableFiles
end;

procedure TFormCommit.actStageAllExecute(Sender: TObject);
begin
  FVstStagedHelper.Model.AddRange(FVstAvailableHelper.Model);
  FVstAvailableHelper.Model.Clear;
  Refresh;
end;

procedure TFormCommit.actStageSelectedExecute(Sender: TObject);
var
  tmp: TFilesList;
  item: TFileInfo;
begin
  tmp := TFilesList(FVstAvailableHelper.SelectedItems);
  FVstStagedHelper.Model.AddRange(tmp);
  for item in tmp do
    FVstAvailableHelper.Model.Remove(item);
  Refresh;
end;

procedure TFormCommit.actStageSelectedUpdate(Sender: TObject);
begin
  actStageSelected.Enabled := FVstAvailableHelper.SelectedCount > 0;
end;

procedure TFormCommit.actUnstageAllExecute(Sender: TObject);
begin
  FVstAvailableHelper.Model.AddRange(FVstStagedHelper.Model);
  FVstStagedHelper.Model.Clear;
  Refresh;
end;

procedure TFormCommit.actUnstageSelectedExecute(Sender: TObject);
var
  tmp: TFilesList;
  item: TFileInfo;
begin
  tmp := TFilesList(FVstStagedHelper.SelectedItems);
  FVstAvailableHelper.Model.AddRange(tmp);
  for item in tmp do
    FVstStagedHelper.Model.Remove(item);
  Refresh;
end;

procedure TFormCommit.actUnstageSelectedUpdate(Sender: TObject);
begin
  actUnstageSelected.Enabled := FVstStagedHelper.SelectedCount > 0;
end;

procedure TFormCommit.cbPrevMessagesChange(Sender: TObject);
begin
  commitMsg.Text := cbPrevMessages.Text;
end;


function TFormCommit.Execute: boolean;
var
  availableList: TFilesList;
  stagedList: TFilesList;
  allowedStates: TFileStates;
begin
  if not Assigned(OnGetAvailableFiles) then
    raise Exception.Create('Event handler for OnGetAvailableFiles not set');
  if not Assigned(OnGetStagedFiles) then
    raise Exception.Create('Event handler for OnGetStagesFiles not set');
  allowedStates := getAllowedStates;
  OnGetAvailableFiles(availableList, allowedStates);
  OnGetStagedFiles(stagedList);

  FVstAvailableHelper.Model := availableList;
  FVstStagedHelper.Model := stagedList;

  result := ShowModal = mrOk;
end;

procedure TFormCommit.FormCreate(Sender: TObject);
begin
  FVstAvailableHelper := TVSTHelper<TFileInfo>.Create;
  FVstAvailableHelper.TreeView := vstAvailableFiles;
  FVstAvailableHelper.ZebraColor := clNone;
  FVstAvailableHelper.OnCompareNodes := hndCompareNodes;
  FVstAvailableHelper.OnGetImageIndex := hndGetImageIndex;

  FVstAvailableHelper.Filtered := true;

  FVstStagedHelper := TVSTHelper<TFileInfo>.Create;
  FVstStagedHelper.TreeView := vstStagedFiles;
  FVstStagedHelper.ZebraColor := clNone;
  FVstStagedHelper.OnCompareNodes := hndCompareNodes;
  FVstStagedHelper.OnGetImageIndex := hndGetImageIndex;

  FAllowedStates := [fsUnversioned, fsModified, fsRemoved];
end;

procedure TFormCommit.FormDestroy(Sender: TObject);
begin
  FVstAvailableHelper.Model.Free;
  FVstAvailableHelper.Free;
  FVstStagedHelper.Free;
end;

function TFormCommit.getAllowedStates: TFileStates;
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

procedure TFormCommit.hndCompareNodes(Item1, Item2: TFileInfo; Column: TColumnIndex; var Result: Integer);
begin
  case Column of
    0: Result := AnsiCompareStr(item1.fullPath, item2.fullPath);
    1: Result := Ord(item1.state) - Ord(item2.state);
  end;
end;

procedure TFormCommit.hndGetImageIndex(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; var Ghosted: Boolean; var ImageIndex: TImageIndex);
begin
  if (column > 0) or not (Kind in [ikNormal, ikSelected]) then
    exit;

  case item.state of
    fsRemoved: ImageIndex := 42;
    fsModified: ImageIndex := 43;
    fsConflict: ImageIndex := 44;
    else
      ImageIndex := 41;
  end;
end;

procedure TFormCommit.Refresh;
begin
  FVstAvailableHelper.RefreshView;
  FVstStagedHelper.RefreshView;
end;

procedure TFormCommit.refreshAvailable(Sender: TObject);
var
  availableList: TFilesList;
begin
  OnGetAvailableFiles(availableList, getAllowedStates);
  FVstAvailableHelper.Model.Free;
  FVstAvailableHelper.Model := availableList;
end;

end.
