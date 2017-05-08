{------------------------------------------------------------------------------}
{                                                                              }
{  TSimpleGraph Demonstration Program                                          }
{  by Kambiz R. Khojasteh                                                      }
{                                                                              }
{  kambiz@delphiarea.com                                                       }
{  http://www.delphiarea.com                                                   }
{                                                                              }
{------------------------------------------------------------------------------}

{$I ..\DELPHIAREA.INC}

unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  SimpleGraph {$IFDEF DELPHI7_UP}, XPMan {$ENDIF}, Dialogs, ExtDlgs,
  Menus, ActnList, ImgList, StdCtrls, ComCtrls, ToolWin, JPEG, System.Actions, System.ImageList;

type
  TMainForm = class(TForm)
    SimpleGraph: TSimpleGraph;
    ToolBar: TToolBar;
    StatusBar: TStatusBar;
    ImageList: TImageList;
    ActionList: TActionList;
    FileNew: TAction;
    FileOpen: TAction;
    FileSave: TAction;
    MainMenu: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    FileExit: TAction;
    N1: TMenuItem;
    Exit1: TMenuItem;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    EditCut: TAction;
    EditCopy: TAction;
    EditPaste: TAction;
    EditDelete: TAction;
    EditSelectAll: TAction;
    EditLockNodes: TAction;
    Edit1: TMenuItem;
    EditCut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Delete1: TMenuItem;
    N2: TMenuItem;
    SelectAll1: TMenuItem;
    N3: TMenuItem;
    LockNodes1: TMenuItem;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ObjectsNone: TAction;
    ObjectsRectangle: TAction;
    ObjectsRoundRect: TAction;
    ObjectsEllipse: TAction;
    ObjectsLink: TAction;
    Opjects1: TMenuItem;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    EditBringToFront: TAction;
    EditSendToBack: TAction;
    N6: TMenuItem;
    BringToFront1: TMenuItem;
    SendToBack1: TMenuItem;
    EditProperties: TAction;
    N7: TMenuItem;
    Properties1: TMenuItem;
    DesignerPopup: TPopupMenu;
    ObjectsPopup: TPopupMenu;
    Properties2: TMenuItem;
    Cut1: TMenuItem;
    Copy2: TMenuItem;
    Paste2: TMenuItem;
    Delete2: TMenuItem;
    N8: TMenuItem;
    Properties3: TMenuItem;
    N10: TMenuItem;
    N12: TMenuItem;
    SelectAllNodes1: TMenuItem;
    ToolButton18: TToolButton;
    Paste5: TMenuItem;
    EditMode1: TMenuItem;
    N4: TMenuItem;
    InsertRectangle1: TMenuItem;
    InsertRoundRectangle1: TMenuItem;
    InsertEllipse1: TMenuItem;
    N5: TMenuItem;
    LinkObjects1: TMenuItem;
    N9: TMenuItem;
    InsertRectangle2: TMenuItem;
    InsertRoundRectangle2: TMenuItem;
    InsertEllipse2: TMenuItem;
    N14: TMenuItem;
    LinkObjects2: TMenuItem;
    N15: TMenuItem;
    BringToFront2: TMenuItem;
    SendToBack2: TMenuItem;
    FilePrint: TAction;
    N16: TMenuItem;
    Print1: TMenuItem;
    PrinterSetupDialog: TPrinterSetupDialog;
    ToolButton19: TToolButton;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    ToolButton22: TToolButton;
    ToolButton23: TToolButton;
    ToolButton24: TToolButton;
    btnSaveAs: TToolButton;
    FileSaveAs: TAction;
    FileSaveAs1: TMenuItem;
    HelpAbout: TAction;
    Help1: TMenuItem;
    About2: TMenuItem;
    FormatToolBar: TToolBar;
    cbxFontName: TComboBox;
    cbxFontSize: TComboBox;
    btnBoldface: TToolButton;
    btnItalic: TToolButton;
    btnUnderline: TToolButton;
    FormatBold: TAction;
    FormatItalic: TAction;
    FormatUnderline: TAction;
    FormatAlignLeft: TAction;
    FormatCenter: TAction;
    FormatAlignRight: TAction;
    ToolButton27: TToolButton;
    ToolButton28: TToolButton;
    ToolButton29: TToolButton;
    FileExport: TAction;
    SavePictureDialog: TSavePictureDialog;
    ToolButton30: TToolButton;
    Export1: TMenuItem;
    ToolButton17: TToolButton;
    ToolButton25: TToolButton;
    ViewZoomIn: TAction;
    ViewZoomOut: TAction;
    ToolButton26: TToolButton;
    ToolButton31: TToolButton;
    ToolButton32: TToolButton;
    ObjectsTriangle: TAction;
    ToolButton33: TToolButton;
    ObjectsRhomboid: TAction;
    ToolButton34: TToolButton;
    ObjectsPentagon: TAction;
    ToolButton35: TToolButton;
    procedure FileNewExecute(Sender: TObject);
    procedure FileOpenExecute(Sender: TObject);
    procedure FileSaveExecute(Sender: TObject);
    procedure FileSaveAsExecute(Sender: TObject);
    procedure FileExportExecute(Sender: TObject);
    procedure FilePrintExecute(Sender: TObject);
    procedure FileExitExecute(Sender: TObject);
    procedure EditCutExecute(Sender: TObject);
    procedure EditCopyExecute(Sender: TObject);
    procedure EditPasteExecute(Sender: TObject);
    procedure EditDeleteExecute(Sender: TObject);
    procedure EditSelectAllExecute(Sender: TObject);
    procedure EditSendToBackExecute(Sender: TObject);
    procedure EditBringToFrontExecute(Sender: TObject);
    procedure EditLockNodesExecute(Sender: TObject);
    procedure EditPropertiesExecute(Sender: TObject);
    procedure FormatBoldExecute(Sender: TObject);
    procedure FormatItalicExecute(Sender: TObject);
    procedure FormatUnderlineExecute(Sender: TObject);
    procedure FormatAlignLeftExecute(Sender: TObject);
    procedure FormatCenterExecute(Sender: TObject);
    procedure FormatAlignRightExecute(Sender: TObject);
    procedure HelpAboutExecute(Sender: TObject);
    procedure ObjectsNoneExecute(Sender: TObject);
    procedure ObjectsRectangleExecute(Sender: TObject);
    procedure ObjectsRoundRectExecute(Sender: TObject);
    procedure ObjectsEllipseExecute(Sender: TObject);
    procedure ObjectsTriangleExecute(Sender: TObject);
    procedure ObjectsLinkExecute(Sender: TObject);
    procedure ObjectsRhomboidExecute(Sender: TObject);
    procedure ObjectsPentagonExecute(Sender: TObject);
    procedure ViewZoomInExecute(Sender: TObject);
    procedure ViewZoomOutExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject;var CanClose: Boolean);
    procedure ActionListUpdate(Action: TBasicAction;var Handled: Boolean);
    procedure cbxFontSizeChange(Sender: TObject);
    procedure cbxFontNameChange(Sender: TObject);
    procedure SimpleGraphDblClick(Sender: TObject);
    procedure SimpleGraphNodeDblClick(Graph: TSimpleGraph;
      Node: TGraphNode);
    procedure SimpleGraphLinkDblClick(Graph: TSimpleGraph;
      Link: TGraphLink);
    procedure FormCreate(Sender: TObject);
    procedure SimpleGraphCommandModeChange(Sender: TObject);
    procedure SimpleGraphCanMoveResizeNode(Graph: TSimpleGraph;
      Node: TGraphNode;var NewLeft, NewTop, NewWidth, NewHeight: Integer;
      var CanMove, CanResize: Boolean);
    procedure SimpleGraphObjectSelect(Graph: TSimpleGraph;
      GraphObject: TGraphObject);
    procedure SimpleGraphObjectDblClick(Graph: TSimpleGraph;
      GraphObject: TGraphObject);
    procedure SimpleGraphObjectInsert(Graph: TSimpleGraph;
      GraphObject: TGraphObject);
  private
    function IsGraphSaved: Boolean;
    procedure ShowHint(Sender: TObject);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  Clipbrd, Printers, DesignProp, NodeProp, LinkProp, ObjectProp,
  AboutDelphiArea;

