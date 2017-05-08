unit SimpleGraphRepo;

interface

uses
  WinApi.Windows,
  SimpleGraph,
  Vcl.Graphics;

type
  TCommitNode = class(TGraphNode)
  protected
    procedure DrawBorder(Canvas: TCanvas); override;
    procedure DrawControlPoints(Canvas: TCanvas); override;
    procedure DrawHighlight(Canvas: TCanvas); override;
    function CreateRegion: HRGN; override;
    function LinkIntersect(const LinkPt: TPoint; const LinkAngle: Double): TPoints; override;
  public
    constructor Create(AOwner: TSimpleGraph; x, y: integer; AText: string);
  end;

  TBranchNode = class(TCommitNode)
  protected
    procedure DrawBorder(Canvas: TCanvas); override;
  public
    constructor Create(AOwner: TSimpleGraph; x, y: integer; aText: string);
  end;

  TParentLink = class(TGraphLink)
  protected
    procedure DrawBody(Canvas: TCanvas); override;
  public
    constructor Create(AOwner: TSimpleGraph); override;
  end;

  TMergeLink = class(TParentLink)
  public
    constructor Create(AOwner: TSimpleGraph); override;
  end;

implementation

uses
  System.Classes,
  whizaxe.VCLHelper;

{ TCommitNode }

constructor TCommitNode.Create(AOwner: TSimpleGraph;  x, y: integer; AText: string);
var
  p: TPoint;
begin
  inherited Create(AOwner);
  Margin := 0;
  Pen.Color := clNavy;
  Pen.Width := 1;
  Brush.Style := bsSolid;
  Brush.Color := $00ffffff;
  Font.Color := clNavy;
  font.Name := 'Tahoma';
  font.Size := 10;
  text := AText;
  p := TVCLHelper.GetTextSize(Font, AText);
  BoundsRect := Rect(x, y, x + p.X + 20, y + p.Y + 10);
  NodeOptions := NodeOptions - [gnoResizable];
end;

function TCommitNode.CreateRegion: HRGN;
begin
  Result := CreateRectRgn(Left, Top, Left + Width, Top + Height);
end;

procedure TCommitNode.DrawBorder(Canvas: TCanvas);
begin
  Canvas.Rectangle(Left, Top, Left + Width, Top + Height);
end;

procedure TCommitNode.DrawControlPoints(Canvas: TCanvas);
begin
  // nie rysujemy
end;

procedure TCommitNode.DrawHighlight(Canvas: TCanvas);
begin
  Canvas.Pen.Width := 3;
  Canvas.Rectangle(Left + 2, Top + 2, Left + Width -2, Top + Height - 2);
end;

function TCommitNode.LinkIntersect(const LinkPt: TPoint; const LinkAngle: Double): TPoints;
begin
  Result := IntersectLineRect(LinkPt, LinkAngle, BoundsRect);
end;

{ TBranchNode }

constructor TBranchNode.Create(AOwner: TSimpleGraph; x, y: integer; aText: string);
begin
  inherited Create(AOwner, x, y, aText);
  Pen.Color := clMaroon;
  Brush.Color := $00f0f0ff;
end;

procedure TBranchNode.DrawBorder(Canvas: TCanvas);
begin
  Canvas.RoundRect(Left, Top, Left + Width, Top + Height, 10, 10);
end;

{ TParentLink }

constructor TParentLink.Create(AOwner: TSimpleGraph);
begin
  inherited;
  Self.BeginStyle := lsNone;
  Self.EndStyle := lsNone;
  self.Options := [goLinkable];
  Pen.Color := clBlue;
end;

procedure TParentLink.DrawBody(Canvas: TCanvas);
begin
  if Self.Source.Selected or Self.Target.Selected
  or Self.Source.Dragging or Self.Target.Dragging then
    Canvas.Pen.Width := 3
  else
    Canvas.Pen.Width := 1;
  inherited;
end;

{ TMergeLink }

constructor TMergeLink.Create(AOwner: TSimpleGraph);
begin
  inherited;
  Self.BeginStyle := lsNone;
  Self.EndStyle := lsArrow;
  Self.EndSize := 4;
  self.Options := [goLinkable];
  Pen.Color := clRed;
end;

initialization
  TSimpleGraph.Register(TCommitNode);
  TSimpleGraph.Register(TBranchNode);
  TSimpleGraph.Register(TParentLink);
  TSimpleGraph.Register(TMergeLink);

finalization
  // Unregisters Link and Node classes
  TSimpleGraph.UnRegister(TCommitNode);
  TSimpleGraph.UnRegister(TBranchNode);
  TSimpleGraph.UnRegister(TParentLink);
  TSimpleGraph.UnRegister(TMergeLink);

end.
