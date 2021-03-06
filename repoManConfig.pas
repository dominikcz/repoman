unit repoManConfig;

interface

type
  TRepoManCfg = class
  public
    //diff
    UseExternalDiff: boolean;
    ExternalDiffPath: string;
    ShowInlineDiffs: boolean;
    IgnoreCase: boolean;
    IgnoreBlanks: boolean;
    DiffOnWords: boolean;

    // editors
    ExternalEditor: string;
    UseExternalAnnotateEditor: boolean;

    // repo
    BackupModifiedFiles: boolean;
    RootPath: string;

    // GUI
    ShowToolbarCaptions: boolean;

    constructor Create;
  end;

implementation

uses
  whizaxe.CfgFile,
  SysUtils;

{ TRepoManCfg }

constructor TRepoManCfg.Create;
begin
  UseExternalDiff := false;
  ExternalDiffPath  := '';
  ShowInlineDiffs := false;
  IgnoreCase := true;
  IgnoreBlanks := true;
  DiffOnWords := false;
  ShowToolbarCaptions := true;
  BackupModifiedFiles := true;
  RootPath := '';

  ExternalEditor := '';
  UseExternalAnnotateEditor := false;

  CfgFile.LoadFromIniFile(ChangeFileExt(ParamStr(0), '.ini'));
  self.UseExternalDiff := CfgFile.getBoolen('Diff.UseExternalDiff', UseExternalDiff);
  self.ExternalDiffPath := CfgFile.getString('Diff.ExternalDiffPath', ExternalDiffPath);
  self.ShowInlineDiffs := CfgFile.getBoolen('Diff.ShowInlineDiffs', ShowInlineDiffs);
  self.IgnoreCase := CfgFile.getBoolen('Diff.IgnoreCase', IgnoreCase);
  self.IgnoreBlanks := CfgFile.getBoolen('Diff.IgnoreBlanks', IgnoreBlanks);
  self.DiffOnWords := CfgFile.getBoolen('Diff.DiffOnWords', DiffOnWords);

  // editors
  self.ExternalEditor := CfgFile.getString('Editors.ExternalEditor', ExternalEditor);
  self.UseExternalAnnotateEditor := CfgFile.getBoolen('Editors.UseExternalAnnotateEditor', UseExternalAnnotateEditor);

  //repo
  self.BackupModifiedFiles := CfgFile.getBoolen('Repo.BackupModifiedFiles', BackupModifiedFiles);
  self.RootPath := CfgFile.getString('Repo.RootPath', RootPath);

  // GUI
  self.ShowToolbarCaptions := CfgFile.getBoolen('GUI.ShowToolbarCaptions', ShowToolbarCaptions);

  if UseExternalDiff and (ExternalDiffPath = '') then
    UseExternalDiff := false;
  if UseExternalAnnotateEditor and (ExternalEditor = '') then
    UseExternalAnnotateEditor := false;
  cfgFile.SaveJsonFile('repoman.json');
end;

end.