resourcestring
  SSaveChanges   = 'Graph has been changed, would you like to save changes?';
  SViewOnly      = 'View Only';
  SEditing       = 'Editing';
  SLinkingNodes  = 'Linking Nodes';
  SInsertingNode = 'Inserting Node';
  SModified      = 'Modified';
  SNotModified   = '';
  SUntitled      = 'Untitled';

function TMainForm.IsGraphSaved: Boolean;
begin
  Result := True;
  if SimpleGraph.Modified then
    case MessageDlg(SSaveChanges, mtConfirmation, [mbYes, mbNo, mbCancel], 0) of
      mrYes:
        begin
          FileSave.Execute;
          Result := not SimpleGraph.Modified;
        end;
      mrCancel:
        Result := False;
    end;
end;

procedure TMainForm.ShowHint(Sender: TObject);
begin
  StatusBar.Panels[6].Text := Application.Hint;
end;

procedure TMainForm.FileNewExecute(Sender: TObject);
begin
  if IsGraphSaved then
  begin
    SimpleGraph.Clear;
    SaveDialog.FileName := SUntitled;
    Caption := SaveDialog.FileName + ' - ' + Application.Title;
  end;
end;

procedure TMainForm.FileOpenExecute(Sender: TObject);
begin
  if IsGraphSaved and OpenDialog.Execute then
  begin
    SimpleGraph.LoadFromFile(OpenDialog.FileName);
    SaveDialog.FileName := OpenDialog.FileName;
    Caption := SaveDialog.FileName + ' - ' + Application.Title;
  end;
