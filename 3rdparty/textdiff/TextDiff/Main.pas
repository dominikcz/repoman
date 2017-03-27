unit Main;

// -----------------------------------------------------------------------------
// Application:     TextDiff                                                   .
// Module:          Main                                                       .
// Version:         4.6                                                        .
// Date:            7-NOVEMBER-2009                                            .
// Target:          Win32, Delphi 7 - Delphi 2009                              .
// Author:          Angus Johnson - angusj-AT-myrealbox-DOT-com                .
// Copyright;       © 2003-2009 Angus Johnson                                  .
// -----------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, ComCtrls, ShellApi, About,
  IniFiles, ToolWin, Clipbrd, ImgList, System.ImageList;

type
  TMainForm = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    mnuOpen1: TMenuItem;
    mnuExit: TMenuItem;
    mnuOptions: TMenuItem;   
    mnuIgnoreBlanks: TMenuItem;
    mnuIgnoreCase: TMenuItem;
    mnuCompare: TMenuItem;
    mnuFont: TMenuItem;
    Help1: TMenuItem;
    mnuAbout: TMenuItem;
    mnuOpen2: TMenuItem;
    mnuHorzSplit: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    mnuHighlightColors: TMenuItem;
    Added1: TMenuItem;
    Modified1: TMenuItem;
    Deleted1: TMenuItem;
    ColorDialog1: TColorDialog;
    mnuCancel: TMenuItem;
    mnuActions: TMenuItem;
    N6: TMenuItem;
    Contents1: TMenuItem;
    mnuShowDiffsOnly: TMenuItem;
    StatusBar1: TStatusBar;
    mnuSave1: TMenuItem;
    N8: TMenuItem;
    mnuNext: TMenuItem;
    mnuPrev: TMenuItem;
    mnuSaveReport: TMenuItem;
    N9: TMenuItem;
    N2: TMenuItem;
    N1: TMenuItem;
    mnuCopyBlockRight: TMenuItem;
    mnuCopyBlockLeft: TMenuItem;
    mnuSave2: TMenuItem;
    N3: TMenuItem;
    mnuEdit: TMenuItem;
    mnuUndo: TMenuItem;
    mnuRedo: TMenuItem;
    N7: TMenuItem;
    mnuCut: TMenuItem;
    mnuCopy: TMenuItem;
    mnuPaste: TMenuItem;
    mnuSearch: TMenuItem;
    mnuFind: TMenuItem;
    mnuFindNext: TMenuItem;
    N10: TMenuItem;
    mnuReplace: TMenuItem;
    ToolBar1: TToolBar;
    tbFolder: TToolButton;
    ToolButton5: TToolButton;
    tbOpen1: TToolButton;
    tbOpen2: TToolButton;
    ToolButton3: TToolButton;
    tbSave1: TToolButton;
    tbSave2: TToolButton;
    ToolButton6: TToolButton;
    tbHorzSplit: TToolButton;
    ToolButton8: TToolButton;
    tbCompare: TToolButton;
    tbCancel: TToolButton;
    ToolButton11: TToolButton;
    tbNext: TToolButton;
    tbPrev: TToolButton;
    ToolButton14: TToolButton;
    tbFind: TToolButton;
    tbReplace: TToolButton;
    ToolButton2: TToolButton;
    tbHelp: TToolButton;
    ImageList1: TImageList;
    ImageList2: TImageList;
    N11: TMenuItem;
    mnuFolder: TMenuItem;
    mnuCompareFiles: TMenuItem;
    N12: TMenuItem;
    mnuDeleteLeft: TMenuItem;
    mnuDeleteRight: TMenuItem;
    N13: TMenuItem;
    mnuRenameLeft: TMenuItem;
    mnuRenameRight: TMenuItem;
    N14: TMenuItem;
    ResettoDefaultColors1: TMenuItem;
    mnuOptions2: TMenuItem;
    mnuIgnoreFileDateTime: TMenuItem;
    mnuIgnoreFileSize: TMenuItem;
    tbOpenFolder1: TToolButton;
    tbOpenFolder2: TToolButton;
    tbOpenFile1: TToolButton;
    tbOpenFile2: TToolButton;
    mnuShowInlineDiffs: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mnuExitClick(Sender: TObject);
    procedure mnuIgnoreBlanksClick(Sender: TObject);
    procedure mnuIgnoreCaseClick(Sender: TObject);
    procedure mnuAboutClick(Sender: TObject);
    procedure AddColorClick(Sender: TObject);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar;
      Panel: TStatusPanel; const Rect: TRect);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Contents1Click(Sender: TObject);
    procedure mnuShowDiffsOnlyClick(Sender: TObject);
    procedure mnuFolderClick(Sender: TObject);
    procedure ResettoDefaultColors1Click(Sender: TObject);
    procedure StatusBar1DblClick(Sender: TObject);
    procedure mnuIgnoreFileDateTimeClick(Sender: TObject);
    procedure mnuIgnoreFileSizeClick(Sender: TObject);
    procedure mnuShowInlineDiffsClick(Sender: TObject);
  private
    procedure LoadOptionsFromIni;
    procedure SaveOptionsToIni;
  public
    FilesFrame: TFrame;
    FoldersFrame: TFrame;
  end;

