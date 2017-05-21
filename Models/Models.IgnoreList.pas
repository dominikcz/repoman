unit Models.IgnoreList;

interface

uses
  Classes;

type
  TIgnoreList = class(TStringList)
  private
    const
      cIgnoreListFileName = 'ignorelist.repoman'; // DONT LOCALIZE
    type
      TMatchType = (mtContains, mtEndsWith, mtStartsWith);
  private
    FFileName: string;
    FDefFileName: string;
  public
    constructor Create;
    procedure Load(const ADir: string = '');
    procedure Compile;
    procedure Save;
    function Allows(path: string): boolean;
  end;

implementation

uses
  System.IOUtils,
  SysUtils;

{ TIgnoreList }

function TIgnoreList.Allows(path: string): boolean;
var
  i: Integer;
  s: string;
begin
  result := true;
  for i := 0 to Count - 1 do
  begin
    s := strings[i];
    case TMatchType(Objects[i]) of
      mtContains:
        result := not path.ToLower.Contains(s.ToLower);
      mtEndsWith:
        result := not path.EndsWith(s, true);
      mtStartsWith:
        result := not path.StartsWith(s, true);
    end;
    if not result then
      exit;
  end;
end;

constructor TIgnoreList.Create;
begin
  inherited Create;
  FFileName := '';
  FDefFileName := TPath.Combine(ExtractFilePath(paramStr(0)), cIgnoreListFileName);
end;

procedure TIgnoreList.Compile;
var
  i: Integer;
  s: string;
begin
  // "kompilujemy" filtry:
  // *... => mtEndsWith
  // ...* => mrStartsWith
  // ... => mtContains
  // konstrukcje typu ...*... czy *...* nie s¹ obslugiwane
  for i := 0 to Count - 1 do
  begin
    s := Strings[i];
    if s.StartsWith('*') then
      Objects[i] := TObject(ord(mtEndsWith))
    else if s.EndsWith('*') then
      Objects[i] := TObject(ord(mtStartsWith))
    else
      Objects[i] := TObject(ord(mtContains));
    Strings[i] := StringReplace(s, '*', '', [rfReplaceAll]);
  end;
end;

procedure TIgnoreList.Load(const ADir: string = '');
begin
  FFileName := TPath.Combine(ADir, cIgnoreListFileName);
  if not FileExists(FFileName) then
    FFileName := FDefFileName;
  if FileExists(FFileName) then
  begin
    self.LoadFromFile(FFileName);
    self.Compile;
  end
  else
    self.Clear;
end;

procedure TIgnoreList.Save;
begin
  if FFileName = '' then
    FFileName := FDefFileName;
  SaveToFile(FFileName);
end;

end.
