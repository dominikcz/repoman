unit dmRepo;

interface

uses
  System.SysUtils, System.Classes, System.Actions, System.Types,
  Vcl.ActnList, Vcl.Graphics,
  VirtualTrees,
  Models.FileInfo,
  whizaxe.vstHelper;

type
  TMatchType = (mtContains, mtEndsWith, mtStartsWith);

  TRepo = class(TDataModule)
    alRepoActions: TActionList;
    alViewActions: TActionList;
    actFlatMode: TAction;
    actModifiedOnly: TAction;
    actIgnore: TAction;
    actShowIgnored: TAction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure hndChangeRootDir(Sender: TObject);
    procedure hndVstFiltered(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode; var Abort, Visible: boolean);
    procedure refreshView(Sender: TObject);
    procedure actShowIgnoredExecute(Sender: TObject);
  private
    { Private declarations }
    FRootPath: string;
    FFiles: TFilesList;
    FDirs: TDirsList;
    FIgnoreList: TStringList;
    FDirHelper: TVSTHelper<TDirInfo>;
    FFileListHelper: TVSTHelper<TFileInfo>;
  public
    { Public declarations }
    procedure ReloadFiles(rootPath: string);
    procedure hndOnChangeDir(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode);
  end;

function Repo: TRepo;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  frmMain,
  whizaxe.vclHelper;

var
  vRepo: TRepo;

function Repo: TRepo;
begin
  if not Assigned(vRepo) then
    vRepo := TRepo.Create(nil);
  Result := vRepo;
end;

procedure TRepo.actShowIgnoredExecute(Sender: TObject);
begin
  FFileListHelper.Filtered := not actShowIgnored.Checked;
end;

procedure TRepo.DataModuleCreate(Sender: TObject);
var
  fileName: string;
  i: Integer;
  s: string;
begin
  FFiles := TFilesList.Create;
  FDirs := TDirsList.Create;

  FFileListHelper := TVSTHelper<TFileInfo>.Create;
  FFileListHelper.Model := FFiles;
  FFileListHelper.TreeView :=  MainForm.ViewFilesBrowser1.fileList;

  FDirHelper := TVSTHelper<TDirInfo>.Create;
  FDirHelper.Model := FDirs;
  FDirHelper.TreeView := MainForm.ViewFilesBrowser1.dirTree;
  FDirHelper.OnChange := hndOnChangeDir;

  FRootPath := 'c:\mccomp\NewPos2014';
  MainForm.ViewFilesBrowser1.RootPath := FRootPath;
  MainForm.ViewFilesBrowser1.OnRootChange := hndChangeRootDir;

  FIgnoreList := TStringList.Create;
  fileName := FRootPath + '\ignorelist.repoman';
  if FileExists(fileName) then
  begin
    FIgnoreList.LoadFromFile(fileName);
    // "kompilujemy" filtry:
    // *... => mtEndsWith
    // ...* => mrStartsWith
    // ... => mtContains
    // konstrukcje typu ...*... czy *...* nie s¹ obslugiwane
    for i := 0 to FIgnoreList.Count - 1 do
    begin
      s := FIgnoreList[i];
      if s.StartsWith('*') then
        FIgnoreList.Objects[i] := TObject(ord(mtEndsWith))
      else if s.EndsWith('*') then
        FIgnoreList.Objects[i] := TObject(ord(mtStartsWith))
      else
        FIgnoreList.Objects[i] := TObject(ord(mtContains));
      FIgnoreList[i] := StringReplace(s, '*', '', [rfReplaceAll]);
    end;
  end;

  FFileListHelper.OnFiltered := hndVstFiltered;
end;

procedure TRepo.DataModuleDestroy(Sender: TObject);
begin
  FDirs.Free;
  FFiles.Free;

  FFileListHelper.Free;
  FDirHelper.Free;

  FIgnoreList.Free;
end;

procedure TRepo.hndChangeRootDir(Sender: TObject);
begin
  FRootPath := MainForm.ViewFilesBrowser1.RootPath;
end;

procedure TRepo.hndOnChangeDir(Sender: TBaseVirtualTree; Item: TDirInfo; Node: PVirtualNode);
begin
  FFiles.Reload(item.fullPath, actFlatMode.Checked);
  FFileListHelper.RefreshView;
end;

procedure TRepo.hndVstFiltered(Sender: TBaseVirtualTree; Item: TFileInfo; Node: PVirtualNode;
  var Abort, Visible: Boolean);
var
  i: Integer;
  s: string;
begin

  for i := 0 to FIgnoreList.Count - 1 do
  begin
    s := FIgnoreList[i];
    case TMatchType(FIgnoreList.Objects[i]) of
      mtContains:
        visible := not item.fullPath.ToLower.Contains(s.ToLower);
      mtEndsWith:
        visible := not item.fullPath.EndsWith(s, true);
      mtStartsWith:
        visible := not item.fullPath.StartsWith(s, true);
    end;
    if not Visible then
      exit;
  end;
end;

procedure TRepo.refreshView(Sender: TObject);
begin
  FDirs.Reload(FRootPath);
  FDirHelper.RefreshView;

  FFiles.Reload(FRootPath, actFlatMode.Checked);
  FFileListHelper.RefreshView;
end;

procedure TRepo.ReloadFiles(rootPath: string);
begin

end;

initialization
  vRepo := nil;

finalization
  vRepo.Free;

end.
