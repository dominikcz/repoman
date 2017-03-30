unit fraFilesBrowser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.ButtonGroup, Vcl.Buttons, VirtualTrees,
  System.Types;

type
  TViewFilesBrowser = class(TFrame)
    Panel1: TPanel;
    log: TMemo;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    edtWorkingCopyPath: TEdit;
    dirTree: TVirtualStringTree;
    fileList: TVirtualStringTree;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    CheckBox1: TCheckBox;
    Button1: TButton;
    procedure edtWorkingCopyPathChange(Sender: TObject);
  private
    FRootPath: string;
    FOnRootChange: TNotifyEvent;
    procedure SetRootPath(const Value: string);
    { Private declarations }

  public
    { Public declarations }
    property RootPath: string read FRootPath write SetRootPath;
    property OnRootChange: TNotifyEvent read FOnRootChange write FOnRootChange;
  end;

implementation

{$R *.dfm}

uses
  dmRepo;

{ TViewFilesBrowser }

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
