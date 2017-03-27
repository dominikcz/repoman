unit AlphaBitmaps;

(*******************************************************************************
*                                                                              *
* Author    :  Angus Johnson                                                   *
* Version   :  1.0                                                             *
* Date      :  21 April 2014                                                   *
* Website   :  http://www.angusj.com                                           *
* Copyright :  Angus Johnson 2010-2014                                         *
*                                                                              *
* License:                                                                     *
* Use, modification & distribution is subject to Boost Software License Ver 1  *
* http://www.boost.org/LICENSE_1_0.txt                                         *
*                                                                              *
*******************************************************************************)

interface

uses
  Windows, Graphics, Classes, Controls, Math, SysUtils;

//ColorToAlpha:
//  Converts a bitmap into a 32bit bitmap alpha channel bitmap and makes
//  pixels near 'ARGBColor' transparent or semi-transparent ...
procedure ColorToAlpha(alphaBmp: TBitmap; ARGBColor: Cardinal);

//PremultiplyAlphaBitmap: Alpha bitmaps must be premultiplied before calling
//DrawPremulAlphaBmpOntoCanvas (see below) ...
procedure PremultiplyAlphaBmp(alphaBmp: TBitmap);
procedure DemultiplyAlphaBmp(alphaBmp: TBitmap);

//DrawPremulAlphaBmpOntoCanvas:
//  Draws a scaled alpha channel bitmap onto the supplied canvas.
//  Color channels must be premultiplied (see PremultiplyAlphaBitmap above).
function DrawPremulAlphaBmpOntoCanvas(destCanvas: TCanvas;
  const destRec: TRect; premulSrcBmp: TBitmap; const srcRec: TRect): Boolean;

//MergeAlphaBitmaps:
//  Merge 2 AlphaBitmaps (returning the result in 'botBmp') ...
procedure MergeAlphaBmps(botBmp, topBmp: TBitmap);

//BlendOntoBkgndBmp: Blends 'alphaBmp' onto an opaque 'bkgndBmp'
procedure BlendOntoBkgndBmp(bkgndBmp, alphaBmp: TBitmap);

procedure CopyCtrlCanvasOntoBmp(ctrl: TWinControl; srcRec: TRect; bmp: TBitmap);

//IconFromAlphaBmp: makes a 32bit alpha channel icon from bmp
procedure IconFromAlphaBmp(alphaBmp: TBitmap; resultIcon: TIcon);

//AddBkgndColor: makes 'alphaBmp' fully opaque
procedure AddBkgndColor(alphaBmp: TBitmap; bkgndColor: Cardinal);

procedure FillBitmap(bmp: TBitmap; ARGBColor: Cardinal);
procedure SetAlphaTo255(alphaBmp: TBitmap);

procedure GetRangeAlpha(alphaBmp: TBitmap; out minAlpha, maxAlpha: Byte);
function FixAlphaChannel(bmp: TBitmap): boolean;

//InvertAlphaBitmap: inverts color channels only ...
procedure InvertAlphaBmp(alphaBmp: TBitmap);

//Blend when background is fully opaque ...
function Blend(const F, B: Cardinal; W: Byte): Cardinal; overload;
function Blend(const F, B: Cardinal): Cardinal; overload;
//Merge when background has transparency ...
function Merge(F, B: Cardinal): Cardinal;

implementation

type
  PColorBytes = ^TColorBytes;
  TColorBytes = array [0 ..3] of Byte;

  PByteArray = ^TByteArray;
  TByteArray = array [0 ..255] of Byte;

  PColorEntry = ^TColorEntry;
  TColorEntry = packed record
    case Integer of
      0: (B, G, R, A: Byte);
      1: (ARGB: Cardinal);
  end;

  PColorArray = ^TColorArray;
  TColorArray = array [0 ..MaxInt div 4 -1] of Cardinal;

var
  MulTable: array [Byte, Byte] of Byte;
  DivTable: array [Byte, Byte] of Byte;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

