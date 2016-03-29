; #########################################################################
;
;   game.asm - Assembly file for EECS205 Assignment 4/5
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include blit.inc
include shot.inc
include player.inc
include game.inc
include keys.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib
	
.DATA

yellowBug EECS205BITMAP <24, 36, 255,, offset yellowBug + sizeof yellowBug>
	BYTE 073h,073h,073h,073h,073h,073h,073h,0dfh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,00bh,00bh,00bh,00bh,00bh,00bh,007h,0dbh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 00fh,00fh,00fh,00fh,00fh,02fh,00bh,0bbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,00fh
	BYTE 00bh,093h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,00bh,00fh
	BYTE 00bh,00bh,00bh,00bh,00bh,00bh,00bh,02fh,00bh,097h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,003h,00bh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,00fh
	BYTE 00bh,073h,0dbh,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,0bbh,097h,097h
	BYTE 02fh,02fh,02fh,02fh,00fh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,0dfh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0b7h,003h,093h,0ffh,0ffh,00bh,00bh,00bh,007h,00bh,00bh,00bh,00bh
	BYTE 00bh,00bh,00bh,00bh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b7h,003h,073h,0ffh,0ffh
	BYTE 0bbh,0bbh,0bbh,0bbh,0b7h,00bh,00bh,00bh,00bh,00bh,00bh,00bh,097h,0b7h,0dbh,0ffh
	BYTE 0ffh,0bbh,0b7h,0b7h,0bbh,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,00bh,02fh,02fh
	BYTE 02fh,00bh,00bh,00bh,00bh,003h,097h,0ffh,0ffh,02fh,003h,0bbh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0dfh,007h,00bh,00bh,00bh,00bh,00bh,00bh,02fh,00bh,0b7h,0ffh
	BYTE 0ffh,02fh,007h,0bbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,0dbh,0dbh
	BYTE 0dbh,0b7h,00bh,00bh,02fh,00bh,0b6h,0fdh,0feh,0c9h,0c1h,0f5h,0fdh,0feh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dfh,00bh,00fh,00bh,007h,0b6h,0fch
	BYTE 0fch,0e8h,0e0h,0f4h,0fch,0fdh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0dbh,00bh,02bh,02fh,00bh,0b6h,0fch,0fch,0e8h,0e0h,0f4h,0fch,0feh,0ffh,0ffh
	BYTE 0ffh,0ffh,0f6h,0e0h,0f1h,0fdh,0fdh,0f1h,0e5h,0e9h,0e1h,0e1h,0f9h,0fdh,0fch,0fch
	BYTE 0fch,0e8h,0e0h,0e8h,0e8h,0f2h,0ffh,0ffh,0ffh,0ffh,0f6h,0e0h,0ech,0fch,0fch,0ech
	BYTE 0e0h,0e0h,0e0h,0e0h,0fch,0fch,0fch,0fch,0fch,0e0h,0e0h,0e0h,0e0h,0eeh,0ffh,0ffh
	BYTE 0fbh,0fbh,0f2h,0e0h,0ech,0fch,0fch,0f0h,0e0h,0e4h,0e0h,0e0h,0fch,0fch,0fch,0fch
	BYTE 0fch,0f0h,0f0h,0f0h,0f0h,0f5h,0ffh,0ffh,0e0h,0e0h,0e0h,0e0h,0ech,0fch,0fch,0f0h
	BYTE 0e0h,0e4h,0e0h,0e0h,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch
	BYTE 0e0h,0e0h,0e0h,0e0h,0ech,0fch,0fch,0f0h,0e0h,0e4h,0e0h,0e0h,0fch,0fch,0fch,0fch
	BYTE 0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch,0f6h,0f6h,0edh,0e0h,0ech,0fch,0fch,0f0h
	BYTE 0e0h,0e4h,0e0h,0e0h,0fch,0fch,0fch,0fch,0fch,0f4h,0f4h,0f4h,0f4h,0f9h,0feh,0feh
	BYTE 0ffh,0ffh,0f6h,0e0h,0ech,0fch,0fch,0f0h,0e0h,0e4h,0e0h,0e0h,0fch,0fch,0fch,0fch
	BYTE 0fch,0e0h,0e0h,0e0h,0e0h,0eeh,0ffh,0ffh,0ffh,0ffh,0f2h,0e0h,0ech,0fch,0fch,0ech
	BYTE 0e0h,0e0h,0e0h,0e0h,0fch,0fch,0fch,0fch,0fch,0e8h,0e0h,0e0h,0e0h,0eeh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0fbh,0fbh,0ffh,0ffh,0fbh,0fbh,0d7h,066h,08ah,092h,072h,0bah,0fch
	BYTE 0fch,0e8h,0e0h,0f0h,0f8h,0fah,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0dfh,00bh,00fh,00bh,003h,096h,0fch,0fch,0e8h,0e0h,0f8h,0fch,0feh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,00bh,02bh,02fh,00bh,0b6h,0fch
	BYTE 0fch,0e8h,0e0h,0f4h,0fch,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,04fh,04fh,04fh
	BYTE 053h,04fh,00bh,00bh,02fh,00bh,0b7h,0ffh,0ffh,06fh,027h,0dbh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,007h,097h,0ffh
	BYTE 0ffh,02fh,003h,0bbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,00bh,00fh,00fh
	BYTE 00fh,00bh,00bh,00bh,053h,04fh,0bbh,0ffh,0ffh,073h,04fh,0bbh,0ffh,0ffh,0ffh,0ffh
	BYTE 00bh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,02fh,00bh,0dfh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0b7h,007h,097h,0ffh,0ffh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,00bh
	BYTE 00bh,00bh,00bh,007h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b7h,003h,093h,0ffh,0ffh
	BYTE 00bh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,04fh,097h,097h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0dbh,073h,097h,0dbh,0dbh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,02fh
	BYTE 00bh,097h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,007h,00bh
	BYTE 00bh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,003h,073h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,007h,00bh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,0b7h
	BYTE 0dbh,0dfh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,0dbh
	BYTE 00bh,00bh,00bh,00bh,00bh,00fh,00bh,0dfh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,00bh,00bh,00bh,00bh,00bh,00bh,00bh,0dbh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh

end