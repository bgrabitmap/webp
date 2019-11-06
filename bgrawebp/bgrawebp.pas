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
  fileWebP: TFileStream;
  inWebP: packed array of byte;
  outWebP: PByte;
  w, h: integer;
begin
  fileWebP := TFileStream.Create(FileName, fmOpenRead);

  SetLength(inWebP, fileWebP.Size);
  if inWebP<>nil then
    fileWebP.Read(inWebP[0], length(inWebP));
  fileWebP.Free;

  WebPGetInfo(@inWebP[0], length(inWebP), @w, @h);

  {$PUSH}{$WARNINGS OFF}
  if TBGRAPixel_RGBAOrder then
    outWebP := WebPDecodeRGBA(@inWebP[0], length(inWebP), @w, @h)
  else
    outWebP := WebPDecodeBGRA(@inWebP[0], length(inWebP), @w, @h);
  {$POP}

  Self.SetSize(w, h);
  move(outWebP^, self.Data^, self.RowSize*h);
  WebPFree(outWebP);
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

  fileWebP := TFileStream.Create(FileName, fmCreate);
  fileWebP.Write(outWebP^, outSize);
  fileWebp.Free;
  WebPFree(outWebP);
  if self.LineOrder = riloBottomToTop then Self.VerticalFlip;
end;

end.


