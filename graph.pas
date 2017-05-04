unit graph;

interface

uses
  WinApi.Windows,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls;

type
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
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Anchors;
    property Brush: TBrush read FBrush write SetBrush;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Constraints;
    property ParentShowHint;
    property Pen: TPen read FPen write SetPen;
    property ShowHint;
    property Touch;
    property Visible;
    property OnContextPopup;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseActivate;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnGesture;
    property OnStartDock;
    property OnStartDrag;
  end;

  TGraphNode = class(TGraphShape)
  protected
    FRect: TRect;
    FCaption: string;
    procedure Paint; override;
    procedure PaintText; virtual;
  public
    constructor Create(AOwner: TComponent; x, y: integer; const ACaption: string = ''); reintroduce;
  end;

  TGraphBranch = class(TGraphNode)
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent; x, y: integer; const ACaption: string = '');
  end;

  TGraphLink = class(TGraphShape)
  protected
    FSourceNode: TGraphNode;
    FDestNode: TGraphNode;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent; ASourceNode, ADestNode: TGraphNode); reintroduce;
  end;


implementation

{ TGraphShape }

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

constructor TGraphBranch.Create(AOwner: TComponent; x, y: integer; const ACaption: string);
begin
  inherited Create(AOwner, x, y, ACaption);
  FPen.Color := clMaroon;
end;

procedure TGraphBranch.Paint;
begin
  prepareCanvas;
  Canvas.RoundRect(FRect, 10, 10);
  PaintText;
end;

{ TGraphLink }

constructor TGraphLink.Create(AOwner: TComponent; ASourceNode, ADestNode: TGraphNode);
begin
  inherited Create(AOwner);
  FSourceNode := ASourceNode;
  FDestNode := ADestNode;
  FPen.Color := clRed;
end;

procedure TGraphLink.Paint;
begin
  inherited;
  Canvas.MoveTo(FSourceNode.Left + FSourceNode.Width div 2, FSourceNode.Top + FSourceNode.Height div 2);
  Canvas.LineTo(FDestNode.Left + FDestNode.Width div 2, FDestNode.Top + FDestNode.Height div 2);
  FSourceNode.Paint;
  FDestNode.Paint;
end;

{ TGraphNode }

constructor TGraphNode.Create(AOwner: TComponent; x, y: integer; const ACaption: string);
begin
  inherited Create(AOwner);
  FCaption := ACaption;
  parent := TWinControl(AOwner);
  left := x;
  top := y;
  Height := 25;
  Pen.Color := clNavy;
  Canvas.Font.Name := 'Tahoma';
  Canvas.Font.Size := 10;
  Canvas.Font.Color := clNavy;
  width := Canvas.TextWidth(ACaption)+ 10;

  FRect.Left := pen.Width div 2;
  FRect.Top := FRect.Left;
  FRect.Width := width;
  FRect.Height := Height;
end;

procedure TGraphNode.Paint;
begin
  inherited;
  Canvas.Rectangle(FRect);
  PaintText;
end;

procedure TGraphNode.PaintText;
begin
  Canvas.TextRect(FRect, FCaption, [tfSingleLine, tfVerticalCenter, tfCenter]);
end;

end.
