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

{ TBGRABitmapWebPHelper }

procedure TBGRABitmapWebPHelper.LoadFromWebPFile(FileName: string);
var
  i: integer;
  bmp: TBGRABitmap;
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

  Self.InvalidateBitmap;
  Self.VerticalFlip;

  fileWebP.Free;
end;

procedure TBGRABitmapWebPHelper.SaveToWebPFile(FileName: string; Quality: single);
var
  outWebP: PByte;
  fileWebP: TFileStream;
  i: integer;
begin
  Self.VerticalFlip;

  WebPEncodeBGRA(Self.DataByte, Self.Width, Self.Height, Self.Width *
    4, Quality, outWebP);

  fileWebP := TFileStream.Create(FileName, fmCreate);
  for i := 0 to (Self.Width * Self.Height) - 1 do
  begin
    fileWebP.Write(outWebP^, 1);
    Inc(outWebP);
  end;
  fileWebp.Free;

  Self.VerticalFlip;
end;

end.


