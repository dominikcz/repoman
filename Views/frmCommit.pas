unit frmCommit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, PngSpeedButton, VirtualTrees, Vcl.ExtCtrls,
  System.Actions, Vcl.ActnList, PngBitBtn,
  Models.FileInfo,
  whizaxe.VSTHelper;

type
  TGetStagedFilesListEvent = procedure(out list: TFilesList) of object;
  TGetAvailableFilesListEvent = procedure(out list: TFilesList; const allowedStates: TFileStates) of object;
  TAddToIgnoredEvent = procedure(const mask: string) of object;

  TFormCommit = class(TForm)
    ActionList1: TActionList;
    actUnstageSelected: TAction;
    actUnstageAll: TAction;
    actStageSelected: TAction;
    actStageAll: TAction;
    actCommit: TAction;
    leftPanel: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    pnlUnstaged: TPanel;
    filterPanel: TPanel;
    unstagedFiles: TVirtualStringTree;
    pnlStaged: TPanel;
    stagingPanel: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    PngSpeedButton1: TPngSpeedButton;
    PngSpeedButton2: TPngSpeedButton;
    PngSpeedButton3: TPngSpeedButton;
    PngSpeedButton4: TPngSpeedButton;
    stagedFiles: TVirtualStringTree;
    pnlCommit: TPanel;
    commitMsg: TMemo;
    cbPrevMessages: TComboBox;
    PngBitBtn1: TPngBitBtn;
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
  private
    { Private declarations }
    FAvailableHelper: TVSTHelper<TFileInfo>;
    FStagedHelper: TVSTHelper<TFileInfo>;
    FOnGetAvailableFiles: TGetAvailableFilesListEvent;
    FOnGetStagedFiles: TGetStagedFilesListEvent;
    FAllowedStates: TFileStates;
    FOnAddToIgnored: TAddToIgnoredEvent;
    procedure Refresh;
  public
    { Public declarations }
    function Execute: boolean;
    property OnGetAvailableFiles: TGetAvailableFilesListEvent read FOnGetAvailableFiles write FOnGetAvailableFiles;
    property OnGetStagedFiles: TGetStagedFilesListEvent read FOnGetStagedFiles write FOnGetStagedFiles;
    property OnAddToIgnored: TAddToIgnoredEvent read FOnAddToIgnored write FOnAddToIgnored;
  end;

implementation

{$R *.dfm}

procedure TFormCommit.actCommitExecute(Sender: TObject);
begin
//
end;

procedure TFormCommit.actCommitUpdate(Sender: TObject);
begin
  actCommit.Enabled := (trim(commitMsg.Text) <> '') and (FStagedHelper.SelectedCount > 0);
end;

procedure TFormCommit.actStageAllExecute(Sender: TObject);
begin
  FStagedHelper.Model.AddRange(FAvailableHelper.Model);
  FAvailableHelper.Model.Clear;
end;

procedure TFormCommit.actStageSelectedExecute(Sender: TObject);
var
  tmp: TFilesList;
  item: TFileInfo;
begin
  tmp := TFilesList(FAvailableHelper.SelectedItems);
  FStagedHelper.Model.AddRange(tmp);
  for item in tmp do
    FAvailableHelper.Model.Remove(item);
  Refresh;
end;

procedure TFormCommit.actStageSelectedUpdate(Sender: TObject);
begin
  actStageSelected.Enabled := FAvailableHelper.SelectedCount > 0;
end;

procedure TFormCommit.actUnstageAllExecute(Sender: TObject);
begin
  FAvailableHelper.Model.AddRange(FStagedHelper.Model);
  FStagedHelper.Model.Clear;
end;

procedure TFormCommit.actUnstageSelectedExecute(Sender: TObject);
var
  tmp: TFilesList;
  item: TFileInfo;
begin
  tmp := TFilesList(FStagedHelper.SelectedItems);
  FAvailableHelper.Model.AddRange(tmp);
  for item in tmp do
    FStagedHelper.Model.Remove(item);
  Refresh;
end;

procedure TFormCommit.actUnstageSelectedUpdate(Sender: TObject);
begin
  actUnstageSelected.Enabled := FStagedHelper.SelectedCount > 0;
end;

procedure TFormCommit.cbPrevMessagesChange(Sender: TObject);
begin
  commitMsg.Text := cbPrevMessages.Text;
end;


function TFormCommit.Execute: boolean;
var
  availableList: TFilesList;
  stagedList: TFilesList;
begin
  if not Assigned(OnGetAvailableFiles) then
    raise Exception.Create('Event handler for OnGetAvailableFiles not set');
  if not Assigned(OnGetStagedFiles) then
    raise Exception.Create('Event handler for OnGetStagesFiles not set');
  OnGetAvailableFiles(availableList, FAllowedStates);
  OnGetStagedFiles(stagedList);

  FAvailableHelper.Model := availableList;
  FStagedHelper.Model := stagedList;

  result := ShowModal = mrOk;
end;

procedure TFormCommit.FormCreate(Sender: TObject);
begin
  FAvailableHelper := TVSTHelper<TFileInfo>.Create;
  FAvailableHelper.TreeView := unstagedFiles;
  FAvailableHelper.ZebraColor := clNone;

  FStagedHelper := TVSTHelper<TFileInfo>.Create;
  FStagedHelper.TreeView := stagedFiles;
  FStagedHelper.ZebraColor := clNone;

  FAllowedStates := [fsUnversioned, fsModified, fsRemoved];
end;

procedure TFormCommit.FormDestroy(Sender: TObject);
begin
  FAvailableHelper.Free;
  FStagedHelper.Free;
end;

procedure TFormCommit.Refresh;
begin
  FAvailableHelper.RefreshView;
  FStagedHelper.RefreshView;
end;

end.
