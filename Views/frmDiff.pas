unit frmDiff;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Searches, FindReplace, HashUnit, Diff, CodeEditor;

type
  TDiffForm = class(TForm)
    pbScrollPosMarker: TPaintBox;
    pnlMain: TPanel;
    Splitter1: TSplitter;
    pnlLeft: TPanel;
    pnlCaptionLeft: TPanel;
    pnlRight: TPanel;
    pnlCaptionRight: TPanel;
    pnlNavigation: TPanel;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    Diff: TDiff;
    Diff1: TDiff;
    Diff2: TDiff;
    Lines1, Lines2: TStrings;
    fStatusbarStr: string;
    CaretPosY: integer;
    pbDiffMarkerBmp: TBitmap;
    Search: TSearch;
    FindInfo: TFindInfo;
    fn1, fn2: string;
    fa1, fa2: TDateTime;
    isUniCode1, isUniCode2: boolean;
    CodeEdit1: TCodeEdit;
    CodeEdit2: TCodeEdit;
    FilesCompared: boolean;

    procedure PaintLeftMargin(Sender: TObject; Canvas: TCanvas;
      MarginRec: TRect; LineNo, Tag: integer);
    procedure SyncScroll(Sender: TObject);
    procedure CodeEditOnEnter(Sender: TObject);
    procedure CodeEditOnExit(Sender: TObject);
    procedure CodeEditOnPaintLine1(Sender: TObject; LineNo: integer;
      Rec: TRect; TextLeft: integer; var Handled: boolean);
    procedure CodeEditOnPaintLine2(Sender: TObject; LineNo: integer;
      Rec: TRect; TextLeft: integer; var Handled: boolean);
    procedure ToggleCodeEditModified(IsCodeEdit1, IsModified: boolean);
    procedure CodeEditLinesOnChange(Sender: TObject);
    function CaretInClrBlk(CodeEdit: TCodeEdit): boolean;
    procedure CodeEditOnCaretPtChange(Sender: TObject);
    function FindNext(CodeEdit: TCodeEdit): boolean;
    function FindPrevious(CodeEdit: TCodeEdit): boolean;
    procedure ReplaceDown(CodeEdit: TCodeEdit);
    procedure ReplaceUp(CodeEdit: TCodeEdit);

    procedure OpenClick(Sender: TObject);
    procedure CompareClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
    procedure HorzSplitClick(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure PrevClick(Sender: TObject);
    procedure SaveReportClick(Sender: TObject);
    procedure CodeEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CopyBlockLeftClick(Sender: TObject);
    procedure CopyBlockRightClick(Sender: TObject);
    procedure UndoClick(Sender: TObject);
    procedure RedoClick(Sender: TObject);
    procedure EditClick(Sender: TObject);
    procedure CutClick(Sender: TObject);
    procedure CopyClick(Sender: TObject);
    procedure PasteClick(Sender: TObject);
    procedure FindClick(Sender: TObject);
    procedure FindNextClick(Sender: TObject);
    procedure ReplaceClick(Sender: TObject);
    procedure FontClick(Sender: TObject);
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TDiffForm.CancelClick(Sender: TObject);
begin

end;

function TDiffForm.CaretInClrBlk(CodeEdit: TCodeEdit): boolean;
begin

end;

procedure TDiffForm.CodeEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin

end;

procedure TDiffForm.CodeEditLinesOnChange(Sender: TObject);
begin

end;

procedure TDiffForm.CodeEditOnCaretPtChange(Sender: TObject);
begin

end;

procedure TDiffForm.CodeEditOnEnter(Sender: TObject);
begin

end;

procedure TDiffForm.CodeEditOnExit(Sender: TObject);
begin

end;

procedure TDiffForm.CodeEditOnPaintLine1(Sender: TObject; LineNo: integer; Rec: TRect; TextLeft: integer;
  var Handled: boolean);
begin

end;

procedure TDiffForm.CodeEditOnPaintLine2(Sender: TObject; LineNo: integer; Rec: TRect; TextLeft: integer;
  var Handled: boolean);
begin

end;

procedure TDiffForm.CompareClick(Sender: TObject);
begin

end;

procedure TDiffForm.CopyBlockLeftClick(Sender: TObject);
begin

end;

procedure TDiffForm.CopyBlockRightClick(Sender: TObject);
begin

end;

procedure TDiffForm.CopyClick(Sender: TObject);
begin

end;

procedure TDiffForm.CutClick(Sender: TObject);
begin

end;

procedure TDiffForm.EditClick(Sender: TObject);
begin

end;

procedure TDiffForm.FindClick(Sender: TObject);
begin

end;

function TDiffForm.FindNext(CodeEdit: TCodeEdit): boolean;
begin

end;

procedure TDiffForm.FindNextClick(Sender: TObject);
begin

end;

function TDiffForm.FindPrevious(CodeEdit: TCodeEdit): boolean;
begin

end;

procedure TDiffForm.FontClick(Sender: TObject);
begin

end;

procedure TDiffForm.FormCreate(Sender: TObject);
begin
  //the diff engine ...
  Diff := TDiff.create(self);
  Diff1 := TDiff.create(self);
  Diff2 := TDiff.create(self);

  //lines1 & lines2 contain the unmodified files
  Lines1 := TStringList.create;
  Lines2 := TStringList.create;

  //edit windows where color highlighing of diffs and changes are displayed ...
  CodeEdit1 := TCodeEdit.create(self);
  with CodeEdit1 do
  begin
    parent := pnlLeft;
    Align := alClient;
    Lines.OnChange := CodeEditLinesOnChange;
    OnCaretPtChange := CodeEditOnCaretPtChange;
    OnPaintLeftMargin := PaintLeftMargin;
    OnEnter := CodeEditOnEnter;
    OnExit := CodeEditOnExit;
    OnPaintLine := CodeEditOnPaintLine1;
    OnKeyDown := CodeEditKeyDown;
  end;
  CodeEdit2 := TCodeEdit.create(self);
  with CodeEdit2 do
  begin
    parent := pnlRight;
    Align := alClient;
    Lines.OnChange := CodeEditLinesOnChange;
    OnCaretPtChange := CodeEditOnCaretPtChange;
    OnPaintLeftMargin := PaintLeftMargin;
    OnEnter := CodeEditOnEnter;
    OnExit := CodeEditOnExit;
    OnPaintLine := CodeEditOnPaintLine2;
    OnKeyDown := CodeEditKeyDown;
  end;
  Search := TSearch.Create(self);

  CaretPosY := -1;
  pbScrollPosMarker.Canvas.Pen.Color := clBlack;
  pbScrollPosMarker.Canvas.Pen.Width := 1;

  pbDiffMarkerBmp := TBitmap.create;
  pbDiffMarkerBmp.Canvas.Brush.Color := clWindow;
end;

procedure TDiffForm.FormResize(Sender: TObject);
begin
  pnlLeft.Width := (ClientWidth - pnlNavigation.Width) div 2;
end;

procedure TDiffForm.HorzSplitClick(Sender: TObject);
begin

end;

procedure TDiffForm.NextClick(Sender: TObject);
begin

end;

procedure TDiffForm.OpenClick(Sender: TObject);
begin

end;

procedure TDiffForm.PaintLeftMargin(Sender: TObject; Canvas: TCanvas; MarginRec: TRect; LineNo, Tag: integer);
begin

end;

procedure TDiffForm.PasteClick(Sender: TObject);
begin

end;

procedure TDiffForm.PrevClick(Sender: TObject);
begin

end;

procedure TDiffForm.RedoClick(Sender: TObject);
begin

end;

procedure TDiffForm.ReplaceClick(Sender: TObject);
begin

end;

procedure TDiffForm.ReplaceDown(CodeEdit: TCodeEdit);
begin

end;

procedure TDiffForm.ReplaceUp(CodeEdit: TCodeEdit);
begin

end;

procedure TDiffForm.SaveReportClick(Sender: TObject);
begin

end;

procedure TDiffForm.SyncScroll(Sender: TObject);
begin

end;

procedure TDiffForm.ToggleCodeEditModified(IsCodeEdit1, IsModified: boolean);
begin

end;

procedure TDiffForm.UndoClick(Sender: TObject);
begin

end;

end.
