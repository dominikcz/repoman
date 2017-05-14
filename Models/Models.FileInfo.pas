unit Models.FileInfo;

interface

uses
  Generics.Collections,
  whizaxe.collections;

type
  TFileState = (fsUnversioned, fsNormal, fsAdded, fsRemoved, fsModified, fsConflict);
  TDirState = (dsUnversioned, dsVersioned);

  TFileInfo = class
  private
    function getStateAsStr: string;
    function getDtAsStr: string;
  public
    fileName: string;
    path: string;
    state: TFileState;
    fullPath: string;
    shortPath: string;
    ext: string;
    dt: TDateTime;
    revision: string;
    branch: string;
    constructor Create(AFullPath: string; ARoot: string = ''; AState: TFileState = fsNormal);
    property stateAsStr: string read getStateAsStr;
    property dtAsStr: string read getDtAsStr;
    function getTempFileName(const prefix: string = ''): string;
    function getFullPathWithoutRoot(ARoot: string): string;
  end;

  TDirInfo = class
  public
    dir: string;
    fullPath: string;
    shortPath: string;
    state: TDirState;
    constructor Create(AFullPath, ARoot: string);
    function IsChildOf(testParent: TDirInfo): boolean;
  end;

  TFilesList = class(TObjectList<TFileInfo>)
  public
    procedure Reload(rootPath: string; flatMode: boolean);
    function tryToFind(path: string; out item: TFileInfo): boolean;
  end;

  TDirsList = class(TObjectList<TDirInfo>)
  public
    type
      TChildrenEnumerator = class(TInterfacedObject, IWxEnumerator<TDirInfo>)
      private
        FList: TDirsList;
        FRoot: TDirInfo;
        FIndex: Integer;
        function GetCurrent: TDirInfo;
      public
        constructor Create(list: TDirsList; root: TDirInfo);
        function MoveNext: Boolean;
    //    procedure Reset;
        property Current: TDirInfo read GetCurrent;
      end;

      TChildrenEnumerable = class(TInterfacedObject, IWxEnumerable<TDirInfo>)
      private
        FList: TDirsList;
        FRoot: TDirInfo;
      public
        constructor Create(list: TDirsList; root: TDirInfo);
        function GetEnumerator: IWxEnumerator<TDirInfo>;
      end;

  public
    procedure Reload(rootPath: string; const includeRoot: boolean = true);
    function HasChildren(const Folder: string): Boolean; overload;
    function HasChildren(item: TDirInfo): Boolean; overload;
    function GetChildrenIterator(item: TDirInfo): IWxEnumerable<TDirInfo>;
  end;

const
  FileStateStr: array[TFileState] of string = ('unversioned', 'normal', 'added', 'removed', 'modified', 'conflict');

implementation

uses
  WinApi.Windows,
  System.Types,
  System.IOUtils,
  System.SysUtils,
  System.DateUtils,
  Generics.Defaults,
  Classes,
  whizaxe.common;

{ TFileInfo }

constructor TFileInfo.Create(AFullPath: string; ARoot: string = ''; AState: TFileState = fsNormal);
var
  fileDt: TDateTime;
  y, m, d, h, n, s, ms: Word;
begin
  fullPath := AFullPath;
  fileName := TPath.GetFileName(AFullPath);
  path := TPath.GetDirectoryName(AFullPath);
  ext := TPath.GetExtension(AFullPath);
  shortPath := getFullPathWithoutRoot(ARoot);
  state := AState;
  if WxU.GetFileModDate(AFullPath, fileDt) then
  begin
    DecodeDateTime(fileDt, y, m, d, h, n, s, ms);
    self.dt := EncodeDateTime(y, m, d, h, n, s, 0);
  end;
end;

function TFileInfo.getDtAsStr: string;
begin
  result := DateTimeToStr(dt);
end;

function TFileInfo.getFullPathWithoutRoot(ARoot: string): string;
begin
  if ARoot <> '' then
    Result := fullPath.Substring(ARoot.Length + 1)
  else
    Result := fullPath;
end;

function TFileInfo.getStateAsStr: string;
begin
  result := FileStateStr[self.state];
end;

function TFileInfo.getTempFileName(const prefix: string = ''): string;
begin
  result := TPath.Combine(TPath.GetTempPath,
    prefix
    + TPath.GetFileNameWithoutExtension(fileName)
    + '_'
    + self.revision
    + TPath.GetExtension(filename)
  );
