unit frmHistoryQuery;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;

type
  THistoryParams = record
    userName: string;
    date: TDate;
    branch: string;
  end;

  THistoryQueryForm = class(TForm)
    edtDate: TDateTimePicker;
    Label1: TLabel;
    edtBranch: TComboBoxEx;
    Label2: TLabel;
    edtUserName: TEdit;
    Label3: TLabel;
    btnOK: TButton;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Execute(out params: THistoryParams): boolean;
  end;

function histDialog: THistoryQueryForm;

implementation

{$R *.dfm}

uses
  DateUtils;

var
  vHistDialog: THistoryQueryForm;

function histDialog: THistoryQueryForm;
begin
  if not Assigned(vHistDialog) then
    vHistDialog := THistoryQueryForm.Create(nil);
  result := vHistDialog;
end;

function THistoryQueryForm.Execute(out params: THistoryParams): boolean;
begin
  result := ShowModal = mrOK;
  if Result then
  begin
    params.userName := edtUserName.Text;
    params.date := edtDate.Date;
    params.branch := edtBranch.Text;
  end;
end;

procedure THistoryQueryForm.FormCreate(Sender: TObject);
begin
  edtDate.DateTime := IncDay(Date, -7);
end;

initialization
  vHistDialog := nil;

finalization
  vHistDialog.Free;

end.
