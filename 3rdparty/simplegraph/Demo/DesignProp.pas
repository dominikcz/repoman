unit DesignProp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, SimpleGraph, ExtCtrls, StdCtrls, Spin, ComCtrls;

type
  TDesignerProperties = class(TForm)
    Grid: TGroupBox;
    ShowGrid: TCheckBox;
    Label1: TLabel;
    SnapToGrid: TCheckBox;
    Colors: TGroupBox;
    Label2: TLabel;
    BackgroundColor: TPanel;
    Label3: TLabel;
    MarkerColor: TPanel;
    Label4: TLabel;
    GridColor: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    ColorDialog: TColorDialog;
    btnApply: TButton;
    Edit1: TEdit;
    GridSize: TUpDown;
    procedure BackgroundColorClick(Sender: TObject);
    procedure MarkerColorClick(Sender: TObject);
    procedure GridColorClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    S: TSimpleGraph;
    procedure ApplyChanges;
  public
    class function Execute(SimpleGraph: TSimpleGraph): Boolean;
  end;

implementation

{$R *.dfm}

{ TDesignerProperties }

class function TDesignerProperties.Execute(SimpleGraph: TSimpleGraph): Boolean;
begin
  Result := False;
  with Create(Application) do
    try
      S := SimpleGraph;
      GridSize.Min := Low(TGridSize);
      GridSize.Max := High(TGridSize);
      SnapToGrid.Checked := SimpleGraph.SnapToGrid;
      ShowGrid.Checked := SimpleGraph.ShowGrid;
      GridSize.Position := SimpleGraph.GridSize;
      BackgroundColor.Color := SimpleGraph.Color;
      MarkerColor.Color := SimpleGraph.MarkerColor;
      GridColor.Color := SimpleGraph.GridColor;
      if ShowModal = mrOK then
      begin
        ApplyChanges;
        Result := True;
      end;
    finally
      Free;
    end;
end;

procedure TDesignerProperties.ApplyChanges;
begin
  S.BeginUpdate;
  try
    S.SnapToGrid := SnapToGrid.Checked;
    S.ShowGrid := ShowGrid.Checked;
    S.GridSize := GridSize.Position;
    S.Color := BackgroundColor.Color;
    S.MarkerColor := MarkerColor.Color;
    S.GridColor := GridColor.Color;
  finally
    S.EndUpdate;
  end;
end;

procedure TDesignerProperties.BackgroundColorClick(Sender: TObject);
begin
  ColorDialog.Color := BackgroundColor.Color;
  if ColorDialog.Execute then
    BackgroundColor.Color := ColorDialog.Color;
end;

procedure TDesignerProperties.MarkerColorClick(Sender: TObject);
begin
  ColorDialog.Color := MarkerColor.Color;
  if ColorDialog.Execute then
    MarkerColor.Color := ColorDialog.Color;
end;

procedure TDesignerProperties.GridColorClick(Sender: TObject);
begin
  ColorDialog.Color := GridColor.Color;
  if ColorDialog.Execute then
    GridColor.Color := ColorDialog.Color;
end;

procedure TDesignerProperties.btnApplyClick(Sender: TObject);
begin
  ApplyChanges;
end;

procedure TDesignerProperties.FormCreate(Sender: TObject);
begin
  Left := Screen.Width - Width - 20;
end;

end.
