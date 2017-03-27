unit FindReplace;

//------------------------------------------------------------------------------
// Module:           FindReplace                                               .
// Version:          1.0                                                       .
// Date:             16 March 2003                                             .
// Compilers:        Delphi 3 - Delphi 7                                       .
// Author:           Angus Johnson - angusj-AT-myrealbox-DOT-com               .
// Copyright:        © 2001 -2003  Angus Johnson                               .
//                                                                             .
// Description:      Dialogs to aid find & replace text                        .
//------------------------------------------------------------------------------


interface

uses
  Windows, Messages, SysUtils, Classes, Controls, Forms,
  StdCtrls, ExtCtrls, Graphics;

type
  TReplaceType = (rtOK, rtSkip, rtAll, rtCancel);

  TFindInfo = record
    findStr: string;
    replaceStr: string;
    directionDown: boolean;
    ignoreCase: boolean;
    wholeWords: boolean;
    replacePrompt: boolean;
    replaceAll: boolean;
  end;

//find dialog ( text to find can be passed via fi.findStr ) ...
function GetFindInfo(aOwner: TCustomForm; var fi: TFindInfo): boolean;

//find replace dialog ( text to find can be passed via fi.findStr ) ...
function GetReplaceInfo(aOwner: TCustomForm; var fi: TFindInfo): boolean;

//replace prompt dialog ( requires a previous call to GetReplaceInfo() ) ...
function ReplacePrompt(aOwner: TCustomForm; Point: TPoint): TReplaceType;

procedure FindFree; //forcibly free resources
                    //nb:resources will automatically be freed on app close
                    //as FindForm is owned by application.mainform.

implementation

type
  TFindForm = class(TForm)
  private
    fOwner: TCustomForm;
    fReplaceAll: boolean;
    FindText: TEdit;
    FindLabel: TLabel;
    ReplaceLabel: TLabel;
    ReplaceText: TEdit;
    GroupBox1: TGroupBox;
    CaseSensitive: TCheckBox;
    WholeWords: TCheckBox;
    Prompt: TCheckBox;
    GroupBox2: TGroupBox;
    Forwards: TRadioButton;
    Backwards: TRadioButton;
    OKBtn: TButton;
    AllBtn: TButton;
    CancelBtn: TButton;
    procedure FindTextChange(Sender: TObject);
    procedure CenterForm;
  public
    constructor create(AOwner: TComponent); override;
  end;

  TReplaceForm = class(TForm)
  private
    fOwner: TCustomForm;
    FindText: TEdit;
    FindLabel: TLabel;
    ReplaceText: TEdit;
    ReplaceLabel: TLabel;
    OKBtn: TButton;
    SkipBtn: TButton;
    AllBtn: TButton;
    CancelBtn: TButton;
  public
    constructor create(AOwner: TComponent); override;
  end;

  var
    DpiScale: double = 1.0;

//------------------------------------------------------------------------------
// TFindForm methods ...
//------------------------------------------------------------------------------

function ScaleDPI(val: Integer): Integer;
begin
  Result := Round(val * DpiScale);
end;
//------------------------------------------------------------------------------

