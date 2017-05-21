unit frmAddToIgnored;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, VirtualTrees,
  Models.FileInfo,
  whizaxe.VstHelper;

type
  TGetPreviewEvent = procedure(filter: TStrings; out list: TFilesList) of object;

  TAddToIgnoreForm = class(TForm)
    vstPreview: TVirtualStringTree;
    Panel1: TPanel;
    Panel2: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    Label2: TLabel;
    mPatterns: TMemo;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure edtPatternChange(Sender: TObject);
  private
    FOnGetPreview: TGetPreviewEvent;
    FVstPreviewHelper: TVstHelper<TFileInfo>;
    { Private declarations }
  public
    { Public declarations }
    property OnGetPreview: TGetPreviewEvent read FOnGetPreview write FOnGetPreview;
  end;

implementation

{$R *.dfm}

uses
  Generics.Collections;

{ TAddToIgnoreForm }

procedure TAddToIgnoreForm.edtPatternChange(Sender: TObject);
var
  list: TFilesList;
begin
  if Assigned(OnGetPreview) then
  begin
    OnGetPreview(mPatterns.Lines, list);
    FVstPreviewHelper.Model.Free;
    FVstPreviewHelper.Model := list;
  end;
end;

procedure TAddToIgnoreForm.FormCreate(Sender: TObject);
begin
  FVstPreviewHelper := TVstHelper<TFileInfo>.Create;
  FVstPreviewHelper.TreeView := vstPreview;
  FVstPreviewHelper.ZebraColor := clNone;
end;

procedure TAddToIgnoreForm.FormDestroy(Sender: TObject);
begin
  FVstPreviewHelper.Free;
end;

end.
