unit ulinuxlib;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function FindLinuxLibrary(ALinkerName: string): string;

implementation

uses process;

function FindLinuxLibrary(ALinkerName: string): string;
const
  OpenBracket = ' (';
  Arrow = ') => ';
var
  dataText, s, fileName, flags, path: string;
  dataList, flagList: TStringList;
  openBracketPos, arrowPos: SizeInt;
  versionInt, errPos, i: integer;
  maxVersionInt: integer;
begin
  result := '';
  maxVersionInt := -1;
  RunCommand('ldconfig', ['-p'], dataText, []);
  dataList := TStringList.Create;
  dataList.Text := dataText;
  flagList := TStringList.Create;
  for i := 0 to dataList.Count-1 do
  begin
    s := dataList[i];
    openBracketPos := pos(OpenBracket, s);
    arrowPos := pos(Arrow,s);
    if (openBracketPos <> 0) and (arrowPos <> 0) then
    begin
      fileName := trim(copy(s,1,openBracketPos-1));
      if fileName.StartsWith(ALinkerName+'.') then
      begin
        val(copy(fileName, length(ALinkerName)+2, length(fileName)-length(ALinkerName)-1), versionInt, errPos);
        if errPos = 0 then
        begin
          flags := copy(s, openBracketPos+length(OpenBracket), arrowPos-openBracketPos-length(OpenBracket));
          flagList.CommaText := flags;
          if {$IFNDEF CPU64}not{$ENDIF} (flagList.IndexOf('x86-64') <> -1) then
          begin
            path := copy(s, arrowPos+length(Arrow), length(s)-arrowPos-length(Arrow)+1);
            if versionInt > maxVersionInt then
            begin
              maxVersionInt := versionInt;
              result := path;
            end;
          end;
        end;
      end;
    end;
  end;
  flagList.Free;
  dataList.Free;
end;

end.

