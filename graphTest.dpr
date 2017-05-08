program graphTest;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Dialogs,
  Vcl.Forms,
  frmGraph in 'Views\frmGraph.pas' {GraphForm},
  repoHelper.CVS in 'repoHelper.CVS.pas',
  Models.LogInfo in 'Models\Models.LogInfo.pas',
  Models.FileInfo in 'Models\Models.FileInfo.pas',
  frmBranchesList in 'Views\frmBranchesList.pas' {BranchesListForm},
  SimpleGraph in '3rdparty\simplegraph\SimpleGraph.pas',
  SimpleGraphRepo in 'SimpleGraphRepo.pas';

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
  if lcvs.logFile(lFileInfo, logNodes, true) <> 0 then
  begin
    ShowMessage('b³ad');
    exit;
  end;

  Application.CreateForm(TgraphForm, graphForm);
  graphForm.Execute(logNodes);
  Application.Run;

  lFileInfo.Free;
  lcvs.Free;

end.
