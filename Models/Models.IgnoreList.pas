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
    FCompiledList: TStringList;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Load(const ADir: string = '');
    procedure Compile;
    procedure Save;
    procedure SaveDefault;
    function Allows(path: string): boolean; overload;
    function Allows(path: string; out ruleIdx: integer): boolean; overload;
  end;

implementation

uses
  System.IOUtils,
  SysUtils;

{ TIgnoreList }

function TIgnoreList.Allows(path: string): boolean;
var
  i: Integer;
begin
  result := Allows(path, i);
end;

function TIgnoreList.Allows(path: string; out ruleIdx: integer): boolean;
var
  i: Integer;
  s: string;
begin
  result := true;
  for i := 0 to FCompiledList.Count - 1 do
  begin
    s := FCompiledList.strings[i];
    case TMatchType(FCompiledList.Objects[i]) of
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
  Duplicates := dupIgnore;
  FFileName := '';
  FDefFileName := TPath.Combine(ExtractFilePath(paramStr(0)), cIgnoreListFileName);
  FCompiledList := TStringList.Create;
end;

destructor TIgnoreList.Destroy;
begin
  FCompiledList.Free;
  inherited;
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
  FCompiledList.Text := self.Text;
  for i := 0 to Count - 1 do
  begin
    s := Strings[i];
    if s.StartsWith('*') then
      FCompiledList.Objects[i] := TObject(ord(mtEndsWith))
    else if s.EndsWith('*') then
      FCompiledList.Objects[i] := TObject(ord(mtStartsWith))
    else
      FCompiledList.Objects[i] := TObject(ord(mtContains));
    FCompiledList.Strings[i] := StringReplace(s, '*', '', [rfReplaceAll]);
  end;
end;

procedure TIgnoreList.Load(const ADir: string = '');
var
  lFileName: string;
begin
  self.Clear;
  FCompiledList.Clear;
  FFileName := TPath.Combine(ADir, cIgnoreListFileName);
  if FileExists(FFileName) then
    lFileName := FFileName
  else
    lFileName := FDefFileName;
  if FileExists(lFileName) then
  begin
    LoadFromFile(lFileName);
    self.Compile;
  end;
end;

procedure TIgnoreList.Save;
begin
  SaveToFile(FFileName);
end;

procedure TIgnoreList.SaveDefault;
begin
  SaveToFile(FDefFileName);
end;

end.