var
  MainForm: TMainForm;
  addClr, delClr, modClr: TColor;
  LastOpenedFolder1, LastOpenedFolder2: string;
  shortDateFmt: string;

const
  FILEVIEW = 12;
  FOLDERVIEW = 13;
  DESIGN_RESOLUTION = 96;

  defaultAddClr = $F4DBC1;
  defaultModClr = $9FFDB3;
  defaultDelClr = $B7ABFF;

implementation

uses FileView, FolderView;

{$R *.DFM}

//---------------------------------------------------------------------
//---------------------------------------------------------------------

procedure TMainForm.FormCreate(Sender: TObject);
var
  FormatSettings: TFormatSettings;
begin
  FormatSettings := TFormatSettings.Create;
  shortDateFmt := FormatSettings.shortdateformat;

  FilesFrame := TFilesFrame.Create(self);
  FilesFrame.Parent := self;
  FilesFrame.Align := alClient;
  FilesFrame.ScaleBy(Screen.PixelsPerInch, DESIGN_RESOLUTION);

  FoldersFrame := TFoldersFrame.Create(self);
  FoldersFrame.Parent := self;
  FoldersFrame.Align := alClient;
  FoldersFrame.ScaleBy(Screen.PixelsPerInch, DESIGN_RESOLUTION);


  //load ini settings before calling FileFrame.Setup ...
  LoadOptionsFromIni;
  TFilesFrame(FilesFrame).Setup;
  TFoldersFrame(FoldersFrame).Setup;
  with TFoldersFrame(FoldersFrame) do
  begin
    DoOpenFolder(LastOpenedFolder1, true);
    DoOpenFolder(LastOpenedFolder2, false);
  end;

  application.helpfile := changefileext(ParamStr(0), '.hlp');
  if paramcount > 0 then
  begin
    //load files or folders from the commandline ...
    if directoryExists(paramstr(1)) then
      with TFoldersFrame(FoldersFrame) do
      begin
        mnuFolderClick(nil);
        DoOpenFolder(paramstr(1), true);
        DoOpenFolder(paramstr(2), false);
      end
    else
      with TFilesFrame(FilesFrame) do
      begin
        mnuFolder.Checked := true; //trick the toggle
        mnuFolderClick(nil);
        DoOpenFile(paramstr(1), true);
        DoOpenFile(paramstr(2), false);
      end;
    mnuCompare.Click;
  end
  //nb: FoldersFrame.Visible set in LoadOptionsFromIni ...
  else if FoldersFrame.Visible then mnuFolderClick(nil)
  else TFilesFrame(FilesFrame).SetMenuEventsToFileView;
