unit umain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, libwebp,
  bgrabitmap, bgrabitmaptypes;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private

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

end.

