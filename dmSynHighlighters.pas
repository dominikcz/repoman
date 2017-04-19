unit dmSynHighlighters;

interface

uses
  System.SysUtils, System.Classes, SynEditHighlighter, SynHighlighterPas, SynHighlighterXML,
  SynHighlighterUNIXShellScript, SynHighlighterSQL, SynHighlighterRuby, SynHighlighterRC, SynHighlighterPython,
  SynHighlighterPHP, SynHighlighterBat, SynHighlighterJSON, SynHighlighterJScript, SynHighlighterIni,
  SynHighlighterHtml, SynHighlighterCSS, SynHighlighterCpp, SynHighlighterCS, SynHighlighterDfm;

type
  TSynHighlighters = class(TDataModule)
    SynDfmSyn1: TSynDfmSyn;
    SynCSSyn1: TSynCSSyn;
    SynCppSyn1: TSynCppSyn;
    SynCssSyn1: TSynCssSyn;
    SynHTMLSyn1: TSynHTMLSyn;
    SynIniSyn1: TSynIniSyn;
    SynJScriptSyn1: TSynJScriptSyn;
    SynJSONSyn1: TSynJSONSyn;
    SynBatSyn1: TSynBatSyn;
    SynPHPSyn1: TSynPHPSyn;
    SynPythonSyn1: TSynPythonSyn;
    SynRCSyn1: TSynRCSyn;
    SynRubySyn1: TSynRubySyn;
    SynSQLSyn1: TSynSQLSyn;
    SynUNIXShellScriptSyn1: TSynUNIXShellScriptSyn;
    SynXMLSyn1: TSynXMLSyn;
    SynPasSyn1: TSynPasSyn;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    fHighLighters: TStringList;
  public
    { Public declarations }
    procedure GetRegisteredHighlighters(AHighlighters: TStringList; AppendToList: boolean);
    function GetHighlighterFromFileExt(Extension: string): TSynCustomHighlighter;
  end;

function SynHighlighters: TSynHighlighters;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

var
  vSynHighlighters: TSynHighlighters;

function SynHighlighters: TSynHighlighters;
begin
  if not Assigned(vSynHighlighters) then
    vSynHighlighters := TSynHighlighters.Create(nil);
  Result := vSynHighlighters;
end;

{ TSynHighlighters }

procedure TSynHighlighters.DataModuleCreate(Sender: TObject);
var
  i, ii: integer;
  highlighter: TSynCustomHighlighter;
  filter: string;
  filters: TArray<string>;
  item: string;
begin
  fHighLighters := TStringList.Create;
  for i := ComponentCount - 1 downto 0 do begin
    if not (Components[i] is TSynCustomHighlighter) then
      continue;
    highlighter := Components[i] as TSynCustomHighlighter;
    filter := highlighter.DefaultFilter.ToLower;
    filters := filter.Substring(filter.IndexOf('|')+1).Split([';']);
    for ii := 0 to length(filters) - 1 do
    begin
      item := StringReplace(filters[ii], '*', '', [rfReplaceAll]);
      if fHighlighters.IndexOf(item) = -1 then
        fHighlighters.AddObject(item, Highlighter);
    end;
  end;
  fHighlighters.Sorted := true;
end;

procedure TSynHighlighters.DataModuleDestroy(Sender: TObject);
begin
  fHighLighters.Free;
end;

function TSynHighlighters.GetHighlighterFromFileExt(Extension: string): TSynCustomHighlighter;
var
  idx: Integer;
begin
  Extension := LowerCase(Extension);
  idx := fHighLighters.IndexOf(Extension);
  if idx >= 0 then
    Result := TSynCustomHighlighter(fHighlighters.Objects[idx])
  else
    Result := nil;
end;

procedure TSynHighlighters.GetRegisteredHighlighters(AHighlighters: TStringList; AppendToList: boolean);
var
  i: integer;
  Highlighter: TSynCustomHighlighter;
begin
  if not AppendToList then
    AHighlighters.Clear;
  AHighlighters.Duplicates := dupIgnore;
  for i := 0 to fHighLighters.Count do
    AHighlighters.Add(TSynCustomHighlighter(fHighLighters.Objects[i]).GetFriendlyLanguageName);
  AHighlighters.Sort;
end;

initialization
  vSynHighlighters := nil;

finalization
  vSynHighlighters.Free;

end.
