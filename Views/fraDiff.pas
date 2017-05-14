unit fraDiff;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, System.ImageList, Vcl.ImgList,
  PngImageList, System.Actions, Vcl.ActnList,
  Diff, fraEditor;

type
  TDiffOptions = record
    showInlineDiffs: boolean;
    ignoreCase: boolean;
    ignoreBlanks: boolean;
  end;

  TFrameDiff = class(TFrame)
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
    actShowDiffsOnly: TAction;
    PngImageList1: TPngImageList;
    pnlMain: TPanel;
    Splitter1: TSplitter;
    pnl1: TPanel;
    FrameEditor1: TFrameEditor;
    pnl2: TPanel;
    FrameEditor2: TFrameEditor;
    pnlNavigation: TPanel;
    pbScrollPosMarker: TPaintBox;
    Splitter2: TSplitter;
    procedure pbScrollPosMarkerPaint(Sender: TObject);
    procedure pbScrollPosMarkerMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pbScrollPosMarkerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure actSaveExecute(Sender: TObject);
    procedure pnlNavigationResize(Sender: TObject);
    procedure actShowDiffsOnlyExecute(Sender: TObject);
    procedure actSaveUpdate(Sender: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure FrameResize(Sender: TObject);
  private
    { Private declarations }
    FDiff: TDiff;
    FCELines1, FCELines2: TStrings;
    FMargin: integer;
    pbDiffMarkerBmp: TBitmap;
    FIsSyncing: boolean;
    fShowDiffsOnly: boolean;

    procedure SyncScroll(Sender: TObject; ScrollBar: TScrollBarKind);
    procedure scrollFromNavigator(y: integer);

    procedure Compare;
    procedure DisplayDiffs;
    procedure UpdateDiffMarkerBmp;
    function NoModAround(idx, range: integer): boolean;

  public
    { Public declarations }
    options: TDiffOptions;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Load(fileName1, fileName2: string);
  end;

implementation

{$R *.dfm}

uses
  SynEdit,
  frmDiff.utils;

procedure TFrameDiff.actRefreshExecute(Sender: TObject);
begin
  FrameEditor1.isUpdating := true;
  FrameEditor2.isUpdating := true;

  FrameEditor1.Reload;
  FrameEditor2.Reload;
  FrameEditor1.ShowDiffsOnly := self.fShowDiffsOnly;
  FrameEditor2.ShowDiffsOnly := self.fShowDiffsOnly;
  Compare;

  FrameEditor1.isUpdating := false;
  FrameEditor2.isUpdating := false;
end;

procedure TFrameDiff.actSaveExecute(Sender: TObject);
begin
  FrameEditor1.codeEditor.Lines.SaveToFile(ExtractFilePath(paramStr(0)) + 'code1.txt');
end;

procedure TFrameDiff.actSaveUpdate(Sender: TObject);
begin
  actSave.Enabled := not fShowDiffsOnly;
end;

procedure TFrameDiff.actShowDiffsOnlyExecute(Sender: TObject);
begin
  fShowDiffsOnly := actShowDiffsOnly.Checked;
  actRefreshExecute(Sender);
end;

procedure TFrameDiff.Compare;
var
  HashList1, HashList2: TList;
begin
  if (FCELines1.Count = 0) or (FCELines2.Count = 0) then
    exit;

  screen.Cursor := crHourglass;
  HashList1 := TList.create;
  HashList2 := TList.create;
  try
    HashList1.capacity := FCELines1.Count;
    HashList2.capacity := FCELines2.Count;
    FrameEditor1.GetHashedSource(HashList1, options.ignoreCase, options.ignoreBlanks);
    FrameEditor2.GetHashedSource(HashList2, options.ignoreCase, options.ignoreBlanks);
    FDiff.Execute(PInteger(HashList1.List), PInteger(HashList2.List), HashList1.Count, HashList2.Count);
    DisplayDiffs;
//    ActiveControl := FrameEditor1.codeEditor;
  finally
    HashList1.Free;
    HashList2.Free;
    screen.Cursor := crDefault;
  end;
end;

constructor TFrameDiff.Create(AOwner: TComponent);
begin
  inherited;
  fShowDiffsOnly := false;

  addClr := defaultAddClr;
  modClr := defaultModClr;
  delClr := defaultDelClr;

  options.showInlineDiffs := false;
  options.ignoreCase := true;
  options.ignoreBlanks := true;

  // the diff engine ...
  FDiff := TDiff.create(self);

  FrameEditor1.codeEditor.OnScroll := SyncScroll;
  FrameEditor1.isCurrent := false;
  FrameEditor1.Diff := FDiff;

  FrameEditor2.codeEditor.OnScroll := SyncScroll;
  FrameEditor2.isCurrent := true;
  FrameEditor2.Diff := FDiff;

  // shortcuts
  FCELines1 := FrameEditor1.codeEditor.Lines;
  FCELines2 := FrameEditor2.codeEditor.Lines;

  SyncScroll(FrameEditor1.codeEditor, sbVertical);
  pnlNavigation.visible := true;

  pbScrollPosMarker.Canvas.Pen.Color := clBlack;
  pbScrollPosMarker.Canvas.Pen.Width := 1;

  pbDiffMarkerBmp := TBitmap.create;
  pbDiffMarkerBmp.Canvas.Brush.Color := clRed;

  FrameEditor1.Enabled := false;
  FrameEditor2.Enabled := false;
end;

destructor TFrameDiff.Destroy;
begin
  FDiff.Free;
  pbDiffMarkerBmp.Free;
  inherited;
end;

procedure TFrameDiff.DisplayDiffs;
var
  i: Integer;
  lines1, lines2: TStringList;
begin
  lines1 := TStringList.Create;
  lines2 := TStringList.Create;
  FCELines1.BeginUpdate;
  FCELines2.BeginUpdate;
  try
    FrameEditor1.GetSource(lines1);
    FrameEditor2.GetSource(lines2);
    FCELines1.Clear;
    FCELines2.Clear;

    with FDiff do
      for i := 0 to Count - 1 do
        with Compares[i] do
          case Kind of
            ckNone:
              begin
                if fShowDiffsOnly and NoModAround(i, 3) then continue;
                FCELines1.AddObject(lines1[oldIndex1], TObject(oldIndex1));
                FCELines2.AddObject(lines2[oldIndex2], TObject(oldIndex2));
              end;
            ckAdd:
              begin
                FCELines1.AddObject('', TObject(-1));
                FCELines2.AddObject(lines2[oldIndex2], TObject(oldIndex2));
              end;
            ckDelete:
              begin
                FCELines1.AddObject(lines1[oldIndex1], TObject(oldIndex1));
                FCELines2.AddObject('', TObject(-1));
              end;
            ckModify:
              begin
                FCELines1.AddObject(lines1[oldIndex1], TObject(oldIndex1));
                FCELines2.AddObject(lines2[oldIndex2], TObject(oldIndex2));
              end;
          end;

  finally
    FCELines1.EndUpdate;
    FCELines2.EndUpdate;
    FrameEditor2.codeEditor.Modified := false;
    UpdateDiffMarkerBmp;
    pbScrollPosMarker.Repaint;
    lines1.Free;
    lines2.Free;
  end;
end;

procedure TFrameDiff.FrameResize(Sender: TObject);
begin
  pnl1.Width := (ClientWidth - pnlNavigation.Width) div 2;
end;

procedure TFrameDiff.Load(fileName1, fileName2: string);
begin
  FrameEditor1.LoadFile(fileName1);
  FrameEditor2.LoadFile(fileName2);
  Compare;
end;

function TFrameDiff.NoModAround(idx, range: integer): boolean;
var
  i, max: Integer;
begin
  result := true;
  max := FDiff.Count - 1;
  for i := idx - range to idx + range do
  begin
    if (i < 0) or (i = idx) or (i>max) then
      continue;
    if FDiff.Compares[i].Kind <> ckNone then
      exit(false);
  end;
end;


procedure TFrameDiff.pbScrollPosMarkerMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if FCELines1.Count = 0 then
    exit;
  scrollFromNavigator(y);
end;

procedure TFrameDiff.pbScrollPosMarkerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if FCELines1.Count = 0 then
    exit;
  if ssLeft in Shift then
    scrollFromNavigator(y);
end;

procedure TFrameDiff.pbScrollPosMarkerPaint(Sender: TObject);
var
  yPos1, yPos2: Integer;
  bm: TBitmap;
begin
  if FCELines1.Count = 0 then
    exit;

  with pbScrollPosMarker do
  begin
    Canvas.Brush.Color := clNavy;
    Canvas.Draw(0, 0, pbDiffMarkerBmp);
    with FrameEditor1.codeEditor do
    begin
      yPos1 := FrameEditor1.TopVisibleLine - 1;
      yPos2 := yPos1 + LinesInWindow + 1;
    end;
    yPos1 := (clientHeight - 4 * FMargin) * yPos1 div FCELines1.Count + 2*FMargin;
    yPos2 := (clientHeight - 4 * FMargin) * yPos2 div FCELines1.Count + 2*FMargin + 2;
    if yPos2 < yPos1 + 2 then
      yPos2 := yPos1 + 2;
    if yPos2 > clientHeight - 2*FMargin then
      yPos2 := clientHeight - 2*FMargin;

    // pó³przezroczysty wype³niony prostok¹t z wyraŸn¹ ramk¹
    Canvas.Pen.Color := clNavy;
    Canvas.Brush.Style := bsClear;

    bm := TBitmap.Create;
    bm.SetSize(ClientWidth, yPos2 - yPos1);
    bm.Canvas.Brush.Color := $00FFB8A4;
    bm.Canvas.Pen.Style := psSolid;
    // bez ramki...
    bm.Canvas.FillRect(Rect(0, 0, bm.Width, bm.Height));
    // rysujemy wype³niony prostok¹t
    Canvas.Draw(0, yPos1, bm, 50);
    // i ramka
    Canvas.Rectangle(0, yPos1, ClientWidth, yPos2);
    bm.Free;
  end;
end;

procedure TFrameDiff.pnlNavigationResize(Sender: TObject);
begin
  UpdateDiffMarkerBmp;
end;

procedure TFrameDiff.scrollFromNavigator(y: integer);
begin
  FrameEditor1.ScrollTo(Y - 2 * FMargin, pbScrollPosMarker.clientHeight - 4 * FMargin);
  SyncScroll(FrameEditor1.codeEditor, sbVertical);
end;

procedure TFrameDiff.SyncScroll(Sender: TObject; ScrollBar: TScrollBarKind);
begin
  if (FCELines1.Count = 0) or FIsSyncing or not(Sender is TSynEdit) then
    exit;
  FIsSyncing := true; // stops recursion
  try
    case ScrollBar of
      sbHorizontal: begin
        if Sender = FrameEditor1.codeEditor then
          FrameEditor2.codeEditor.LeftChar := FrameEditor1.codeEditor.LeftChar
        else
          FrameEditor1.codeEditor.LeftChar := FrameEditor2.codeEditor.LeftChar;
      end;
      sbVertical: begin
        if Sender = FrameEditor1.codeEditor then
          FrameEditor2.TopVisibleLine := FrameEditor1.TopVisibleLine
        else
          FrameEditor1.TopVisibleLine := FrameEditor2.TopVisibleLine;
      end;
    end;
  finally
    FIsSyncing := false;
  end;
  pbScrollPosMarkerPaint(self);
end;

procedure TFrameDiff.UpdateDiffMarkerBmp;
var
  i, y1, y2, x1_1, x1_2, x2_1, x2_2: Integer;
  clr1, clr2: TColor;
  HeightRatio: single;
begin
  if (FCELines1.Count = 0) or (FCELines2.Count = 0) then
    exit;

  FMargin := (pbScrollPosMarker.ClientWidth - 30) div 10;
  if FMargin > 5 then
    FMargin := 5;

  HeightRatio := (pbScrollPosMarker.ClientHeight - 4 * FMargin) / FCELines1.Count;

  pbDiffMarkerBmp.Width := pbScrollPosMarker.ClientWidth;
  pbDiffMarkerBmp.Height := pbScrollPosMarker.ClientHeight;

  with pbDiffMarkerBmp do
  begin
    Canvas.Pen.Width := 1;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Color := clBlack;
    Canvas.Brush.Color := pbScrollPosMarker.Color;
    Canvas.Brush.Style := bsSolid;

    // t³o
    Canvas.FillRect(Rect(0, 0, Width, Height));

    x1_1 := 2*FMargin;
    x1_2 := pbScrollPosMarker.ClientWidth div 2 - FMargin;
    x2_1 := pbScrollPosMarker.ClientWidth div 2 + FMargin;
    x2_2 := pbScrollPosMarker.ClientWidth - 2*FMargin;

    // dwa bia³e paski
    Canvas.Brush.Color := clWhite;
    Canvas.FillRect(Rect(x1_1, 2*FMargin, x1_2, pbScrollPosMarker.ClientHeight -2*FMargin));
    Canvas.FillRect(Rect(x2_1, 2*FMargin, x2_2, pbScrollPosMarker.ClientHeight -2*FMargin));

    for i := 0 to FCELines1.Count - 1 do
    begin
      case FDiff.Compares[i].Kind of
        ckAdd: begin
          clr1 := grayColor;
          clr2 := addClr;
        end;
        ckDelete: begin
          clr1 := delClr;
          clr2 := grayColor;
        end;
        ckModify: begin
          clr1 := modClr;
          clr2 := modClr;
        end
      else
        continue;
      end;
      y1 := trunc(i * HeightRatio) + 2*FMargin;
      y2 := trunc((i+1) * HeightRatio) + 2*FMargin;
      if y2 = y1 then
        inc(y2);
      // linie
      Canvas.Brush.Color := clr1;
      Canvas.FillRect(Rect(x1_1, y1, x1_2, y2));

      Canvas.Brush.Color := clr2;
      Canvas.FillRect(Rect(x2_1, y1, x2_2, y2));
    end;
    if FMargin > 0 then
    begin
      // ramka wokó³ obu pasków
      Canvas.Brush.Color := clBlack;
      Canvas.FrameRect(Rect(x1_1, 2*FMargin, x1_2, pbScrollPosMarker.ClientHeight - 2*FMargin));
      Canvas.FrameRect(Rect(x2_1, 2*FMargin, x2_2, pbScrollPosMarker.ClientHeight - 2*FMargin));
    end;
  end;

  pbScrollPosMarker.Invalidate;
end;

end.
