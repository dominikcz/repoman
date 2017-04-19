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
  public
    operation: THistOperation;
    user: string;
    dt: TDateTime;
    revision: string;
    filePath: string;
    comp: string;
  end;

  TRepoHistory = class(TObjectList<TRepoHistoryItem>)
  public
    constructor Create;
  end;

  IRepoHelper = interface
    procedure updateFilesState(files: TFilesList);
    procedure updateDirsState(dirs: TDirsList);
    procedure Init(root: string);
    function getUpdateCmd(item: TFileInfo): string;
    function diffFile(item: TFileInfo; out outputFile: string): integer;
    function getHistory(sinceDate: TDate; forUser: string; inBranch: string; output: TRepoHistory): integer;
    function getOnLogging: TProc<string>;
    procedure setOnLogging(Value: TProc<string>);
    property OnLogging: TProc<string> read getOnLogging write setOnLogging;
  end;

implementation

{ TRepoHistory }

constructor TRepoHistory.Create;
begin
  inherited Create(true);
end;

end.
