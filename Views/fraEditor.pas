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
    procedure codeEditorEnter(Sender: TObject);
    procedure codeEditorExit(Sender: TObject);
    procedure codeEditorSpecialLineColors(Sender: TObject; Line: Integer; var Special: Boolean; var FG, BG: TColor);
  private
    FDiff: TDiff;
    FisCurrent: boolean;
    FFileName: string;
    FisUpdating: boolean;
    FShowDiffsOnly: boolean;
    function GetTopVisibleLine: Integer;
    procedure SetTopVisibleLine(const Value: Integer);
    { Private declarations }
  public
    { Public declarations }
    procedure LoadFile(AFileName: string);
    procedure Reload;
    procedure Save;
    procedure ScrollTo(Y, max: Integer);
    procedure ScrollToLine(Y: Integer);
    procedure GetSource(lines: TStrings);
    procedure GetHashedSource(list: TList; ignoreCase, ignoreBlanks: boolean);

    property TopVisibleLine: Integer read GetTopVisibleLine write SetTopVisibleLine;
    property Diff: TDiff read FDiff write FDiff;
    property isCurrent: boolean read FisCurrent write FisCurrent;
    property isUpdating: boolean read FisUpdating write FisUpdating;
    property ShowDiffsOnly: boolean read FShowDiffsOnly write FShowDiffsOnly;
  end;

implementation

{$R *.dfm}

uses
  whizaxe.Math,
  HashUnit,
  frmDiff.utils,
  dmSynHighlighters,
  whizaxe.common;

procedure TFrameEditor.codeEditorEnter(Sender: TObject);
begin
  pnlCaption.Color := clActiveCaption;
end;

procedure TFrameEditor.codeEditorExit(Sender: TObject);
begin
  pnlCaption.Color := clInactiveCaption;
end;

procedure TFrameEditor.codeEditorGutterGetText(Sender: TObject; aLine: Integer; var aText: string);
var
  idx: Integer;
begin
  if isUpdating then
    exit;
  if Assigned(Diff) then
  begin
    if fShowDiffsOnly then
      idx := integer(codeEditor.lines.Objects[aLine -1])
    else
      idx := aLine -1;
    aText := '';
    if idx < 0 then
      exit;

    if isCurrent then
      case Diff.Compares[idx].Kind of
        ckNone, ckModify:
          aText := IntToStr(Diff.Compares[idx].oldIndex2 + 1);
        ckAdd:
          aText := IntToStr(Diff.Compares[idx].oldIndex2 + 1);
      end
    else
      case Diff.Compares[idx].Kind of
        ckNone, ckModify:
          aText := IntToStr(Diff.Compares[idx].oldIndex1 + 1);
        ckDelete:
          aText := IntToStr(Diff.Compares[idx].oldIndex1 + 1);
      end
  end
  else
    aText := IntToStr(aLine);
end;

procedure TFrameEditor.codeEditorSpecialLineColors(Sender: TObject; Line: Integer; var Special: Boolean; var FG,
  BG: TColor);
var
  kind: TChangeKind;
  idx: Integer;
begin
  if isUpdating then
    exit;
  if Assigned(Diff) and (Diff.Count > 0) then
  begin
//    idx := integer(codeEditor.Lines.Objects[Line - 1]);
    idx := Line - 1;
    if idx < 0 then
      exit;
    kind := Diff.Compares[idx].Kind;
    if kind = ckNone then
      exit;
    Special := true;
    case kind of
      ckModify:
        BG := modClr;
//        len1 := length(s);
//        len2 := length(ss);
//        //nb: with v. rapid line changes it's possible for Execute to return false
//        if not Diff1.Execute(pchar(s),pchar(ss),len1,len2) then exit;
//        Handled := true;
//        canvas.FillRect(rec);
//        lastKind := ckNone;
//        s := lines[LineNo];
//        ss := '';
//        sss := '';
//        for i := 0 to Diff1.Count-1 do
//          case Diff1[i].Kind of
//            ckNone,ckDelete,ckModify:
//              begin
//                AddStrClr(ss,sss,s[Diff1[i].oldIndex1+1], Diff1[i].Kind, lastKind);
//                lastKind := Diff1[i].Kind;
//              end;
//          end;
//        MarkupTextOut(canvas, rec, TextLeft,rec.Top,ss,sss,[modClr, MakeDarker(modClr)]);
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
  FFileName := AFileName;
  codeEditor.lines.LoadFromFile(FFileName);
  pnlCaption.caption := '  ' + FFileName;
  codeEditor.Highlighter := SynHighlighters.GetHighlighterFromFileExt(ExtractFileExt(FFileName));
end;

procedure TFrameEditor.Reload;
begin
  codeEditor.Lines.LoadFromFile(FFileName);
end;

procedure TFrameEditor.Save;
begin
  SafeRenameFile(FFileName, '.bak');
  codeEditor.Lines.SaveToFile(FFileName);
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
