program SGDemo;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  DesignProp in 'DesignProp.pas' {DesignerProperties},
  ObjectProp in 'ObjectProp.pas' {ObjectProperties},
  LinkProp in 'LinkProp.pas' {LinkProperties},
  NodeProp in 'NodeProp.pas' {NodeProperties},
  AboutDelphiArea in 'AboutDelphiArea.pas' {About},
  SimpleGraph in '..\SimpleGraph.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Simple Graph Demo';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
