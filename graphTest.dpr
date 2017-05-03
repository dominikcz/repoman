program graphTest;

uses
  Vcl.Forms,
  frmGraph in 'Views\frmGraph.pas' {GraphForm},
  repoHelper.CVS in 'repoHelper.CVS.pas',
  Models.LogInfo in 'Models\Models.LogInfo.pas',
  Models.FileInfo in 'Models\Models.FileInfo.pas',
  graph in 'graph.pas';

{$R *.res}

var
  graphForm: TGraphForm;

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TgraphForm, graphForm);
  Application.Run;
end.