function Blend(const F, B: Cardinal): Cardinal; //nb: B is fully opaque
var
  fg: TColorEntry ABSOLUTE F;
  bg: TColorEntry ABSOLUTE B;
  res: TColorEntry ABSOLUTE Result;
  Fw, Bw: PByteArray;
begin
  if fg.A = 0 then result := B
  else if fg.A = $FF then result := F
  else
  begin
    Fw := @MulTable[fg.A];
    Bw := @MulTable[not fg.A];
    Res.R := Fw[fg.R] + Bw[bg.R];
    Res.G := Fw[fg.G] + Bw[bg.G];
    Res.B := Fw[fg.B] + Bw[bg.B];
    Res.A := 255;
  end;
end;
//------------------------------------------------------------------------------

function Blend(const F, B: Cardinal; W: Byte): Cardinal; //nb: B is fully opaque
var
  fg: TColorEntry ABSOLUTE F;
  bg: TColorEntry ABSOLUTE B;
  res: TColorEntry ABSOLUTE Result;
  Fw, Bw: PByteArray;
begin
  if W = 0 then result := B
  else if W = $FF then result := F
  else
  begin
    Fw := @MulTable[W];
    Bw := @MulTable[not W];
    Res.R := Fw[fg.R] + Bw[bg.R];
    Res.G := Fw[fg.G] + Bw[bg.G];
    Res.B := Fw[fg.B] + Bw[bg.B];
    Res.A := 255;
  end;
end;
//------------------------------------------------------------------------------

function Merge(F, B: Cardinal): Cardinal;
var
 Fa, Ba, Wa: Cardinal;
 Fw, Bw: PByteArray;
 Fx: TColorEntry absolute F;
 Bx: TColorEntry absolute B;
 Rx: TColorEntry absolute Result;
begin
 Fa := F shr 24;
 Ba := B shr 24;
 if Fa = $FF then Result := F
 else if Fa = $0 then Result := B
 else if Ba = $0 then Result := F
 else
 begin
   //the following line is exactly equivalent to
   //Rx.A := MulTable[Fa xor 255, Ba xor 255] xor 255;
   Rx.A := Fa + MulTable[Ba, Fa xor $FF];
   Wa := DivTable[Rx.A, Fa];
   Fw := @MulTable[Wa];
   Bw := @MulTable[Wa xor $FF];
   Rx.R := Fw[Fx.R] + Bw[Bx.R];
   Rx.G := Fw[Fx.G] + Bw[Bx.G];
   Rx.B := Fw[Fx.B] + Bw[Bx.B];
 end;
end;
//------------------------------------------------------------------------------

procedure WhiteToAlpha(alphaBmp: TBitmap);
var
  i, x, y, a: integer;
  p: PByteArray;
  bg: PColorBytes;
begin
  alphaBmp.PixelFormat := pf32bit;
  for y := 0 to alphaBmp.Height -1 do
  begin
    bg := alphaBmp.ScanLine[y];
    for x := 0 to alphaBmp.Width -1 do
    begin
      a := 0;
      for i := 0 to 2 do
        if bg[i] < 255 then
          a := Max(a,(bg[i] xor $FF));
      if a > 0 then
      begin
        bg[3] := MulTable[bg[3], a];
        p := @DivTable[a];
        for i := 0 to 2 do bg[i] := p[bg[i] xor $FF] xor $FF;
      end else
        bg[3] := 0;
      inc(bg);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure BlackToAlpha(alphaBmp: TBitmap);
var
  i, x, y, a: integer;
  p: PByteArray;
  bg: PColorBytes;
begin
  alphaBmp.PixelFormat := pf32bit;
  for y := 0 to alphaBmp.Height -1 do
  begin
    bg := alphaBmp.ScanLine[y];
    for x := 0 to alphaBmp.Width -1 do
    begin
      a := 0;
      for i := 0 to 2 do
        if bg[i] > 0 then
          a := Max(a, bg[i]);
      if a > 0 then
      begin
        bg[3] := MulTable[bg[3], a];
        p := @DivTable[a];
        for i := 0 to 2 do bg[i] := p[bg[i]];
      end else
        bg[3] := 0;
      inc(bg);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure ColorToAlpha(alphaBmp: TBitmap; ARGBColor: Cardinal);
