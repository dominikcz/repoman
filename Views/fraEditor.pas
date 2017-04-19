unit fraEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SynEdit, Vcl.ExtCtrls, SynEditSearch, SynEditMiscClasses,
  Diff;

type
  TFrameEditor = class(TFrame)
    pnlEditor: TPanel;
    pnlCaption: TPanel;
    codeEditor: TSynEdit;
    SynEditSearch1: TSynEditSearch;
    procedure codeEditorGutterGetText(Sender: TObject; aLine: Integer; var aText: string);
    procedure codeEditorGutterPaint(Sender: TObject; aLine, X, Y: Integer);
    procedure codeEditorEnter(Sender: TObject);
    procedure codeEditorExit(Sender: TObject);
    procedure codeEditorSpecialLineColors(Sender: TObject; Line: Integer; var Special: Boolean; var FG, BG: TColor);
  private
    FDiff: TDiff;
    FisCurrent: boolean;
    function GetTopVisibleLine: Integer;
    procedure SetTopVisibleLine(const Value: Integer);
    { Private declarations }
  public
    { Public declarations }
    procedure LoadFile(AFileName: string);
    procedure ScrollTo(Y, max: Integer);
    procedure ScrollToLine(Y: Integer);
    procedure GetSource(lines: TStrings);
    procedure GetHashedSource(list: TList; ignoreCase, ignoreBlanks: boolean);

    property TopVisibleLine: Integer read GetTopVisibleLine write SetTopVisibleLine;
    property Diff: TDiff read FDiff write FDiff;
    property isCurrent: boolean read FisCurrent write FisCurrent;
  end;

implementation

{$R *.dfm}

uses
  whizaxe.Math,
  HashUnit,
  frmDiff.utils,
  dmSynHighlighters;

procedure TFrameEditor.codeEditorEnter(Sender: TObject);
begin
  pnlCaption.Color := clActiveCaption;
end;

procedure TFrameEditor.codeEditorExit(Sender: TObject);
begin
  pnlCaption.Color := clInactiveCaption;
end;

procedure TFrameEditor.codeEditorGutterGetText(Sender: TObject; aLine: Integer; var aText: string);
begin
  if Assigned(Diff) then
  begin
    aText := '';
    case Diff.Compares[aLine].Kind of
      ckNone, ckModify:
        aText := IntToStr(aLine);
      ckAdd:
        if isCurrent then
          aText := IntToStr(aLine);
      ckDelete:
        if not isCurrent then
          aText := IntToStr(aLine);
    end;
  end
  else
    aText := IntToStr(aLine);
end;

procedure TFrameEditor.codeEditorGutterPaint(Sender: TObject; aLine, X, Y: Integer);
var
  newWidth: Integer;
begin
  newWidth := trunc(codeEditor.CharWidth * (Log10(codeEditor.lines.Count) + 1));
  if codeEditor.Gutter.Width <> newWidth then
    codeEditor.Gutter.Width := newWidth;
end;

procedure TFrameEditor.codeEditorSpecialLineColors(Sender: TObject; Line: Integer; var Special: Boolean; var FG,
  BG: TColor);
var
  kind: TChangeKind;
begin
  if Assigned(Diff) then
  begin
    kind := Diff.Compares[Line - 1].Kind;
    if kind = ckNone then
      exit;
    Special := true;
    case kind of
      ckModify:
        BG := modClr;
      ckAdd:
        if isCurrent then BG := addClr else BG := grayColor;
      ckDelete:
        if isCurrent then BG := grayColor else BG := delClr;
    end;
  end
end;

procedure TFrameEditor.GetHashedSource(list: TList; ignoreCase, ignoreBlanks: boolean);
var
  i: Integer;
  kind: TChangeKind;
  max: Integer;
begin
  list.Clear;
  if not assigned(Diff) then
    exit;

  max := codeEditor.Lines.Count;
  if diff.Count = max then
    for i := 0 to max - 1 do
    begin
      kind := diff.Compares[i].Kind;
      if (kind in [ckNone, ckModify]) or ((kind = ckAdd) and isCurrent) then
        list.Add(HashLine(codeEditor.Lines[i], ignoreCase, ignoreBlanks));
    end
  else
    for i := 0 to max - 1 do
      list.Add(HashLine(codeEditor.Lines[i], ignoreCase, ignoreBlanks));
end;

procedure TFrameEditor.GetSource(lines: TStrings);
var
  i: Integer;
  kind: TChangeKind;
  max: Integer;
begin
  lines.Clear;
  if not assigned(Diff) then
    exit;

  max := codeEditor.Lines.Count;
  if diff.Count = max then
    for i := 0 to max - 1 do
    begin
      kind := diff.Compares[i].Kind;
      if (kind in [ckNone, ckModify]) or ((kind = ckAdd) and isCurrent) then
        lines.Add(codeEditor.Lines[i]);
    end
  else
    lines.AddStrings(codeEditor.Lines);
end;

function TFrameEditor.GetTopVisibleLine: Integer;
begin
  result := codeEditor.TopLine;
end;

procedure TFrameEditor.LoadFile(AFileName: string);
begin
  if not FileExists(AFileName) then
    exit;
  codeEditor.lines.LoadFromFile(AFileName);
  pnlCaption.caption := '  ' + AFileName;
  codeEditor.Highlighter := SynHighlighters.GetHighlighterFromFileExt(ExtractFileExt(AFileName));
end;

procedure TFrameEditor.ScrollTo(Y, max: Integer);
begin
  with codeEditor do
    TopLine := (lines.Count * Y div max) + 1;
end;

procedure TFrameEditor.ScrollToLine(Y: Integer);
begin
  codeEditor.TopLine := Y;
end;

procedure TFrameEditor.SetTopVisibleLine(const Value: Integer);
begin
  codeEditor.TopLine := Value;
end;

end.
