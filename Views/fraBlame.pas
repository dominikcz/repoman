unit fraBlame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.ExtCtrls, SynEdit, SynEditHighlighter,
  SynHighlighterPas, SynURIOpener, SynHighlighterURI, fraDiff;

type
  TBlameFrame = class(TFrame)
    linesList: TVirtualStringTree;
    codeEditor: TSynEdit;
    Splitter1: TSplitter;
    SynPasSyn1: TSynPasSyn;
    SynURIOpener1: TSynURIOpener;
    SynURISyn1: TSynURISyn;
    FrameDiff1: TFrameDiff;
    Splitter2: TSplitter;
    procedure codeEditorScroll(Sender: TObject; ScrollBar: TScrollBarKind);
    procedure linesListScroll(Sender: TBaseVirtualTree; DeltaX, DeltaY: Integer);
    procedure FrameResize(Sender: TObject);
  private
    { Private declarations }
    scrollFromCodeEditor: boolean;
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TBlameFrame.codeEditorScroll(Sender: TObject; ScrollBar: TScrollBarKind);
var
  Node: PVirtualNode;
  Dummy: Integer;
begin
  Node := linesList.GetNodeAt(10, (codeEditor.TopLine - 1 + codeEditor.LinesInWindow) * linesList.DefaultNodeHeight, False, Dummy);
  scrollFromCodeEditor := true;
  linesList.ScrollIntoView(node, false);
//  fOldRow := codeEditor.TopLine;
end;

procedure TBlameFrame.FrameResize(Sender: TObject);
var
  h, nh: Integer;
begin
  h := linesList.ClientHeight;
  nh := linesList.DefaultNodeHeight;
  if h mod nh <> 0 then
    ClientHeight := h div nh * nh + (ClientHeight - h);
end;

procedure TBlameFrame.linesListScroll(Sender: TBaseVirtualTree; DeltaX, DeltaY: Integer);
var
  idx: cardinal;
  node: PVirtualNode;
  nodeTop: Integer;
begin
  if scrollFromCodeEditor then
  begin
    scrollFromCodeEditor := false;
    exit;
  end;

  node := sender.GetNodeAt(10, 10, true, nodeTop);
  idx := sender.AbsoluteIndex(node);
  codeEditor.TopLine := idx + 1;
end;

end.
