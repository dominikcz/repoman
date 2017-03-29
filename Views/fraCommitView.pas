unit fraCommitView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.Buttons,
  VirtualTrees, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TViewCommit = class(TFrame)
    leftPanel: TPanel;
    ActionList1: TActionList;
    actUnstageSelected: TAction;
    actUnstageAll: TAction;
    actStageSelected: TAction;
    actStageAll: TAction;
    Panel1: TPanel;
    commitMsg: TMemo;
    Splitter1: TSplitter;
    pnlUnstaged: TPanel;
    filterPanel: TPanel;
    unstagedFiles: TVirtualStringTree;
    pnlStaged: TPanel;
    stagingPanel: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    stagedFiles: TVirtualStringTree;
    Splitter2: TSplitter;
    Label1: TLabel;
    Label2: TLabel;
    Button5: TButton;
    actCommit: TAction;
    cbLastMessages: TComboBox;
    procedure actCommitUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TViewCommit.actCommitUpdate(Sender: TObject);
begin
  actCommit.Enabled := commitMsg.Text <> '';
end;

end.
