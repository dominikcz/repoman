unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, fraFilesBrowser, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls;

type
  TMainForm = class(TForm)
    pages: TPageControl;
    StatusBar1: TStatusBar;
    tabRepoView: TTabSheet;
    tabCodeReview: TTabSheet;
    tabCommit: TTabSheet;
    ActionToolBar1: TActionToolBar;
    ViewFilesBrowser1: TViewFilesBrowser;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses
  dmRepo,
  whizaxe.Screen;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //DC: musimy pozamykaæ wszelkie otwarte okienka zanim Delphi zrobi to za nas bo jeœli nie to
  // SynEdit siê wydumli na assertach do TheFontsInfoManager.Destroy; i póŸniejszych
  // jeœli rêcznie zamkniemy okienka wczeœniej to jest OK :)
  repo.CloseAllChildForms;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  preffMon: Integer;
begin
  preffMon := FindPrefferedMonitor(1920, 1080);

  Left := Screen.Monitors[preffMon].Left;
  Top := Screen.Monitors[preffMon].Top;

  repo;
  // BUG w delphi powoduje, ¿e czasem przypisanie znika z dfm
  ActionToolBar1.ActionManager.ActionBars[0].ActionBar := ActionToolBar1;
  ActionToolBar1.AutoSizing := true;

  repo.actRefreshExecute(sender);
end;

procedure TMainForm.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  handled := Repo.alRepoActions.IsShortCut(Msg);
end;

end.