end;

procedure TMainForm.FileSaveExecute(Sender: TObject);
begin
  if SaveDialog.FileName <> SUntitled then
  begin
    SimpleGraph.SaveToFile(SaveDialog.FileName);
    Caption := SaveDialog.FileName + ' - ' + Application.Title;
  end
  else
  begin
    if SaveDialog.Execute then
      SimpleGraph.SaveToFile(SaveDialog.FileName);
  end;
  Caption := SaveDialog.FileName + ' - ' + Application.Title;
end;

procedure TMainForm.FileSaveAsExecute(Sender: TObject);
begin
  if SaveDialog.Execute then
  begin
    SimpleGraph.SaveToFile(SaveDialog.FileName);
    Caption := SaveDialog.FileName + ' - ' + Application.Title;
  end;
end;

procedure TMainForm.FileExportExecute(Sender: TObject);
begin
  SavePictureDialog.FileName := ChangeFileExt(SaveDialog.FileName, '.' + SavePictureDialog.DefaultExt);
  if SavePictureDialog.Execute then
    SimpleGraph.SaveAsMetafile(SavePictureDialog.FileName);
end;

procedure TMainForm.FilePrintExecute(Sender: TObject);
var
  Rect: TRect;
begin
  if PrinterSetupDialog.Execute then
  begin
    SetRect(Rect, 0, 0, Printer.PageWidth, Printer.PageHeight);
    InflateRect(Rect, -50, -50);
    Printer.BeginDoc;
    SimpleGraph.Print(Printer.Canvas, Rect);
    Printer.EndDoc;
  end;
end;

procedure TMainForm.FileExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.EditCutExecute(Sender: TObject);
begin
  EditCopy.Execute;
  EditDelete.Execute;
end;

procedure TMainForm.EditCopyExecute(Sender: TObject);
begin
  SimpleGraph.CopyToClipboard(True);
end;

