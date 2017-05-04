program graphTest;

uses
  Vcl.Forms,
  frmGraph in 'Views\frmGraph.pas' {GraphForm},
  repoHelper.CVS in 'repoHelper.CVS.pas',
  Models.LogInfo in 'Models\Models.LogInfo.pas',
  Models.FileInfo in 'Models\Models.FileInfo.pas',
  graph in 'graph.pas',
  frmBranchesList in 'Views\frmBranchesList.pas' {BranchesListForm};

{$R *.res}

var
  graphForm: TGraphForm;
  lFileInfo: TFileInfo;
  lcvs: TRepoHelperCVS;
  logNodes: TLogNodes;

const
  fileName: string = 'c:\mccomp\NewPos2014\Whizaxe\whizaxe.common.pas';

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  lFileInfo := TFileInfo.Create(fileName, 'c:\mccomp\NewPos2014');
  lcvs := TRepoHelperCVS.Create;
  lcvs.logFile(lFileInfo, logNodes, true);

  Application.CreateForm(TgraphForm, graphForm);
  graphForm.Execute(fileName, logNodes);
  Application.Run;

  lFileInfo.Free;
  lcvs.Free;

end.
