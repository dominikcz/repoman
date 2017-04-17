unit frmDiff.utils;

interface

uses
  Winapi.Windows, Vcl.Graphics, Diff;

function MakeDarker(color: TColor): TColor;
procedure MarkupTextOut(canvas: TCanvas; rec: TRect; x,y: integer; const text, colors: string; clrs: array of TColor);
procedure AddStrClr(var s1, s2: string; c: char; kind, lastkind: TChangeKind);

implementation

function MakeDarker(color: TColor): TColor;
var
  r,g,b: byte;
begin
  Color := ColorToRGB(color);
  b := (Color shr 16) and $FF;
  g := (Color shr 8) and $FF;
  r := (Color and $FF);
  b := b * 7 div 8;
  g := g * 7 div 8;
  r := r * 7 div 8;
  result := (b shl 16) or (g shl 8) or r;
end;

procedure MarkupTextOut(canvas: TCanvas; rec: TRect; x,y: integer; const text, colors: string; clrs: array of TColor);
var
  i,j, len: integer;
  savedTextAlign, SavedBkColor, savedTextColor: cardinal;
  savedPt: TPoint;
  clr: TColor;
begin
  len := length(text);
  if (len = 0) or (length(colors) <> len) or (high(clrs) < 1) then exit;

  savedTextColor := GetTextColor(canvas.Handle);
  SavedBkColor := GetBkColor(canvas.handle);
  savedTextAlign := GetTextAlign(canvas.Handle);
  SetTextAlign(canvas.Handle, savedTextAlign or TA_UPDATECP);
  MoveToEx(canvas.Handle, x, y, @savedPt);

  clr := clrs[ord(colors[1])];
  SetBkColor(canvas.handle, clr);
  j := 1;
  for i := 1 to len+1 do
    if (i > len) then
      ExtTextOut(canvas.handle,0,0,ETO_CLIPPED, @rec, pchar(@text[j]),i-j, nil)
    else if (clr <> clrs[ord(colors[i])]) then
    begin
      ExtTextOut(canvas.handle,0,0,ETO_CLIPPED, @rec, pchar(@text[j]),i-j, nil);
      clr := clrs[ord(colors[i])];
      SetBkColor(canvas.handle, clr);
      j := i;
    end;

  SetTextColor(canvas.handle,savedTextColor);
  SetBkColor(canvas.handle, SavedBkColor);
  SetTextAlign(canvas.Handle, savedTextAlign);
  with savedPt do MoveToEx(canvas.Handle, X,Y, nil);
end;

//---------------------------------------------------------------------

procedure AddStrClr(var s1, s2: string; c: char; kind, lastkind: TChangeKind);
begin
  s1 := s1 + c;
  case kind of
    ckNone: s2 := s2 + #0;
    else s2 := s2 + #1;
  end;
end;

//---------------------------------------------------------------------

end.