var
  i, x, y, a: integer;
  px: PColorBytes;
  c: TColorBytes ABSOLUTE ARGBColor;
  p: PByteArray;
begin
  with TColorEntry(ARGBColor) do i := R+G+B;
  if i > 255 * 3 - 10 then
    WhiteToAlpha(alphaBmp) //accept a very small tolerance
  else if i < 10 then
    BlackToAlpha(alphaBmp) //accept a very small tolerance
  else
  begin
    alphaBmp.PixelFormat := pf32bit;
    for y := 0 to alphaBmp.Height -1 do
    begin
      px := alphaBmp.ScanLine[y];
      for x := 0 to alphaBmp.Width -1 do
      begin
        a := 0;
        for i := 0 to 2 do
          if px[i] <> c[i] then
          begin
            if px[i] > c[i] then
              a := Max(a, DivTable[ c[i] xor $ff, px[i] - c[i] ]) else
              a := Max(a, DivTable[ c[i], c[i] - px[i] ]);
          end;
        if a = 0 then
        begin
          px[3] := 0;
        end else
        begin
          px[3] := MulTable[ a, px[3] ];
          p := @DivTable[a];
          for i := 0 to 2 do
            if px[i] > c[i] then
              px[i] := c[i] + p[px[i] - c[i]] else
              px[i] := c[i] - p[c[i] - px[i]];
        end;
        inc(px);
      end;
    end;
  end;
end;
//------------------------------------------------------------------------------

function DrawPremulAlphaBmpOntoCanvas(destCanvas: TCanvas;
  const destRec: TRect; premulSrcBmp: TBitmap; const srcRec: TRect): Boolean;
var
  dc: HDC;
  bf: TBlendFunction;
begin
  Result := false;
  if (premulSrcBmp.PixelFormat <> pf32bit) or
    not destCanvas.HandleAllocated then Exit;

  bf.BlendOp := AC_SRC_OVER;
  bf.BlendFlags := 0;
  bf.SourceConstantAlpha := 255;
  bf.AlphaFormat := AC_SRC_ALPHA;
  dc := CreateCompatibleDC(destCanvas.Handle);
  try
    SelectObject(dc, premulSrcBmp.Handle);
    Result := Windows.AlphaBlend(destCanvas.Handle,
      destRec.Left, destRec.Top,
      destRec.Right - destRec.Left, destRec.Bottom - destRec.Top,
      dc,
      srcRec.Left, srcRec.Top,
      srcRec.Right - srcRec.Left, srcRec.Bottom - srcRec.Top,
      bf);
  finally
    DeleteDC(dc);
  end;
end;
//------------------------------------------------------------------------------

procedure IconFromAlphaBmp(alphaBmp: TBitmap; resultIcon: TIcon);
var
  w,h: integer;
  monoBmp: HBITMAP;
  iconInfo: TIconInfo;
begin
  resultIcon.handle := 0;
  if (alphaBmp.PixelFormat <> pf32bit) then alphaBmp.PixelFormat := pf32bit;
  w := alphaBmp.Width;
  h := alphaBmp.Height;
  if Max(w, h) > 256 then
    raise Exception.Create('Image too large to fit into an icon.');
  monoBmp := CreateBitmap(w, h, 1, 0, nil);
  try
    iconInfo.fIcon := true;
    iconInfo.xHotspot := 0;
    iconInfo.yHotspot := 0;
    iconInfo.hbmMask := monoBmp;
    iconInfo.hbmColor := alphaBmp.Handle;
    resultIcon.Handle := CreateIconIndirect(iconInfo);
  finally
    DeleteObject(monoBmp);
  end;
end;
//------------------------------------------------------------------------------