end;
//---------------------------------------------------------------------

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  TFilesFrame(FilesFrame).Cleanup;
  TFoldersFrame(FoldersFrame).Cleanup;
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuExitClick(Sender: TObject);
begin
  close;
end;
//---------------------------------------------------------------------

procedure TMainForm.LoadOptionsFromIni;
var
  l,t,w,h: integer;
begin
  with TIniFile.create(changefileext(paramstr(0),'.ini')) do
  try
    l := ReadInteger('Options','Bounds.Left', 0);
    t := ReadInteger('Options','Bounds.Top', 0);
    w := ReadInteger('Options','Bounds.Width', -1);
    h := ReadInteger('Options','Bounds.Height', -1);
    //set (Add, Del, Mod) colors...
    addClr := strtointdef(ReadString('Options','AddColor', ''),defaultAddClr);
    modClr := strtointdef(ReadString('Options','ModColor', ''), defaultModClr);
    delClr := strtointdef(ReadString('Options','DelColor', ''), defaultDelClr);

    mnuIgnoreBlanks.Checked := ReadBool('Options','IgnoreBlanks', false);
    mnuIgnoreCase.Checked := ReadBool('Options','IgnoreCase', false);
    mnuShowInlineDiffs.Checked := ReadBool('Options','InlineDiffs', true);

    with TFilesFrame(FilesFrame).FontDialog1.Font do
    begin
      Name := ReadString('Options','Font.Name', 'Courier New');
      Size := ReadInteger('Options','Font.size', 10);
    end;

    if ReadBool('Options','Horizontal',false) then mnuHorzSplit.Checked := true;

    LastOpenedFolder1 := ReadString('Options','Folder.1', '');
    LastOpenedFolder2 := ReadString('Options','Folder.2', '');
    //FoldersFrame.Visible := ReadBool('Options','FolderView', false);
  finally
    free;
  end;
  //make sure the form is positioned on screen ...
  //ie: make sure nobody's done something silly with the INI file!
  if (w > 0) and (h > 0) and (l < screen.Width) and (t < screen.Height) and
      (l+w > 0) and (t+h > 0) then
    setbounds(l,t,w,h) else
    Position := poScreenCenter;
end;
//---------------------------------------------------------------------

procedure TMainForm.SaveOptionsToIni;
begin
  with TIniFile.create(changefileext(paramstr(0),'.ini')) do
  try
    if windowState = wsNormal then
    begin
      WriteInteger('Options','Bounds.Left', self.Left);
      WriteInteger('Options','Bounds.Top', self.Top);
      WriteInteger('Options','Bounds.Width', self.Width);
      WriteInteger('Options','Bounds.Height', self.Height);
    end;
    WriteString('Options','AddColor', '$'+inttohex(addClr,8));
    WriteString('Options','ModColor', '$'+inttohex(modClr,8));
    WriteString('Options','DelColor', '$'+inttohex(delClr,8));

    WriteBool('Options','IgnoreBlanks', mnuIgnoreBlanks.Checked);
    WriteBool('Options','IgnoreCase', mnuIgnoreCase.Checked);
    WriteBool('Options','InlineDiffs', mnuShowInlineDiffs.Checked);

    with TFilesFrame(FilesFrame).FontDialog1.Font do
    begin
      WriteString('Options','Font.Name', name);
      WriteInteger('Options','Font.size', Size);
    end;
    WriteBool('Options','Horizontal', mnuHorzSplit.Checked);
    WriteString('Options','Folder.1', LastOpenedFolder1);
    WriteString('Options','Folder.2', LastOpenedFolder2);
    //WriteBool('Options','FolderView', FoldersFrame.Visible);
  finally
    free;
  end;
