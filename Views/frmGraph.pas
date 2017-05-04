unit frmGraph;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, graph, Vcl.StdCtrls, Vcl.ComCtrls, VirtualTrees,
  whizaxe.VSTHelper,
  Models.LogInfo, System.ImageList, Vcl.ImgList, PngImageList, System.Actions, Vcl.ActnList, Vcl.Menus,
  Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnPopup;

type
  TGraphForm = class(TForm)
    PageControl1: TPageControl;
    tabGraph: TTabSheet;
    tabGraphLog: TTabSheet;
    graphPanel: TScrollBox;
    graphMemo: TMemo;
    logoGraph: TVirtualStringTree;
    icons: TPngImageList;
    ActionList1: TActionList;
    actHideIgnored: TAction;
    actFilterBranches: TAction;
    PopupActionBar1: TPopupActionBar;
    filterbranches1: TMenuItem;
    Hideignored1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

    procedure hndShapeMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure hndShapeMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure hndShapeMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure graphPanelMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
      var Handled: Boolean);
    procedure cbxHideTrashClick(Sender: TObject);
    procedure actFilterBranchesExecute(Sender: TObject);
    procedure actHideIgnoredExecute(Sender: TObject);
    procedure logoGraphColumnResize(Sender: TVTHeader; Column: TColumnIndex);
    procedure logoGraphColumnWidthDblClickResize(Sender: TVTHeader; Column: TColumnIndex; Shift: TShiftState; P: TPoint;
      var Allowed: Boolean);
  private
    fdragging: Boolean;
    fDragX: Integer;
    fDragY: Integer;
    FVSTHelper: TVSTHelper<TlogNode>;
    Fbranches: TLogBranches;
    fColResizing: Boolean;

    procedure hndPaintCell(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Item: TLogNode; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect; var DefaultDraw: boolean);
    procedure hndDrawHeader(Sender: TVTHeader; var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements; var DefaultDraw: boolean);
    procedure hndAfterItemPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Item: TLogNode; Node: PVirtualNode; ItemRect: TRect);
    procedure toggleDeadBranches;
    function getMaxDynColIdx: integer;
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

procedure TGraphForm.actFilterBranchesExecute(Sender: TObject);
begin
//
end;

procedure TGraphForm.actHideIgnoredExecute(Sender: TObject);
begin
  toggleDeadBranches;
end;

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

  function CreateBranchCol(idx: integer): TVirtualTreeColumn;
  begin
    result := TVirtualTreeColumn(FVSTHelper.TreeView.Header.Columns.Insert(i));
    result.Text := key;
    result.Hint := Fbranches[key].revision;
    result.tag := integer(Fbranches[key]);
    result.width := 30;
    result.MaxWidth := 30;
    result.MinWidth := 10;
    result.Options := result.Options - [coEditable];
  end;

begin
  lFileInfo := TFileInfo.Create('c:\mccomp\NewPos2014\Whizaxe\whizaxe.common.pas', 'c:\mccomp\NewPos2014');
  lcvs := TRepoHelperCVS.Create;
  lcvs.logFile(lFileInfo, logNodes, true);

  FVSTHelper := TVSTHelper<TLogNode>.Create;
  FVSTHelper.OnPaintCell := hndPaintCell;
  FVSTHelper.OnDrawHeader := hndDrawHeader;
  FVSTHelper.OnAfterItemPaint := hndAfterItemPaint;
  FVSTHelper.TreeView := logoGraph;

  Fbranches := logNodes.getBranches;

  i := 0;
  for key in Fbranches.Keys do
  begin
    treeCol := CreateBranchCol(i);
    if key = 'HEAD' then
      treeCol.index := 0;
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

function TGraphForm.getMaxDynColIdx: integer;
begin
  result := logoGraph.Header.Columns.Count - 3 - 1;
end;

procedure TGraphForm.graphPanelMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  handled := true;
  graphPanel.VertScrollBar.Position := graphPanel.VertScrollBar.Position - WheelDelta;
end;

procedure TGraphForm.hndAfterItemPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Item: TLogNode;
  Node: PVirtualNode; ItemRect: TRect);
