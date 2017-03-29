unit Models.FileInfo;

interface

uses
  Generics.Collections;

type
  TFileState = (fsNormal, fsNew, fsRemoved, fsModified);

  TFileInfo = class
  public
    fileName: string;
    path: string;
    branch: string;
    state: TFileState;
    fullPath: string;
    shortPath: string;
    ext: string;
    dt: TDateTime;
    constructor Create(AFullPath: string; ARoot: string = ''; AState: TFileState = fsNormal);
    function stateAsStr: string;
  end;

  TDirInfo = class
  public
    dir: string;
    fullPath: string;
    shortPath: string;
    hasChildren: boolean;
    constructor Create(AFullPath, ARoot: string);
  end;

  TFilesList = class(TObjectList<TFileInfo>)
  public
    procedure Reload(rootPath: string; flatMode: boolean);
  end;

  TDirsList = class(TObjectList<TDirInfo>)
  public
    procedure Reload(rootPath: string);
  end;

const
  FileStateStr: array[TFileState] of string = ('normal', 'new', 'removed', 'modified');

implementation

uses
  System.Types,
  System.IOUtils,
  System.SysUtils;

{ TFileInfo }

constructor TFileInfo.Create(AFullPath: string; ARoot: string = ''; AState: TFileState = fsNormal);
begin
  fullPath := AFullPath;
  fileName := TPath.GetFileName(AFullPath);
  path := TPath.GetDirectoryName(AFullPath);
  ext := TPath.GetExtension(AFullPath);
  if ARoot <> '' then
    shortPath := AFullPath.Substring(ARoot.Length + 1)
  else
    shortPath := AFullPath;
  state := AState;
end;

function TFileInfo.stateAsStr: string;
begin
  result := FileStateStr[self.state];
end;

{ TFilesList }

procedure TFilesList.Reload(rootPath: string; flatMode: boolean);
var
  LSearchOption: TSearchOption;
  lList: TStringDynArray;
  s: string;
begin
  if flatMode then
    LSearchOption := TSearchOption.soAllDirectories
  else
    LSearchOption := TSearchOption.soTopDirectoryOnly;

  lList := TDirectory.GetFiles(rootPath, '*', LSearchOption);
  Clear;
  for s in lList do
     Add(TFileInfo.Create(s, rootPath));
end;

{ TDirInfo }

constructor TDirInfo.Create(AFullPath, ARoot: string);
begin
  dir := TPath.GetFileName(AFullPath);
  fullPath := AFullPath;
  shortPath := AFullPath.Substring(ARoot.Length + 1);
//  hasChildren := findFirst()
end;

{ TDirsList }

procedure TDirsList.Reload(rootPath: string);
var
  lList: TStringDynArray;
  s: string;
begin
  lList := TDirectory.GetDirectories(rootPath, '*', TSearchOption.soAllDirectories);
  Clear;
  for s in lList do
     Add(TDirInfo.Create(s, rootPath));
end;

end.
