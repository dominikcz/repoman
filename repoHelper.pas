unit repoHelper;

interface

uses
  Models.FileInfo;

type
  IRepoHelper = interface
    procedure updateFilesState(files: TFilesList);
    procedure updateDirsState(dirs: TDirsList);
    procedure Init(root: string);
  end;

implementation

end.
