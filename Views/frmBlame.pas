unit frmBlame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  VirtualTrees,
  Generics.Collections,
  fraBlame,
  whizaxe.VSTHelper,
  Models.BlameInfo, Vcl.ExtCtrls, fraDiff;

type
  TGetAnnotateEvent = procedure(AFilename, ARevision: string; out annFileName: string) of object;

  TBlameHelper = class
  public
    model: TBlameInfos;
    helper: TVSTHelper<TBlameInfo>;
    constructor Create(AModel: TBlameInfos; AHelper: TVSTHelper<TBlameInfo>);
    destructor Destroy; override;
  end;

  TBlameForm = class(TForm)
    tabs: TPageControl;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FFileName: string;
    FModels: TObjectList<TBlameHelper>;
    FOnGetAnnotate: TGetAnnotateEvent;
    FPrevLine: Cardinal;
    function NewTab(Arev: string): TBlameFrame;
    procedure hndNodeDblClick(Sender: TBaseVirtualTree; item: TBlameInfo; const HitInfo: THitInfo);
    function tryActivateTab(revision: string): boolean;
    function getActiveFrame: TBlameFrame;
  public
    { Public declarations }
    procedure load(fileName, annFileName, rev: string);
    property OnGetAnnotate: TGetAnnotateEvent read FOnGetAnnotate write FOnGetAnnotate;
  end;

var
  BlameForm: TBlameForm;

implementation

{$R *.dfm}

{ TBlameForm }

procedure TBlameForm.FormCreate(Sender: TObject);
begin
  FModels := TObjectList<TBlameHelper>.Create(true);
end;

procedure TBlameForm.FormDestroy(Sender: TObject);
begin
  FModels.Free;
end;

function TBlameForm.getActiveFrame: TBlameFrame;
var
  i: Integer;
  tab: TTabSheet;
begin
  tab := tabs.ActivePage;
  for i := 0 to ControlCount -1 do
    if tab.Controls[i].ClassType = TBlameFrame then
      exit(TBlameFrame(tab.Controls[i]));
end;

procedure TBlameForm.hndNodeDblClick(Sender: TBaseVirtualTree; item: TBlameInfo; const HitInfo: THitInfo);
var
  outputFileName: string;
begin
  if tryActivateTab(item.revision) then
    exit;
  if assigned(OnGetAnnotate) then
  begin
    OnGetAnnotate(fFilename, item.revision, outputFileName);
    load(FFileName, outputFileName, item.revision);
  end;
end;

procedure TBlameForm.load(fileName, annFileName, rev: string);
var
  sl: TStringList;
  i: Integer;
  model: TBlameInfos;
  item: TBlameInfo;
  frame: TBlameFrame;
  helper: TVSTHelper<TBlameInfo>;
begin
  if not FileExists(annFileName) then
    exit;
  FFileName := fileName;
  sl := TStringList.Create;
  try
    if tabs.PageCount > 0 then
      FPrevLine := getActiveFrame.codeEditor.topLine
    else
      FPrevLine := 0;
    frame := NewTab(rev);
    frame.codeEditor.BeginUpdate;
    frame.codeEditor.Clear;
    sl.LoadFromFile(annFileName);
    model := TBlameInfos.Create(true);
    for i := 0 to sl.Count -1 do
    begin
      item := TBlameInfo.Create;
      item.parseCVSAnnotate(sl.Strings[i], frame.codeEditor.Lines);
      model.Add(item);
    end;
    helper := TVSTHelper<TBlameInfo>.Create;
    helper.ZebraColor := clNone;
    helper.OnNodeDblClick := hndNodeDblClick;
    helper.TreeView := frame.linesList;
    helper.Model := model;
    FModels.Add(TBlameHelper.Create(model, helper));
  finally
    if FPrevLine > 0 then
      frame.codeEditor.TopLine := FPrevLine;
    frame.codeEditor.EndUpdate;
    sl.Free;
  end;
end;

function TBlameForm.NewTab(Arev: string): TBlameFrame;
var
  tab: TTabSheet;
begin
  tab := TTabSheet.Create(tabs);
  tab.PageControl := tabs;
  tab.Caption := arev;
  tabs.ActivePage := tab;
  result := TBlameFrame.Create(tab);
  result.Align := alClient;
  result.Parent := tab;
  result.linesList.DefaultNodeHeight := result.codeEditor.LineHeight;
  result.linesList.ScrollBarOptions.VerticalIncrement := result.codeEditor.LineHeight;
end;

function TBlameForm.tryActivateTab(revision: string): boolean;
var
  tab: TTabSheet;
  i: Integer;
begin
  result := false;
  for i := 0 to tabs.PageCount -1 do
  begin
    tab := tabs.Pages[i];
    if tab.Caption = revision then
    begin
      tabs.ActivePage := tab;
      exit(true);
    end;
  end;
end;

{ TBlameHelper }

constructor TBlameHelper.Create(AModel: TBlameInfos; AHelper: TVSTHelper<TBlameInfo>);
begin
  inherited Create;
  model := AModel;
  helper := AHelper;
end;

destructor TBlameHelper.destroy;
begin
  model.Free;
  helper.Free;
  inherited;
end;

end.