constructor TFindForm.create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  clientwidth := ScaleDPI(304);
  clientheight := ScaleDPI(231);
  caption := ' Replace text';
  BorderIcons := [biSystemMenu];
  BorderStyle := bsDialog;
  Font.Assign(TCustomForm(AOwner).Font);

  FindText := TEdit.Create(self);
  FindText.parent := self;
  FindText.left := ScaleDPI(88);
  FindText.top := ScaleDPI(14);
  FindText.width := ScaleDPI(190);
  FindText.OnChange := FindTextChange;

  FindLabel := TLabel.Create(self);
  FindLabel.parent := self;
  FindLabel.left := ScaleDPI(15);
  FindLabel.top := ScaleDPI(17);
  FindLabel.caption := '&Text to Find:';
  FindLabel.focusControl := FindText;

  ReplaceText := TEdit.Create(self);
  ReplaceText.parent := self;
  ReplaceText.left := ScaleDPI(88);
  ReplaceText.top := ScaleDPI(41);
  ReplaceText.width := ScaleDPI(190);

  ReplaceLabel := TLabel.Create(self);
  ReplaceLabel.parent := self;
  ReplaceLabel.left := ScaleDPI(15);
  ReplaceLabel.top := ScaleDPI(44);
  ReplaceLabel.caption := '&Replace with:';
  ReplaceLabel.focusControl := ReplaceText;

  GroupBox1 := TGroupBox.Create(self);
  GroupBox1.Parent := self;
  GroupBox1.Caption := 'Options';
  GroupBox1.setbounds(
    ScaleDPI(15),
    ScaleDPI(72),
    ScaleDPI(148),
    ScaleDPI(84));

  CaseSensitive := TCheckBox.Create(self);
  CaseSensitive.Parent := GroupBox1;
  CaseSensitive.Caption := '&Case Sensitive';
  CaseSensitive.setbounds(
    ScaleDPI(12),
    ScaleDPI(19),
    ScaleDPI(120),
    ScaleDPI(18));

  WholeWords := TCheckBox.Create(self);
  WholeWords.Parent := GroupBox1;
  WholeWords.Caption := '&Whole Words Only';
  WholeWords.setbounds(
    ScaleDPI(12),
    ScaleDPI(39),
    ScaleDPI(120),
    ScaleDPI(18));

  Prompt := TCheckBox.Create(self);
  Prompt.Parent := GroupBox1;
  Prompt.Caption := '&Prompt on Replace';
  Prompt.setbounds(
    ScaleDPI(12),
    ScaleDPI(59),
    ScaleDPI(120),
    ScaleDPI(18));

  Prompt.Checked := true;

  GroupBox2 := TGroupBox.Create(self);
  GroupBox2.Parent := self;
  GroupBox2.Caption := 'Direction';
  GroupBox2.setbounds(
    ScaleDPI(176),
    ScaleDPI(72),
    ScaleDPI(102),
    ScaleDPI(84));

  Forwards := TRadioButton.Create(self);
  Forwards.Parent := GroupBox2;
  Forwards.Caption := '&Forwards';
  Forwards.setbounds(
    ScaleDPI(12),
    ScaleDPI(26),
    ScaleDPI(80),
    ScaleDPI(18));
  Forwards.Checked := true;
  //Forwards.Enabled := false;

  Backwards := TRadioButton.Create(self);
  Backwards.Parent := GroupBox2;
  Backwards.Caption := '&Backwards';
  Backwards.setbounds(
    ScaleDPI(12),
    ScaleDPI(47),
    ScaleDPI(80),
    ScaleDPI(18));
  //Backwards.Enabled := false;

  OKBtn := TButton.create(self);
  OKBtn.Parent := self;
  OKBtn.Default := true;
  OKBtn.caption := 'Replace &One';
  OKBtn.Enabled := false;
  OKBtn.ModalResult := mrOK;
  OKBtn.SetBounds(
    ScaleDPI(15),
    ScaleDPI(165),
    ScaleDPI(75),
    ScaleDPI(25));

  AllBtn := TButton.create(self);
  AllBtn.Parent := self;
  AllBtn.Enabled := false;
  AllBtn.caption := 'Replace &All';
  AllBtn.ModalResult := mrYes;
  AllBtn.SetBounds(
    ScaleDPI(111),
    ScaleDPI(165),
    ScaleDPI(75),
    ScaleDPI(25));

  CancelBtn := TButton.create(self);
  CancelBtn.Parent := self;
  CancelBtn.Cancel := true;
  CancelBtn.Enabled := true;
  CancelBtn.caption := 'Cancel';
  CancelBtn.ModalResult := mrCancel;
  CancelBtn.SetBounds(
    ScaleDPI(204),
    ScaleDPI(165),
    ScaleDPI(75),
    ScaleDPI(25));
end;
//------------------------------------------------------------------------------

procedure TFindForm.FindTextChange(Sender: TObject);
begin
  if FindText.text = '' then begin
    OKBtn.enabled := false;
    AllBtn.enabled := false;
    end
  else begin
    OKBtn.enabled := true;
    AllBtn.enabled := true;
  end;
end;
//------------------------------------------------------------------------------

procedure TFindForm.CenterForm;
var
  l,t: integer;
