unit bgrawebp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BGRABitmap, BGRABitmapTypes, libwebp;

type

  { TBGRABitmapWebPHelper }

  TBGRABitmapWebPHelper = class helper for TBGRABitmap
  public
    procedure LoadFromWebPFile(FileName: string);
    procedure SaveToWebPFile(FileName: string; Quality: single);
  end;

implementation

uses Windows;

{ TBGRABitmapWebPHelper }

procedure TBGRABitmapWebPHelper.LoadFromWebPFile(FileName: string);
var
  i: integer;
  fileWebP: TFileStream;
  inWebP: array of byte;
  outWebP: PByte;
  w, h: integer;
  p: PBGRAPixel;
begin
  fileWebP := TFileStream.Create(FileName, fmOpenRead);

  SetLength(inWebP, fileWebP.Size);

  for i := 0 to fileWebP.Size - 1 do
  begin
    inWebP[i] := fileWebP.ReadByte;
  end;

  WebPGetInfo(@inWebP[0], fileWebP.Size, @w, @h);
  outWebP := WebPDecodeRGBA(@inWebP[0], fileWebP.Size, @w, @h);

  Self.SetSize(w, h);

  p := Self.Data;

  for i := 0 to (w * h) - 1 do
  begin
    p^.red := outWebP^;
    Inc(outWebP);
    p^.green := outWebP^;
    Inc(outWebP);
    p^.blue := outWebP^;
    Inc(outWebP);
    p^.alpha := outWebP^;
    Inc(outWebP);
    Inc(p);
  end;

  Self.VerticalFlip;

  fileWebP.Free;
end;

procedure TBGRABitmapWebPHelper.SaveToWebPFile(FileName: string; Quality: single);
var
  outWebP: PByte;
  fileWebP: TFileStream;
  i: integer;
  outSize: Cardinal;
begin
  if self.LineOrder = riloBottomToTop then Self.VerticalFlip;

  outSize := WebPEncodeBGRA(Self.DataByte, Self.Width, Self.Height, Self.Width *
    4, Quality, outWebP{%H-});

  fileWebP := TFileStream.Create(FileName, fmCreate);
  fileWebP.Write(outWebP^, outSize);
  fileWebp.Free;

  //Free or WebPFree(outWebP);

  if self.LineOrder = riloBottomToTop then Self.VerticalFlip;
end;

end.


