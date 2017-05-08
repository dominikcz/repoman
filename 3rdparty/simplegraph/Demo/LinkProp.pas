unit LinkProp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, SimpleGraph, ExtCtrls, StdCtrls;

type
  TLinkProperties = class(TForm)
    Label1: TLabel;
    LinkLabel: TEdit;
    Style: TGroupBox;
    StyleSolid: TRadioButton;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    StyleDash: TRadioButton;
    StyleDot: TRadioButton;
    Colors: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    LineColor: TPanel;
    LinkArrowColor: TPanel;
    btnChangeFont: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    FontDialog: TFontDialog;
    ColorDialog: TColorDialog;
    btnApply: TButton;
    Kind: TGroupBox;
    KindUndirected: TRadioButton;
    KindDirected: TRadioButton;
    KindBidirected: TRadioButton;
    ReverseDir: TCheckBox;
    procedure LineColorClick(Sender: TObject);
    procedure LinkArrowColorClick(Sender: TObject);
    procedure btnChangeFontClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure KindClick(Sender: TObject);
  private
    S: TSimpleGraph;
    L: TGraphObjectList;
    procedure ApplyChanges;
  public
    class function Execute(Links: TGraphObjectList): Boolean;
  end;

implementation

{$R *.dfm}

{ TLinkProperties }

class function TLinkProperties.Execute(Links: TGraphObjectList): Boolean;
begin
  Result := False;
  with Create(Application) do
    try
      L := Links;
      S := Links[0].Owner;
      with TGraphLink(Links[0]) do
      begin
        LinkLabel.Text := Text;
        case Pen.Style of
          psSolid: StyleSolid.Checked := True;
          psDash: StyleDash.Checked := True;
          psDot: StyleDot.Checked := True;
        end;
        LineColor.Color := Pen.Color;
        LinkArrowColor.Color := Brush.Color;
        case Kind of
          lkUndirected: KindUndirected.Checked := True;
          lkDirected: KindDirected.Checked := True;
          lkBidirected: KindBidirected.Checked := True;
        end;
        ReverseDir.Enabled := (Kind = lkDirected);
        FontDialog.Font := Font;
      end;
      if ShowModal = mrOK then
      begin
        ApplyChanges;
        Result := True;
      end;
    finally
      Free;
    end;
end;

procedure TLinkProperties.ApplyChanges;
var
  I: Integer;
begin
  S.BeginUpdate;
  try
    for I := 0 to L.Count - 1 do
      with TGraphLink(L[I]) do
      begin
        Text := LinkLabel.Text;
        if StyleSolid.Checked then
          Pen.Style := psSolid
        else if StyleDash.Checked then
          Pen.Style := psDash
        else if StyleDot.Checked then
          Pen.Style := psDot;
        Pen.Color := LineColor.Color;
        Brush.Color := LinkArrowColor.Color;
        if KindUndirected.Checked then
          Kind := lkUndirected
        else if KindDirected.Checked then
          Kind := lkDirected
        else if KindBidirected.Checked then
          Kind := lkBidirected;
        Font := FontDialog.Font;
        if ReverseDir.Checked then Reverse;
      end;
  finally
    S.EndUpdate;
  end;
end;

procedure TLinkProperties.LineColorClick(Sender: TObject);
begin
  ColorDialog.Color := LineColor.Color;
  if ColorDialog.Execute then
    LineColor.Color := ColorDialog.Color;
end;

procedure TLinkProperties.LinkArrowColorClick(Sender: TObject);
begin
  ColorDialog.Color := LinkArrowColor.Color;
  if ColorDialog.Execute then
    LinkArrowColor.Color := ColorDialog.Color;
end;

procedure TLinkProperties.btnChangeFontClick(Sender: TObject);
begin
  FontDialog.Execute;
end;

procedure TLinkProperties.btnApplyClick(Sender: TObject);
begin
  ApplyChanges;
end;

procedure TLinkProperties.FormCreate(Sender: TObject);
begin
  Left := Screen.Width - Width - 20;
end;

procedure TLinkProperties.KindClick(Sender: TObject);
begin
  ReverseDir.Enabled := KindDirected.Checked;
end;

end.
