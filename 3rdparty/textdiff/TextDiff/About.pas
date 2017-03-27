unit About;

// -----------------------------------------------------------------------------
// Application:     TextDiff                                                   .
// Module:          Main                                                       .
// Version:         4.6                                                        .
// Date:            7-NOVEMBER-2009                                            .
// Target:          Win32, Delphi 7 - Delphi 2009                              .
// Author:          Angus Johnson - angusj-AT-myrealbox-DOT-com                .
// Copyright;       © 2003-2009 Angus Johnson                                  .
// -----------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ShellAPI, AlphaBitmaps;

type
  TAboutForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Image1: TImage;
    Button1: TButton;
    Label3: TLabel;
    lblCompileDate: TLabel;
    procedure Label6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.DFM}

type
  PIMAGE_RESOURCE_DIRECTORY = ^IMAGE_RESOURCE_DIRECTORY;
  IMAGE_RESOURCE_DIRECTORY = packed record
    Characteristics : DWORD;
    TimeDateStamp   : DWORD;
    MajorVersion    : WORD;
    MinorVersion    : WORD;
    NumberOfNamedEntries : WORD;
    NumberOfIdEntries : WORD;
  end;

{$IFDEF UNICODE}
  PChar8 = PByte;
{$ELSE}
  PChar8 = PChar;
{$ENDIF}

function GetCompileDateTime: TDateTime;
var
  i: integer;
  resourceDataDirectory: TImageDataDirectory;
  imageResourceDirectory: PIMAGE_RESOURCE_DIRECTORY;
  fh: PImageFileHeader;
  oh: PImageOptionalHeader32;
  sh: PImageSectionHeader;
  rsh: PImageSectionHeader;
  va: DWORD;
begin
  result := 0; // if error then result = 0
  fh := Pointer(hinstance);
  inc(PByte(fh), PImageDosHeader(fh)^._lfanew + sizeof(dword));
  PChar8(oh) := PChar8(fh) + sizeof(TImageFileHeader);
  if oh.Magic = $20B then
  begin
    PChar8(sh) := PChar8(oh) + 240; //sizeof(IMAGE_OPTIONAL_HEADER64);
    resourceDataDirectory := oh.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE];
  end else
  begin
    PChar8(sh) := PChar8(oh) + sizeof(IMAGE_OPTIONAL_HEADER);
    resourceDataDirectory := oh.DataDirectory[IMAGE_DIRECTORY_ENTRY_RESOURCE];
  end;
  va := resourceDataDirectory.VirtualAddress;
  if (va = 0) then Exit; //ie: no resource section
  rsh := sh;
  for i := 1 to fh.NumberOfSections do
  begin
    if (va >= rsh.VirtualAddress) and
      (va < rsh.VirtualAddress + rsh.SizeOfRawData) then break;
    Inc(rsh);
  end;
  imageResourceDirectory := Pointer(hinstance + rsh.VirtualAddress);
  Result := FileDateToDateTime(imageResourceDirectory.TimeDateStamp);
end;
//------------------------------------------------------------------------------

procedure TAboutForm.Label6Click(Sender: TObject);
begin
  Label6.cursor := crAppStart;
  application.processmessages;
  ShellExecute(0, Nil, PChar(Label6.caption), Nil, Nil, SW_NORMAL);
  Label6.cursor := crHandPoint;
end;
//------------------------------------------------------------------------------

procedure TAboutForm.FormCreate(Sender: TObject);
begin
  image1.Picture.Icon.Handle := LoadImage(hInstance, 'MAINICON', IMAGE_ICON, 48, 48, 0);
  lblCompileDate.Caption :=
    'Build Date: ' + FormatDateTime('dd mmm yyyy', GetCompileDateTime);
end;

end.
