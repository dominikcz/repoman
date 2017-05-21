unit fraFilesBrowser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.ButtonGroup, Vcl.Buttons, VirtualTrees,
  System.Types, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls;

type
  TViewFilesBrowser = class(TFrame)
    Panel1: TPanel;
    log: TMemo;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    edtWorkingCopyPath: TEdit;
    dirTree: TVirtualStringTree;
    fileList: TVirtualStringTree;
    procedure edtWorkingCopyPathChange(Sender: TObject);
  private
    { Private declarations }
    FRootPath: string;
    FOnRootChange: TNotifyEvent;
    procedure SetRootPath(const Value: string);

  public
    { Public declarations }
    procedure AddToLog(buff: string);
    property RootPath: string read FRootPath write SetRootPath;
    property OnRootChange: TNotifyEvent read FOnRootChange write FOnRootChange;
  end;

implementation

{$R *.dfm}

uses
  dmCommonResources;

{ TViewFilesBrowser }

procedure TViewFilesBrowser.AddToLog(buff: string);
begin
  log.Text := log.Text + buff;
  SendMessage(log.Handle, EM_LINESCROLL, 0, log.Lines.Count);
end;

procedure TViewFilesBrowser.edtWorkingCopyPathChange(Sender: TObject);
begin
  if DirectoryExists(edtWorkingCopyPath.Text) then
  begin
    FRootPath := edtWorkingCopyPath.Text;
    if Assigned(OnRootChange) then
      OnRootChange(self);
  end
  else
    edtWorkingCopyPath.Text := RootPath;
end;

procedure TViewFilesBrowser.SetRootPath(const Value: string);
begin
  FRootPath := Value;
  edtWorkingCopyPath.Text := Value;
end;

end.