var
  x: integer;
  p: TPoint;
  i: Integer;
  treeCol0, treeCol1: TVirtualTreeColumn;
  r: TRect;
  p1, p2, p3, p4: TPoint;
  dx: Integer;
  dy: integer;

  function findColWithRev(ARev: string): TVirtualTreeColumn;
  var
    i: integer;
    crev: string;
  begin
    for i := getMaxDynColIdx downto 0 do
    begin
      result := Sender.Header.Columns[i];
      crev := TLogBranchInfo(result.Tag).revision;
      if TCVSRevision.isSameBranch(ARev, crev) then
        exit;
    end;
  end;

begin
  if item.mergeFrom <> '' then
  begin
    treeCol0 := findColWithRev(item.mergeFrom);
    treeCol1 := findColWithRev(item.revision);
    if not ((coVisible in treeCol1.Options) and (coVisible in treeCol0.Options))
      or (treeCol0.Text = treeCol1.Text) then
      exit;

    dx := treeCol0.Width div 2 -1;
    dy := TVirtualStringTree(sender).DefaultNodeHeight div 2 -1;
    r := TargetCanvas.ClipRect;
    p1 := Point(r.Left + treeCol0.Left + dx, 0);
    p4 := Point(r.Left + treeCol1.left + dx, dy);
    p2 := Point(p1.X + (p4.X - p1.X) div 4, dy);
    p3 := Point(p4.X - (p4.X - p1.X) div 4, dy);
    TargetCanvas.Pen.Color := clRed;
    TargetCanvas.Pen.Width := 1;

    TargetCanvas.PolyBezier([p1, p2, p3, p4]);
  end;

end;

procedure TGraphForm.hndDrawHeader(Sender: TVTHeader; var PaintInfo: THeaderPaintInfo; const Elements: THeaderPaintElements; var DefaultDraw: boolean);
var
  s: string;
begin
  if PaintInfo.Column = nil then
    exit;

  if (PaintInfo.Column.Index in [0..getMaxDynColIdx]) and (hpeText in Elements) then
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
  c: TColor;
  r: TRect;
  branch: string;
  x: Integer;
  col: TVirtualTreeColumn;
begin
  if Column < 0 then
    exit;
  col := Sender.Header.Columns[Column];
  if (Column in [0..getMaxDynColIdx]) then
  begin
    branch := col.Text;

    c := WebColorStrToColor(BRANCHES_COLORS[(col.Index) mod MAX_COLORS]);
    TargetCanvas.Pen.Style := psSolid;
    TargetCanvas.Pen.Width := 3;
    TargetCanvas.Pen.Color := c;
    x := CellRect.Left + CellRect.Width div 2 -1;
    TargetCanvas.MoveTo(x, 0);
    TargetCanvas.LineTo(x, CellRect.Height);

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
  if Column > getMaxDynColIdx then
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

procedure TGraphForm.logoGraphColumnResize(Sender: TVTHeader; Column: TColumnIndex);
var
  i: Integer;
begin
  if fColResizing then
    exit;
  if Column < self.getMaxDynColIdx then
  begin
    fColResizing := true;
    for i := 0 to getMaxDynColIdx do
      sender.Columns[i].Width := sender.Columns[Column].Width;
    fColResizing := false;
  end;
end;

procedure TGraphForm.logoGraphColumnWidthDblClickResize(Sender: TVTHeader; Column: TColumnIndex; Shift: TShiftState;
  P: TPoint; var Allowed: Boolean);
begin
  if sender.Columns[column].Width = 30 then
    sender.Columns[column].Width := 10
  else
    sender.Columns[column].Width := 30;

end;

procedure TGraphForm.toggleDeadBranches;
var
  i: Integer;
  key: string;
  treeCol: TVirtualTreeColumn;
begin
  for i := 1 to getMaxDynColIdx do
  begin
    treeCol := logoGraph.Header.Columns[i];
    key := treeCol.Text;
    if actHideIgnored.Checked then
    begin
      if (key <> 'HEAD')
      and (coVisible in treeCol.Options)
      and (DaysBetween(now, Fbranches[key].lastActivity) > 60) then
        treeCol.Options := treeCol.Options - [coVisible];
    end
    else
      treeCol.Options := treeCol.Options + [coVisible]
  end;

end;

end.
