unit repoHelper;

interface

uses
  Classes,
  Models.FileInfo;

type
  IRepoHelper = interface
    procedure updateFilesState(files: TFilesList);
    procedure updateDirsState(dirs: TDirsList);
    procedure Init(root: string);
    function getUpdateCmd(item: TFileInfo): string;
    function diffFile(item: TFileInfo; out outputFile: string): integer;
  end;

implementation

end.
