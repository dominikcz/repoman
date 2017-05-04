unit repoHelper.CVS;

interface

uses
  Windows,
  SysUtils,
  System.Types,
  Generics.Collections,
  repoHelper,
  Models.FileInfo,
  Models.LogInfo,
  Classes;

type
  TCVSEntry = class
    // entries:
    // /name/revision/timestamp[+conflict]/options/tagdate
    // D/name/filler1/filler2/filler3/filler4
    // entries.extra:
    // /name/saved mergepoint/filler1/rcstime/edit_revision/edit_tag/edit_bugid/
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

  TCVSBranchName = string;
  TCVSRevision = class
  private
  public
    class function getBranchRev(const childRev: string): string;
    class function isSameBranch(const rev1, rev2: string): boolean;

  end;

  TCVSBranches = class(TDictionary<string, TCVSBranchName>);

  TRepoHelperCVS = class(TInterfacedObject, IRepoHelper)
  private
    FEntries: TCVSEntries;
    FRootPath: string;
    FCVSROOT: string;
    FOnLogging: TProc<string>;
    FLastCmdResult: TStringStream;
    procedure notifyLogging(aMsg: string);
    function ExecBatch(cmd, params, redirectTo: string): integer;
    function ExecCVSCmd(cmd: string): integer; overload;
    function ExecCVSCmd(cmd, redirectTo: string): integer; overload;
    procedure hndCommand(buff: string);
    function ParseHistory(fileName: string): TRepoHistory;
    function doAnnotateFile(item: TFileInfo; params, prefix: string; out outputFile: string; useCache: boolean): integer;
    function doParseLog(outputFile: string; out logNodes: TLogNodes): integer;
  public
    procedure updateFilesState(files: TFilesList);
    procedure updateDirsState(dirs: TDirsList);
    procedure Init(root: string);
    function diffFile(item: TFileInfo; out outputFile: string; useCache: boolean): integer;
    function logFile(item: TFileInfo; out logNodes: TLogNodes; useCache: boolean): integer;
    function getHistory(sinceDate: TDate; forUser: string; inBranch: string; out history: TRepoHistory; useCache: boolean): integer;
    function annotateFile(item: TFileInfo; sinceRev: string; out outputFile: string; useCache: boolean): integer; overload;
    function annotateFile(item: TFileInfo; sinceDate: TDateTime; out outputFile: string; useCache: boolean): integer; overload;
    function getOnLogging: TProc<string>;
    procedure setOnLogging(Value: TProc<string>);

    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.IOUtils,
  whizaxe.common,
  Generics.Defaults,
  whizaxe.processes;

{ TRepoHelperCVS }

function TRepoHelperCVS.annotateFile(item: TFileInfo; sinceDate: TDateTime; out outputFile: string;
  useCache: boolean): integer;
var
  params: string;
  prefix: string;
  dateStr: string;
begin
//cvs annotate -- VirtualTreeViewV6\Demos\Advanced\Advanced.res (in directory C:\mccomp\NewPos2014\komponenty\)
//cvs annotate -D 2017-04-01 -- VirtualTreeViewV6\Demos\Advanced\Advanced.dproj (in directory C:\mccomp\NewPos2014\komponenty\)
  prefix := 'ann_';
  dateStr := FormatDateTime('yyyy-mm-dd hh:nn', sinceDate);
  if sinceDate <> 0 then
  begin
    prefix := 'ann_'+dateStr+'_';
    params := '-D '+dateStr;
  end;
  result := doAnnotateFile(item, params, prefix, outputFile, useCache);
end;

function TRepoHelperCVS.annotateFile(item: TFileInfo; sinceRev: string; out outputFile: string; useCache: boolean): integer;
var
  params: string;
  prefix: string;
