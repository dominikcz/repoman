unit repoHelper;

interface

uses
  Classes,
  SysUtils,
  Models.FileInfo,
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
    function getHistory(sinceDate: TDate; forUser: string; inBranch: string; out history: TRepoHistory; useCache: boolean): integer;
    function annotateFile(item: TFileInfo; sinceRev: string; out outputFile: string; useCache: boolean): integer; overload;
    function annotateFile(item: TFileInfo; sinceDate: TDateTime; out outputFile: string; useCache: boolean): integer; overload;
    function getOnLogging: TProc<string>;
    procedure setOnLogging(Value: TProc<string>);
    property OnLogging: TProc<string> read getOnLogging write setOnLogging;
  end;

implementation

uses
  DateUtils;

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
var
  delta: Integer;
  FS: TFormatSettings;
  sFormat: string;
begin
  FS := TFormatSettings.Create;
  delta := DaysBetween(now, dt);
  if delta < 7 then
    sFormat := 'ddd hh:nn'
  else if delta < 30 then
    sFormat := 'ddd dd mmm'
  else if YearsBetween(now, dt) = 0 then
    sFormat := 'dd mmm'
  else
    sFormat := 'yyyy-mm-dd';

  result := FormatDateTime(sFormat, dt, FS);
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
