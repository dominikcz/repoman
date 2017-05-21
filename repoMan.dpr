program repoMan;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  frmMain in 'frmMain.pas' {MainForm},
  fraFilesBrowser in 'Views\fraFilesBrowser.pas' {ViewFilesBrowser: TFrame},
  Models.FileInfo in 'Models\Models.FileInfo.pas',
  dmRepo in 'dmRepo.pas' {Repo: TDataModule},
  fraCommitView in 'Views\fraCommitView.pas' {FrameCommitView: TFrame},
  repoHelper in 'repoHelper.pas',
  repoHelper.CVS in 'repoHelper.CVS.pas',
  frmDiff in 'Views\frmDiff.pas' {DiffForm},
  formManager in 'formManager.pas',
  Diff in '3rdparty\textdiff\Diff.pas',
  HashUnit in '3rdparty\textdiff\TextDiff\HashUnit.pas',
  frmDiff.utils in 'Views\frmDiff.utils.pas',
  fraEditor in 'Views\fraEditor.pas' {FrameEditor: TFrame},
  dmSynHighlighters in 'dmSynHighlighters.pas' {SynHighlighters: TDataModule},
  frmHistoryQuery in 'Views\frmHistoryQuery.pas' {HistoryQueryForm},
  frmHistory in 'Views\frmHistory.pas' {HistoryForm},
  frmFileHistory in 'Views\frmFileHistory.pas' {FileHistoryForm},
  frmGraph in 'Views\frmGraph.pas' {GraphForm},
  Models.LogInfo in 'Models\Models.LogInfo.pas',
  frmBranchesList in 'Views\frmBranchesList.pas' {BranchesListForm},
  SimpleGraph in '3rdparty\simplegraph\SimpleGraph.pas',
  frmBlame in 'Views\frmBlame.pas' {BlameForm},
  fraBlame in 'Views\fraBlame.pas' {BlameFrame: TFrame},
  Models.BlameInfo in 'Models\Models.BlameInfo.pas',
  fraDiff in 'Views\fraDiff.pas' {FrameDiff: TFrame},
  frmCommit in 'Views\frmCommit.pas' {FormCommit},
  Models.IgnoreList in 'Models\Models.IgnoreList.pas',
  dmCommonResources in 'dmCommonResources.pas' {commonResources: TDataModule},
  frmAddToIgnored in 'Views\frmAddToIgnored.pas' {AddToIgnoreForm};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
