unit frmDiff;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,
  Searches, FindReplace, HashUnit, Diff, CodeEditor, System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList,
  PngImageList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, Vcl.ToolWin, Vcl.ActnCtrls;

type
  TDiffOptions = record
    showInlineDiffs: boolean;
    ignoreCase: boolean;
    ignoreBlanks: boolean;
  end;

  TDiffForm = class(TForm)
    pbScrollPosMarker: TPaintBox;
    pnlMain: TPanel;
    Splitter1: TSplitter;
    pnlLeft: TPanel;
    pnlCaptionLeft: TPanel;
    pnlRight: TPanel;
    pnlCaptionRight: TPanel;
    pnlNavigation: TPanel;
    StatusBar: TStatusBar;
    PngImageList1: TPngImageList;
    ActionList1: TActionList;
    actSave: TAction;
    actUndo: TAction;
    actRedo: TAction;
    actNext: TAction;
    actPrev: TAction;
    actCurrent: TAction;
    actFirst: TAction;
    actLast: TAction;
    actCopyRight: TAction;
    actCopyLeft: TAction;
    actCopyRightAndNext: TAction;
    actCopyLeftAndNext: TAction;
    actAllRight: TAction;
    actAllLeft: TAction;
    actRefresh: TAction;
    ActionToolBar1: TActionToolBar;
    ActionManager1: TActionManager;
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure pbScrollPosMarkerPaint(Sender: TObject);
    procedure pbScrollPosMarkerMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pbScrollPosMarkerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
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

    procedure DoOpenFile(const Filename: string; IsFile1: boolean);
    procedure PaintLeftMargin(Sender: TObject; Canvas: TCanvas;
      MarginRec: TRect; LineNo, Tag: integer);
    procedure SyncScroll(Sender: TObject);
    procedure CodeEditOnEnter(Sender: TObject);
    procedure CodeEditOnExit(Sender: TObject);
    procedure CodeEditOnPaintLine1(Sender: TObject; LineNo: integer; Rec: TRect; TextLeft: integer; var Handled: boolean);
    procedure CodeEditOnPaintLine2(Sender: TObject; LineNo: integer; Rec: TRect; TextLeft: integer; var Handled: boolean);
    procedure ToggleCodeEditModified(IsCodeEdit1, IsModified: boolean);
    procedure ToggleLinkedScroll(IsLinked: boolean);
    procedure CodeEditLinesOnChange(Sender: TObject);
    function CaretInClrBlk(CodeEdit: TCodeEdit): boolean;
    procedure CodeEditOnCaretPtChange(Sender: TObject);

    procedure CompareClick(Sender: TObject);
    procedure HorzSplitClick(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure PrevClick(Sender: TObject);
    procedure CodeEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure CopyBlockLeftClick(Sender: TObject);
    procedure CopyBlockRightClick(Sender: TObject);
    procedure UndoClick(Sender: TObject);
    procedure RedoClick(Sender: TObject);
    procedure EditClick(Sender: TObject);
    procedure CutClick(Sender: TObject);
    procedure CopyClick(Sender: TObject);
    procedure PasteClick(Sender: TObject);

    procedure DisplayDiffs;
    procedure UpdateDiffMarkerBmp;
  public
    { Public declarations }
    options: TDiffOptions;

    procedure Load(fileName1, fileName2: string);
  end;

implementation

{$R *.dfm}

uses
  frmDiff.utils;

var
  addClr, delClr, modClr: TColor;
  shortDateFmt: string;

const
  defaultAddClr = $05cbef;  // ¿ó³ty: #efcb05 -> jaœniejszy: #f1e2ad
  defaultModClr = $9FFDB3;  // czerwony: #ef7774 -> #ffa0a0
  defaultDelClr = $B7ABFF;  // szary: #c0c0c0

function TDiffForm.CaretInClrBlk(CodeEdit: TCodeEdit): boolean;
begin
  with CodeEdit do
    result := assigned(CodeEdit.Partner) and (CaretPt.Y < lines.Count) and
      (lines.LineObj[CaretPt.Y].BackClr <> clWindow) and
      not lines.LineObj[CaretPt.Y].LineModified;
end;

procedure TDiffForm.CodeEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if not assigned(CodeEdit1.Partner) or
    (Shift * [ssAlt,ssCtrl] <> [ssAlt,ssCtrl]) then exit;
  if (key = VK_RIGHT) and CaretInClrBlk(CodeEdit1) then
    CopyBlockRightClick(nil)
  else if (key = VK_LEFT) and CaretInClrBlk(CodeEdit2) then
    CopyBlockLeftClick(nil);
end;

procedure TDiffForm.CodeEditLinesOnChange(Sender: TObject);
begin
  ToggleCodeEditModified(Sender = CodeEdit1.Lines, true);
  ToggleLinkedScroll(false);
end;

procedure TDiffForm.CodeEditOnCaretPtChange(Sender: TObject);
var
  caretInClrBlock: boolean;
begin
  if not assigned(CodeEdit1.Partner) or not TCodeEdit(Sender).Focused then exit;
  caretInClrBlock := CaretInClrBlk(TCodeEdit(Sender)); //ie calls function once
//  MainForm.mnuCopyBlockRight.Enabled := caretInClrBlock and (Sender = CodeEdit1);
//  MainForm.mnuCopyBlockLeft.Enabled := caretInClrBlock and (Sender = CodeEdit2);
end;

procedure TDiffForm.CodeEditOnEnter(Sender: TObject);
begin
  //keep compared (and unedited) text carets in sync ...
  if assigned(CodeEdit1.Partner) and (CaretPosY >= 0) then
    with TCodeEdit(Sender) do CaretPt := Point(0,CaretPosY);
end;

procedure TDiffForm.CodeEditOnExit(Sender: TObject);
begin
  //keep compared text carets in sync too ...
  with TCodeEdit(Sender) do
    if (CaretPt.Y >= TopVisibleLine) and
      (CaretPt.Y <= TopVisibleLine + VisibleLines) then
      CaretPosY := CaretPt.Y
    else
      CaretPosY := -1;
end;

procedure TDiffForm.CodeEditOnPaintLine1(Sender: TObject; LineNo: integer; Rec: TRect; TextLeft: integer;
  var Handled: boolean);
var
  i,len1, len2: integer;
  s, ss, sss: string;
  lastKind: TChangeKind;
begin
  with CodeEdit1 do
  begin
    //if it's not an unedited 'modified' line then markup inline differences
    if not options.showInlineDiffs or
      not assigned(Partner) or
      lines.LineObj[LineNo].LineModified or
      (lines.LineObj[LineNo].BackClr <> modClr) then exit;
    if options.ignoreCase then
    begin
      s := AnsiUpperCase(lines[LineNo]);
      ss := AnsiUpperCase(Partner.lines[LineNo]);
    end else
    begin
      s := lines[LineNo];
      ss := Partner.lines[LineNo];
    end;
    len1 := length(s);
    len2 := length(ss);
    //nb: with v. rapid line changes it's possible for Execute to return false
    if not Diff1.Execute(pchar(s),pchar(ss),len1,len2) then exit;
    Handled := true;
    canvas.FillRect(rec);
    lastKind := ckNone;
    s := lines[LineNo];
    ss := '';
    sss := '';
    for i := 0 to Diff1.Count-1 do
      case Diff1[i].Kind of
        ckNone,ckDelete,ckModify:
          begin
            AddStrClr(ss,sss,s[Diff1[i].oldIndex1+1], Diff1[i].Kind, lastKind);
            lastKind := Diff1[i].Kind;
          end;
      end;
    MarkupTextOut(canvas, rec, TextLeft,rec.Top,ss,sss,[modClr, MakeDarker(modClr)]);
  end;
end;

procedure TDiffForm.CodeEditOnPaintLine2(Sender: TObject; LineNo: integer; Rec: TRect; TextLeft: integer;
  var Handled: boolean);
var
  i,len1, len2: integer;
  s, ss, sss: string;
  lastKind: TChangeKind;
begin
  with CodeEdit2 do
  begin
    //if it's not an unedited 'modified' line then markup inline differences
    if not options.showInlineDiffs or
      not assigned(Partner) or
      lines.LineObj[LineNo].LineModified or
      (lines.LineObj[LineNo].BackClr <> modClr) then exit;
    if options.ignoreCase then
    begin
      s := AnsiUpperCase(Partner.lines[LineNo]);
      ss := AnsiUpperCase(lines[LineNo]);
    end else
    begin
      s := Partner.lines[LineNo];
      ss := lines[LineNo];
    end;
    len1 := length(s);
    len2 := length(ss);
    //nb: with v. rapid line changes it's possible for Execute to return false
    if not Diff2.Execute(pchar(s),pchar(ss),len1,len2) then exit;
    Handled := true;
    canvas.FillRect(rec);
    lastKind := ckNone;
    s := '';
    ss := lines[LineNo];
    sss := '';
    for i := 0 to Diff2.Count-1 do
      case Diff2[i].Kind of
        ckNone,ckAdd,ckModify:
          begin
            AddStrClr(s,sss, ss[Diff2[i].oldIndex2+1], Diff2[i].Kind, lastKind);
            lastKind := Diff2[i].Kind;
          end;
      end;
    MarkupTextOut(canvas, rec, TextLeft,rec.Top,s,sss,[modClr, MakeDarker(modClr)]);
  end;
end;

procedure TDiffForm.CompareClick(Sender: TObject);
var
  i: integer;
  HashList1,HashList2: TList;
begin
  if (Lines1.Count = 0) or (Lines2.Count = 0) then exit;

  CodeEdit1.Color := clWindow;
  CodeEdit2.Color := clWindow;

  //THIS PROCEDURE IS WHERE ALL THE HEAVY LIFTING (COMPARING) HAPPENS ...
  screen.Cursor := crHourglass;
  HashList1 := TList.create;
  HashList2 := TList.create;
  try
    //Create the hash lists used to compare line differences.
    //nb - there is a small possibility of different lines hashing to the
    //same value. However the probability of an invalid match occuring
    //in proximity to its invalid partner is remote. Ideally, these hash
    //collisions should be managed by ? incrementing the hash value.
    HashList1.capacity := Lines1.Count;
    HashList2.capacity := Lines2.Count;
    for i := 0 to Lines1.Count-1 do
      HashList1.add(HashLine(Lines1[i], options.ignoreCase, options.ignoreBlanks));
    for i := 0 to Lines2.Count-1 do
      HashList2.add(HashLine(Lines2[i],options.ignoreCase, options.ignoreBlanks));
//    mnuCompare.Enabled := false;
//    tbCompare.Enabled := false;
//    mnuCancel.ShortCut := Shortcut(27,[]);
    try
//      mnuCancel.Enabled := true;
//      tbCancel.Enabled := true;
      //CALCULATE THE DIFFS HERE ...
      Diff.Execute(PInteger(HashList1.List),PInteger(HashList2.List),
        HashList1.count, HashList2.count);
      DisplayDiffs;
    finally
//      mnuCompare.Enabled := true;
//      tbCompare.Enabled := true;
//      mnuCancel.Enabled := false;
//      tbCancel.Enabled := false;
//      mnuCancel.ShortCut := 0;
    end;
    ToggleLinkedScroll(true);
    ToggleCodeEditModified(true, false);
    ToggleCodeEditModified(false, false);
    ActiveControl := CodeEdit1;
//    mnuNext.Enabled := true;
//    mnuPrev.Enabled := true;
//    tbNext.Enabled := true;
//    tbPrev.Enabled := true;
//    mnuSaveReport.Enabled := true;
  finally
    HashList1.Free;
    HashList2.Free;
    screen.Cursor := crDefault;
  end;
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

procedure TDiffForm.DisplayDiffs;
var
  i: integer;
  linesSame, linesAdd, linesMod, linesDel: integer;

  procedure AddAndFormat(CodeEdit: TCodeEdit; const Text: string; Color: TColor; num: longint);
  var
    i: integer;
  begin
    i := CodeEdit.Lines.Add(Text);
    with CodeEdit.Lines.LineObj[i] do
    begin
      BackClr := Color;
      Tag := num;
    end;
  end;

begin

  //THIS IS WHERE THE TDIFF RESULT IS CONVERTED INTO COLOR HIGHLIGHTING ...

  linesSame := 0; linesAdd := 0; linesMod := 0; linesDel := 0;
  CodeEdit1.Lines.BeginUpdate;
  CodeEdit2.Lines.BeginUpdate;
  try
    CodeEdit1.Lines.Clear;
    CodeEdit2.Lines.Clear;
    CodeEdit1.AutoLineNum := false;
    CodeEdit2.AutoLineNum := false;
    CodeEdit1.GutterWidth := trunc(CodeEdit1.CharWidth*(Log10(Lines1.Count)+1));
    CodeEdit2.GutterWidth := trunc(CodeEdit2.CharWidth*(Log10(Lines2.Count)+1));

    with Diff do
    for i := 0 to Count-1 do
      with Compares[i] do
        case Kind of
          ckNone:
            begin
             inc(linesSame);
//             if mnuShowDiffsOnly.Checked  then continue;
             AddAndFormat(CodeEdit1, lines1[oldIndex1],clWindow,oldIndex1+1);
             AddAndFormat(CodeEdit2, lines2[oldIndex2],clWindow,oldIndex2+1);
            end;
          ckAdd:
            begin
              AddAndFormat(CodeEdit1, '',addClr, 0);
              AddAndFormat(CodeEdit2,lines2[oldIndex2],addClr,oldIndex2+1);
              inc(linesAdd);
            end;
          ckDelete:
            begin
              AddAndFormat(CodeEdit1,lines1[oldIndex1],delClr,oldIndex1+1);
              AddAndFormat(CodeEdit2, '',delClr,0);
              inc(linesDel);
            end;
          ckModify:
            begin
              AddAndFormat(CodeEdit1,lines1[oldIndex1],modClr,oldIndex1+1);
              AddAndFormat(CodeEdit2,lines2[oldIndex2],modClr,oldIndex2+1);
              inc(linesMod);
            end;
        end;

  finally
    CodeEdit1.Lines.EndUpdate;
    CodeEdit2.Lines.EndUpdate;
    CodeEdit1.Lines.Modified := false;
    CodeEdit2.Lines.Modified := false;
    UpdateDiffMarkerBmp;
    pbScrollPosMarker.Repaint;
  end;

  fStatusbarStr := '';
  if options.ignoreCase then
    fStatusbarStr := 'Case Ignored';
  if options.ignoreBlanks then
    if fStatusbarStr = '' then
      fStatusbarStr := 'Blanks Ignored' else
      fStatusbarStr := fStatusbarStr + ', Blanks Ignored';
  if fStatusbarStr <> '' then
    fStatusbarStr := '  ('+fStatusbarStr+')';

  if (linesAdd = 0) and (linesMod = 0) and (linesDel = 0) then
    fStatusbarStr := format('  No differences.  %s', [ fStatusbarStr])
  else
    fStatusbarStr :=
      format('  %d lines unchanged,  %d lines added, %d lines modified, %d lines deleted.  %s',
        [ linesSame, linesAdd, linesMod, linesDel, fStatusbarStr]);
  Statusbar.Panels[3].text := fStatusbarStr;
end;

procedure TDiffForm.DoOpenFile(const Filename: string; IsFile1: boolean);
var
  CodeEdit: TCodeEdit;
begin
  if not fileexists(Filename) then exit;
  ToggleLinkedScroll(false);
  if IsFile1 then
  begin
    CodeEdit := CodeEdit1;
    Lines1.LoadFromFile(filename);
    //Lines1.LoadFromFile(filename);
    CodeEdit.Lines.Assign(Lines1);
    fn1 := Filename;
    fileAge(fn1, fa1);
    pnlCaptionLeft.caption := '  '+ filename;
  end
  else
  begin
    CodeEdit := CodeEdit2;
    Lines2.LoadFromFile(filename);
    //Lines2.LoadFromFile(filename);
    CodeEdit.Lines.Assign(Lines2);
    fn2 := Filename;
    fileAge(fn2, fa2);
    pnlCaptionRight.caption := '  '+ filename;
  end;
  CodeEdit.AutoLineNum := true;
  ToggleCodeEditModified(IsFile1, false);
  pnlNavigation.visible := false;

  activeControl := CodeEdit;
  Statusbar.Panels[3].text := '';
end;

procedure TDiffForm.EditClick(Sender: TObject);
begin

end;

procedure TDiffForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Diff.free;
  Diff1.free;
  Diff2.free;
  Lines1.free;
  Lines2.free;
  pbDiffMarkerBmp.free;
  CodeEdit1.Free;
  CodeEdit2.Free;
end;

procedure TDiffForm.FormCreate(Sender: TObject);
begin
  addClr := defaultAddClr;
  modClr := defaultModClr;
  delClr := defaultDelClr;

  options.showInlineDiffs := false;
  options.ignoreCase := true;
  options.ignoreBlanks := true;

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

procedure TDiffForm.Load(fileName1, fileName2: string);
begin
  DoOpenFile(fileName1, true);
  DoOpenFile(fileName2, false);
  CompareClick(nil);
end;

procedure TDiffForm.NextClick(Sender: TObject);
var
  i: integer;
  clr: TColor;
  CodeEdit: TCodeEdit;
begin
//go to next color block (only enabled if files have been compared)
  if CodeEdit1.Focused then
    CodeEdit := CodeEdit1
  else if CodeEdit2.Focused then
    CodeEdit := CodeEdit2
  else exit;

  //get next colored block ...
  with CodeEdit do
  begin
    if lines.Count = 0 then exit;
    i := CaretPt.Y;
    clr := lines.LineObj[i].BackClr;
    repeat
      inc(i);
    until (i = Lines.Count) or (lines.LineObj[i].BackClr <> clr);
    if (i = Lines.Count) then //do nothing here
    else if lines.LineObj[i].BackClr = color then
    repeat
      inc(i);
    until (i = Lines.Count) or (lines.LineObj[i].BackClr <> color);
    if (i = Lines.Count) then
    begin
      beep;  //not found
      exit;
    end;
    CaretPt := Point(0,i);
    //now make sure as much of the block as possible is visible ...
    clr := lines.LineObj[i].BackClr;
    repeat
      inc(i);
    until(i = Lines.Count) or (lines.LineObj[i].BackClr <> clr);
    if i >= TopVisibleLine + visibleLines then TopVisibleLine := CaretPt.Y;
  end;
end;

procedure TDiffForm.PaintLeftMargin(Sender: TObject; Canvas: TCanvas; MarginRec: TRect; LineNo, Tag: integer);
var
  numStr: string;
begin
  //custom numbering of lines based on Tag (tag == 0 means no number) ...
  if tag = 0 then exit;
  numStr := inttostr(tag);
  Canvas.TextOut(MarginRec.Left + TCodeEdit(Sender).GutterWidth -
    Canvas.textwidth(numStr)-4, MarginRec.Top, numStr);
end;

procedure TDiffForm.PasteClick(Sender: TObject);
begin

end;

procedure TDiffForm.pbScrollPosMarkerMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  CodeEdit1.TopVisibleLine :=
    (CodeEdit1.Lines.Count * Y div pbScrollPosMarker.clientHeight) -
    (CodeEdit1.VisibleLines div 2);
end;

procedure TDiffForm.pbScrollPosMarkerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
    CodeEdit1.TopVisibleLine :=
      (CodeEdit1.Lines.Count * Y div pbScrollPosMarker.clientHeight) -
      (CodeEdit1.VisibleLines div 2);
end;

procedure TDiffForm.pbScrollPosMarkerPaint(Sender: TObject);
var
  yPos1, yPos2: integer;
begin
  //paint a marker indicating the vertical scroll position relative to change map
  if CodeEdit1.Lines.Count = 0 then exit;

  with pbScrollPosMarker do
  begin
    Canvas.Brush.Color := clWindow;
    Canvas.StretchDraw(Rect(0,0,width,Height),pbDiffMarkerBmp);
    with CodeEdit1 do
    begin
      yPos1 := TopVisibleLine;
      yPos2 := yPos1 + VisibleLines;
    end;
    yPos1 := clientHeight* yPos1 div CodeEdit1.Lines.Count;
    yPos2 := clientHeight* yPos2 div CodeEdit1.Lines.Count;
    if yPos2 < yPos1 + 2 then yPos2 := yPos1 +2;
    if yPos1 > 0 then dec(yPos1);
    if yPos2 < clientHeight then inc(yPos2) else yPos2 := clientHeight;
    Canvas.Brush.Style := bsClear;
    Canvas.Rectangle(0,yPos1,clientWidth,yPos2);
  end;
end;

procedure TDiffForm.PrevClick(Sender: TObject);
var
  i: integer;
  clr: TColor;
  CodeEdit: TCodeEdit;
label notFound;
begin
  if CodeEdit1.Focused then
    CodeEdit := CodeEdit1
  else if CodeEdit2.Focused then
    CodeEdit := CodeEdit2
  else exit;

  //get prev colored block ...
  with CodeEdit do
  begin
    i := CaretPt.Y;
    if i = Lines.count then goto notFound;
    clr := lines.LineObj[i].BackClr;
    repeat
      dec(i);
    until (i < 0) or (lines.LineObj[i].BackClr <> clr);
    if i < 0 then goto notFound;
    if lines.LineObj[i].BackClr = Color then
    repeat
      dec(i);
    until (i < 0) or (lines.LineObj[i].BackClr <> Color);
    if i < 0 then goto notFound;
    clr := lines.LineObj[i].BackClr;
    while (i > 0) and (lines.LineObj[i-1].BackClr = clr) do dec(i);
    //'i' now at the beginning of the previous color block.
    CaretPt := Point(0,i);
    exit;
  end;

notFound: beep;
end;

procedure TDiffForm.RedoClick(Sender: TObject);
begin

end;

//Synchronise scrolling of both CodeEdits (once files are compared)...
var IsSyncing: boolean;

procedure TDiffForm.SyncScroll(Sender: TObject);
begin
  if IsSyncing or not (Sender is TCodeEdit) then exit;
  IsSyncing := true; //stops recursion
  try
    if Sender = CodeEdit1 then
      CodeEdit2.TopVisibleLine := CodeEdit1.TopVisibleLine else
      CodeEdit1.TopVisibleLine := CodeEdit2.TopVisibleLine;
  finally
    IsSyncing := false;
  end;
  pbScrollPosMarkerPaint(self);
end;

procedure TDiffForm.ToggleCodeEditModified(IsCodeEdit1, IsModified: boolean);
begin

end;

procedure TDiffForm.ToggleLinkedScroll(IsLinked: boolean);
begin
  FilesCompared := IsLinked;
  if IsLinked then
  begin
    CodeEdit1.OnScroll := SyncScroll;
    CodeEdit2.OnScroll := SyncScroll;
    SyncScroll(CodeEdit1);
    pnlNavigation.visible := true;
    CodeEdit1.Partner := CodeEdit2;
    CodeEdit2.Partner := CodeEdit1;
  end else
  begin
    CodeEdit1.Partner := nil;
    CodeEdit2.Partner := nil;
    CodeEdit1.OnScroll := nil;
    CodeEdit2.OnScroll := nil;
    pnlNavigation.visible := false;
  end;
end;

procedure TDiffForm.UndoClick(Sender: TObject);
begin

end;

procedure TDiffForm.UpdateDiffMarkerBmp;
var
  i,y: integer;
  clr: TColor;
  HeightRatio: single;
begin
  //draws a map of the differences ...
  if (CodeEdit1.Lines.Count = 0) or (CodeEdit2.Lines.Count = 0) then exit;
  HeightRatio := Screen.Height/CodeEdit1.Lines.Count;

  pbDiffMarkerBmp.Height := Screen.Height;
  pbDiffMarkerBmp.Width := pbScrollPosMarker.ClientWidth;
  pbDiffMarkerBmp.Canvas.Pen.Width := 2;
  with pbDiffMarkerBmp do Canvas.FillRect(Rect(0,0,width,height));
  with CodeEdit1 do
  begin
    for i := 0 to Lines.Count-1 do
    begin
      clr := CodeEdit1.lines.lineobj[i].BackClr;
      if clr = clWindow then continue;
      pbDiffMarkerBmp.Canvas.Pen.Color := MakeDarker(clr);
      y := trunc(i*HeightRatio);
      pbDiffMarkerBmp.Canvas.MoveTo(-1,y);
      pbDiffMarkerBmp.Canvas.LineTo(pbDiffMarkerBmp.Width,y);
    end;
  end;
  pbScrollPosMarker.Invalidate;
end;

end.
