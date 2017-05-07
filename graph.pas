unit graph;

interface

uses
  WinApi.Windows,
  WinApi.Messages,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms;

type
  TGraphNode = class;

  TGraphPanel = class(TScrollBox)
  private
    FCanvas: TCanvas;
    FControlState: TControlState;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  protected
    procedure Paint;
    procedure PaintWindow(DC: HDC); override;
    property Canvas: TCanvas read FCanvas;

    procedure SetScrollBars(AScrollBar: TControlScrollBar);
    procedure Changed(ANode: TGraphNode);
    procedure DrawLinksOfNode(ANode: TGraphNode);
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean; override;
  public
    constructor Create(AOwner: TComponent);  override;
    destructor Destroy; override;
  end;

  TGraphShape = class(TGraphicControl)
  private
    FPen: TPen;
    FBrush: TBrush;
    procedure SetBrush(Value: TBrush);
    procedure SetPen(Value: TPen);
  protected
    procedure prepareCanvas; virtual;
    procedure Paint; override;
    procedure StyleChanged(Sender: TObject);
    function Center: TPoint;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Brush: TBrush read FBrush write SetBrush;
    property Pen: TPen read FPen write SetPen;
    property Visible;
    property OnContextPopup;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

  TGraphLink = class(TPersistent)
  private
    FSourcePoint: TPoint;
    FDestPoint: TPoint;
    FPen: TPen;
    FOwner: TGraphPanel;
  protected
    FSourceNode: TGraphNode;
    FDestNode: TGraphNode;
    procedure Paint(ACanvas: TCanvas);
    procedure recalculateDimensions;
  public
    constructor Create(AOwner: TComponent; ASourceNode, ADestNode: TGraphNode); reintroduce;
    destructor Destroy; override;
    property Pen: TPen read FPen write FPen;
  end;

  TGraphNode = class(TGraphShape)
  protected
    fDragging: Boolean;
    fDragX: Integer;
    fDragY: Integer;
    FParentLink: TGraphLink;
    FMergeLink: TGraphLink;
    FCaption: string;
    procedure Paint; override;
    procedure PaintText; virtual;
    function LinkIntersect(const LinkAngle: Single; Backward: Boolean): TPoint; virtual;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent; x, y: integer; const ACaption: string = ''; AParentNode: TGraphNode = nil); reintroduce;
    destructor Destroy; override;
    procedure MergeFrom(AMergeSource: TGraphNode);
  end;

  TGraphBranch = class(TGraphNode)
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent; x, y: integer; const ACaption: string = ''; AParentNode: TGraphNode = nil);
  end;

procedure Register;

implementation

uses
  Math;

// In the following functions, the line passes through the center of shape
function IntersectLineRect(const LineAngle: Single; const Rect: TRect; Backward: Boolean): TPoint;
var
  M, C, A: Single;
  Xc, Yc: Single;
begin
  Xc := (Rect.Left + Rect.Right) / 2;
  Yc := (Rect.Top + Rect.Bottom) / 2;
  if Abs(LineAngle) = Pi / 2 then
  begin
    if (LineAngle > 0) xor Backward then
      Result := Point(Round(Xc), Rect.Bottom)
    else
      Result := Point(Round(Xc), Rect.Top);
  end
  else if (LineAngle = 0) or (Abs(LineAngle) = Pi) then
  begin
    if (LineAngle <> 0) xor Backward then
      Result := Point(Rect.Left, Round(Yc))
    else
      Result := Point(Rect.Right, Round(Yc));
  end
  else
  begin
    M := Tan(LineAngle);
    C := Yc - M * Xc;
    A := 0;
    if (Rect.Right - Rect.Left) > 0 then
      A := ArcTan2((Rect.Bottom - Rect.Top) / 2, (Rect.Right - Rect.Left) / 2);
    if ((Abs(LineAngle) >= 0) and (Abs(LineAngle) <= A) and Backward) or
       ((Pi - Abs(LineAngle) >= 0) and (Pi - Abs(LineAngle) <= A) and not Backward)
    then
      Result := Point(Rect.Left, Round(M * Rect.Left + C))
    else if ((Abs(LineAngle) >= 0) and (Abs(LineAngle) <= A) and not Backward) or
            ((Pi - Abs(LineAngle) >= 0) and (Pi - Abs(LineAngle) <= A) and Backward)
    then
      Result := Point(Rect.Right, Round(M * Rect.Right + C))
    else if (LineAngle > 0) xor Backward then
      Result := Point(Round((Rect.Bottom - C) / M), Rect.Bottom)
    else
      Result := Point(Round((Rect.Top - C) / M), Rect.Top);
  end;
