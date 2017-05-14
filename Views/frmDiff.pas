unit frmDiff;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,
  System.Actions, Vcl.ActnList, System.ImageList, Vcl.ImgList,
  PngImageList, Vcl.PlatformDefaultStyleActnCtrls, Vcl.ActnMan, Vcl.ToolWin, Vcl.ActnCtrls,
  fraDiff;

type
  TDiffForm = class(TForm)
    ActionToolBar1: TActionToolBar;
    ActionManager1: TActionManager;
    FrameDiff: TFrameDiff;
  private
    function getOptions: TDiffOptions;
    procedure setOptions(const Value: TDiffOptions);
    { Private declarations }
  public
    { Public declarations }
    procedure Load(fileName1, fileName2: string);
    property options: TDiffOptions read getOptions write setOptions;
  end;

implementation

{$R *.dfm}

{ TDiffForm }

function TDiffForm.getOptions: TDiffOptions;
begin
  result := FrameDiff.options;
end;

procedure TDiffForm.Load(fileName1, fileName2: string);
begin
  FrameDiff.Load(fileName1, fileName2);
end;

procedure TDiffForm.setOptions(const Value: TDiffOptions);
begin
  FrameDiff.options := Value;
end;

end.
