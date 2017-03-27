unit FileView;

interface

uses
  Windows, Messages, types, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, CodeEditor, ToolWin, Clipbrd, Searches,
  FindReplace, Main, HashUnit, Diff, Menus;

type
  TFilesFrame = class(TFrame)
    pnlMain: TPanel;
    Splitter1: TSplitter;
    pnlLeft: TPanel;
    pnlCaptionLeft: TPanel;
    pnlRight: TPanel;
    pnlCaptionRight: TPanel;
    pnlDisplay: TPanel;
    pbScrollPosMarker: TPaintBox;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    FontDialog1: TFontDialog;
    procedure pbScrollPosMarkerPaint(Sender: TObject);
    procedure FrameResize(Sender: TObject);
    procedure pbScrollPosMarkerMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pbScrollPosMarkerMouseMove(Sender: TObject;
      Shift: TShiftState; X, Y: Integer);
  private
    Diff: TDiff;
    Diff1: TDiff;
    Diff2: TDiff;
    Lines1, Lines2: TStrings;
    fStatusbarStr: string;
    CaretPosY: integer;
    pbDiffMarkerBmp: TBitmap;
    Search: TSearch;
    FindInfo: TFindInfo;
    procedure AppActivate(Sender: TObject);
    procedure FileDrop(Sender: TObject;
      const Filename: string; var DropAccepted: boolean);
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
    fn1, fn2: string;
    fa1, fa2: TDateTime;
    isUniCode1, isUniCode2: boolean; 
    CodeEdit1: TCodeEdit;
    CodeEdit2: TCodeEdit;
    FilesCompared: boolean;
    procedure Setup;
    procedure Cleanup;
    procedure DoOpenFile(const Filename: string; IsFile1: boolean);
    procedure SaveFileClick(Sender: TObject);
    procedure SetMenuEventsToFileView;
    procedure DisplayDiffs;
    procedure UpdateDiffMarkerBmp;
    procedure ToggleLinkedScroll(IsLinked: boolean);
  end;

const
  ISMODIFIED_COLOR = clMoneyGreen;

implementation

uses Math;

{$R *.dfm}

//------------------------------------------------------------------------------

function GetFileAttributesEx2(lpFileName: PChar; fInfoLevelId: TGetFileExInfoLevels;
  lpFileInformation: Pointer): BOOL;
var
  Handle: THandle;
  FindData: TWin32FindData;