begin
//cvs annotate -- VirtualTreeViewV6\Demos\Advanced\Advanced.res (in directory C:\mccomp\NewPos2014\komponenty\)
//cvs annotate -r 1.6.2.4 -- VirtualTreeViewV6\Demos\Advanced\Advanced.dproj (in directory C:\mccomp\NewPos2014\komponenty\)
  prefix := 'ann_';
  params := '';
  if sinceRev <> '' then
  begin
    prefix := 'ann_'+sinceRev+'_';
    params := '-r '+sinceRev;
  end;
  result := doAnnotateFile(item, params, prefix, outputFile, useCache);
end;

constructor TRepoHelperCVS.Create;
begin
  FEntries := TCVSEntries.Create;
  FLastCmdResult := TStringStream.Create;
end;

destructor TRepoHelperCVS.Destroy;
begin
  FLastCmdResult.Free;
  FEntries.Free;
  inherited;
end;

function TRepoHelperCVS.ExecBatch(cmd, params, redirectTo: string): integer;
begin
  FLastCmdResult.Clear;
  notifyLogging(cmd + ' ' + params);
  params := params + ' > '+redirectTo;
  result := TProcesses.ExecBatch(cmd, params, FRootPath, 1, true);
end;

function TRepoHelperCVS.ExecCVSCmd(cmd, redirectTo: string): integer;
begin
  FLastCmdResult.Clear;
  notifyLogging('cvs '+cmd);
  cmd := 'cvs -d '+FCVSROOT+ ' '+ cmd +' > '+redirectTo;
  result := TProcesses.ExecBatch('cmd /c', cmd, FRootPath);
  if result <> 0 then
  begin
    notifyLogging('ERROR: '+IntToStr(result));
    if FileExists(redirectTo) then
      DeleteFile(redirectTo);
  end;
end;

function TRepoHelperCVS.ExecCVSCmd(cmd: string): integer;
begin
  FLastCmdResult.Clear;
  notifyLogging('cvs ' + cmd);
  cmd := 'cvs -d '+FCVSROOT+ ' '+ cmd;
  TProcesses.CaptureConsoleOutput('cvs.exe', cmd, hndCommand);
  result := 0;
end;

function TRepoHelperCVS.getHistory(sinceDate: TDate; forUser, inBranch: string; out history: TRepoHistory; useCache: boolean): integer;
var
  cmd, sdate, fileName: string;
begin
  cmd := 'history -x AMRT';
  sdate := '';
  if sinceDate <> 0 then
  begin
    sdate := TMcStr.DateTimeWithMsToStr(sinceDate, dtmISODate);
    cmd := format(cmd + ' -D "%s"', [sdate]);
  end;
  if forUser <> '' then
    cmd := cmd + ' -u '+forUser;
  result := 0;
  fileName := TPath.Combine(TPath.GetTempPath, ''.Join('_', ['history', sdate, forUser, inBranch])+'.txt');
  if not (useCache and FileExists(fileName)) then
  begin
    result := ExecCVSCmd(cmd);
    FLastCmdResult.SaveToFile(fileName);
  end;
  history := ParseHistory(fileName);
end;

function TRepoHelperCVS.getOnLogging: TProc<string>;
begin
  result := fOnLogging;
end;

procedure TRepoHelperCVS.hndCommand(buff: string);
begin
  FLastCmdResult.WriteString(buff);
  if assigned(FOnLogging) then
    FOnLogging(buff);
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
  isRootInitialized: Boolean;
  s: string;
