unit NodeProp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, SimpleGraph, ExtCtrls, StdCtrls, ComCtrls, ExtDlgs;

type
  TNodeProperties = class(TForm)
    Label1: TLabel;
    NodeShape: TRadioGroup;
    Colors: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    BodyColor: TPanel;
    NodeBorderColor: TPanel;
    btnChangeFont: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    FontDialog: TFontDialog;
    ColorDialog: TColorDialog;
    NodeText: TMemo;
    btnApply: TButton;
    rgAlignment: TRadioGroup;
    GroupBox2: TGroupBox;
    edtMargin: TEdit;
    UpDownMargin: TUpDown;
    btnChangBkgnd: TButton;
    OpenPictureDialog: TOpenPictureDialog;
    btnClearBackground: TButton;
    procedure BodyColorClick(Sender: TObject);
    procedure NodeBorderColorClick(Sender: TObject);
    procedure btnChangeFontClick(Sender: TObject);
    procedure btnChangBkgndClick(Sender: TObject);
    procedure btnClearBackgroundClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    Backgnd: Integer;
    S: TSimpleGraph;
    N: TGraphObjectList; // w2m - for apply button
    procedure ListRegistredNodeClasses;
    procedure ApplyChanges;
  public
    class function Execute(Nodes: TGraphObjectList): Boolean;
  end;

implementation

{$R *.dfm}

function PrettyNodeClassName(const AClassName: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 2 to Length(AClassName) do
  begin
    if(UpCase(AClassName[I]) = AClassName[I]) and(Result <> '') then
      Result := Result + ' ' + AClassName[I]
    else
      Result := Result + AClassName[I]
  end;
  Result := StringReplace(Result, ' Node', '', []);
end;

{ TNodeProperties }

class function TNodeProperties.Execute(Nodes: TGraphObjectList): Boolean;
begin
  Result := False;
  with Create(Application) do
  try
    N := Nodes;
    S := Nodes[0].Owner;
    ListRegistredNodeClasses;
    with TGraphNode(Nodes[0]) do
    begin
      case Alignment of
        taLeftJustify: rgAlignment.ItemIndex := 0;
        taCenter: rgAlignment.ItemIndex := 1;
        taRightJustify: rgAlignment.ItemIndex := 2;
      end;
      UpDownMargin.Position := Margin;
      NodeText.Lines.Text := Text;
      if Nodes.Count = 1 then
        NodeShape.ItemIndex := NodeShape.Items.IndexOfObject(TObject(ClassType))
      else
        NodeShape.ItemIndex := -1;
      BodyColor.Color := Brush.Color;
      NodeBorderColor.Color := Pen.Color;
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

procedure TNodeProperties.ListRegistredNodeClasses;
var
  I: Integer;
  NodeClass: TGraphNodeClass;
begin
  for I := 0 to TSimpleGraph.NodeClassCount - 1 do
  begin
    NodeClass := TSimpleGraph.NodeClasses(I);
    NodeShape.Items.AddObject(PrettyNodeClassName(NodeClass.ClassName),
      TObject(NodeClass));
  end;
end;

procedure TNodeProperties.ApplyChanges;
var
  I: Integer;
begin
  S.BeginUpdate;
  try
    for I := 0 to N.Count - 1 do
      with TGraphNode(N[I]) do
      begin
        case rgAlignment.ItemIndex of
          0: Alignment := taLeftJustify;
          1: Alignment := taCenter;
          2: Alignment := taRightJustify;
        end;
        Margin := UpDownMargin.Position;
        Text := NodeText.Lines.Text;
        Brush.Color := BodyColor.Color;
        Pen.Color := NodeBorderColor.Color;
        Font := FontDialog.Font;
        if NodeShape.ItemIndex >= 0 then
          ConvertTo(TSimpleGraph.NodeClasses(NodeShape.ItemIndex));
        if Backgnd = 1 then
          Background.LoadFromFile(OpenPictureDialog.FileName)
        else if Backgnd = 2 then
          Background.Graphic := nil;
      end;
  finally
    S.EndUpdate;
    Backgnd := 0;
  end;
end;

procedure TNodeProperties.BodyColorClick(Sender: TObject);
begin
  ColorDialog.Color := BodyColor.Color;
  if ColorDialog.Execute then
    BodyColor.Color := ColorDialog.Color;
end;

procedure TNodeProperties.NodeBorderColorClick(Sender: TObject);
begin
  ColorDialog.Color := NodeBorderColor.Color;
  if ColorDialog.Execute then
    NodeBorderColor.Color := ColorDialog.Color;
end;

procedure TNodeProperties.btnChangeFontClick(Sender: TObject);
begin
  FontDialog.Execute;
end;

procedure TNodeProperties.btnChangBkgndClick(Sender: TObject);
begin
  if OpenPictureDialog.Execute then
    Backgnd := 1;
end;

procedure TNodeProperties.btnClearBackgroundClick(Sender: TObject);
begin
  Backgnd := 2;
end;

procedure TNodeProperties.btnApplyClick(Sender: TObject);
begin
  ApplyChanges;
end;

procedure TNodeProperties.FormCreate(Sender: TObject);
begin
  Left := Screen.Width - Width - 20;
end;

end.

