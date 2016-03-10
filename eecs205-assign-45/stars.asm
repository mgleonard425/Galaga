; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA

	;; If you need to, you can place global variables here
.CODE

DrawStarField proc

	;; Place your code here
invoke DrawStar, 100, 100
invoke DrawStar, 100, 200
invoke DrawStar, 100, 300
invoke DrawStar, 100, 400
invoke DrawStar, 200, 100
invoke DrawStar, 200, 200
invoke DrawStar, 200, 300
invoke DrawStar, 200, 400
invoke DrawStar, 300, 100
invoke DrawStar, 300, 200
invoke DrawStar, 300, 300
invoke DrawStar, 300, 400
invoke DrawStar, 400, 100
invoke DrawStar, 400, 200
invoke DrawStar, 400, 300
invoke DrawStar, 400, 400
	ret  			; Careful! Don't remove this line
DrawStarField endp


AXP	proc a:FXPT, x:FXPT, p:FXPT

	;; Place your code here
mov eax, a
mov ebx, x
mov ecx, p
xor edx, edx
imul ebx
shr eax, 16
shl edx, 16
add eax, edx
add eax, ecx
	;; Remember that the return value should be copied in to EAX
	
	ret  			; Careful! Don't remove this line	
AXP	endp

	

END