procedure TMainForm.EditPasteExecute(Sender: TObject);
begin
  SimpleGraph.PasteFromClipboard;
end;

procedure TMainForm.EditDeleteExecute(Sender: TObject);
var
  I: Integer;
begin
  with SimpleGraph do
  begin
    BeginUpdate;
    try
      for I := SelectedObjects.Count - 1 downto 0 do
        SelectedObjects[I].Free;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TMainForm.EditSelectAllExecute(Sender: TObject);
var
  I: Integer;
begin
  with SimpleGraph do
  begin
    BeginUpdate;
    try
      // SelectedObjects.Assign(Objects, laOr);
      for I := 0 to Objects.Count - 1 do
        Objects[I].Selected := True;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TMainForm.EditSendToBackExecute(Sender: TObject);
var
  I: Integer;
begin
  with SimpleGraph do
  begin
    BeginUpdate;
    try
      for I := SelectedObjects.Count - 1 downto 0 do
        SelectedObjects[I].SendToBack;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TMainForm.EditBringToFrontExecute(Sender: TObject);
var
  I: Integer;
begin
  with SimpleGraph do
  begin
    BeginUpdate;
    try
      for I := SelectedObjects.Count - 1 downto 0 do
        SelectedObjects[I].BringToFront;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TMainForm.EditLockNodesExecute(Sender: TObject);
begin
  SimpleGraph.LockNodes := not SimpleGraph.LockNodes;
end;

procedure TMainForm.EditPropertiesExecute(Sender: TObject);
var
  LinkCount: Integer;
begin
  if SimpleGraph.SelectedObjects.Count = 0 then
    TDesignerProperties.Execute(SimpleGraph)
  else
  begin
    LinkCount := SimpleGraph.SelectedObjectsCount(TGraphLink);
    if LinkCount = 0 then
      TNodeProperties.Execute(SimpleGraph.SelectedObjects)
    else if LinkCount = SimpleGraph.SelectedObjects.Count then
      TLinkProperties.Execute(SimpleGraph.SelectedObjects)
    else
      TObjectProperties.Execute(SimpleGraph.SelectedObjects);
  end;
end;

procedure TMainForm.FormatBoldExecute(Sender: TObject);
var
  I: Integer;
begin
  with SimpleGraph do
  begin
    BeginUpdate;
    try
      for I := SelectedObjects.Count - 1 downto 0 do
        with SelectedObjects[I].Font do
          if FormatBold.Checked then
            Style := Style + [fsBold]
          else
            Style := Style - [fsBold];
    finally
      EndUpdate;
    end;
  end;
end;

procedure TMainForm.FormatItalicExecute(Sender: TObject);
var
  I: Integer;
begin
  with SimpleGraph do
  begin
    BeginUpdate;
    try
      for I := SelectedObjects.Count - 1 downto 0 do
        with SelectedObjects[I].Font do
          if FormatItalic.Checked then
            Style := Style + [fsItalic]
          else
            Style := Style - [fsItalic];
    finally
      EndUpdate;
    end;
  end;
end;

procedure TMainForm.FormatUnderlineExecute(Sender: TObject);
var
  I: Integer;
begin
  with SimpleGraph do
  begin
    BeginUpdate;
    try
      for I := SelectedObjects.Count - 1 downto 0 do
        with SelectedObjects[I].Font do
          if FormatUnderline.Checked then
            Style := Style + [fsUnderLine]
          else
            Style := Style - [fsUnderline];
    finally
      EndUpdate;
    end;
  end;
end;

procedure TMainForm.FormatAlignLeftExecute(Sender: TObject);
var
  I: Integer;
begin
  with SimpleGraph do
  begin
    BeginUpdate;
    try
      for I := SelectedObjects.Count - 1 downto 0 do
        if SelectedObjects[I] is TGraphNode then
          TGraphNode(SelectedObjects[I]).Alignment := taLeftJustify;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TMainForm.FormatCenterExecute(Sender: TObject);
