unit frmGraph;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, graph, Vcl.StdCtrls, Vcl.ComCtrls, VirtualTrees,
  whizaxe.VSTHelper,
  Models.LogInfo;

type
  TGraphForm = class(TForm)
    PageControl1: TPageControl;
    tabGraph: TTabSheet;
    tabGraphLog: TTabSheet;
    graphPanel: TScrollBox;
    graphMemo: TMemo;
    logoGraph: TVirtualStringTree;
    Panel1: TPanel;
    cbxHideTrash: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure hndShapeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure hndShapeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure hndShapeMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure graphPanelMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
      var Handled: Boolean);
    procedure cbxHideTrashClick(Sender: TObject);
    procedure logoGraphAfterItemPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
      ItemRect: TRect);
  private
    fdragging: Boolean;
    fDragX: Integer;
    fDragY: Integer;
    FVSTHelper: TVSTHelper<TlogNode>;
    Fbranches: TLogBranches;

    procedure hndPaintCell(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Item: TLogNode; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect; var DefaultDraw: boolean);
    procedure hndDrawHeader(Sender: TVTHeader; var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements; var DefaultDraw: boolean);
    procedure toggleDeadBranches;
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses
  Models.FileInfo,
  repoHelper.CVS,
  DateUtils,
  Vcl.GraphUtil;

const
  MAX_COLORS = 5;
  BRANCHES_COLORS: array[0..MAX_COLORS -1] of string = ('#6963FF', '#47E8D4', '#6BDB52', '#E84BA5', '#FFA657');

{ TGraphForm }

procedure TGraphForm.cbxHideTrashClick(Sender: TObject);
begin
  toggleDeadBranches;
end;

procedure TGraphForm.FormCreate(Sender: TObject);
var
  lcvs: TRepoHelperCVS;
  logNodes: TLogNodes;
  node: TLogNode;
  lFileInfo: TFileInfo;
  col: Integer;
  x: Integer;
  y: Integer;
  r: TRect;
  shape: TGraphShape;
  key: string;
  i: Integer;
  treeCol: TVirtualTreeColumn;
  sl: TStringList;
begin
  lFileInfo := TFileInfo.Create('c:\mccomp\NewPos2014\Whizaxe\whizaxe.common.pas', 'c:\mccomp\NewPos2014');
  lcvs := TRepoHelperCVS.Create;
  lcvs.logFile(lFileInfo, logNodes, true);

  FVSTHelper := TVSTHelper<TLogNode>.Create;
  FVSTHelper.OnPaintCell := hndPaintCell;
  FVSTHelper.OnDrawHeader := hndDrawHeader;
  FVSTHelper.TreeView := logoGraph;

  Fbranches := logNodes.getBranches;

  i := 0;
  for key in Fbranches.Keys do
  begin
    treeCol := TVirtualTreeColumn(FVSTHelper.TreeView.Header.Columns.Insert(i));
    treeCol.Text := key;
    treeCol.tag := DaysBetween(now, Fbranches[key].lastActivity);
    treeCol.width := 30;
    treeCol.Hint := key;
    if key = 'HEAD' then
      treeCol.Position := 0;
    inc(i);
  end;
  toggleDeadBranches;

  FVSTHelper.Model := logNodes;

  y := 50;
  sl := TStringList.Create;
  sl.Add('rev;date;branch;mergeFrom');
  try
    for node in logNodes do
    begin
      sl.Add(node.asString);
      col := node.revision.CountChar('.');
      x := col * 100;
      y := y + 40;
      r := Rect(x, y, x + 10, y +30);
      if node.isTagOnly then
        shape := TGraphBranch.Create(graphPanel, x, y, node.branch)
      else
        shape := TGraphNode.Create(graphPanel, x, y, node.revision);

      shape.OnMouseDown := hndShapeMouseDown;
      shape.OnMouseMove := hndShapeMouseMove;
      shape.OnMouseUp := hndShapeMouseUp;
    end;
  finally
    lFileInfo.Free;
    lcvs.Free;
    sl.SaveToFile('graph.csv');
    sl.Free;
  end;
end;

