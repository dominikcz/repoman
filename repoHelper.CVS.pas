unit repoHelper.CVS;

interface

uses
  repoHelper,
  Models.FileInfo;

type
  TRepoHelperCVS = class(TInterfacedObject, IRepoHelper)
  public
    procedure updateFilesState(files: TFilesList);
  end;

implementation

{ TRepoHelperCVS }

procedure TRepoHelperCVS.updateFilesState(files: TFilesList);
begin

end;

end.
