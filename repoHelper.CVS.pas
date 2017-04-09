unit repoHelper.CVS;

interface

uses
  System.Types,
  Generics.Collections,
  repoHelper,
  Models.FileInfo;

type
  TCVSEntry = class
//entries:
//    /name/revision/timestamp[+conflict]/options/tagdate
//    D/name/filler1/filler2/filler3/filler4
//entries.extra:
//    /name/saved mergepoint/filler1/rcstime/edit_revision/edit_tag/edit_bugid/
    isDir: boolean;
    name: string;
    revision: string;
    timestamp: TDateTime;
    state: TFileState;
    info: string;
    options: string;
    tagdate: string;
  end;

  TCVSEntries = class(TObjectList<TCVSEntry>)
  end;

  TRepoHelperCVS = class(TInterfacedObject, IRepoHelper)
  private
    FEntries: TCVSEntries;
  public
    procedure updateFilesState(files: TFilesList);
    procedure updateDirsState(dirs: TDirsList);
    procedure Init(root: string);
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.IOUtils,
  Classes,
  SysUtils,
  whizaxe.common;

{ TRepoHelperCVS }

constructor TRepoHelperCVS.Create;
begin
  FEntries := TCVSEntries.Create;
end;

destructor TRepoHelperCVS.Destroy;
begin
  FEntries.Free;
  inherited;
end;

procedure TRepoHelperCVS.Init(root: string);
var
  lList: TStringDynArray;
  dir: string;
  item: TCVSEntry;
  path: string;
  sl: TStringList;
  line: string;
  i: integer;
  tmp: TArray<string>;
  basePath: string;
begin
  lList := TDirectory.GetDirectories(root, 'CVS', TSearchOption.soAllDirectories);
  sl := TStringList.Create;
  for dir in lList do
  begin
    // dodajemy g³ówne foldery
    item := TCVSEntry.Create;
    item.isDir := true;
    item.name := dir.Substring(0, dir.Length - 4);
    FEntries.Add(item);
    // dodajemy zawartoœæ Entries + Entries.Extra
    path := TPath.Combine(dir, 'Entries');
    if FileExists(path) then
    begin
      sl.LoadFromFile(path);
      basePath := path.Substring(0, path.Length - '\cvs\Entries'.Length);
      for i := 0 to sl.Count -1 do
      begin
        line := sl.Strings[i];
        if line.Length < 2 then
          continue;
        item := TCVSEntry.Create;
        if line.StartsWith('D/') then
        begin
          //    D/name/filler1/filler2/filler3/filler4
          tmp := line.Split(['/'], 3);
          item.isDir := true;
          item.name := TPath.Combine(basePath, tmp[1]);
        end
        else
        begin
          //    /name/revision/timestamp[+conflict]/options/tagdate
          // np:
          //    /saleSupport.pas/1.48.14.1.6.6/Sun Mar 19 18:18:33 2017//TMcRESS
          //    /saleProcess.pas/1.185.12.8.6.2.2.34/Result of merge+Thu Apr  6 23:33:07 2017//TMcRESS  <- conflict
          //    /saleProcessPSP.pas/1.70.8.2.8.2.10.2/Result of merge//Tversions_7_3_1                  <- branch
          //    /SaleProcessEvents.pas/1.1.2.4/Sun Mar 19 18:18:32 2017//T1.1.2.4                       <- revision
          //    /SaleProcessOrlenConsts.pas/1.1.2.1/Tue Feb 21 12:12:17 2017//Taqq                      <- tag
          //    /McPOS_Icon.ico/0/dummy timestamp/-kb/TMcRESS                                           <- added
          //    /actionsMonitor.pas/1.3.8.1/Mon Nov 21 15:45:10 2016//Taqq                              <- modified
          //    /actionsMonitor.pas/-1.3.8.1.32.1/dummy timestamp//Taqq                                 <- removed

          tmp := line.Split(['/'], 6);
          item.isDir := false;
          item.name := TPath.Combine(basePath, tmp[1]);
          item.revision := tmp[2];
          if item.revision[1] = '0' then
          begin
            item.state := fsAdded;
            item.timestamp := 0;
          end
          else
          if item.revision[1] = '-' then
          begin
            item.state := fsRemoved;
            item.timestamp := 0;
          end
          else
          begin
            if tmp[3].StartsWith('Result of merge') then
            begin
              item.info := 'Result of merge';
              delete(tmp[3], 1, 15);
            end;
            if tmp[3].StartsWith('+') then
            begin
              item.state := fsConflict;
              delete(tmp[3], 1, 1);
            end;
            item.timestamp := DateTimeStrEval('ddd mmm dd hh:nn:ss yyyy', tmp[3], TFormatSettings.Invariant);
          end;
          item.options := tmp[4];
          item.tagdate := tmp[5].Substring(1);
        end;
        FEntries.Add(item);
      end;
    end;
  end;
  sl.Free;
end;

procedure TRepoHelperCVS.updateDirsState(dirs: TDirsList);
var
  dirInfo: TDirInfo;
  lastRepoIdx, lastFound: Integer;
  repoItem: TCVSEntry; // TODO: do zmiany
  dirLen: integer;
  max: Integer;
begin
  lastFound := 0;
  max := FEntries.Count - 1;
  for dirInfo in dirs do
  begin
    lastRepoIdx := lastFound;
    dirInfo.state := dsUnversioned;
    dirLen := dirInfo.fullPath.Length;
    if dirInfo.fullPath.EndsWith('\CVS') then
      dirInfo.state := dsVersioned
    else
      repeat
        repoItem := FEntries.Items[lastRepoIdx];
        if repoItem.name.StartsWith(dirInfo.fullPath) then
        begin
          dirInfo.state := dsVersioned;
          lastFound := lastRepoIdx;
          break;
        end;
        inc(lastRepoIdx); // TODO: zoptymalizowaæ przez analizê œcie¿ki?
      until (lastRepoIdx >= max);
  end;
end;

procedure TRepoHelperCVS.updateFilesState(files: TFilesList);
var
  fileInfo: TFileInfo;
  lastRepoIdx: Integer;
  repoItem: TCVSEntry; // TODO: do zmiany
begin
  lastRepoIdx := 0;
  for fileInfo in files do
  begin
    repoItem := FEntries.Items[lastRepoIdx];
    while (lastRepoIdx < FEntries.Count - 2) and (FEntries.Items[lastRepoIdx].name < fileInfo.fullPath) do
    begin
      inc(lastRepoIdx);
      repoItem := FEntries.Items[lastRepoIdx];
    end;
    if fileInfo.fullPath = repoItem.name then
      fileInfo.state := repoItem.state
    else
      fileInfo.state := fsUnversioned;
  end;
end;

end.
