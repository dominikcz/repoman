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
  formManager in 'formManager.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
