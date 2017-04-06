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
    isConflict: boolean;
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
  SysUtils;

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
      for i := 0 to sl.Count -1 do
      begin
        if line.StartsWith('D/') then
        begin
          item := TCVSEntry.Create;
          tmp := line.Split(['/'], 3);
          item.isDir := true;
          item.name := TPath.Combine(line.Substring(2, line.Length - 4), tmp[1]);
          FEntries.Add(item);
        end;
      end;
    end;
  end;
end;

procedure TRepoHelperCVS.updateDirsState(dirs: TDirsList);
var
  dir: TDirInfo;
begin
  for dir in dirs do
  begin

  end;
end;

procedure TRepoHelperCVS.updateFilesState(files: TFilesList);
begin

end;

end.