procedure TGraphForm.FormDestroy(Sender: TObject);
begin
  FVSTHelper.Model.Free;
  FVSTHelper.Free;
  Fbranches.Free;
end;

procedure TGraphForm.graphPanelMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  handled := true;
  graphPanel.VertScrollBar.Position := graphPanel.VertScrollBar.Position - WheelDelta;
end;

procedure TGraphForm.hndDrawHeader(Sender: TVTHeader; var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements; var DefaultDraw: boolean);
var
  s: string;
begin
  if PaintInfo.Column = nil then
    exit;

  if (PaintInfo.Column.Index in [0..Sender.Columns.Count - 3 - 1]) and (hpeText in Elements) then
  begin
    PaintInfo.TargetCanvas.Font.Orientation := 900;
    PaintInfo.TargetCanvas.Font.color := clBlack;
    PaintInfo.TargetCanvas.Font.color := clYellow;
    s := PaintInfo.Column.Text;
    PaintInfo.TargetCanvas.TextOut(PaintInfo.TextRectangle.Left, PaintInfo.PaintRectangle.Bottom -5 , s);
    DefaultDraw := false;
  end;
end;

procedure TGraphForm.hndPaintCell(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Item: TLogNode; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect; var DefaultDraw: boolean);
var
  dynColsMax: Integer;
  c: TColor;
  r: TRect;
  branch: string;
  x: Integer;
  col: TVirtualTreeColumn;
begin
  dynColsMax := Sender.Header.Columns.Count - 3 - 1;
  if Column < 0 then
    exit;
  col := Sender.Header.Columns[Column];
  if (Column in [0..dynColsMax]) then
  begin
    branch := col.Text;

    c := WebColorStrToColor(BRANCHES_COLORS[(col.Left div col.Width) mod MAX_COLORS]);
    TargetCanvas.Pen.Style := psSolid;
    TargetCanvas.Pen.Width := 3;
    TargetCanvas.Pen.Color := c;
    x := CellRect.Left + CellRect.Width div 2 -1;
    TargetCanvas.MoveTo(x, 0);
    TargetCanvas.LineTo(x, CellRect.Height);

    if item.mergeFrom <> '' then
    begin
      TargetCanvas.PolyBezier([Point(0, 0), Point(x, CellRect.Height div 2)]);
    end;


    if item.branch = branch then
    begin
      TargetCanvas.Brush.Style := bsSolid;
      TargetCanvas.Brush.Color := c;

      r := CellRect;
      r.Offset(r.Width div 2 - 5, 4);
      r.Width := 9;
      r.Height := 9;
      TargetCanvas.Ellipse(r);
    end;
    DefaultDraw := false;
  end;
  if Column > dynColsMax then
  begin
    TargetCanvas.Brush.Style := bsClear;
    DefaultDraw := true;
  end;
end;

procedure TGraphForm.hndShapeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fdragging := true;
  TShape(Sender).Pen.Color := clRed;
  fDragX := x;
  fDragY := y;
end;

procedure TGraphForm.hndShapeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  mp: TPoint;
begin
  if fdragging then
  begin
    mp := ScreenToClient(Mouse.CursorPos);
    TShape(Sender).Left := mp.X - fDragX;
    TShape(Sender).top := mp.Y - fDragY;
  end;
end;

procedure TGraphForm.hndShapeMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fdragging := false;
  TShape(Sender).Pen.Color := clNavy;
end;

procedure TGraphForm.logoGraphAfterItemPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  ItemRect: TRect);
begin
//
end;

procedure TGraphForm.toggleDeadBranches;
var
  i: Integer;
  key: string;
  treeCol: TVirtualTreeColumn;
begin
  for i := 1 to logoGraph.Header.Columns.Count - 3 - 1 do
  begin
    treeCol := logoGraph.Header.Columns[i];
    key := treeCol.Text;
    if cbxHideTrash.Checked then
    begin
      if (key <> 'HEAD')
      and (coVisible in treeCol.Options)
      and (DaysBetween(now, Fbranches[key].lastActivity) > 60) then
        treeCol.Options := treeCol.Options - [coVisible];
    end
    else
      treeCol.Options := treeCol.Options + [coVisible];
  end;

end;

end.