procedure MergeAlphaBmps(botBmp, topBmp: TBitmap);
var
  x,y: Integer;
  c1, c2: PColorEntry;
begin
  botBmp.PixelFormat := pf32bit;
  topBmp.PixelFormat := pf32bit;
  if (botBmp.Width <> topBmp.Width) or
    (botBmp.Height <> topBmp.Height) then
      raise Exception.Create('Bitmaps must have the same dimensions to merge.');
  for y := 0 to botBmp.Height -1 do
  begin
    c1 := botBmp.ScanLine[y];
    c2 := topBmp.ScanLine[y];
    for x := 0 to botBmp.Width -1 do
    begin
      c1.ARGB := Merge(c2.ARGB, c1.ARGB);
      inc(c1); inc(c2);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure BlendOntoBkgndBmp(bkgndBmp, alphaBmp: TBitmap);
var
  x,y: Integer;
  c1, c2: PColorEntry;
begin
  bkgndBmp.PixelFormat := pf32bit;
  alphaBmp.PixelFormat := pf32bit;
  if (alphaBmp.Width <> bkgndBmp.Width) or
    (alphaBmp.Height <> bkgndBmp.Height) then
      raise Exception.Create('Bitmaps must have the same dimensions to merge.');

  for y := 0 to bkgndBmp.Height -1 do
  begin
    c1 := bkgndBmp.ScanLine[y];
    c2 := alphaBmp.ScanLine[y];
    for x := 0 to bkgndBmp.Width -1 do
    begin
      c1.ARGB := Blend(c2.ARGB, c1.ARGB);
      inc(c1); inc(c2);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure AddBkgndColor(alphaBmp: TBitmap; bkgndColor: Cardinal);
var
  x,y: Integer;
  c: PColorEntry;
  cl: TColorEntry ABSOLUTE bkgndColor;
begin
  alphaBmp.PixelFormat := pf32bit;
  cl.A := 255;
  for y := 0 to alphaBmp.Height -1 do
  begin
    c := alphaBmp.ScanLine[y];
    for x := 0 to alphaBmp.Width -1 do
    begin
      c.ARGB := Blend(c.ARGB, cl.ARGB);
      inc(c);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure SetAlphaTo255(alphaBmp: TBitmap);
var
  x,y: Integer;
  c: PColorEntry;
begin
  alphaBmp.PixelFormat := pf32bit;
  for y := 0 to alphaBmp.Height -1 do
  begin
    c := alphaBmp.ScanLine[y];
    for x := 0 to alphaBmp.Width -1 do
    begin
      c.A := 255;
      inc(c);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure PremultiplyAlphaBmp(alphaBmp: TBitmap);
var
  x,y: Integer;
  src: PColorEntry;
  alphaIsStale: Boolean;
  p: PByteArray;
begin
  //Unfortunately Delphi doesn't recognize 32bpp with BI_BITFIELDS compress type
  alphaIsStale :=
    (alphaBmp.PixelFormat <> pf32bit) and (alphaBmp.PixelFormat <> pfCustom);
  if (alphaBmp.PixelFormat <> pf32bit) then alphaBmp.PixelFormat := pf32bit;

  for y := 0 to alphaBmp.Height -1 do
  begin
    src := alphaBmp.ScanLine[y];
    for x := 0 to alphaBmp.Width -1 do
    begin
      if (src.A = 0) then
      begin
        if alphaIsStale then
          src.A := $FF
        else
        begin
          src.R := 0;
          src.G := 0;
          src.B := 0;
        end;
      end
      else if (src.A < 255) then
      begin
        p := @MulTable[src.A];
        src.R := p[src.R];
        src.G := p[src.G];
        src.B := p[src.B];
      end;
      inc(src);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure DemultiplyAlphaBmp(alphaBmp: TBitmap);
var
  x,y: Integer;
  src: PColorEntry;
  p: PByteArray;
