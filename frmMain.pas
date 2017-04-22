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
    ViewFilesBrowser1: TViewFilesBrowser;
    ActionToolBar1: TActionToolBar;
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
  dmRepo;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //DC: musimy pozamykaæ wszelkie otwarte okienka zanim Delphi zrobi to za nas bo jeœli nie to
  // SynEdit siê wydumli na assertach do TheFontsInfoManager.Destroy; i póŸniejszych
  // jeœli rêcznie zamkniemy okienka wczeœniej to jest OK :)
  repo.CloseAllChildForms;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  repo.actRefreshExecute(sender);
end;

procedure TMainForm.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  handled := Repo.alRepoActions.IsShortCut(Msg);
end;

end.