begin
  Handle := FindFirstFile(lpFileName, FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if lpFileInformation <> nil then
    begin
      Move(FindData, lpFileInformation^, SizeOf(TWin32FileAttributeData));
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;
//------------------------------------------------------------------------------

function FileAge(const FileName: string; out FileDateTime: TDateTime): Boolean;
var
  FindData: TWin32FindData;
  LSystemTime: TSystemTime;
  LocalFileTime: TFileTime;
begin
  Result := False;
  if GetFileAttributesEx2(Pointer(Filename), GetFileExInfoStandard, @FindData) then
  begin
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      Result := True;
      FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
      FileTimeToSystemTime(LocalFileTime, LSystemTime);
      with LSystemTime do
        FileDateTime := EncodeDate(wYear, wMonth, wDay) +
          EncodeTime(wHour, wMinute, wSecond, wMilliSeconds);
    end;
  end;
end;
//------------------------------------------------------------------------------

function MakeDarker(color: TColor): TColor;
var
  r,g,b: byte;
begin
  Color := ColorToRGB(color);
  b := (Color shr 16) and $FF;
  g := (Color shr 8) and $FF;
  r := (Color and $FF);
  b := b * 7 div 8;
  g := g * 7 div 8;
  r := r * 7 div 8;
  result := (b shl 16) or (g shl 8) or r;
end;
//------------------------------------------------------------------------------

Procedure LoadFileUnicodeAware(const filename: string;
  strings: TStrings; out isUniCode: boolean);

(* UTF16BE = 0xFEFF         *
   UTF16LE = 0xFFFE         *
   UTF32LE = 0xFFFE0000     *
   UTF32BE = 0x0000FEFF     *
   UTF8    = 0xEFBBBF       *)

  procedure SwapWideChars( p: PWideChar );
  begin
    while p^ <> #0000 do
    begin
      p^ := WideChar( Swap( Word(p^)));
      Inc( p );
    end;
  end;

var
  ms: TMemoryStream;
  wc: WideChar;
  pWc: PWideChar;
begin
  isUniCode := false;
  ms:= TMemoryStream.Create;
  try
    ms.LoadFromFile( filename );
    ms.Seek( 0, soFromEnd );
    wc := #0000;
    ms.Write( wc, sizeof(wc));

    pWc := ms.Memory;
    if pWc^ = #$FEFF then
    begin                         // normal byte order mark
      Inc(pWc);
      strings.Text := WideCharToString( pWc );
      isUniCode := true;
    end
    else if pWc^ = #$FFFE then
    begin                         // byte order is big-endian
      SwapWideChars( pWc );
      Inc( pWc );
      strings.Text := WideCharToString( pWc );
      isUniCode := true;
    end else
    begin
      ms.Seek(0, soFromBeginning);
      strings.LoadFromStream(ms);
    end;
  finally
    ms.free;
  end;
end;
//------------------------------------------------------------------------------

Procedure SaveStringsAsUnicode(const filename: string; sl: TStrings ); overload;
var
  ws: WideString;
  fs: TFileStream;
  byteorder_marker: Word;
begin
  ws:= sl.Text;
  fs:= Tfilestream.create( filename, fmCreate );
  try
    byteorder_marker := $FEFF;
    fs.WriteBuffer( byteorder_marker, sizeof(byteorder_marker));
    fs.WriteBuffer( PWideChar(ws)^, Length(ws)*2);
  finally
    fs.free
  end;
end;
//------------------------------------------------------------------------------

procedure SaveStringsAsUnicode(const filename: string; s: string); overload;
var
  ws: WideString;
  fs: TFileStream;
  byteorder_marker: Word;
begin
  ws:= s;
  fs:= Tfilestream.create( filename, fmCreate );
  try
    byteorder_marker := $FEFF;
    fs.WriteBuffer( byteorder_marker, sizeof(byteorder_marker));
    fs.WriteBuffer( PWideChar(ws)^, Length(ws)*2);
  finally
    fs.free
  end;
end;
//------------------------------------------------------------------------------

procedure StringToFile(const filename, s: string);
begin
  with TFileStream.Create(filename, fmCreate) do
  try
    if s <> '' then
      WriteBuffer(Pointer(s)^, Length(s));
  finally
    free;
  end;
end;

//------------------------------------------------------------------------------
// TFilesFrame methods
//------------------------------------------------------------------------------

procedure TFilesFrame.Setup;
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
    OnDropFiles := FileDrop;
    OnEnter := CodeEditOnEnter;
    OnExit := CodeEditOnExit;
    OnPaintLine := CodeEditOnPaintLine1;
    OnKeyDown := CodeEditKeyDown;
    Font := FontDialog1.Font;
  end;
  CodeEdit2 := TCodeEdit.create(self);
  with CodeEdit2 do
  begin
    parent := pnlRight;
    Align := alClient;
    Lines.OnChange := CodeEditLinesOnChange;
    OnCaretPtChange := CodeEditOnCaretPtChange;
    OnPaintLeftMargin := PaintLeftMargin;
    OnDropFiles := FileDrop;
    OnEnter := CodeEditOnEnter;
    OnExit := CodeEditOnExit;
    OnPaintLine := CodeEditOnPaintLine2;
    OnKeyDown := CodeEditKeyDown;
    Font := FontDialog1.Font;
  end;
  Search := TSearch.Create(self);

  CaretPosY := -1;
  pbScrollPosMarker.Canvas.Pen.Color := clBlack;
  pbScrollPosMarker.Canvas.Pen.Width := 1;

  pbDiffMarkerBmp := TBitmap.create;
  pbDiffMarkerBmp.Canvas.Brush.Color := clWindow;

  pnlCaptionLeft.Font := MainForm.Font;
  pnlCaptionRight.Font := MainForm.Font;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.Cleanup;
begin
  Diff.free;
  Lines1.free;
  Lines2.free;
  pbDiffMarkerBmp.free;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.SetMenuEventsToFileView;
begin
  with MainForm do
  begin
    tbFolder.ImageIndex := Main.FILEVIEW;
    tbFolder.Hint := 'Toggle to Folder View';

    mnuOpen1.OnClick := OpenClick;
    mnuOpen2.OnClick := OpenClick;
    tbOpenFile1.OnClick := OpenClick;
    tbOpenFile2.OnClick := OpenClick;
    mnuOpen1.Caption := 'Op&en File 1';
    mnuOpen2.Caption := 'Ope&n File 2';

    mnucompare.OnClick := CompareClick;
    tbCompare.OnClick := CompareClick;
    mnuCancel.OnClick := CancelClick;
    tbCancel.OnClick :=  CancelClick;

    //workaround of the toggle event ...
    mnuHorzSplit.OnClick := nil;
    mnuHorzSplit.Checked := not mnuHorzSplit.Checked;
    HorzSplitClick(nil);
    mnuHorzSplit.OnClick := HorzSplitClick;
    tbHorzSplit.OnClick := HorzSplitClick;
    mnuHorzSplit.enabled := true;
    tbHorzSplit.enabled := true;

    mnuSave1.OnClick := SaveFileClick;
    mnuSave2.OnClick := SaveFileClick;
    tbSave1.OnClick := SaveFileClick;
    tbSave2.OnClick := SaveFileClick;
    mnuSave1.Enabled := CodeEdit1.Lines.Count > 0;// pnlCaptionLeft.Color = ISMODIFIED_COLOR;
    mnuSave2.Enabled :=CodeEdit2.Lines.Count > 0;// pnlCaptionRight.Color = ISMODIFIED_COLOR;
    tbSave1.Enabled := mnuSave1.Enabled;
    tbSave2.Enabled := mnuSave2.Enabled;
    tbSave1.Visible := true;
    tbSave2.Visible := true;
    tbOpenFile1.Visible := true;
    tbOpenFile2.Visible := true;
    tbOpen1.Visible := false;
    tbOpen2.Visible := false;
    tbOpenFolder1.Visible := false;
    tbOpenFolder2.Visible := false;

    mnuSaveReport.Enabled := assigned(CodeEdit1.Partner);
    mnuCompare.enabled := (Lines1.Count > 0) and (Lines2.Count > 0);
    tbCompare.enabled := mnuCompare.enabled;

    mnuEdit.Enabled := true;
    mnuEdit.OnClick := EditClick;
    mnuCut.OnClick := CutClick;
    mnuCopy.OnClick := CopyClick;
    mnuPaste.OnClick := PasteClick;
    mnuUndo.OnClick := UndoClick;
    mnuRedo.OnClick := RedoClick;
    mnuSaveReport.OnClick := SaveReportClick;

    mnuSearch.Enabled := true;
    mnuFind.OnClick := FindClick;
    mnuFindNext.OnClick := FindNextClick;
    tbFind.OnClick := FindClick;
    tbFind.Enabled := true;
    mnuReplace.OnClick := ReplaceClick;
    tbReplace.OnClick := ReplaceClick;
    tbReplace.enabled := true;

    mnuOptions.visible := true;
    mnuOptions2.visible := false;
    mnuFont.OnClick := FontClick;

    mnuNext.OnClick := NextClick;
    tbNext.OnClick := NextClick;
    mnuPrev.OnClick := PrevClick;
    tbPrev.OnClick := PrevClick;

    mnuCompareFiles.Visible := false;
    mnuNext.visible := true;
    mnuPrev.visible := true;
    tbNext.Enabled := FilesCompared;
    tbPrev.Enabled := FilesCompared;

    mnuCopyBlockLeft.OnClick := CopyBlockLeftClick;
    mnuCopyBlockRight.OnClick := CopyBlockRightClick;
    mnuDeleteLeft.Visible := false;
    mnuDeleteRight.Visible := false;
    mnuRenameLeft.Visible := false;
    mnuRenameRight.Visible := false;

    application.OnActivate := AppActivate;
    if assigned(CodeEdit1.Partner) then
      Statusbar1.Panels[3].text := fStatusbarStr
    else Statusbar1.Panels[3].text := '';
    ActiveControl := CodeEdit1;
  end;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.AppActivate(Sender: TObject);
var
  newAge1, newAge2: TDatetime;
begin
  //if a file change externally after being loaded in TextDiff,
  //then automatically reload that file ...
  if (fa1 <> 0) and fileExists(fn1) and fileAge(fn1, newAge1) and (fa1 <> newAge1) then
    DoOpenFile(fn1,true);
  if (fa2 <> 0) and fileExists(fn2) and fileAge(fn2, newAge2) and (fa2 <> newAge2) then
    DoOpenFile(fn2,false);
end;
//---------------------------------------------------------------------

procedure TFilesFrame.FrameResize(Sender: TObject);
begin
  if MainForm.mnuHorzSplit.checked then
    pnlLeft.height := pnlMain.ClientHeight div 2 -1 else
    pnlLeft.width := pnlMain.ClientWidth div 2 -1;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.OpenClick(Sender: TObject);
var
  IsFile1: boolean;
begin
  with MainForm do
    IsFile1 := (Sender = mnuOpen1) or (Sender = tbOpenFile1);
  if IsFile1 then
    OpenDialog1.InitialDir := LastOpenedFolder1 else
    OpenDialog1.InitialDir := LastOpenedFolder2;
  OpenDialog1.FileName := '';
  if not OpenDialog1.execute then exit;
  DoOpenFile(OpenDialog1.filename, IsFile1);
end;
//---------------------------------------------------------------------

procedure TFilesFrame.HorzSplitClick(Sender: TObject);
begin
  with MainForm do
  begin
    mnuHorzSplit.checked := not mnuHorzSplit.checked;
    if mnuHorzSplit.checked then
    begin
      pnlLeft.Align := alTop;
      pnlLeft.Height := pnlMain.ClientHeight div 2 -1;
      Splitter1.Align := alTop;
      Splitter1.cursor := crVSplit;
      mnuCopyBlockRight.Caption := 'Copy Block &Down';
      mnuCopyBlockRight.ShortCut := Shortcut(ord('D'),[ssCtrl,ssAlt]);
      mnuCopyBlockLeft.Caption := 'Copy Block &Up';
      mnuCopyBlockLeft.ShortCut := Shortcut(ord('U'),[ssCtrl,ssAlt]);
    end else
    begin
      pnlLeft.Align := alLeft;
      pnlLeft.Width := pnlMain.ClientWidth div 2 -1;
      Splitter1.Align := alLeft;
      Splitter1.Left := 10;
      Splitter1.cursor := crHSplit;
      mnuCopyBlockRight.Caption := 'Copy Block &Right';
      mnuCopyBlockRight.ShortCut := Shortcut(ord('R'),[ssCtrl,ssAlt]);
      mnuCopyBlockLeft.Caption := 'Copy Block &Left';
      mnuCopyBlockLeft.ShortCut := Shortcut(ord('L'),[ssCtrl,ssAlt]);
    end;
    if ActiveControl is TCodeEdit then
      TCodeEdit(ActiveControl).ScrollCaretIntoView;
  end;
end;
//---------------------------------------------------------------------

procedure TFilesFrame.CompareClick(Sender: TObject);
var
  i: integer;
  HashList1,HashList2: TList;
begin
  if (Lines1.Count = 0) or (Lines2.Count = 0) then exit;

  if (CodeEdit1.Lines.Modified) or (CodeEdit2.Lines.Modified) then
  begin
    if application.MessageBox(
      'Changes will be lost if you proceed with this compare.'#10+
      'Continue? ...',pchar(application.title),
      MB_YESNO or MB_ICONSTOP or MB_DEFBUTTON2) <> IDYES then exit;
  end;


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
    with MainForm do
    begin
      for i := 0 to Lines1.Count-1 do
        HashList1.add(HashLine(Lines1[i], mnuIgnoreCase.checked,mnuIgnoreBlanks.checked));
      for i := 0 to Lines2.Count-1 do
        HashList2.add(HashLine(Lines2[i],mnuIgnoreCase.checked,mnuIgnoreBlanks.checked));
      mnuCompare.Enabled := false;
      tbCompare.Enabled := false;
      mnuCancel.ShortCut := Shortcut(27,[]);
      try
        mnuCancel.Enabled := true;
        tbCancel.Enabled := true;
        //CALCULATE THE DIFFS HERE ...
        Diff.Execute(PInteger(HashList1.List),PInteger(HashList2.List),
          HashList1.count, HashList2.count);
        DisplayDiffs;
      finally
        mnuCompare.Enabled := true;
        tbCompare.Enabled := true;
        mnuCancel.Enabled := false;
        tbCancel.Enabled := false;
        mnuCancel.ShortCut := 0;
      end;
      ToggleLinkedScroll(true);
      ToggleCodeEditModified(true, false);
      ToggleCodeEditModified(false, false);
      MainForm.ActiveControl := CodeEdit1;
      mnuNext.Enabled := true;
      mnuPrev.Enabled := true;
      tbNext.Enabled := true;
      tbPrev.Enabled := true;
      mnuSaveReport.Enabled := true;
    end;
  finally
    HashList1.Free;
    HashList2.Free;
    screen.Cursor := crDefault;
  end;
end;
//---------------------------------------------------------------------

procedure TFilesFrame.CancelClick(Sender: TObject);
begin
  Diff.Cancel;
  MainForm.Statusbar1.Panels[3].text := 'Compare cancelled.'
end;
//---------------------------------------------------------------------

procedure TFilesFrame.DisplayDiffs;
var
  i: integer;
  linesSame, linesAdd, linesMod, linesDel: integer;

  procedure AddAndFormat(CodeEdit: TCodeEdit; const Text: string;
    Color: TColor; num: longint);
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

    with MainForm, Diff do
    for i := 0 to Count-1 do
      with Compares[i] do
        case Kind of
          ckNone:
            begin
             inc(linesSame);
             if mnuShowDiffsOnly.Checked  then continue;
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
  if MainForm.mnuIgnoreCase.checked then
    fStatusbarStr := 'Case Ignored';
  if MainForm.mnuIgnoreBlanks.checked then
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
  MainForm.Statusbar1.Panels[3].text := fStatusbarStr;

end;
//---------------------------------------------------------------------

//Synchronise scrolling of both CodeEdits (once files are compared)...
var IsSyncing: boolean;

procedure TFilesFrame.SyncScroll(Sender: TObject);
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
//---------------------------------------------------------------------

procedure TFilesFrame.ToggleCodeEditModified(IsCodeEdit1, IsModified: boolean);
const
  clr: array[boolean] of TColor = (clBtnFace, ISMODIFIED_COLOR);
begin
  //change the color of the filename panel whenever file is modified ...
  if IsCodeEdit1 then
  begin
    pnlCaptionLeft.Color := clr[IsModified];
    mainForm.mnuSave1.Enabled := CodeEdit1.Lines.Count > 0;// IsModified;
    mainForm.tbSave1.Enabled := mainForm.mnuSave1.Enabled;
  end else
  begin
    pnlCaptionRight.Color := clr[IsModified];
    mainForm.mnuSave2.Enabled := CodeEdit2.Lines.Count > 0;// IsModified;
    mainForm.tbSave2.Enabled := mainForm.mnuSave2.Enabled;
  end;
end;
//---------------------------------------------------------------------

procedure TFilesFrame.CodeEditLinesOnChange(Sender: TObject);
begin
  ToggleCodeEditModified(Sender = CodeEdit1.Lines, true);
  ToggleLinkedScroll(false);
end;
//---------------------------------------------------------------------

//detect whenever the caret is moved into a colored difference block
function TFilesFrame.CaretInClrBlk(CodeEdit: TCodeEdit): boolean;
begin
  with CodeEdit do
    result := assigned(CodeEdit.Partner) and (CaretPt.Y < lines.Count) and
      (lines.LineObj[CaretPt.Y].BackClr <> clWindow) and
      not lines.LineObj[CaretPt.Y].LineModified;
end;
//---------------------------------------------------------------------

//change menu options depending on whether caret is in a diff color block or not
procedure TFilesFrame.CodeEditOnCaretPtChange(Sender: TObject);
var
  caretInClrBlock: boolean;
begin
  if not assigned(CodeEdit1.Partner) or not TCodeEdit(Sender).Focused then exit;
  caretInClrBlock := CaretInClrBlk(TCodeEdit(Sender)); //ie calls function once
  MainForm.mnuCopyBlockRight.Enabled := caretInClrBlock and (Sender = CodeEdit1);
  MainForm.mnuCopyBlockLeft.Enabled := caretInClrBlock and (Sender = CodeEdit2);
end;
//---------------------------------------------------------------------

procedure TFilesFrame.CodeEditOnEnter(Sender: TObject);
begin
  //keep compared (and unedited) text carets in sync ...
  if assigned(CodeEdit1.Partner) and (CaretPosY >= 0) then
    with TCodeEdit(Sender) do CaretPt := Point(0,CaretPosY);
end;
//---------------------------------------------------------------------

procedure TFilesFrame.CodeEditOnExit(Sender: TObject);
begin
  //keep compared text carets in sync too ...
  with TCodeEdit(Sender) do
    if (CaretPt.Y >= TopVisibleLine) and
      (CaretPt.Y <= TopVisibleLine + VisibleLines) then
      CaretPosY := CaretPt.Y
    else
      CaretPosY := -1;
end;
//---------------------------------------------------------------------

procedure MarkupTextOut(canvas: TCanvas;
  rec: TRect; x,y: integer; const text, colors: string; clrs: array of TColor);
var
  i,j, len: integer;
  savedTextAlign, SavedBkColor, savedTextColor: cardinal;
  savedPt: TPoint;
  clr: TColor;
begin
  len := length(text);
  if (len = 0) or (length(colors) <> len) or (high(clrs) < 1) then exit;

  savedTextColor := GetTextColor(canvas.Handle);
  SavedBkColor := GetBkColor(canvas.handle);
  savedTextAlign := GetTextAlign(canvas.Handle);
  SetTextAlign(canvas.Handle, savedTextAlign or TA_UPDATECP);
  MoveToEx(canvas.Handle, x, y, @savedPt);

  clr := clrs[ord(colors[1])];
  SetBkColor(canvas.handle, clr);
  j := 1;
  for i := 1 to len+1 do
    if (i > len) then
      ExtTextOut(canvas.handle,0,0,ETO_CLIPPED, @rec, pchar(@text[j]),i-j, nil)
    else if (clr <> clrs[ord(colors[i])]) then
    begin
      ExtTextOut(canvas.handle,0,0,ETO_CLIPPED, @rec, pchar(@text[j]),i-j, nil);
      clr := clrs[ord(colors[i])];
      SetBkColor(canvas.handle, clr);
      j := i;
    end;

  SetTextColor(canvas.handle,savedTextColor);
  SetBkColor(canvas.handle, SavedBkColor);
  SetTextAlign(canvas.Handle, savedTextAlign);
  with savedPt do MoveToEx(canvas.Handle, X,Y, nil);
end;
//---------------------------------------------------------------------

procedure AddStrClr(var s1, s2: string; c: char; kind, lastkind: TChangeKind);
begin
  s1 := s1 + c;
  case kind of
    ckNone: s2 := s2 + #0;
    else s2 := s2 + #1;
  end;
end;
//---------------------------------------------------------------------

procedure TFilesFrame.CodeEditOnPaintLine1(Sender: TObject;
  LineNo: integer; Rec: TRect; TextLeft: integer; var Handled: boolean);
var
  i,len1, len2: integer;
  s, ss, sss: string;
  lastKind: TChangeKind;
begin
  with CodeEdit1 do
  begin
    //if it's not an unedited 'modified' line then markup inline differences
    if not MainForm.mnuShowInlineDiffs.Checked or
      not assigned(Partner) or
      lines.LineObj[LineNo].LineModified or
      (lines.LineObj[LineNo].BackClr <> modClr) then exit;
    if MainForm.mnuIgnoreCase.checked then
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
//---------------------------------------------------------------------

procedure TFilesFrame.CodeEditOnPaintLine2(Sender: TObject;
  LineNo: integer; Rec: TRect; TextLeft: integer; var Handled: boolean);
var
  i,len1, len2: integer;
  s, ss, sss: string;
  lastKind: TChangeKind;
begin
  with CodeEdit2 do
  begin
    //if it's not an unedited 'modified' line then markup inline differences
    if not MainForm.mnuShowInlineDiffs.Checked or
      not assigned(Partner) or
      lines.LineObj[LineNo].LineModified or
      (lines.LineObj[LineNo].BackClr <> modClr) then exit;
    if MainForm.mnuIgnoreCase.checked then
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
//---------------------------------------------------------------------

procedure TFilesFrame.ToggleLinkedScroll(IsLinked: boolean);
begin
  FilesCompared := IsLinked;
  if IsLinked then
  begin
    CodeEdit1.OnScroll := SyncScroll;
    CodeEdit2.OnScroll := SyncScroll;
    SyncScroll(CodeEdit1);
    pnlDisplay.visible := true;
    CodeEdit1.Partner := CodeEdit2;
    CodeEdit2.Partner := CodeEdit1;
  end else
  begin
    CodeEdit1.Partner := nil;
    CodeEdit2.Partner := nil;
    CodeEdit1.OnScroll := nil;
    CodeEdit2.OnScroll := nil;
    pnlDisplay.visible := false;
  end;
end;
//---------------------------------------------------------------------

procedure TFilesFrame.pbScrollPosMarkerPaint(Sender: TObject);
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
//---------------------------------------------------------------------

procedure TFilesFrame.FileDrop(Sender: TObject;
    const Filename: string; var DropAccepted: boolean);
begin
  DoOpenFile(Filename, Sender = CodeEdit1);
  setForegroundWindow(application.handle);
  DropAccepted := true;
end;
//---------------------------------------------------------------------

procedure TFilesFrame.DoOpenFile(const Filename: string; IsFile1: boolean);
var
  CodeEdit: TCodeEdit;
begin
  if not fileexists(Filename) then exit;
  ToggleLinkedScroll(false);
  if IsFile1 then
  begin
    CodeEdit := CodeEdit1;
    LoadFileUnicodeAware(filename, Lines1, isUniCode1);
    //Lines1.LoadFromFile(filename);
    CodeEdit.Lines.Assign(Lines1);
    fn1 := Filename;
    fileAge(fn1, fa1);
    pnlCaptionLeft.caption := '  '+ filename;
    LastOpenedFolder1 := extractfilepath(filename);
  end
  else
  begin
    CodeEdit := CodeEdit2;
    LoadFileUnicodeAware(filename, Lines2, isUniCode2);
    //Lines2.LoadFromFile(filename);
    CodeEdit.Lines.Assign(Lines2);
    fn2 := Filename;
    fileAge(fn2, fa2);
    pnlCaptionRight.caption := '  '+ filename;
    LastOpenedFolder2 := extractfilepath(filename);
  end;
  CodeEdit.AutoLineNum := true;
  ToggleCodeEditModified(IsFile1, false);
  pnlDisplay.visible := false;
  with MainForm do
  begin
    activeControl := CodeEdit;
    mnuCompare.enabled := (Lines1.Count > 0) and (Lines2.Count > 0);
    tbCompare.enabled := MainForm.mnuCompare.enabled;
    Statusbar1.Panels[3].text := '';
    mnuNext.Enabled := false;
    mnuPrev.Enabled := false;
    tbNext.Enabled := false;
    tbPrev.Enabled := false;
    mnuSaveReport.Enabled := false;
  end;
end;
//---------------------------------------------------------------------

procedure TFilesFrame.UpdateDiffMarkerBmp;
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
//---------------------------------------------------------------------

procedure TFilesFrame.PaintLeftMargin(Sender: TObject; Canvas: TCanvas;
  MarginRec: TRect; LineNo, Tag: integer);
var
  numStr: string;
begin
  //custom numbering of lines based on Tag (tag == 0 means no number) ...
  if tag = 0 then exit;
  numStr := inttostr(tag);
  Canvas.TextOut(MarginRec.Left + TCodeEdit(Sender).GutterWidth -
    Canvas.textwidth(numStr)-4, MarginRec.Top, numStr);
end;
//---------------------------------------------------------------------

type
  TSysCharSet = set of AnsiChar;

function CharInSet(C: Char; const CharSet: TSysCharSet): Boolean;
var
  i: integer;
begin
  i := ord(C);
  Result := (i < 255) and (AnsiChar(Chr(i)) in CharSet);
end;
//---------------------------------------------------------------------

function TFilesFrame.FindNext(CodeEdit: TCodeEdit): boolean;
var
  i, PatLen, fndOffset: integer;

  function IsWholeWord(const line: string; xOffset, wordLen: integer): boolean;
  begin
    result := ((xOffset = 0) or not
      CharInSet( line[xOffset], ['A'..'Z','a'..'z','0'..'9'])) and
      ((xOffset + wordLen >= length(line)) or not
      CharInSet(line[xOffset + wordLen +1], ['A'..'Z','a'..'z','0'..'9']));
  end;

begin
  result := false;
  with CodeEdit do
  begin
    if CaretPt.Y >= lines.Count then exit;
    PatLen := length(Search.Pattern);
    Search.SetData(pchar(lines[CaretPt.Y]),lines.LineObj[CaretPt.Y].LineLen);
    i := CaretPt.Y;
    //search the first line, making sure we've gone beyond the caret ...
    fndOffset := Search.FindFirst;
    repeat
     if (fndOffset < 0) then break //not found
     else if (fndOffset < CaretPt.X) then fndOffset := Search.FindNext
     else if not FindInfo.wholeWords or
       IsWholeWord(lines[CaretPt.Y], fndOffset, PatLen) then break //found!!
     else fndOffset := Search.FindNext;
    until false;
    //if not found, search each subsequent line...
    while (fndOffset < 0) and (i < lines.Count-1) do
    begin
     inc(i);
     Search.SetData(pchar(lines[i]),lines.LineObj[i].LineLen);
     fndOffset := Search.FindFirst;
     if (fndOffset >= 0) and FindInfo.wholeWords then
       while (fndOffset >= 0) and not IsWholeWord(lines[i], fndOffset, PatLen) do
         fndOffset := Search.FindNext;
    end;
    if fndOffset < 0 then exit; //not found
    CaretPt := Point(fndOffset,i);
    SelLength := length(Search.Pattern);
    ScrollCaretIntoView;
    result := true;
  end;
end;
//------------------------------------------------------------------------------

function TFilesFrame.FindPrevious(CodeEdit: TCodeEdit): boolean;
var
  i, PatLen, fndOffset, lastFoundXPos: integer;

  function IsWholeWord(const line: string; xOffset, wordLen: integer): boolean;
  begin
    result := ((xOffset = 0) or not
      CharInSet(line[xOffset], ['A'..'Z','a'..'z','0'..'9'])) and
      ((xOffset + wordLen >= length(line)) or not
      CharInSet(line[xOffset + wordLen +1], ['A'..'Z','a'..'z','0'..'9']));
  end;

begin
  result := false;
  with CodeEdit do
  begin
    if CaretPt.Y >= lines.Count then exit;
    PatLen := length(Search.Pattern);
    //search the first line, going as close to but not beyond the caret ...
    lastFoundXPos := -1;
    fndOffset := Search.FindFirst;
    //avoid finding the same result with repeated searches ...
    while (fndOffset >= 0) and (fndOffset < CaretPt.X - PatLen) do
    begin
     if not FindInfo.wholeWords or
       IsWholeWord(lines[CaretPt.Y], fndOffset, PatLen) then
         lastFoundXPos := fndOffset;
     fndOffset := Search.FindNext;
    end;
    i := CaretPt.Y;
    //if not found, search each preceeding line...
    while (lastFoundXPos < 0) and (i > 0) do
    begin
     dec(i);
     Search.SetData(pchar(lines[i]),lines.LineObj[i].LineLen);
     fndOffset := Search.FindFirst;
     while (fndOffset >= 0) do
     begin
       if not FindInfo.wholeWords or IsWholeWord(lines[i], fndOffset, PatLen) then
         lastFoundXPos := fndOffset;
       fndOffset := Search.FindNext;
     end;
    end;
    if lastFoundXPos < 0 then exit; //not found
    CaretPt := Point(lastFoundXPos,i);
    SelLength := length(Search.Pattern);
    ScrollCaretIntoView;
    result := true;
  end;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.ReplaceDown(CodeEdit: TCodeEdit);
var
  ReplaceType: TReplaceType;
  CaretCoord: TPoint;
begin
  if FindInfo.replacePrompt then
  begin
    ReplaceType := rtOK;
    while FindNext(CodeEdit) do
    begin
      if ReplaceType <> rtAll then
      begin
        //get the clientcoords of Caret ...
        CaretCoord := CodeEdit.ClientPtFromCharPt(CodeEdit.CaretPt);
        //convert CaretCoord to form's Coords ...
        CaretCoord := CodeEdit.ClientToScreen(CaretCoord);
        CaretCoord := self.ScreenToClient(CaretCoord);
        //now display the replace prompt dialog ...
        ReplaceType := ReplacePrompt(MainForm, CaretCoord);
      end;
      case ReplaceType of
        rtOK:
          begin
            CodeEdit.Selection := FindInfo.replaceStr;
            if not FindInfo.replaceAll then exit; //replace One
          end;
        rtSkip: ; //do nothing
        rtAll:  CodeEdit.Selection := FindInfo.replaceStr;
        rtCancel: exit;
      end;
    end;
  end
  else if FindInfo.replaceAll then
    while FindNext(CodeEdit) do
      CodeEdit.Selection := FindInfo.replaceStr
  else if FindNext(CodeEdit) then //replace One - no prompt
    CodeEdit.Selection := FindInfo.replaceStr;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.ReplaceUp(CodeEdit: TCodeEdit);
var
  ReplaceType: TReplaceType;
  CaretCoord: TPoint;
begin
  if FindInfo.replacePrompt then
  begin
    ReplaceType := rtOK;
    while FindPrevious(CodeEdit) do
    begin
      if ReplaceType <> rtAll then
      begin
        //get the clientcoords of Caret ...
        CaretCoord := CodeEdit.ClientPtFromCharPt(CodeEdit.CaretPt);
        //convert CaretCoord to form's Coords ...
        CaretCoord := CodeEdit.ClientToScreen(CaretCoord);
        CaretCoord := self.ScreenToClient(CaretCoord);
        //now display the replace prompt dialog ...
        ReplaceType := ReplacePrompt(TForm(owner), CaretCoord);
      end;
      case ReplaceType of
        rtOK:
          begin
            CodeEdit.Selection := FindInfo.replaceStr;
            if not FindInfo.replaceAll then exit; //replace One
          end;
        rtSkip: ; //do nothing
        rtAll:  CodeEdit.Selection := FindInfo.replaceStr;
        rtCancel: exit;
      end;
    end;
  end
  else if FindInfo.replaceAll then
    while FindPrevious(CodeEdit) do
      CodeEdit.Selection := FindInfo.replaceStr
  else if FindPrevious(CodeEdit) then //replace One - no prompt
    CodeEdit.Selection := FindInfo.replaceStr;
end;
//------------------------------------------------------------------------------

//go to next color block (only enabled if files have been compared)
procedure TFilesFrame.NextClick(Sender: TObject);
var
  i: integer;
  clr: TColor;
  CodeEdit: TCodeEdit;
begin
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
//---------------------------------------------------------------------

//go to previous color block (only enabled if files have been compared)
procedure TFilesFrame.PrevClick(Sender: TObject);
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
//---------------------------------------------------------------------

procedure TFilesFrame.SaveFileClick(Sender: TObject);
var
  i, LineCnt: integer;
  s: string;
  p: PChar;
  CodeEdit: TCodeEdit;
  isUniCode: boolean;
begin
  if (Sender = MainForm.mnuSave1) or (Sender = MainForm.tbSave1) then
  begin
    CodeEdit := CodeEdit1;
    SaveDialog1.FileName := trim(pnlCaptionLeft.Caption);
    isUniCode := isUniCode1;
  end else
  begin
    CodeEdit := CodeEdit2;
    SaveDialog1.FileName := trim(pnlCaptionRight.Caption);
    isUniCode := isUniCode2;
  end;
  if not SaveDialog1.Execute then exit;
  LineCnt := CodeEdit.lines.Count;

  if CodeEdit.AutoLineNum then //ie hasn't been compared
  begin
    //just save whatever's there. reload it (to update filenames etc) & exit
    if isUniCode then
      SaveStringsAsUnicode(SaveDialog1.FileName, CodeEdit.Lines) else
      CodeEdit.Lines.SaveToFile(SaveDialog1.FileName);
    DoOpenFile(SaveDialog1.FileName, CodeEdit = CodeEdit1);
    exit;
  end;

  if LineCnt > 0 then
  begin
    //get max possible size
    with CodeEdit.Lines.LineObj[LineCnt-1] do
      i := LineOffset + LineLen + Sizeof(CodeEditor.NEWLINE);
    setLength(s,i);
    p := pchar(s);
    //just copy numbered lines and edited lines ...
    for i := 0 to LineCnt -1 do
    begin
      with CodeEdit.Lines.LineObj[i] do
        if (Tag > 0) or LineModified then
        begin
          if LineLen > 0 then
          begin
            system.Move(pchar(CodeEdit.Lines[i])^,p^,LineLen);
            inc(p, LineLen);
          end;
          system.Move(CodeEditor.NEWLINE, p^, sizeof(CodeEditor.NEWLINE));
          inc(p, sizeof(CodeEditor.NEWLINE));
        end;
    end;
    setlength(s, p - @s[1]);
  end;
  if isUniCode then
    SaveStringsAsUnicode(SaveDialog1.FileName, s) else
    StringToFile(SaveDialog1.FileName, s);
  //reload the file ...
  DoOpenFile(SaveDialog1.FileName, CodeEdit = CodeEdit1);
end;
//---------------------------------------------------------------------

procedure TFilesFrame.SaveReportClick(Sender: TObject);
var
  i, ln: integer;
  clr: TColor;
  shortDateFmt: string;
  FormatSettings: TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create;
  shortDateFmt := FormatSettings.shortdateformat;

  SaveDialog1.InitialDir := extractfilepath(fn1);
  SaveDialog1.Filter := 'Text Files (*.txt)|*.txt';
  SaveDialog1.DefaultExt := 'txt';
  if not SaveDialog1.execute then exit;
  with TStringList.create do
  try
    beginupdate;
    add('Difference Report - '+ formatdatetime(shortDateFmt +', '+ shortDateFmt, now));
    add('================================================================================');
    add('');
    add(format('File 1: "%s"',[fn1]));
    add('        Last modified on '+
      formatdatetime(shortDateFmt + ', '+ shortDateFmt, fa1));
    add(format('File 2: "%s"',[fn2]));
    add('        Last modified on '+
      formatdatetime(shortDateFmt + ', '+ shortDateFmt, fa2));
    add('');

    ln := 0;
    clr := clWindow;
    for i := 0 to CodeEdit1.Lines.count-1 do
      with CodeEdit1.Lines.LineObj[i] do
      begin
        //nb: 'Tag' is 1 based line index (unless lines added where Tag = 0)
        if Tag > ln then ln := Tag;
        if BackClr <> clr then //new color block
        begin
          if BackClr = addClr then
          begin
            add('================================================================================');
            add('Lines added at '+ inttostr(ln+1));
            add('================================================================================');
            add('+ '+ CodeEdit2.Lines[i]);
          end
          else if BackClr = modClr then
          begin
            add('================================================================================');
            add('Lines modified at '+inttostr(ln));
            add('================================================================================');
            add('- '+ CodeEdit1.Lines[i]);
            add('+ '+ CodeEdit2.Lines[i]);
          end
          else if BackClr = delClr then
          begin
            add('================================================================================');
            add('Lines deleted at '+inttostr(ln));
            add('================================================================================');
            add('- '+ CodeEdit1.Lines[i]);
          end;
          clr := BackClr;
        end else //add line to existing block
        begin
          if BackClr = addClr then
            add('+ '+ CodeEdit2.Lines[i])
          else if BackClr = modClr then
          begin
            add('- '+ CodeEdit1.Lines[i]);
            add('+ '+ CodeEdit2.Lines[i]);
          end
          else if BackClr = delClr then
            add('- '+ CodeEdit1.Lines[i]);
        end;
      end;
    endupdate;
    savetofile(SaveDialog1.FileName);
  finally
    free;
  end;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.CodeEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if not assigned(CodeEdit1.Partner) or
    (Shift * [ssAlt,ssCtrl] <> [ssAlt,ssCtrl]) then exit;
  if (key = VK_RIGHT) and CaretInClrBlk(CodeEdit1) then
    CopyBlockRightClick(nil)
  else if (key = VK_LEFT) and CaretInClrBlk(CodeEdit2) then
    CopyBlockLeftClick(nil);
end;
//------------------------------------------------------------------------------

type
  TCodeEditHack = class(TCodeEdit);

procedure TFilesFrame.CopyBlockRightClick(Sender: TObject);
var
  i, blockTopLine, blockBottomLine: integer;
  clr: TColor;
  txt: string;
begin
  MainForm.mnuCopyBlockRight.Enabled := false;
  if MainForm.ActiveControl <> CodeEdit1 then exit;
  with CodeEdit1 do
  begin
    if lines.Count = 0 then exit;
    blockTopLine := CaretPt.Y;
    clr := lines.LineObj[blockTopLine].BackClr;
    if clr = clWindow then exit; //we're not in a colored block !!!
    blockBottomLine := blockTopLine;
    while (blockTopLine > 0) and
      (lines.LineObj[blockTopLine-1].BackClr = clr) do dec(blockTopLine);
    while (blockBottomLine < Lines.Count-1) and
      (lines.LineObj[blockBottomLine+1].BackClr = clr) do inc(blockBottomLine);
    //make sure color blocks still match up ...
    if (blockBottomLine > CodeEdit2.Lines.Count -1) or
      (CodeEdit2.Lines.LineObj[blockTopLine].BackClr <> clr) or
      (CodeEdit2.Lines.LineObj[blockBottomLine].BackClr <> clr) then exit;
    //copy the color block into txt ...
    txt := lines[blockTopLine] + #13#10;
    for i := blockTopLine +1 to blockBottomLine do txt := txt + lines[i] + #13#10;
    //select the source color block ...
    SelStart := lines.LineObj[blockTopLine].LineOffset;
    SelLength := 0;
  end;
  //this is a roundabout way of handling undoing ...
  with CodeEdit2 do
  begin
    //select the destination color block ...
    SelStart := lines.LineObj[blockTopLine].LineOffset;
    SelLength := lines.LineObj[blockBottomLine].LineOffset +
      lines.LineObj[blockBottomLine].LineLen - SelStart +2; //+2 for #13#10
    Lines.OnChange := nil;
    TCodeEditHack(CodeEdit2).SetSelection(txt);
    ToggleCodeEditModified(false, true);
    Lines.OnChange := CodeEditLinesOnChange;
    SelLength := 0;
    Partner := CodeEdit2;
  end;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.CopyBlockLeftClick(Sender: TObject);
var
  i, blockTopLine, blockBottomLine: integer;
  clr: TColor;
  txt: string;
begin
  MainForm.mnuCopyBlockLeft.Enabled := false;
  if MainForm.ActiveControl <> CodeEdit2 then exit;
  with CodeEdit2 do
  begin
    if lines.Count = 0 then exit;
    blockTopLine := CaretPt.Y;
    clr := lines.LineObj[blockTopLine].BackClr;
    if clr = clWindow then exit; //we're not in a colored block !!!
    blockBottomLine := blockTopLine;
    while (blockTopLine > 0) and
      (lines.LineObj[blockTopLine-1].BackClr = clr) do dec(blockTopLine);
    while (blockBottomLine < Lines.Count-1) and
      (lines.LineObj[blockBottomLine+1].BackClr = clr) do inc(blockBottomLine);
    //make sure color blocks still match up ...
    if (blockBottomLine > CodeEdit1.Lines.Count -1) or
      (CodeEdit1.Lines.LineObj[blockTopLine].BackClr <> clr) or
      (CodeEdit1.Lines.LineObj[blockBottomLine].BackClr <> clr) then exit;
    //copy the color block into txt ...
    txt := lines[blockTopLine] + #13#10;
    for i := blockTopLine +1 to blockBottomLine do txt := txt + lines[i] + #13#10;
    //select the source color block ...
    SelStart := lines.LineObj[blockTopLine].LineOffset;
    SelLength := 0;
  end;
  //this is a roundabout way of handling undoing ...
  with CodeEdit1 do
  begin
    //select the destination color block ...
    SelStart := lines.LineObj[blockTopLine].LineOffset;
    SelLength := lines.LineObj[blockBottomLine].LineOffset +
      lines.LineObj[blockBottomLine].LineLen - SelStart +2; //+2 for #13#10
    Lines.OnChange := nil;
    TCodeEditHack(CodeEdit1).SetSelection(txt);
    ToggleCodeEditModified(true, true);
    Lines.OnChange := CodeEditLinesOnChange;
    SelLength := 0;
    Partner := CodeEdit2;
  end;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.UndoClick(Sender: TObject);
var
  CodeEdit: TCodeEdit;
begin
  if MainForm.ActiveControl = CodeEdit1 then
    CodeEdit := CodeEdit1
  else if MainForm.ActiveControl = CodeEdit2 then
    CodeEdit := CodeEdit2
  else exit;

  CodeEdit.Lines.OnChange := nil;
  CodeEdit.Undo;
  CodeEdit.Lines.OnChange := CodeEditLinesOnChange;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.RedoClick(Sender: TObject);
var
  CodeEdit: TCodeEdit;
begin
  if MainForm.ActiveControl = CodeEdit1 then
    CodeEdit := CodeEdit1
  else if MainForm.ActiveControl = CodeEdit2 then
    CodeEdit := CodeEdit2
  else exit;

  CodeEdit.Lines.OnChange := nil;
  CodeEdit.Redo;
  CodeEdit.Lines.OnChange := CodeEditLinesOnChange;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.EditClick(Sender: TObject);
begin
  with MainForm do
  begin
    if ActiveControl = CodeEdit1 then
    begin
      mnuUndo.Enabled := CodeEdit1.CanUndo;
      mnuRedo.Enabled := CodeEdit1.CanRedo;
      mnuCut.Enabled := CodeEdit1.SelLength > 0;
    end
    else if ActiveControl = CodeEdit2 then
    begin
      mnuUndo.Enabled := CodeEdit2.CanUndo;
      mnuRedo.Enabled := CodeEdit2.CanRedo;
      mnuCut.Enabled := CodeEdit2.SelLength > 0;
    end;
    mnuCopy.Enabled := mnuCut.Enabled;
    Clipboard.Open;
    try
      mnuPaste.Enabled := Clipboard.HasFormat(CF_TEXT);
    finally
      Clipboard.Close;
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.CutClick(Sender: TObject);
begin
  if MainForm.ActiveControl = CodeEdit1 then
    CodeEdit1.CutToClipBoard
  else if MainForm.ActiveControl = CodeEdit2 then
    CodeEdit2.CutToClipBoard;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.CopyClick(Sender: TObject);
begin
  if MainForm.ActiveControl = CodeEdit1 then
    CodeEdit1.CopyToClipBoard
  else if MainForm.ActiveControl = CodeEdit2 then
    CodeEdit2.CopyToClipBoard;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.PasteClick(Sender: TObject);
begin
  if MainForm.ActiveControl = CodeEdit1 then
    CodeEdit1.PasteFromClipBoard
  else if MainForm.ActiveControl = CodeEdit2 then
    CodeEdit2.PasteFromClipBoard;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.FindClick(Sender: TObject);
const
  alphaNumeric = ['0'..'9','A'..'Z','a'..'z'];
var
  i,j: integer;
  pt: TPoint;
  codeEdit: TCodeEdit;
  txt: string;
begin
  if codeEdit1 = MainForm.activeControl then codeEdit := codeEdit1
  else if codeEdit2 = MainForm.activeControl then codeEdit := codeEdit2
  else exit;
  //first, see if there is a sensible selection to search ...
  txt := trim(codeEdit.Selection);
  if (txt <> '') and (pos(#10,txt) = 0) then FindInfo.findStr := txt
  //otherwise, see if the insertion point is over a word ...
  else if (txt = '') then
  begin
    FindInfo.findStr := '';
    pt := codeEdit.CaretPt;
    if (pt.Y < codeEdit.Lines.Count) and (length(codeEdit.Lines[pt.Y]) > 0) then
    begin
      i := pt.X+1; //nb: pt.X is zero based !!!!
      j := i;
      while (i > 0) and CharInSet(codeEdit.Lines[pt.Y][i-1], alphaNumeric) do dec(i);
      while (j <= length(codeEdit.Lines[pt.Y])) and
        CharInSet(codeEdit.Lines[pt.Y][j], alphaNumeric) do inc(j);
      FindInfo.findStr := copy(codeEdit.Lines[pt.Y],i,j-i);
    end;
  end;

  if not GetFindInfo(MainForm, FindInfo) then exit;
  Search.Pattern := FindInfo.findStr;
  Search.CaseSensitive := not FindInfo.ignoreCase;
  FindNextClick(nil);
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.FindNextClick(Sender: TObject);
var
  codeEdit: TCodeEdit;
begin
  if FindInfo.findStr = '' then
   FindClick(nil)
  else
  begin
    if codeEdit2 = MainForm.activeControl then
      codeEdit := codeEdit2 else
      codeEdit := codeEdit1;
    if FindInfo.directionDown then
    begin
      if not FindNext(CodeEdit) then beep;
    end else
      if not FindPrevious(CodeEdit) then beep;
  end;
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.ReplaceClick(Sender: TObject);
var
  codeEdit: TCodeEdit;
begin
  if not GetReplaceInfo(MainForm, FindInfo) then exit;
  Search.Pattern := FindInfo.findStr;
  Search.CaseSensitive := not FindInfo.ignoreCase;
  if codeEdit2 = MainForm.activeControl then
    codeEdit := codeEdit2 else
    codeEdit := codeEdit1;
  if FindInfo.directionDown then
    ReplaceDown(CodeEdit) else
    ReplaceUp(CodeEdit);
end;
//------------------------------------------------------------------------------

procedure TFilesFrame.FontClick(Sender: TObject);
begin
  if not FontDialog1.Execute then exit;
  CodeEdit1.Font := FontDialog1.Font;
  CodeEdit2.Font := FontDialog1.Font;
end;
//---------------------------------------------------------------------

procedure TFilesFrame.pbScrollPosMarkerMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  CodeEdit1.TopVisibleLine :=
    (CodeEdit1.Lines.Count * Y div pbScrollPosMarker.clientHeight) -
    (CodeEdit1.VisibleLines div 2);
end;
//---------------------------------------------------------------------

procedure TFilesFrame.pbScrollPosMarkerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
    CodeEdit1.TopVisibleLine :=
      (CodeEdit1.Lines.Count * Y div pbScrollPosMarker.clientHeight) -
      (CodeEdit1.VisibleLines div 2);
end;
//---------------------------------------------------------------------

end.
