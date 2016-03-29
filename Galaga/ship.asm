; #########################################################################
;
;   ship.asm - Assembly file for Galaga ship
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

.CODE

;BalanceShots takes an array of shots and rebalances it to remove all shots that should be erased from
;the screen. It also returns the number of shots left on screen in eax
BalanceShots PROC USES edx ecx esi ebx edi my_shots:PTR DWORD
	LOCAL num_empty:DWORD
	xor ecx, ecx					;ecx will serve as our counter
	mov num_empty, 0				;num_empty holds the number of shots we have removed
	
  CHECK_OFF_SCREEN:
	mov esi, (Shot PTR[ecx]).x
	cmp esi, 0
	jl REMOVE
	cmp esi, 640
	jg REMOVE
	
	mov esi, (Shot PTR[ecx]).y
	cmp esi, 0
	jl REMOVE
	cmp esi, 480
	jg REMOVE

  REMOVE:
	inc num_empty
	mov ebx, ecx					;ebx = index of the current element in the array
	inc ebx
	cmp ebx, LENGTHOF my_shots
	jge NEXT_ELEMENT
	
	mov edi, TYPE my_shots
	mov eax, ebx
	mul edi
	add eax, my_shots
	mov esi, eax
	
	mov eax, ebx
	sub eax, num_empty
	mul edi
	add eax, my_shots
	
	mov [eax], esi
	
	
	
	jmp REMOVE
	
  NEXT_ELEMENT:
	inc ecx
	cmp ecx, LENGTHOF my_shots
	jl CHECK_OFF_SCREEN
	
	mov eax, LENGTHOF my_shots
	sub eax, num_empty
  
	ret
BalanceShots ENDP
END