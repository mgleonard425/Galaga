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
include game.inc
include keys.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib
	
.DATA

galagaShot EECS205BITMAP <8, 3, 255,, offset galagaShot + sizeof galagaShot>
	BYTE 000h,000h,000h,000h,0e0h,0e0h,000h,000h,0dbh,0dbh,0dbh,0dbh,01fh,0e0h,0e0h,0e0h
	BYTE 000h,000h,000h,000h,0e0h,0e0h,000h,000h

end