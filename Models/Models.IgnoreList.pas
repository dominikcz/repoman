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
    FLoading: Boolean;
  public
    constructor Create(const ADir: string);
    procedure Load;
    function Add(const S: string): Integer; override;
    function Accepts(path: string): boolean;
  end;

implementation

uses
  System.IOUtils,
  SysUtils;

{ TIgnoreList }

function TIgnoreList.Accepts(path: string): boolean;
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

function TIgnoreList.Add(const S: string): Integer;
var
  sl: TStringList;
begin
  if FLoading then
  begin
    inherited Add(s);
    exit;
  end;

  sl := TStringList.Create;
  try
    if FileExists(FFileName) then
      sl.LoadFromFile(FFileName);
    result := sl.Add(S);
    sl.SaveToFile(FFileName);
    Load;
  finally
    sl.Free;
  end;
end;

constructor TIgnoreList.Create(const ADir: string);
begin
  inherited Create;
  FFileName := TPath.Combine(ADir, cIgnoreListFileName);
  if not FileExists(FFileName) then
    FFileName := TPath.Combine(ExtractFilePath(paramStr(0)), cIgnoreListFileName);
end;

procedure TIgnoreList.Load;
var
  i: Integer;
  s: string;
begin
  if FileExists(FFileName) then
  begin
    FLoading := true;
    self.LoadFromFile(FFileName);
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
    FLoading := false;
  end
  else
    self.Clear;
end;

end.
