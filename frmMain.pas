unit frmMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, fraFilesBrowser;

type
  TMainForm = class(TForm)
    pages: TPageControl;
    StatusBar1: TStatusBar;
    tabRepoView: TTabSheet;
    tabCodeReview: TTabSheet;
    ViewFilesBrowser1: TViewFilesBrowser;
    tabCommit: TTabSheet;
    procedure FormCreate(Sender: TObject);
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

procedure TMainForm.FormCreate(Sender: TObject);
begin
  repo.refreshView(sender);
end;

end.