end;
//---------------------------------------------------------------------

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  fn: string;
begin
  with TFilesFrame(FilesFrame) do
  begin
    if fn1 = '' then
      fn := 'An new file has been created.' else
      fn := '"'+fn1+'"'+#10+'has changed.';
    if CodeEdit1.Lines.Modified and
      (application.messagebox(
        pchar(fn+#10#10+'Do you wish to save changes?'),
        pchar(application.Title), MB_ICONQUESTION or MB_YESNO) = IDYES) then
      SaveFileClick(mnuSave1);

    if fn2 = '' then
      fn := 'An new file has been created.' else
      fn := '"'+fn2+'"'+#10+'has changed.';
    if CodeEdit2.Lines.Modified and
      (application.messagebox(
        pchar(fn+#10#10+'Do you wish to save changes?'),
        pchar(application.Title), MB_ICONQUESTION or MB_YESNO) = IDYES) then
      SaveFileClick(mnuSave2);
  end;

  SaveOptionsToIni;
  Application.HelpCommand(HELP_QUIT, 0);
end;
//---------------------------------------------------------------------

procedure TMainForm.Contents1Click(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTENTS, 0);
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuIgnoreBlanksClick(Sender: TObject);
begin
  mnuIgnoreBlanks.checked := not mnuIgnoreBlanks.checked;
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuIgnoreCaseClick(Sender: TObject);
begin
  mnuIgnoreCase.checked := not mnuIgnoreCase.checked;
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuShowInlineDiffsClick(Sender: TObject);
begin
  mnuShowInlineDiffs.Checked := not mnuShowInlineDiffs.Checked;
  with TFilesFrame(FilesFrame) do
  begin
    CodeEdit1.Invalidate;
    CodeEdit2.Invalidate;
  end;
end;
//---------------------------------------------------------------------


procedure TMainForm.mnuIgnoreFileDateTimeClick(Sender: TObject);
begin
  mnuIgnoreFileDateTime.checked := not mnuIgnoreFileDateTime.checked;
  with TFoldersFrame(FoldersFrame) do
    if FoldersCompared then
    begin
      LoadFolderList(trim(pnlCaptionRight.Caption), false);
      LoadFolderList(trim(pnlCaptionLeft.Caption), true);
      CompareClick(nil);
    end;
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuIgnoreFileSizeClick(Sender: TObject);
begin
  mnuIgnoreFileSize.checked := not mnuIgnoreFileSize.checked;
  with TFoldersFrame(FoldersFrame) do
    if FoldersCompared then
    begin
      LoadFolderList(trim(pnlCaptionRight.Caption), false);
      LoadFolderList(trim(pnlCaptionLeft.Caption), true);
      CompareClick(nil);
    end;
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuShowDiffsOnlyClick(Sender: TObject);
begin
  mnuShowDiffsOnly.checked := not mnuShowDiffsOnly.checked;
  //if files have been compared (without subseq. editing) then refresh view ...
  with TFilesFrame(FilesFrame) do
    if assigned(CodeEdit1.Partner) then
    begin
      DisplayDiffs;
      ToggleLinkedScroll(true);
    end;
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuAboutClick(Sender: TObject);
begin
  with TAboutForm.create(self) do
  try
    showmodal;
  finally
    free;
  end;
end;
//---------------------------------------------------------------------

procedure TMainForm.AddColorClick(Sender: TObject);
var
  i: integer;
  oldColor, newColor: TColor;
begin
  with ColorDialog1 do
  begin
    if Sender = Added1 then color := addClr
    else if Sender = Modified1 then color := modClr
    else color := delClr;

    oldColor := color;
    if not execute then exit;
    newColor := color;

    if Sender = Added1 then addClr := color
    else if Sender = Modified1 then modClr := color
    else delClr := color
  end;

  StatusBar1.Invalidate;
  with TFilesFrame(FilesFrame) do
    if FilesCompared then
    begin
      for i := 0 to CodeEdit1.Lines.Count -1 do
        if CodeEdit1.lines.lineobj[i].BackClr = oldColor then
        begin
          CodeEdit1.lines.lineobj[i].BackClr := newColor;
          CodeEdit2.lines.lineobj[i].BackClr := newColor;
        end;
      UpdateDiffMarkerBmp;
      pbScrollPosMarker.Invalidate;
      CodeEdit1.Invalidate;
      CodeEdit2.Invalidate;
    end;
end;
//---------------------------------------------------------------------

procedure TMainForm.ResettoDefaultColors1Click(Sender: TObject);
var
  i: integer;
begin
  StatusBar1.Invalidate;
  with TFilesFrame(FilesFrame) do
  begin
    if FilesCompared then
    begin
      for i := 0 to CodeEdit1.Lines.Count -1 do
        if CodeEdit1.lines.lineobj[i].BackClr <> clWindow then
          if CodeEdit1.lines.lineobj[i].BackClr = AddClr then
          begin
            CodeEdit1.lines.lineobj[i].BackClr := defaultAddClr;
            CodeEdit2.lines.lineobj[i].BackClr := defaultAddClr;
          end
          else if CodeEdit1.lines.lineobj[i].BackClr = ModClr then
          begin
            CodeEdit1.lines.lineobj[i].BackClr := defaultModClr;
            CodeEdit2.lines.lineobj[i].BackClr := defaultModClr;
          end
          else if CodeEdit1.lines.lineobj[i].BackClr = DelClr then
          begin
            CodeEdit1.lines.lineobj[i].BackClr := defaultDelClr;
            CodeEdit2.lines.lineobj[i].BackClr := defaultDelClr;
          end;
      AddClr := defaultAddClr; ModClr := defaultModClr; DelClr := defaultDelClr;
      UpdateDiffMarkerBmp;
      pbScrollPosMarker.Invalidate;
      CodeEdit1.Invalidate;
      CodeEdit2.Invalidate;
    end;
  end;
end;
//---------------------------------------------------------------------

procedure TMainForm.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  case Panel.Index of
    0:
      begin
        StatusBar1.Canvas.Brush.Color := addClr;
        StatusBar1.Canvas.TextRect(Rect, Rect.Left+4,Rect.Top, '+');
      end;
    1:
      begin
        StatusBar1.Canvas.Brush.Color := modClr;
        StatusBar1.Canvas.TextRect(Rect, Rect.Left+4,Rect.Top, '~');
      end;
    2:
      begin
        StatusBar1.Canvas.Brush.Color := delClr;
        StatusBar1.Canvas.TextRect(Rect, Rect.Left+4,Rect.Top, #150);
      end;
  end;
end;
//---------------------------------------------------------------------

procedure TMainForm.mnuFolderClick(Sender: TObject);
begin
  //toggle file view vs folder view ...
  mnuFolder.Checked := not mnuFolder.Checked;

  if mnuFolder.Checked then
  begin
    TFoldersFrame(FoldersFrame).Visible := true;
    TFilesFrame(FilesFrame).Visible := false;
    TFoldersFrame(FoldersFrame).SetMenuEventsToFolderView;
  end else
  begin
    TFilesFrame(FilesFrame).Visible := true;
    TFoldersFrame(FoldersFrame).Visible := false;
    TFilesFrame(FilesFrame).SetMenuEventsToFileView;
  end;
end;
//------------------------------------------------------------------------------

procedure TMainForm.StatusBar1DblClick(Sender: TObject);
var
  pt: TPoint;
begin
  GetCursorPos(pt);
  with StatusBar1 do
  begin
    pt := ScreenToClient(pt);
    if pt.X < Panels[0].width then
      AddColorClick(Added1)
    else if pt.X < Panels[0].width + Panels[1].width then
      AddColorClick(Modified1)
    else if pt.X < Panels[0].width + Panels[1].width + Panels[2].width then
      AddColorClick(Deleted1);
  end;
end;
//------------------------------------------------------------------------------

end.