end;

{ TFilesList }

procedure TFilesList.Reload(rootPath: string; flatMode: boolean);
var
  LSearchOption: TSearchOption;
  lList: TStringDynArray;
  s: string;
  item: TFileInfo;
begin
  if flatMode then
    LSearchOption := TSearchOption.soAllDirectories
  else
    LSearchOption := TSearchOption.soTopDirectoryOnly;

  lList := TDirectory.GetFiles(rootPath, '*', LSearchOption);
  TArray.Sort<string>(lList, caseInsensitiveAnsiComparer);
  Clear;
  for s in lList do
  begin
    item := TFileInfo.Create(s, rootPath);
    Add(item);
  end;
end;

function TFilesList.tryToFind(path: string; out item: TFileInfo): boolean;
var
  lItem: TFileInfo;
begin
  result := false;
  for lItem in self do
    if lItem.fullPath = path then
    begin
      item := lItem;
      exit(true);
    end;
end;

{ TDirInfo }

constructor TDirInfo.Create(AFullPath, ARoot: string);
begin
  dir := TPath.GetFileName(AFullPath);
  fullPath := AFullPath;
  shortPath := AFullPath.Substring(ARoot.Length + 1);
//  hasChildren := findFirst()
end;

function TDirInfo.IsChildOf(testParent: TDirInfo): boolean;
var
  tmp: string;
begin
  if not self.fullPath.StartsWith(testParent.fullPath+'\') then
    exit(false);
  tmp := self.fullPath.Substring(testParent.fullPath.Length + 1);
  result := tmp.IndexOf('\') = -1;
end;

{ TDirsList }

function TDirsList.HasChildren(const Folder: string): Boolean;
var
  item: TDirInfo;
begin
  result := false;
  for item in self do
  begin
    if item.fullPath = Folder then
      exit(HasChildren(item));
  end;
end;

function TDirsList.GetChildrenIterator(item: TDirInfo): IWxEnumerable<TDirInfo>;
begin
  result := TChildrenEnumerable.Create(self, item);
end;

function TDirsList.HasChildren(item: TDirInfo): Boolean;
var
  idx: Integer;
  nextItem: TDirInfo;
begin
  result := false;
  idx := IndexOf(item);
  if (idx >=0) and (idx < self.Count -1) then
  begin
    nextItem := Items[idx+1];
    result := nextItem.IsChildOf(item);
  end;
end;

procedure TDirsList.Reload(rootPath: string; const includeRoot: boolean = true);
var
  lList: TStringDynArray;
  s: string;
  dirInfo: TDirInfo;
begin
  lList := TDirectory.GetDirectories(rootPath, '*', TSearchOption.soAllDirectories);
  Clear;
  Add(TDirInfo.Create(rootPath, rootPath));
  for s in lList do
  begin
    dirInfo := TDirInfo.Create(s, rootPath);

    Add(dirInfo);
  end;
end;

{ TDirsList.TChildrenEnumerator }

constructor TDirsList.TChildrenEnumerator.Create(list: TDirsList; root: TDirInfo);
begin
  FRoot := root;
  FList := list;
  FIndex := FList.IndexOf(root);
end;

function TDirsList.TChildrenEnumerator.GetCurrent: TDirInfo;
begin
  Result := FList[FIndex];
end;

function TDirsList.TChildrenEnumerator.MoveNext: Boolean;
var
  nextItem: TDirInfo;
begin
  Result := False;
  while FIndex < FList.Count - 1 do
  begin
    Inc(FIndex);
    nextItem := FList.Items[FIndex];
    if not nextItem.fullPath.StartsWith(FRoot.fullPath) then
      exit(false);
    if nextItem.IsChildOf(FRoot) then
      Exit(True);
  end;
end;

{ TDirsList.TChildrenEnumerable }

constructor TDirsList.TChildrenEnumerable.Create(list: TDirsList; root: TDirInfo);
begin
  FList := list;
  FRoot := root;
end;

function TDirsList.TChildrenEnumerable.GetEnumerator: IWxEnumerator<TDirInfo>;
begin
  result := TChildrenEnumerator.Create(FList, FRoot);
end;

end.
