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
    function AsString: string;
  end;

  THistoryQueryForm = class(TForm)
    edtDate: TDateTimePicker;
    edtBranch: TComboBoxEx;
    Label2: TLabel;
    edtUserName: TEdit;
    Label3: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    cbxUseDate: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure cbxUseDateClick(Sender: TObject);
    procedure RepoactDiffExecute(Sender: TObject);
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

procedure THistoryQueryForm.cbxUseDateClick(Sender: TObject);
begin
  edtDate.Enabled := cbxUseDate.Checked;
end;

function THistoryQueryForm.Execute(out params: THistoryParams): boolean;
begin
  result := ShowModal = mrOK;
  if Result then
  begin
    params.userName := edtUserName.Text;
    if cbxUseDate.Checked then
      params.date := edtDate.Date
    else
      params.date := 0;

    params.branch := edtBranch.Text;
  end;
end;

procedure THistoryQueryForm.FormCreate(Sender: TObject);
begin
  edtDate.DateTime := IncDay(Date, -7);
end;

procedure THistoryQueryForm.RepoactDiffExecute(Sender: TObject);
begin

end;

{ THistoryParams }

function THistoryParams.AsString: string;
begin
  result := '';
  if date <> 0 then
    result := result + DateToStr(date);
  if userName <> '' then
    result := result + ', ' + userName;
  if branch <> '' then
    result := result + ', ' + branch;
end;

initialization
  vHistDialog := nil;

finalization
  vHistDialog.Free;

end.