begin
  FRootPath := root;
  isRootInitialized := false;
  lList := TDirectory.GetDirectories(root, 'CVS', TSearchOption.soAllDirectories);
  sl := TStringList.Create;
  for dir in lList do
  begin
    if not isRootInitialized then
    begin
      s := TPath.Combine(dir, 'root');
      if FileExists(s) then
      begin
        FCVSROOT := trim(TFile.ReadAllText(s));
        isRootInitialized := SetEnvironmentVariable('CVSROOT', PChar(FCVSROOT));
      end;
    end;

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
      for i := 0 to sl.Count - 1 do
      begin
        line := sl.Strings[i];
        if line.Length < 2 then
          continue;
        item := TCVSEntry.Create;
        if line.StartsWith('D/') then
        begin
          // D/name/filler1/filler2/filler3/filler4
          tmp := line.Split(['/'], 3);
          item.isDir := true;
          item.name := TPath.Combine(basePath, tmp[1]);
        end
        else
        begin
          // /name/revision/timestamp[+conflict]/options/tagdate
          // np:
          // /saleSupport.pas/1.48.14.1.6.6/Sun Mar 19 18:18:33 2017//TMcRESS
          // /saleProcess.pas/1.185.12.8.6.2.2.34/Result of merge+Thu Apr  6 23:33:07 2017//TMcRESS  <- conflict
          // /saleProcessPSP.pas/1.70.8.2.8.2.10.2/Result of merge//Tversions_7_3_1                  <- branch
          // /SaleProcessEvents.pas/1.1.2.4/Sun Mar 19 18:18:32 2017//T1.1.2.4                       <- revision
          // /SaleProcessOrlenConsts.pas/1.1.2.1/Tue Feb 21 12:12:17 2017//Taqq                      <- tag
          // /McPOS_Icon.ico/0/dummy timestamp/-kb/TMcRESS                                           <- added
          // /actionsMonitor.pas/1.3.8.1/Mon Nov 21 15:45:10 2016//Taqq                              <- modified
          // /actionsMonitor.pas/-1.3.8.1.32.1/dummy timestamp//Taqq                                 <- removed

          tmp := line.Split(['/'], 6);
          item.state := fsNormal;
          item.isDir := false;
          item.name := TPath.Combine(basePath, tmp[1]);
          item.revision := tmp[2];
          if item.revision[1] = '0' then
          begin
            item.state := fsAdded;
            item.timestamp := 0;
          end
          else if item.revision[1] = '-' then
          begin
            item.state := fsRemoved;
            item.timestamp := 0;
          end
          else
          begin
            if tmp[3].StartsWith('Result of merge') then
            begin
              item.info := 'Result of merge';
              item.state := fsModified;
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
  FEntries.Sort(TComparer<TCVSEntry>.Construct(
    function(const Left, Right: TCVSEntry): integer
    begin
      Result := AnsiCompareStr(Left.name, Right.name);
    end));

  sl.Free;
end;

function TRepoHelperCVS.logFile(item: TFileInfo; out logNodes: TLogNodes; useCache: boolean): integer;
var
  params: string;
  outputFile: string;
begin
  params := 'log -r "' + item.getFullPathWithoutRoot(FRootPath)+'"';
  outputFile := item.getTempFileName('log_');
  result := 0;
  if not (useCache and FileExists(outputFile)) then
    result := ExecCVSCmd(params, outputFile);

  if result = 0 then
    result := doParseLog(outputFile, logNodes);
end;

