unit dmRepo;

interface

uses
  System.SysUtils, System.Classes, System.Actions, System.Types,
  Vcl.ActnList, Vcl.Graphics,
  VirtualTrees,
  Models.FileInfo,
  whizaxe.vstHelper;

type
  TRepo = class(TDataModule)
    alRepoActions: TActionList;
    alViewActions: TActionList;
    actFlatMode: TAction;
    actModifiedOnly: TAction;
    actIgnore: TAction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure hndChangeRootDir(Sender: TObject);
    procedure refreshView(Sender: TObject);
  private
    { Private declarations }
    FRootPath: string;
    FFiles: TFilesList;
    FDirs: TDirsList;
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

procedure TRepo.DataModuleCreate(Sender: TObject);
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
end;

procedure TRepo.DataModuleDestroy(Sender: TObject);
begin
  FDirs.Free;
  FFiles.Free;

  FFileListHelper.Free;
  FDirHelper.Free;
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