begin
  if not assigned(fOwner) then exit;
  l := fOwner.left + (fOwner.width-width) div 2;
  t := fOwner.top + (fOwner.height-height) div 2;
  setbounds(l,t,width,height);
end;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// TReplaceForm methods ...
//------------------------------------------------------------------------------

constructor TReplaceForm.create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  clientwidth := ScaleDPI(313);
  clientheight := ScaleDPI(126);
  caption := ' Replace ...';
  BorderIcons := [biSystemMenu];
  BorderStyle := bsDialog;
  Font.Assign(TCustomForm(AOwner).Font);

  FindText := TEdit.Create(self);
  FindText.parent := self;
  FindText.left := ScaleDPI(69);
  FindText.top := ScaleDPI(10);
  FindText.width := ScaleDPI(220);
  FindText.color := clBtnFace;
  FindText.ReadOnly := true;
  FindText.TabStop := false;

  FindLabel := TLabel.Create(self);
  FindLabel.parent := self;
  FindLabel.left := ScaleDPI(15);
  FindLabel.top := ScaleDPI(14);
  FindLabel.caption := 'Replace:';
  FindLabel.focusControl := FindText;

  ReplaceText := TEdit.Create(self);
  ReplaceText.parent := self;
  ReplaceText.left := ScaleDPI(69);
  ReplaceText.top := ScaleDPI(34);
  ReplaceText.width := ScaleDPI(220);
  ReplaceText.color := clBtnFace;
  ReplaceText.ReadOnly := true;
  ReplaceText.TabStop := false;

  ReplaceLabel := TLabel.Create(self);
  ReplaceLabel.parent := self;
  ReplaceLabel.left := ScaleDPI(15);
  ReplaceLabel.top := ScaleDPI(37);
  ReplaceLabel.caption := 'with:';
  ReplaceLabel.focusControl := ReplaceText;

  OKBtn := TButton.create(self);
  OKBtn.Parent := self;
  OKBtn.Default := true;
  OKBtn.caption := '&OK';
  OKBtn.ModalResult := mrOK;
  OKBtn.SetBounds(
    ScaleDPI(15),
    ScaleDPI(68),
    ScaleDPI(64),
    ScaleDPI(22));

  SkipBtn := TButton.create(self);
  SkipBtn.Parent := self;
  SkipBtn.caption := '&Skip';
  SkipBtn.ModalResult := mrNo;
  SkipBtn.SetBounds(
    ScaleDPI(84),
    ScaleDPI(68),
    ScaleDPI(64),
    ScaleDPI(22));

  AllBtn := TButton.create(self);
  AllBtn.Parent := self;
  AllBtn.caption := '&All';
  AllBtn.ModalResult := mrYes;
  AllBtn.SetBounds(
    ScaleDPI(154),
    ScaleDPI(68),
    ScaleDPI(64),
    ScaleDPI(22));

  CancelBtn := TButton.create(self);
  CancelBtn.Parent := self;
  CancelBtn.Cancel := true;
  CancelBtn.caption := '&Cancel';
  CancelBtn.ModalResult := mrCancel;
  CancelBtn.SetBounds(
    ScaleDPI(225),
    ScaleDPI(68),
    ScaleDPI(64),
    ScaleDPI(22));

end;
//------------------------------------------------------------------------------



var
  FindForm: TFindForm;
  ReplaceForm: TReplaceForm;

procedure FindCreate;
begin
  if assigned(FindForm) then exit;
  FindForm := TFindForm.create(application.MainForm);
end;
//------------------------------------------------------------------------------

procedure ReplaceCreate;
begin
  if assigned(ReplaceForm) then exit;
  ReplaceForm := TReplaceForm.create(application.MainForm);
end;
//------------------------------------------------------------------------------

procedure FindFree;
begin
  if assigned(FindForm) then FindForm.free;
  FindForm := nil;
  if assigned(ReplaceForm) then ReplaceForm.free;
  ReplaceForm := nil;
end;
//------------------------------------------------------------------------------

