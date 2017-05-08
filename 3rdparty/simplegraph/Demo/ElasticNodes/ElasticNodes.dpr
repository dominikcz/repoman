program ElasticNodes;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  SimpleGraph in '..\..\SimpleGraph.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := true;
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