end;

function IntersectLineRoundRect(const LineAngle: Single; const Bounds: TRect; Backward: Boolean; Rgn: HRgn): TPoint;
var
  CR: TRect;
  Sw, Sh, W, H: Integer;
  A2, B2, M, C: Single;
  Xc, Yc, X, Y: Single;
  a, b, d: Single;
begin
  Result := IntersectLineRect(LineAngle, Bounds, Backward);
  SetRect(CR, Result.X, Result.Y, Result.X, Result.Y);
  InflateRect(CR, 1, 1);
  if not RectInRegion(Rgn, CR) and (Abs(LineAngle) <> Pi / 2) then
  begin
    W := Bounds.Right - Bounds.Left;
    H := Bounds.Bottom - Bounds.Top;
    if W > H then
    begin
      Sw := W div 4;
      if Sw > H then
        Sh := H
      else
        Sh := Sw;
    end
    else
    begin
      Sh := H div 4;
      if Sh > W then
        Sw := W
      else
        Sw := Sh;
    end;
    if ((LineAngle > 0) and (LineAngle < Pi / 2) and Backward) or
       ((LineAngle < -Pi / 2) and (LineAngle > -Pi) and not Backward)
    then
      SetRect(CR, Bounds.Left, Bounds.Top, Bounds.Left + Sw, Bounds.Top + Sh)
    else if ((LineAngle > 0) and (LineAngle < Pi / 2) and not Backward) or
            ((LineAngle < -Pi / 2) and (LineAngle > -Pi) and Backward)
    then
      SetRect(CR, Bounds.Right - Sw, Bounds.Bottom - Sh, Bounds.Right, Bounds.Bottom)
    else if ((LineAngle < 0) and (LineAngle > -Pi / 2) and Backward) or
            ((LineAngle > Pi / 2) and (LineAngle < Pi) and not Backward)
    then
      SetRect(CR, Bounds.Left, Bounds.Bottom - Sh, Bounds.Left + Sw, Bounds.Bottom)
    else if ((LineAngle < 0) and (LineAngle > -Pi / 2) and not Backward) or
            ((LineAngle > Pi / 2) and (LineAngle < Pi) and Backward)
    then
      SetRect(CR, Bounds.Right - Sw, Bounds.Top, Bounds.Right, Bounds.Top + Sh);
    Xc := (Bounds.Left + Bounds.Right) / 2;
    Yc := (Bounds.Top + Bounds.Bottom) / 2;
    M := Tan(LineAngle);
    C := Yc - M * Xc;
    Xc := (CR.Left + CR.Right) / 2;
    Yc := (CR.Top + CR.Bottom) / 2;
    A2 := Sqr(Sw / 2);
    B2 := Sqr(Sh / 2);
    a := (B2 + A2 * Sqr(M));
    b := (A2 * M * (C - Yc)) - B2 * Xc;
    d := Sqr(b) - a * (B2 * Sqr(Xc) + A2 * Sqr(C - Yc) - A2 * B2);
    if d > 0 then
    begin
      if (Abs(LineAngle) < Pi / 2) xor Backward then
        X := (-b + Sqrt(d)) / a
      else
        X := (-b - Sqrt(Sqr(b) - a * (B2 * Sqr(Xc) + A2 * Sqr(C - Yc) - A2 * B2))) / a;
      Y := M * X + C;
      Result := Point(Round(X), Round(Y));
    end;
  end;
