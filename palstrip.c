/* palstrip.c: Extract color pallet from BMP file
 *
 * BMP Pallet
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
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int mpf=0;
unsigned char cbits[4]={0,0,0,0};
int frmt=0;
char *bmpfile="";
FILE *pal=NULL,*bmp=NULL;

main(int argc,char *argv[])
{
  printf("BMP Palett, Version 1.00\n\n");

  if(argc==2) {
    strcat(bmpfile,strlwr(argv[1]));
  }
  else if(argc>2) {
    mpf=!strcmp(strlwr(argv[1]),"-mpf");
    strcat(bmpfile,strlwr(argv[2]));
  }
  else if(argc<2) {
      printf("USAGE: palstrip [-mpf] <bmp file>\n\t-mpf\tMicroangelo palette format.\n");
      exit(1);
  }

  if(strcmp(bmpfile+strlen(bmpfile)-4,".bmp"))strcat(bmpfile,".bmp");

  if((bmp=fopen(bmpfile,"r"))==NULL) {
    printf("Error opening %s\n",bmpfile);
    exit(1);
  }

  fread(cbits,sizeof(cbits),1,bmp);
  if(cbits[0]!=0x42||cbits[1]!=0x4d) {
    printf("%s is not a valid bitmap.\n",bmpfile);
    fclose(bmp);
    exit(1);
  }

  *(bmpfile+strlen(bmpfile)-4)='\0';
  strcat(bmpfile,".pal");

  if((pal=fopen(bmpfile,"w"))==NULL) {
    printf("Error opening %s\n",bmpfile);
    exit(1);
  }

  fseek(bmp,0x1c,0);
  frmt=fgetc(bmp);
  printf("Processing %i-bit BMP...",frmt);

  if(frmt>8)frmt=8;

  if(mpf)  {
    fprintf(pal,"JASC-PAL\n0100\n%d\n",1<<frmt);
  }

  fseek(bmp,0x36,0);
  for(int x=0; x<(1<<frmt); x++) {
    fread(cbits,sizeof(cbits),1,bmp);
    fprintf(pal,"%d %d %d\n",cbits[0],cbits[1],cbits[2]);
  }

  fputc(0x00,pal);
  fputc(0x0A,pal);
  fputc(0x1A,pal);

  fclose(bmp);
  fclose(pal);

  printf("done\n");

  return 0;
}

