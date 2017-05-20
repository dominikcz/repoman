unit fraCommitView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.Buttons,
  VirtualTrees, Vcl.ExtCtrls, Vcl.StdCtrls,
  dmRepo, PngSpeedButton;

type
  TFrameCommitView = class(TFrame)
    leftPanel: TPanel;
    ActionList1: TActionList;
    actUnstageSelected: TAction;
    actUnstageAll: TAction;
    actStageSelected: TAction;
    actStageAll: TAction;
    Splitter1: TSplitter;
    pnlUnstaged: TPanel;
    filterPanel: TPanel;
    unstagedFiles: TVirtualStringTree;
    pnlStaged: TPanel;
    stagingPanel: TPanel;
    stagedFiles: TVirtualStringTree;
    Splitter2: TSplitter;
    Label1: TLabel;
    Label2: TLabel;
    actCommit: TAction;
    PngSpeedButton1: TPngSpeedButton;
    PngSpeedButton2: TPngSpeedButton;
    PngSpeedButton3: TPngSpeedButton;
    PngSpeedButton4: TPngSpeedButton;
    pnlCommit: TPanel;
    commitMsg: TMemo;
    Button5: TButton;
    cbLastMessages: TComboBox;
    procedure actCommitUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

procedure TFrameCommitView.actCommitUpdate(Sender: TObject);
begin
  actCommit.Enabled := commitMsg.Text <> '';
end;

end.
