{* bmpdisp.pas: Display the BMP image on VGA screen
 *
 * BMP Display
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

uses crt,dos;
var curpos,x,y,count,mx,my:word;
    fbmp:text;
    srec:searchrec;
    c,cold,num:byte;
    bmpfactor:shortint;
    ch:char;
    fname:string;
{$r-}
procedure swapbyte(var num:byte);
var tmp,c,b:byte;
begin
  tmp:=0;
  for c:=1 to 8 do
    begin
      b:=0;
      b:=num and 1;
      tmp:=tmp shl 1;
      tmp:=tmp+b;
      num:=num shr 1;
    end;
  num:=tmp;
end;
{$r+}
procedure loadgui(mode:byte);assembler;
asm
  push ax
  xor ax,ax
  mov al,mode
  int 10h
  pop ax
end;
procedure writedot(x,y:word;col:byte);assembler;
asm
  push ax
  push dx
  push cx
  mov ah,0ch
  mov al,col
  mov dx,y
  mov cx,x
  int 10h
  pop cx
  pop dx
  pop ax
end;
begin
  writeln('BMP Display,  Version 1.00 (Beta Version)');
  writeln;
  if paramcount<1 then
    begin
      writeln('USAGE: bmpdisp filename');
      writeln;
      writeln('filename        Path and filename of the bitmap you want to view.');
      writeln;
      halt(1);
    end;
  fname:=paramstr(1);
  findfirst(fname,$3f,srec);
  if srec.name='' then
    begin
      writeln('File not found ',fname);
      halt(1);
    end;
  assign(fbmp,fname);
  {$i-}reset(fbmp);{$i+}
  if ioresult<>0 then
    begin
      writeln('I/O failure on opening ',fname);
      halt(1);
    end;
  for count:=1 to 19 do
    begin
      read(fbmp,ch);
    end;
  bmpfactor:=0;
  count:=ord(ch);
  read(fbmp,ch);
  num:=ord(ch);
  mx:=count+(num shl 8);
  read(fbmp,ch);
  read(fbmp,ch);
  read(fbmp,ch);
  count:=ord(ch);
  read(fbmp,ch);
  num:=ord(ch);
  my:=count+(num shl 8);
  if(mx>800)or(my>600)then
    begin
      writeln('Resolution ',mx,'x',my,' is not supported.');
      halt(1);
    end;
  for count:=1 to 5 do
    begin
      read(fbmp,ch);
    end;
  cold:=ord(ch);
  if((mx=640)or(mx=800))then
    begin
      bmpfactor:=1;
    end;
  if mx<640 then
    begin
      case cold of
        8:bmpfactor:=1;
        4:bmpfactor:=3;
        1:bmpfactor:=-3;
        end;
    end;
  if (mx>640)and(mx<800) then
    begin
      bmpfactor:=0;
    end;
  if(mx>640)or(my>480)then
    begin
      loadgui($ea);
    end
  else
    begin
      loadgui($12);
    end;
  case cold of
    1:begin
        for count:=1 to 33 do
          begin
            read(fbmp,ch);
          end;
        for y:=my-1 downto 0 do
          begin
            for x:=0 to mx-bmpfactor do
              begin
                if keypressed then
                  begin
                    loadgui($3);
                    exit;
                  end;
                read(fbmp,ch);
                num:=ord(ch);
                swapbyte(num);
                for count:=1 to 8 do
                  begin
                    c:=num and 1;
                    if c=1 then
                      begin
                        c:=15;
                      end;
                    writedot(x,y,c);
                    num:=num shr 1;
                    if count<8 then
                      begin
                        inc(x);
                      end;
                  end;
                end;
            end;
      end;
    4:begin
        for count:=1 to 89 do
          begin
            read(fbmp,ch);
          end;
        for y:=my-1 downto 0 do
          begin
            for x:=0 to mx+bmpfactor do
              begin
                if keypressed then
                  begin
                    exit;
                  end;
                read(fbmp,ch);
                num:=ord(ch);
                writedot(x,y,num div 16);
                inc(x);
                writedot(x,y,num mod 16);
              end;
          end;
      end;
    8:begin
        for count:=1 to 1049 do
          begin
            read(fbmp,ch);
          end;
        for y:=my-1 downto 0 do
          begin
            for x:=0 to mx-bmpfactor do
              begin
                if keypressed then
                  begin
                    loadgui($3);
                    close(fbmp);
                    halt(1);
                  end;
                read(fbmp,ch);
                num:=ord(ch);
                writedot(x,y,num);
              end;
          end;
      end;
    else
      begin
        loadgui($3);
        writeln;
        writeln(cold,'-bit format is not spported.');
        halt(1);
      end;
    end;
  readkey;
  loadgui($3);
  close(fbmp);
end.