end;

{ TGraphShape }

function TGraphShape.Center: TPoint;
begin
  Result := Point(Left + Width div 2, Top + Height div 2);
end;

constructor TGraphShape.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  Width := 100;
  Height := 35;
  FPen := TPen.Create;
  FPen.OnChange := StyleChanged;
  FBrush := TBrush.Create;
  FBrush.OnChange := StyleChanged;
end;

destructor TGraphShape.Destroy;
begin
  FPen.Free;
  FBrush.Free;
  inherited;
end;

procedure TGraphShape.Paint;
begin
  prepareCanvas;
end;

procedure TGraphShape.prepareCanvas;
begin
  with Canvas do
  begin
    Pen := FPen;
    Brush := FBrush;
  end;
end;

procedure TGraphShape.SetBrush(Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TGraphShape.SetPen(Value: TPen);
begin
  FPen.Assign(Value);
end;

procedure TGraphShape.StyleChanged(Sender: TObject);
begin
  Invalidate;
end;

{ TGraphBranch }

constructor TGraphBranch.Create(AOwner: TComponent; x, y: integer; const ACaption: string = ''; AParentNode: TGraphNode = nil);
begin
  inherited Create(AOwner, x, y, ACaption, AParentNode);
  FPen.Color := clMaroon;
  FBrush.Color := $00eeeeee;
end;

procedure TGraphBranch.Paint;
begin
  prepareCanvas;
  Canvas.RoundRect(0, 0, width, height, 10, 10);
  PaintText;
end;

{ TGraphLink }

constructor TGraphLink.Create(AOwner: TComponent; ASourceNode, ADestNode: TGraphNode);
begin
  inherited Create;
  FOwner := TGraphPanel(AOwner);
  FPen := TPen.Create;
  FPen.Width := 1;
  FPen.Color := clBlue;
  FSourceNode := ASourceNode;
  FDestNode := ADestNode;
  recalculateDimensions;
end;

destructor TGraphLink.Destroy;
begin
  FPen.Free;
  inherited;
end;

procedure TGraphLink.Paint(ACanvas: TCanvas);
begin
  if self = nil then
    exit;
  ACanvas.Pen.Assign(Pen);
  ACanvas.MoveTo(FSourcePoint.X, FSourcePoint.Y);
  ACanvas.LineTo(FDestPoint.X, FDestPoint.Y);
end;

procedure TGraphLink.recalculateDimensions;
var
  r: TRect;
  angle: single;
begin
  if self = nil then
    exit;
  if Assigned(FSourceNode) and Assigned(FDestNode) then
  begin
    FSourcePoint := FSourceNode.Center;
    FDestPoint := FDestNode.Center;
    if FSourcePoint.X <> FDestPoint.X then
      angle := ArcTan2((FDestPoint.Y - FSourcePoint.Y), (FDestPoint.X - FSourcePoint.X))
    else if FSourcePoint.Y >= FDestPoint.Y then
      angle := -Pi / 2
    else
      angle := Pi / 2;
    FSourcePoint := FSourceNode.LinkIntersect(Angle, False);
    FDestPoint := FDestNode.LinkIntersect(Angle, True);
  end;
end;

{ TGraphNode }

constructor TGraphNode.Create(AOwner: TComponent; x, y: integer; const ACaption: string = ''; AParentNode: TGraphNode = nil);
begin
  inherited Create(AOwner);
  FParentLink := nil;
  FMergeLink := nil;

  FCaption := ACaption;
  parent := TWinControl(AOwner);
  left := x;
  top := y;

  FPen.Color := clNavy;
  FPen.Width := 1;
  FPen.Style := psSolid;

  FBrush.Style := bsSolid;
  FBrush.Color := clWhite;

  Canvas.Font.Name := 'Tahoma';
  Canvas.Font.Size := 10;
  Canvas.Font.Color := clNavy;

  Height := 25;
  Width := Canvas.TextWidth(ACaption)+ 10;

  if Assigned(AParentNode) then
  begin
    FParentLink := TGraphLink.Create(AOwner, AParentNode, self);
    Refresh;
  end;
end;

destructor TGraphNode.Destroy;
begin
  FParentLink.Free;
  FMergeLink.Free;
  inherited;
end;

function TGraphNode.LinkIntersect(const LinkAngle: single; Backward: Boolean): TPoint;
begin
  Result := IntersectLineRect(LinkAngle, BoundsRect, Backward);
end;

procedure TGraphNode.MergeFrom(AMergeSource: TGraphNode);
begin
  FMergeLink := TGraphLink.Create(Owner, AMergeSource, self);
  FMergeLink.Pen.Color := clRed;
  Refresh;
end;

procedure TGraphNode.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fDragging := true;
  Pen.Color := clRed;
  fDragX := x;
  fDragY := y;
  inherited;
end;

procedure TGraphNode.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  mp: TPoint;
begin
  if fDragging then
  begin
    mp := Parent.ScreenToClient(Mouse.CursorPos);
    Left := mp.X - fDragX;
    Top := mp.Y - fDragY;
    FParentLink.recalculateDimensions;
    FMergeLink.recalculateDimensions;
    TGraphPanel(Owner).Changed(self);
  end;
  inherited;
end;

procedure TGraphNode.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  fDragging := false;
  Pen.Color := clNavy;
  inherited;
end;

procedure TGraphNode.Paint;
begin
//  if fDragging then
//    exit;
  Canvas.Rectangle(0, 0, width, height);
  PaintText;
end;

procedure TGraphNode.PaintText;
var
  r: TRect;
begin
  r := Rect(0, 0, width, height);
  Canvas.TextRect(r, FCaption, [tfSingleLine, tfVerticalCenter, tfCenter]);
end;

{ TGraphPanel }

procedure TGraphPanel.Changed(ANode: TGraphNode);
begin
  DrawLinksOfNode(ANode);
  Invalidate;
end;

constructor TGraphPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Color := clWhite;
  BevelInner := bvNone;
  BevelOuter := bvNone;
  BorderStyle := bsNone;
  FCanvas := TControlCanvas.Create;
  TControlCanvas(FCanvas).Control := Self;
  SetScrollBars(VertScrollBar);
  SetScrollBars(HorzScrollBar);
end;

destructor TGraphPanel.Destroy;
begin
  FCanvas.Free;
  inherited;
end;

function TGraphPanel.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  VertScrollBar.Position := VertScrollBar.Position - WheelDelta;
  invalidate;
  inherited;
end;

procedure TGraphPanel.DrawLinksOfNode(ANode: TGraphNode);
var
  parentLink: TGraphLink;
  mergeLink: TGraphLink;
begin
  parentLink := ANode.FParentLink;
  mergeLink := ANode.FMergeLink;
  parentLink.Paint(Canvas);
  mergeLink.Paint(Canvas);
end;

procedure TGraphPanel.Paint;
var
  i: Integer;
  ctrl: TControl;

begin
  for i := 0 to ControlCount - 1 do
  begin
    ctrl := controls[i];
    if ctrl is TGraphNode then
      DrawLinksOfNode(TGraphNode(ctrl))
  end;
end;

procedure TGraphPanel.PaintWindow(DC: HDC);
begin
  FCanvas.Lock;
  try
    FCanvas.Handle := DC;
    try
      TControlCanvas(FCanvas).UpdateTextFlags;
      Paint;
    finally
      FCanvas.Handle := 0;
    end;
  finally
    FCanvas.Unlock;
  end;
end;

procedure TGraphPanel.SetScrollBars(AScrollBar: TControlScrollBar);
begin
  AScrollBar.Smooth := true;
  AScrollBar.Tracking := true;
end;

procedure TGraphPanel.WMPaint(var Message: TWMPaint);
begin
  ControlState := ControlState + [csCustomPaint];
  inherited;
  ControlState := ControlState - [csCustomPaint];
end;

procedure Register;
begin
  RegisterComponents('Samples', [TGraphPanel]);
end;

end.