function GetFindInfo(aOwner: TCustomForm; var fi: TFindInfo): boolean;
begin
  FindCreate;
  result := false;
  with FindForm do
  begin
    fOwner := aOwner;
    caption := ' Find text';
    if fi.findStr <> '' then findText.Text := fi.findStr;
    findText.SelectAll;
    Groupbox1.height := ScaleDPI(65);
    Groupbox1.top := ScaleDPI(41);
    Groupbox2.height := ScaleDPI(65);
    Groupbox2.top := ScaleDPI(41);
    Forwards.Top := ScaleDPI(19);
    Backwards.top := ScaleDPI(39);
    OKBtn.top := ScaleDPI(119);
    OKBtn.caption := '&OK';
    OKBtn.left := ScaleDPI(63);
    AllBtn.visible := false;
    CancelBtn.top := ScaleDPI(119);
    CancelBtn.left := ScaleDPI(156);
    prompt.visible := false;
    ReplaceLabel.visible := false;
    replacetext.visible := false;
    height := ScaleDPI(186);
    ActiveControl := FindText;
    CenterForm;
    if showmodal <> mrOK then exit;
    fi.findStr := FindText.Text;
    fi.ignoreCase := not CaseSensitive.Checked;
    fi.wholeWords := WholeWords.Checked;
    fi.directionDown := Forwards.Checked;
  end;
  result := true;
end;
//------------------------------------------------------------------------------

function GetReplaceInfo(aOwner: TCustomForm; var fi: TFindInfo): boolean;
var
  mr: TModalResult;
begin
  FindCreate;
  result := false;
  with FindForm do
  begin
    fOwner := aOwner;
    caption := ' Replace text';
    if fi.findStr <> '' then findText.Text := fi.findStr;
    findText.SelectAll;
    Groupbox1.height := ScaleDPI(84);
    Groupbox1.top := ScaleDPI(72);
    Groupbox2.height := ScaleDPI(84);
    Groupbox2.top := ScaleDPI(72);
    Forwards.Top := ScaleDPI(26);
    Backwards.top := ScaleDPI(47);
    OKBtn.top := ScaleDPI(165);
    OKBtn.caption :=  'Replace &One';
    OKBtn.left := ScaleDPI(15);
    AllBtn.visible := true;
    CancelBtn.top := ScaleDPI(165);
    CancelBtn.left := ScaleDPI(204);
    prompt.visible := true;
    ReplaceLabel.visible := true;
    replacetext.visible := true;
    height := ScaleDPI(231);
    ActiveControl := FindText;

    CenterForm;
    mr := showmodal;
    if not (mr in [mrOK,mrYes]) then exit;
    fi.findStr := FindText.Text;
    fi.replaceStr := ReplaceText.Text;
    fi.ignoreCase := not CaseSensitive.Checked;
    fi.wholeWords := WholeWords.Checked;
    fi.directionDown := Forwards.Checked;
    fi.replacePrompt := Prompt.Checked;
    fi.replaceAll := (mr = mrYes);
    fReplaceAll := fi.replaceAll;
  end;
  result := true;
end;
//------------------------------------------------------------------------------

function ReplacePrompt(aOwner: TCustomForm; Point: TPoint): TReplaceType;
var
  mr: TModalResult;
begin
  result := rtCancel;
  if not assigned(FindForm) or (aOwner = nil) then exit;
  Point := aOwner.ClientToScreen(Point);
  ReplaceCreate;
  with ReplaceForm do
  begin
    fOwner := aOwner;
    FindText.Text := FindForm.FindText.Text;
    findText.SelectAll;
    ReplaceText.Text := FindForm.ReplaceText.Text;
    if Point.x + width > screen.width then
      Point.x := screen.width - width - ScaleDPI(4);
    Left := Point.x;
    if Point.y - height -ScaleDPI(8) > 0 then
      Top := Point.y - height -ScaleDPI(8) else
      Top := Point.y + ScaleDPI(30); //30 = guess at lineheight with some margin
    ActiveControl := OkBtn;
    SkipBtn.Enabled := FindForm.fReplaceAll;
    AllBtn.Enabled := FindForm.fReplaceAll;
    mr := ShowModal;
    case mr of
      mrOK: result := rtOK;
      mrNo: result := rtSkip;
      mrYes: result := rtAll;
      else result := rtCancel;
    end;
  end;
end;
//------------------------------------------------------------------------------

initialization
  DpiScale := Screen.PixelsPerInch / 96;

end.

