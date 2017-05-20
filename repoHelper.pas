unit repoHelper;

interface

uses
  Classes,
  SysUtils,
  Models.FileInfo,
  Models.LogInfo,
  Generics.Collections;

type
  THistOperation = (hoAdd, hoDel, hoMerge, hoCommit, hoTag);

  TRepoHistoryItem = class
  private
    function getDtAsStr: string;
  public
    dt: TDateTime;
    user: string;
    operation: THistOperation;
    revisionOrBranch: string;
    filePath: string;
    host: string;
    function operationAsStr: string;
    function dtAsIso: string;
    property dtAsStr: string read getDtAsStr;
  end;

  TRepoHistory = class(TObjectList<TRepoHistoryItem>)
  public
    constructor Create;
  end;

  IRepoHelper = interface
    procedure updateFilesState(files: TFilesList);
    procedure updateDirsState(dirs: TDirsList);
    procedure Init(root: string);
    function diffFile(item: TFileInfo; out outputFile: string; useCache: boolean): integer;
    function logFile(item: TFileInfo; out logNodes: TLogNodes; useCache: boolean): integer;
    function getHistory(sinceDate: TDate; forUser: string; inBranch: string; out history: TRepoHistory; useCache: boolean): integer;
    function annotateFile(item: TFileInfo; sinceRev: string; out outputFile: string; useCache: boolean): integer; overload;
    function annotateFile(item: TFileInfo; sinceDate: TDateTime; out outputFile: string; useCache: boolean): integer; overload;
    function getOnLogging: TProc<string>;
    function tryGetPrevRevision(sinceRev: string; out prevRev: string): boolean;
    procedure setOnLogging(Value: TProc<string>);

    function updateFiles(list: TFilesList; const cleanCopy: boolean = false): integer;
    function updateDir(dir: TDirinfo; const cleanCopy: boolean = false): integer;
    function updateAll(cleanCopy: boolean): integer;
    function updateModule(moduleName: string; cleanCopy: boolean): integer;
    function commit(list: TFilesList): integer;

    property OnLogging: TProc<string> read getOnLogging write setOnLogging;
  end;

implementation

uses
  whizaxe.common;

{ TRepoHistory }

constructor TRepoHistory.Create;
begin
  inherited Create(true);
end;

{ TRepoHistoryItem }

function TRepoHistoryItem.dtAsIso: string;
var
  FS: TFormatSettings;
begin
  FS := TFormatSettings.Create;
  result := FormatDateTime('yyyy-mm-dd hh:nn:ss', dt, FS);
end;

function TRepoHistoryItem.getDtAsStr: string;
begin
  result := WxU.DateTimeAsFriendlyStr(dt);
end;

function TRepoHistoryItem.operationAsStr: string;
begin
 case operation of
   hoAdd: result := 'A';
   hoDel: result := 'R';
   hoMerge: result := 'M';
   hoCommit: result := '?';
   hoTag: result := 'T';
 end;
end;

end.
