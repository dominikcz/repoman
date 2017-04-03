unit repoHelper;

interface

uses
  Models.FileInfo;

type
  IRepoHelper = interface
    procedure updateFilesState(files: TFilesList);
  end;

implementation

end.
