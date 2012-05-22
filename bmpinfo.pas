{* bmpinfo.pas: Display the details about BMP image
 *
 * BMP Info
 * Copyright (C) 1998 Sudaraka Wijesinghe <sudaraka.wijesinghe@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *}

uses crt;
var count,num:word;
    fbmp:text;
    c,cold:longint;
    ch:char;
    fname:string;
begin
  writeln('BMP Info,  Version 1.00');
  writeln;
  if paramcount<1 then
    begin
      halt(0);
    end;
  fname:=paramstr(1);
  write('Loadding the bitmap...');
  assign(fbmp,fname);
  reset(fbmp);
  for count:=1 to 19 do
    begin
      read(fbmp,ch);
    end;
  gotoxy(1,wherey);
  clreol;
  writeln('Infrmation on ',fname);
  count:=0;
  num:=ord(ch);
  count:=num;
  read(fbmp,ch);
  num:=ord(ch);
  count:=count+(num shl 8);
  write('Bitmap resolution: ',count,'x');
  read(fbmp,ch);
  read(fbmp,ch);
  read(fbmp,ch);
  count:=0;
  num:=ord(ch);
  count:=num;
  read(fbmp,ch);
  num:=ord(ch);
  count:=count+(num shl 8);
  writeln(count);
  for count:=1 to 5 do
    begin
      read(fbmp,ch);
    end;
  num:=ord(ch);
  cold:=1;
  for c:=1 to num do
    begin
      cold:=cold shl 1;
    end;
  writeln('Color depth: ',num,'-bit (',cold,' Colors).');
  writeln;
  readkey;
  close(fbmp);
end.