var
  I: Integer;
begin
  with SimpleGraph do
  begin
    BeginUpdate;
    try
      for I := SelectedObjects.Count - 1 downto 0 do
        if SelectedObjects[I] is TGraphNode then
          TGraphNode(SelectedObjects[I]).Alignment := taCenter;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TMainForm.FormatAlignRightExecute(Sender: TObject);
var
  I: Integer;
begin
  with SimpleGraph do
  begin
    BeginUpdate;
    try
      for I := SelectedObjects.Count - 1 downto 0 do
        if SelectedObjects[I] is TGraphNode then
          TGraphNode(SelectedObjects[I]).Alignment := taRightJustify;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TMainForm.HelpAboutExecute(Sender: TObject);
begin
  with TAbout.Create(Application) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TMainForm.ObjectsNoneExecute(Sender: TObject);
begin
  SimpleGraph.CommandMode := cmEdit;
end;

procedure TMainForm.ObjectsRectangleExecute(Sender: TObject);
begin
  SimpleGraph.DefaultNodeClass := TRectangularNode;
  SimpleGraph.CommandMode := cmInsertNode;
end;

procedure TMainForm.ObjectsRoundRectExecute(Sender: TObject);
begin
  SimpleGraph.DefaultNodeClass := TRoundRectangularNode;
  SimpleGraph.CommandMode := cmInsertNode;
end;

procedure TMainForm.ObjectsEllipseExecute(Sender: TObject);
begin
  SimpleGraph.DefaultNodeClass := TEllipticNode;
  SimpleGraph.CommandMode := cmInsertNode;
end;

procedure TMainForm.ObjectsTriangleExecute(Sender: TObject);
begin
  SimpleGraph.DefaultNodeClass := TTriangularNode;
  SimpleGraph.CommandMode := cmInsertNode;
end;

procedure TMainForm.ObjectsRhomboidExecute(Sender: TObject);
begin
  SimpleGraph.DefaultNodeClass := TRhomboidalNode;
  SimpleGraph.CommandMode := cmInsertNode;
end;

procedure TMainForm.ObjectsPentagonExecute(Sender: TObject);
begin
  SimpleGraph.DefaultNodeClass := TPentagonalNode;
  SimpleGraph.CommandMode := cmInsertNode;
end;

procedure TMainForm.ObjectsLinkExecute(Sender: TObject);
begin
  SimpleGraph.CommandMode := cmLinkNodes;
end;

procedure TMainForm.ViewZoomInExecute(Sender: TObject);
begin
  SimpleGraph.Zoom := SimpleGraph.Zoom + SimpleGraph.ZoomStep;
end;

procedure TMainForm.ViewZoomOutExecute(Sender: TObject);
begin
  SimpleGraph.Zoom := SimpleGraph.Zoom - SimpleGraph.ZoomStep;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject;var CanClose: Boolean);
begin
  CanClose := IsGraphSaved;
end;

