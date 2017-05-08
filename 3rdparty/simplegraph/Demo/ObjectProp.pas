unit ObjectProp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, SimpleGraph, ExtCtrls, StdCtrls, ComCtrls;

type
  TObjectProperties = class(TForm)
    Label1: TLabel;
    Colors: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    FillColor: TPanel;
    LineColor: TPanel;
    btnChangeFont: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    FontDialog: TFontDialog;
    ColorDialog: TColorDialog;
    ObjectText: TMemo;
    btnApply: TButton;
    procedure FillColorClick(Sender: TObject);
    procedure LineColorClick(Sender: TObject);
    procedure btnChangeFontClick(Sender: TObject);
    procedure btnApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    S: TSimpleGraph;
    O: TGraphObjectList;
    procedure ApplyChanges;
  public
    class function Execute(Objects: TGraphObjectList): Boolean;
  end;

implementation

{$R *.dfm}

{ TObjectProperties }

class function TObjectProperties.Execute(Objects: TGraphObjectList): Boolean;
begin
  Result := False;
  with Create(Application) do
    try
      O := Objects;
      S := Objects[0].Owner;
      with Objects[0] do
      begin
        ObjectText.Lines.Text := Text;
        FillColor.Color := Brush.Color;
        LineColor.Color := Pen.Color;
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

procedure TObjectProperties.ApplyChanges;
var
  I: Integer;
begin
  S.BeginUpdate;
  try
    for I := 0 to O.Count - 1 do
      with O[I] do
      begin
        Text := ObjectText.Lines.Text;
        Brush.Color := FillColor.Color;
        Pen.Color := LineColor.Color;
        Font := FontDialog.Font;
      end;
  finally
    S.EndUpdate;
  end;
end;

procedure TObjectProperties.FillColorClick(Sender: TObject);
begin
  ColorDialog.Color := FillColor.Color;
  if ColorDialog.Execute then
    FillColor.Color := ColorDialog.Color;
end;

procedure TObjectProperties.LineColorClick(Sender: TObject);
begin
  ColorDialog.Color := LineColor.Color;
  if ColorDialog.Execute then
    LineColor.Color := ColorDialog.Color;
end;

procedure TObjectProperties.btnChangeFontClick(Sender: TObject);
begin
  FontDialog.Execute;
end;

procedure TObjectProperties.btnApplyClick(Sender: TObject);
begin
  ApplyChanges;
end;

procedure TObjectProperties.FormCreate(Sender: TObject);
begin
  Left := Screen.Width - Width - 20;
end;

end.
