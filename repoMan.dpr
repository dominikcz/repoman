program repoMan;

uses
  Vcl.Forms,
  frmMain in 'frmMain.pas' {MainForm},
  fraFilesBrowser in 'Views\fraFilesBrowser.pas' {ViewFilesBrowser: TFrame},
  Models.FileInfo in 'Models\Models.FileInfo.pas',
  dmRepo in 'dmRepo.pas' {Repo: TDataModule},
  fraCommitView in 'Views\fraCommitView.pas' {ViewCommit: TFrame},
  whizaxe.VSTHelper.Tree in 'whizaxe.VSTHelper.Tree.pas',
  repoHelper in 'repoHelper.pas',
  repoHelper.CVS in 'repoHelper.CVS.pas',
  frmDiff in 'Views\frmDiff.pas' {DiffForm},
  formManager in 'formManager.pas',
  Diff in '3rdparty\textdiff\Diff.pas',
  CodeEditor in '3rdparty\textdiff\TextDiff\CodeEditor.pas',
  FindReplace in '3rdparty\textdiff\TextDiff\FindReplace.pas',
  HashUnit in '3rdparty\textdiff\TextDiff\HashUnit.pas',
  Searches in '3rdparty\textdiff\TextDiff\Searches.pas',
  frmDiff.utils in 'Views\frmDiff.utils.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