procedure TMainForm.ActionListUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  Handled := True;
  FileSave.Enabled := SimpleGraph.Modified;
  FileSaveAs.Enabled := (SimpleGraph.Objects.Count > 0);
  FileExport.Enabled := (SimpleGraph.Objects.Count > 0);
  FilePrint.Enabled :=(Printer.Printers.Count > 0) and
   (SimpleGraph.Objects.Count > 0);
  EditCut.Enabled :=(SimpleGraph.SelectedObjects.Count > 0);
  EditCopy.Enabled :=(SimpleGraph.SelectedObjects.Count > 0);
  EditPaste.Enabled := Clipboard.HasFormat(CF_SIMPLEGRAPH);
  EditDelete.Enabled :=(SimpleGraph.SelectedObjects.Count > 0);
  EditBringToFront.Enabled :=(SimpleGraph.SelectedObjects.Count > 0);
  EditSendToBack.Enabled :=(SimpleGraph.SelectedObjects.Count > 0);
  EditSelectAll.Enabled :=
   (SimpleGraph.Objects.Count > SimpleGraph.SelectedObjects.Count);
  EditLockNodes.Checked := SimpleGraph.LockNodes;
  ObjectsNone.Checked :=(SimpleGraph.CommandMode = cmEdit);
  ObjectsRectangle.Checked :=(SimpleGraph.CommandMode = cmInsertNode) and
   (SimpleGraph.DefaultNodeClass = TRectangularNode);
  ObjectsRoundRect.Checked :=(SimpleGraph.CommandMode = cmInsertNode) and
   (SimpleGraph.DefaultNodeClass = TRoundRectangularNode);
  ObjectsEllipse.Checked :=(SimpleGraph.CommandMode = cmInsertNode) and
   (SimpleGraph.DefaultNodeClass = TEllipticNode);
  ObjectsTriangle.Checked :=(SimpleGraph.CommandMode = cmInsertNode) and
   (SimpleGraph.DefaultNodeClass = TTriangularNode);
  ObjectsRhomboid.Checked :=(SimpleGraph.CommandMode = cmInsertNode) and
   (SimpleGraph.DefaultNodeClass = TRhomboidalNode);
  ObjectsPentagon.Checked :=(SimpleGraph.CommandMode = cmInsertNode) and
   (SimpleGraph.DefaultNodeClass = TPentagonalNode);
  ObjectsLink.Enabled :=(SimpleGraph.ObjectsCount(TGraphNode) >= 2);
  ObjectsLink.Checked :=(SimpleGraph.CommandMode = cmLinkNodes);
  ViewZoomOut.Enabled := (SimpleGraph.Zoom > SimpleGraph.ZoomMin);
  ViewZoomIn.Enabled := (SimpleGraph.Zoom < SimpleGraph.ZoomMax);
  if SimpleGraph.Modified then
    StatusBar.Panels[4].Text := SModified
  else
    StatusBar.Panels[4].Text := SNotModified;
  StatusBar.Panels[5].Text := Format('%d%%', [SimpleGraph.Zoom]);
end;

procedure TMainForm.cbxFontSizeChange(Sender: TObject);
var
  I: Integer;
  FontSize: Integer;
begin
  try
    FontSize := StrToInt(cbxFontSize.Text);
  except
    Exit;
  end;
  with SimpleGraph do
  begin
    BeginUpdate;
    try
      for I := SelectedObjects.Count - 1 downto 0 do
        SelectedObjects[I].Font.Size := FontSize;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TMainForm.cbxFontNameChange(Sender: TObject);
var
  I: Integer;
  FontName: String;
begin
  FontName := cbxFontName.Items[cbxFontName.ItemIndex];
  with SimpleGraph do
  begin
    BeginUpdate;
    try
      for I := SelectedObjects.Count - 1 downto 0 do
        SelectedObjects[I].Font.Name := FontName;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TMainForm.SimpleGraphDblClick(Sender: TObject);
begin
  EditProperties.Execute;
end;

procedure TMainForm.SimpleGraphNodeDblClick(Graph: TSimpleGraph;
  Node: TGraphNode);
begin
  EditProperties.Execute;
end;

procedure TMainForm.SimpleGraphLinkDblClick(Graph: TSimpleGraph;
  Link: TGraphLink);
begin
  EditProperties.Execute;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  {$IFDEF DELPHI7_UP}
  TXPManifest.Create(Self);
  {$ENDIF}
  Application.OnHint := ShowHint;
  SimpleGraphCommandModeChange(nil);
  cbxFontName.Items := Screen.Fonts;
  if ParamCount > 0 then
  begin
    SimpleGraph.LoadFromFile(ParamStr(1));
    SaveDialog.FileName := ExpandFileName(ParamStr(1));
    Caption := SaveDialog.FileName + ' - ' + Application.Title;
  end;
end;

