unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, libwebp,
  BGRAVirtualScreen, bgrabitmap, bgrabitmaptypes, BCTypes;

type

  { TForm1 }

  TForm1 = class(TForm)
    BGRAVirtualScreen1: TBGRAVirtualScreen;
    Button1: TButton;
    Button2: TButton;
    procedure BGRAVirtualScreen1Redraw(Sender: TObject; Bitmap: TBGRABitmap);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    bgrab: TBGRABitmap;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  bmp: TBGRABitmap;
  outWebP: PByte;
  fileWebP: TFileStream;
  i: integer;
begin
  bmp := TBGRABitmap.Create('powered_by.png');
  bmp.DataByte;
  WebPEncodeBGRA(bmp.DataByte, bmp.width, bmp.height, bmp.Width * 4, 100, outWebP);

  fileWebP := TFileStream.Create('file.webp', fmCreate);
  for i:=0 to (bmp.Width*bmp.Height)-1 do
  begin
    fileWebP.Write(outWebP^, 1);
    Inc(outWebP,1);
  end;
  fileWebp.Free;
  bmp.Free;
end;

procedure TForm1.BGRAVirtualScreen1Redraw(Sender: TObject; Bitmap: TBGRABitmap);
begin
  Bitmap.Fill(BGRAWhite);
  Bitmap.PutImage(0, 0, bgrab, dmDrawWithTransparency);
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: integer;
  bmp: TBGRABitmap;
  fileWebP: TFileStream;
  inWebP: array of byte;
  outWebP: PByte;
  w, h: Integer;
  p: PBGRAPixel;
begin

  fileWebP := TFileStream.Create('file.webp', fmOpenRead);

  SetLength(inWebP, fileWebP.Size);

  //ShowMessage(fileWebP.Size.ToString);

  for i:=0 to fileWebP.Size-1 do
  begin
    inWebP[i] := fileWebP.ReadByte;
  end;

  WebPGetInfo(@inWebP[0], fileWebP.Size, @w, @h);
  outWebP := WebPDecodeRGBA(@inWebP[0], fileWebP.Size, @w, @h);

  bgrab.SetSize(w, h);

  p := bgrab.Data;

  for i:=0 to (w*h)-1 do
  begin
    p^.red := outWebP^;
    inc(outWebP);
    p^.green := outWebP^;
    inc(outWebP);
    p^.blue := outWebP^;
    inc(outWebP);
    p^.alpha := outWebP^;
    inc(outWebP);
    inc(p);
  end;

  bgrab.InvalidateBitmap;

  //ShowMessage(w.ToString + ' ' + h.ToString);

  fileWebP.Free;
  BGRAVirtualScreen1.DiscardBitmap;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  bgrab := TBGRABitmap.Create(0,0);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  bgrab.Free;
end;

end.

