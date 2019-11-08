unit bgrawebp;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BGRABitmap, BGRABitmapTypes, libwebp_dl;

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
  fileWebP: TFileStream;
  inWebP: packed array of byte;
  w, h: integer;
  ok: Boolean;
begin
  fileWebP := TFileStream.Create(FileName, fmOpenRead);
  try
    SetLength(inWebP, fileWebP.Size);
    if inWebP<>nil then
      fileWebP.Read(inWebP[0], length(inWebP));
  finally
    fileWebP.Free;
  end;

  if WebPGetInfo(@inWebP[0], length(inWebP), @w, @h) = 0 then
    raise exception.Create('Invalid WebP header');

  Self.SetSize(w, h);
  {$PUSH}{$WARNINGS OFF}
  if TBGRAPixel_RGBAOrder then
    ok := WebPDecodeRGBAInto(@inWebP[0], length(inWebP), self.DataByte, self.RowSize*h, self.RowSize)<>nil
  else
    ok := WebPDecodeBGRAInto(@inWebP[0], length(inWebP), self.DataByte, self.RowSize*h, self.RowSize)<>nil;
  {$POP}
  if not ok then raise exception.Create('Error decoding WebP');
  if self.LineOrder = riloBottomToTop then Self.VerticalFlip;
end;

procedure TBGRABitmapWebPHelper.SaveToWebPFile(FileName: string; Quality: single);
var
  outWebP: PByte;
  fileWebP: TFileStream;
  outSize: Cardinal;
begin
  if self.LineOrder = riloBottomToTop then Self.VerticalFlip;

  {$PUSH}{$WARNINGS OFF}
  if TBGRAPixel_RGBAOrder then
    outSize := WebPEncodeRGBA(Self.DataByte, Self.Width, Self.Height, Self.Width *
      4, Quality, outWebP{%H-})
  else
    outSize := WebPEncodeBGRA(Self.DataByte, Self.Width, Self.Height, Self.Width *
      4, Quality, outWebP{%H-});
  {$POP}
  if outSize = 0 then
    raise exception.Create('Error encoding WebP');

  fileWebP := TFileStream.Create(FileName, fmCreate);
  try
    fileWebP.Write(outWebP^, outSize);
    if self.LineOrder = riloBottomToTop then Self.VerticalFlip;
  finally
    fileWebp.Free;
    WebPFree(outWebP);
  end;
end;

end.


