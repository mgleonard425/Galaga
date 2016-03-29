; #########################################################################
;
;   shot.asm - Assembly file for Galaga shot
;	Author: Michael Leonard
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include \masm32\include\windows.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib

include stars.inc
include lines.inc
include blit.inc
include shot.inc
include ship.inc
include player.inc
include game.inc
include keys.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib

END