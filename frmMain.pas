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
  ViewFilesBrowser1.btnFlatMode.GroupIndex := 1;
  ViewFilesBrowser1.btnModifiedOnly.GroupIndex := 2;
  ViewFilesBrowser1.btnShowUnversioned.GroupIndex := 3;
  ViewFilesBrowser1.btnShowIgnored.GroupIndex := 4;

  //DC: wioska, ale co zrobiæ...
  ViewFilesBrowser1.btnFlatMode.Down := true;
  repo.actFlatMode.Checked := true;

  repo.actRefreshExecute(sender);
end;

end.
