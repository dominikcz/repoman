unit frmFileHistory;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls;

type
  TFileHistoryForm = class(TForm)
    pnlGraph: TPanel;
    PageControl1: TPageControl;
    tabView: TTabSheet;
    tabDiff: TTabSheet;
    tabAnnotate: TTabSheet;
    Splitter1: TSplitter;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FileHistoryForm: TFileHistoryForm;

implementation

{$R *.dfm}

end.