procedure TMainForm.SimpleGraphCommandModeChange(Sender: TObject);
begin
  case SimpleGraph.CommandMode of
    cmViewOnly:
      StatusBar.Panels[0].Text := SViewOnly;
    cmEdit:
      StatusBar.Panels[0].Text := SEditing;
    cmLinkNodes:
      StatusBar.Panels[0].Text := SLinkingNodes;
    cmInsertNode:
      StatusBar.Panels[0].Text := SInsertingNode;
  end;
end;

procedure TMainForm.SimpleGraphCanMoveResizeNode(Graph: TSimpleGraph;
  Node: TGraphNode;var NewLeft, NewTop, NewWidth, NewHeight: Integer;
  var CanMove, CanResize: Boolean);
begin
  if SimpleGraph.SelectedObjects.Count = 1 then
  begin
    StatusBar.Panels[1].Text := Format('(%d, %d)', [NewLeft, NewTop]);
    StatusBar.Panels[2].Text := Format('%d x %d', [NewWidth, NewHeight]);
  end;
end;

procedure TMainForm.SimpleGraphObjectSelect(Graph: TSimpleGraph;
  GraphObject: TGraphObject);
var
  Node: TGraphNode;
  PosFirstLine: integer;
begin
  if (SimpleGraph.SelectedObjects.Count > 0) then
  begin
    GraphObject := SimpleGraph.SelectedObjects[0];
    cbxFontName.Text := GraphObject.Font.Name;
    cbxFontSize.Text := IntToStr(GraphObject.Font.Size);
    FormatBold.Checked := (fsBold in GraphObject.Font.Style);
    FormatItalic.Checked := (fsItalic in GraphObject.Font.Style);
    FormatUnderline.Checked := (fsUnderline in GraphObject.Font.Style);
  end;
  if (SimpleGraph.SelectedObjects.Count = 1) and
     (SimpleGraph.SelectedObjects[0] is TGraphNode) then
  begin
    Node := TGraphNode(SimpleGraph.SelectedObjects[0]);
    case Node.Alignment of
      taCenter: FormatCenter.Checked := True;
      taLeftJustify: FormatAlignLeft.Checked := True;
      taRightJustify: FormatAlignRight.Checked := True;
    end;
    StatusBar.Panels[1].Text := Format('(%d, %d)', [Node.Left, Node.Top]);
    StatusBar.Panels[2].Text := Format('%d x %d', [Node.Width, Node.Height]);
    PosFirstLine := Pos(#$D#$A, Node.Text);
    if PosFirstLine <> 0 then
      StatusBar.Panels[3].Text := Copy(Node.Text, 1, PosFirstLine)
    else
      StatusBar.Panels[3].Text := Node.Text;
  end
  else
  begin
    StatusBar.Panels[1].Text := '';
    StatusBar.Panels[2].Text := '';
    StatusBar.Panels[3].Text := '';
  end;
end;

procedure TMainForm.SimpleGraphObjectDblClick(Graph: TSimpleGraph;
  GraphObject: TGraphObject);
begin
  EditProperties.Execute;
end;

procedure TMainForm.SimpleGraphObjectInsert(Graph: TSimpleGraph;
  GraphObject: TGraphObject);
var
  FontStyle: TFontStyles;
begin
  FontStyle := [];
  if FormatBold.Checked then
    Include(FontStyle, fsBold);
  if FormatItalic.Checked then
    Include(FontStyle, fsItalic);
  if FormatUnderline.Checked then
    Include(FontStyle, fsUnderline);
  with GraphObject.Font do
  begin
    Size := StrToIntDef(cbxFontSize.Text, Size);
    Name := cbxFontName.Text;
    Style := FontStyle;
  end;
  if GraphObject is TGraphNode then
  begin
    if FormatAlignLeft.Checked then
      TGraphNode(GraphObject).Alignment := taLeftJustify
    else if FormatAlignRight.Checked then
      TGraphNode(GraphObject).Alignment := taRightJustify
    else
      TGraphNode(GraphObject).Alignment := taCenter;
  end;
end;

end.