procedure TRepoHelperCVS.notifyLogging(aMsg: string);
begin
  if Assigned(FOnLogging) then
    FOnLogging(aMsg + #13#10);
end;

function TRepoHelperCVS.ParseHistory(fileName: string): TRepoHistory;
var
  sl: TStringList;
  line: string;
  item: TRepoHistoryItem;
  tmp: TArray<string>;
begin
  sl := TStringList.Create;
  sl.LoadFromFile(fileName);
  result := TRepoHistory.Create;
  for line in sl do
  begin
    if line.StartsWith('cvs') then
      continue;
//    M 2017-04-19 00:34 +0000 dc 1.7.88.1.8.2  whizaxe.CfgFile.pas        Whizaxe    == adsl-172-10-1-101.dsl.sndg02.sbcglobal.net
//    T 2016-08-31 07:51 +0000 dc DCC32CFG   [versions_7_2:HEAD]
    tmp := line.Split([' '], ExcludeEmpty);
    if not (length(tmp) in [7, 10]) then
      continue;
    item := TRepoHistoryItem.Create;
    if tmp[0] = 'A' then
      item.operation := hoAdd
    else if tmp[0] = 'M' then
      item.operation := hoMerge
    else if tmp[0] = 'R' then
      item.operation := hoDel
    else if tmp[0] = 'T' then
      item.operation := hoTag
    else
      item.operation := hoCommit;

    item.user := tmp[4];
    item.dt := DateTimeStrEval('yyyy-mm-dd hh:nn', tmp[1] + ' ' + tmp[2]);
    if item.operation = hoTag then
    begin
      item.filePath := tmp[5];
      item.revisionOrBranch := StringReplace(tmp[6], ':', ' <- ', []);
    end
    else
    begin
      item.revisionOrBranch := tmp[5];
      item.filePath := TPath.Combine(FRootPath, tmp[7] + '\' + tmp[6]);
      item.host := tmp[9];
    end;
    Result.Add(item);
  end;
  sl.Free;
end;

procedure TRepoHelperCVS.setOnLogging(Value: TProc<string>);
begin
  fOnLogging := value;
end;

procedure TRepoHelperCVS.updateDirsState(dirs: TDirsList);
var
  dirInfo: TDirInfo;
  lastRepoIdx, lastFound: integer;
  repoItem: TCVSEntry; // TODO: do zmiany
  max: integer;
begin
  lastFound := 0;
  max := FEntries.Count - 1;
  for dirInfo in dirs do
  begin
    lastRepoIdx := lastFound;
    dirInfo.state := dsUnversioned;
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

function TRepoHelperCVS.diffFile(item: TFileInfo; out outputFile: string; useCache: boolean): integer;
var
  params: string;
begin
  params := 'update -p -r '+item.revision + ' "' + item.getFullPathWithoutRoot(FRootPath)+'"';
  outputFile := item.getTempFileName;
  result := 0;
  if not (useCache and FileExists(outputFile)) then
    result := ExecCVSCmd(params, outputFile)
end;

function TRepoHelperCVS.doAnnotateFile(item: TFileInfo; params, prefix: string; out outputFile: string; useCache: boolean): integer;
begin
  outputFile := item.getTempFileName(prefix);
  params := trim('annotate '+ params) + ' "' + item.getFullPathWithoutRoot(FRootPath)+'"';
  result := 0;
  if not (useCache and FileExists(outputFile)) then
    result := ExecCVSCmd(params, outputFile);
end;

function TRepoHelperCVS.doParseLog(outputFile: string; out logNodes: TLogNodes): integer;
var
  sl, ss: TStringList;
  i: Integer;
  branches: TCVSBranches;
  tmp: TArray<string>;
  s, msg: string;
  logNode: TLogNode;
  tmpRev: string;
begin
  branches := TCVSBranches.Create();
  logNodes := TLogNodes.Create;

  sl := TStringList.Create;
  ss := TStringList.Create;
  ss.NameValueSeparator := ':';

  try
    sl.LoadFromFile(outputFile);
    i := 0;
    repeat
      inc(i);
    until sl[i] = 'symbolic names:';

    logNode := TLogNode.Create;
    logNode.branch := 'HEAD';
    logNode.revision := '1.1';
    logNode.isTagOnly := true;
    logNodes.Add(logNode);
    branches.Add(logNode.revision, logNode.branch);

    repeat
      inc(i);
      if sl[i].StartsWith(#9) then
      begin
        tmp := sl[i].Split([':']);
        logNode := TLogNode.Create;
        logNode.branch := trim(tmp[0]);
        logNode.revision := trim(tmp[1]);
        logNode.isTagOnly := true;
        logNodes.Add(logNode);
        branches.Add(logNode.revision, logNode.branch);
      end;
    until sl[i].StartsWith('---');
    // wczytywanie commitów
    repeat
      logNode := TLogNode.Create;
      msg := '';
      repeat
        inc(i);
        s := sl[i];
        if s.StartsWith('revision') then
          logNode.revision := s.Substring(length('revision '))
        else if s.StartsWith('date: ') then
        begin
          s := StringReplace(s, ';', #13#10, [rfReplaceAll]);
          s := StringReplace(s, ' ', '', [rfReplaceAll]);
          ss.Text := s;
          logNode.date := DateTimeStrEval('yyyy/mm/ddhh:nn:ss', ss.Values['date']);
          logNode.author := ss.Values['author'];
          logNode.mergeFrom := ss.Values['mergepoint'];
        end
        else if s.StartsWith('branches: ') then
          logNode.mergeTo := s.Substring(length('branches: ') + 1, s.Length - 12)
        else
          if (s <> '----------------------------') and (not s.StartsWith('===========')) then
            msg := msg + s + '; ';
      until s.StartsWith('--------') or s.StartsWith('===========');
      logNode.comment := trim(msg).Substring(0, msg.Length - 2);
//      logNode.branch := branches[logNode.revision];
      if logNode.revision <> '' then
        logNodes.Add(logNode);
    until s.StartsWith('===========');
    // sortujemy po revision ¿eby zbudowaæ drzewo
    logNodes.Sort(TComparer<TLogNode>.Construct(
      function(const Left, Right: TLogNode): integer
      begin
        Result := CompareText(Left.expandRevision, Right.expandRevision);
        if result = 0 then
          result := round(left.date - right.date);
      end));
    // teraz mo¿emy uzupe³niæ daty dla branchy
    for i := 0 to logNodes.Count - 1 do
    begin
      logNode := logNodes[i];
      if logNode.isTagOnly then
        logNode.date := logNodes.findParent(i).date
      else
      begin
        // a dla zwyk³ych revision nadajemy nazwy branchy
        tmpRev := TCVSRevision.getBranchRev(logNode.revision);
        logNode.branch := branches[tmpRev];
      end;
    end;
    // i wreszcie sortujemy ca³oœæ po datach
    logNodes.Sort(TComparer<TLogNode>.Construct(
      function(const Left, Right: TLogNode): integer
      begin
        result := round(left.date - right.date);
        if result = 0 then
          result := CompareText(Left.expandRevision, Right.expandRevision);
      end));
    result := 0;
  finally
    sl.Free;
    ss.Free;
    branches.Free;
  end;

end;

procedure TRepoHelperCVS.updateFilesState(files: TFilesList);
var
  FileInfo: TFileInfo;
  lastRepoIdx, lastFound: integer;
  repoItem: TCVSEntry; // TODO: do zmiany
  max: integer;
begin
  lastFound := 0;
  max := FEntries.Count - 1;
  for FileInfo in files do
  begin
    lastRepoIdx := lastFound;
    FileInfo.state := fsUnversioned;
    repeat
      repoItem := FEntries.Items[lastRepoIdx];
      if repoItem.name = FileInfo.fullPath then
      begin
        FileInfo.state := repoItem.state;
        FileInfo.revision := repoItem.revision;
        FileInfo.branch := repoItem.tagdate;
        lastFound := lastRepoIdx;
        break;
      end;
      inc(lastRepoIdx); // TODO: zoptymalizowaæ przez analizê œcie¿ki?
    until (lastRepoIdx >= max);
  end;
end;

{ TCVSRevision }

class function TCVSRevision.getBranchRev(const childRev: string): string;
var
  t: TArray<string>;
begin
  if childRev.CountChar('.') = 1 then
    exit('1.1');
  t := childRev.Split(['.']);
  t[length(t) - 1] := t[length(t) - 2];
  t[length(t) - 2] := '0';
  result := String.join('.', t);
end;

class function TCVSRevision.isSameBranch(const rev1, rev2: string): boolean;
var
  tmp0, tmp1: string;
begin
  if (rev1 = '') or (rev2 = '') then
    exit(false);
  tmp0 := rev1.Substring(0, rev1.LastIndexOf('.'));
  tmp1 := rev2.Substring(0, rev2.LastIndexOf('.'));
  result := tmp0 = tmp1;
end;

end.