begin
  for y := 0 to alphaBmp.Height -1 do
  begin
    src := alphaBmp.ScanLine[y];
    for x := 0 to alphaBmp.Width -1 do
    begin
      if (src.A = 0) or (src.A = 255) then continue
      else
      begin
        p := @DivTable[src.A];
        src.R := p[src.R];
        src.G := p[src.G];
        src.B := p[src.B];
      end;
      inc(src);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure InvertAlphaBmp(alphaBmp: TBitmap);
var
  x, y, z: Integer;
  b: PColorBytes;
begin
  alphaBmp.PixelFormat := pf32bit;
  for y := 0 to alphaBmp.Height -1 do
  begin
    b := alphaBmp.ScanLine[y];
    for x := 0 to alphaBmp.Width -1 do
    begin
      for z := 0 to 2 do b[z] := b[z] xor $FF;
      inc(b);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure FillBitmap(bmp: TBitmap; ARGBColor: Cardinal);
var
  x,y: Integer;
  b: PColor;
begin
  bmp.PixelFormat := pf32bit;
  for y := 0 to bmp.Height -1 do
  begin
    b := bmp.ScanLine[y];
    for x := 0 to bmp.Width -1 do
    begin
      b^ := ARGBColor;
      inc(b);
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure GetRangeAlpha(alphaBmp: TBitmap; out minAlpha, maxAlpha: Byte);
var
  x,y: Integer;
  b: PColorEntry;
  bitmap: windows.BITMAP;
begin
  //this accepts alphaBmp.PixelFormat = pfCustom too
  if (GetObject(alphaBmp.Handle, sizeof(bitmap), @bitmap) = 0) or
    (bitmap.bmBitsPixel <> 32) then
  begin
    alphaBmp.PixelFormat := pf32bit;
    minAlpha := 0;
    maxAlpha := 0;
    Exit;
  end;

  minAlpha := 255;
  maxAlpha := 0;
  for y := 0 to alphaBmp.Height -1 do
  begin
    b := alphaBmp.ScanLine[y];
    for x := 0 to alphaBmp.Width -1 do
    begin
      if b.A > maxAlpha then maxAlpha := b.A;
      if b.A < minAlpha then minAlpha := b.A;
      inc(b);
    end;
  end;
  if minAlpha > maxAlpha then maxAlpha := 255;
end;
//------------------------------------------------------------------------------

function FixAlphaChannel(bmp: TBitmap): boolean;
var
  minA, maxA: Byte;
begin
  GetRangeAlpha(bmp, minA, maxA);
  if maxA = 0 then SetAlphaTo255(bmp);
  Result := maxA > minA;
end;
//------------------------------------------------------------------------------

procedure CopyCtrlCanvasOntoBmp(ctrl: TWinControl; srcRec: TRect; bmp: TBitmap);
var
  w, h: Integer;
  dc: HDC;
begin
  //consider preconditions: ctrl.HandleAllocated and ctrl.Showing
  w := srcRec.Right - srcRec.Left;
  h := srcRec.Bottom - srcRec.Top;
  bmp.Width := w;
  bmp.Height := h;
  bmp.PixelFormat := pf32bit;

  dc := GetDc(ctrl.Handle);
  try
    BitBlt(bmp.Canvas.Handle, 0, 0, w, h, dc, srcRec.Left, srcRec.Top, SRCCOPY);
  finally
    ReleaseDC(ctrl.Handle, dc);
  end;
end;
//------------------------------------------------------------------------------

{$R-}
procedure MakeTables;
var
  I, J: Integer;
const
  Div255 = 1 / 255;
begin
  for I := 0 to 255 do
  begin
    MulTable[I, 0] := 0;
    DivTable[I, 0] := 0;
  end;
  for I := 1 to 255 do
    for J := 0 to 255 do
    begin
      MulTable[I, J] := Round(I * J * Div255);
      DivTable[I, J] := Round((J * 255) / I);
    end;
end;
//------------------------------------------------------------------------------
{$R+}

initialization
  MakeTables;
end.
