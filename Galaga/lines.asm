; #########################################################################
;
;   lines.asm - Assembly file for sine/cosine and line drawing procedures
;	Author: Michael Leonard
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc

.DATA
;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  256 / PI   (use this to find the table entry for a given angle
	                        ;;              it is easier to use than divison would be)

	;; If you need to, you can place global variables here
	
.CODE
	

FixedSin PROC USES edx ecx ebx edi angle:FXPT

	xor ebx, ebx

Interval_Test:
	cmp angle, 0
	jl Negative
	cmp angle, TWO_PI
	jge Over_Two_Pi
	cmp angle, PI
	jge Over_Pi
	cmp angle, PI_HALF
	jge Over_Pi_Half

Under_Pi_Half:
	mov eax, PI_INC_RECIP
	xor edx, edx
	imul angle  ; edx gets the index
	xor eax, eax
	movzx eax, [edx*2+SINTAB]
	jmp Return_Value

Is_Pi_Half:
	mov eax, 10000h
	jmp Return_Value

Over_Pi_Half:
	cmp angle, PI_HALF
	je Is_Pi_Half
	mov eax, PI_INC_RECIP
	mov ecx, PI
	sub ecx, angle
	imul ecx ; edx gets the index
	xor eax, eax
	movzx eax, [edx*2+SINTAB]
	jmp Return_Value

Is_Pi:
	mov eax, 0
	jmp Return_Value

Over_Pi:
	cmp angle, PI
	je Is_Pi
	mov ebx, 1
	sub angle, PI
	jmp Interval_Test

Over_Two_Pi:
	sub angle, TWO_PI
	jmp Interval_Test

Negative:
	add angle, TWO_PI
	jmp Interval_Test

Return_Value:
	cmp ebx, 0
	je Finish
	mov edi, -1
	imul edi

Finish:

	ret        	;;  Don't delete this line...you need it	
FixedSin ENDP 
	
FixedCos PROC USES edx angle:FXPT

	mov edx, angle
	add edx, PI_HALF
	invoke FixedSin, edx
	
	ret        	;;  Don't delete this line...you need it		
FixedCos ENDP	


PLOT PROC USES ebx edx x:DWORD, y:DWORD, color:DWORD

	mov eax, y ;eax=y
	mov ebx, 640 ; ebx=640
	mul ebx ;eax=y*640
	xor ebx, ebx ;ebx=0
	mov ebx, x ;ebx = x
	add eax, ebx ;eax= y*639+x
	xor edx, edx ;edx=0
	mov edx, color ;edx=color
	xor ebx, ebx ;ebx=0
	mov ebx, ScreenBitsPtr ;ebx = screenbitsptr addrs
	mov BYTE PTR [ebx + eax], dl ;moving least 8 significant bytes

	ret
PLOT ENDP

	
DrawLine PROC USES ebx ecx edx esi edi x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD


Check_Bounds:

	cmp x0, 640
	jg Error
	cmp x1, 640
	jg Error
	cmp y0, 480
	jg Error
	cmp y1, 480
	jg Error

	mov eax, x0 ; eax = x0
	sub eax, x1 ; eax = x0-x1
	cmp eax, 0
	jl x_neg ; jump if x0-x1<0
	jmp continue1
x_neg:
	xor eax, eax
	mov eax, x1 ; eax = x1
	sub eax, x0 ; eax = x1-x0
continue1:            ;eax = |x1-x0|

	mov ecx, y0 ; ecx = y0
	sub ecx, y1 ; ecx = y0-y1
	cmp ecx, 0
	jl y_neg
	jmp continue2
y_neg:
	xor ecx, ecx
	mov ecx, y1
	sub ecx, y0
continue2:            ;ecx = |y1-y0|

	cmp ecx, eax
	jge else_draw ; jump if |y1-y0|>=|x1-x0|

if_draw:              ;|y1-y0|<|x1-x0|
	xor ecx, ecx
	xor eax, eax
	mov ecx, x1 ; ecx = x1
	sub ecx, x0 ; ecx = x1-x0
	mov eax, y1 ; eax = y1
	sub eax, y0 ; eax = y1-y0
	mov edx, eax
	sar edx, 16
	sal eax, 16 ; {edx,eax} = fixed (y1-y0)
	idiv ecx     ; eax = (y1-y0)/(x1-x0)
	mov edi, eax ; edi = fixed_inc
		
	cmp ecx, 0
	jl x_SWAP ; jump if x1-x0<0
	mov ecx, x0 ; ecx = x0
	mov edx, x1 ; edx = x1
	mov esi, y0 ; esi = y0
	shl esi, 16 ; esi -> floating point
	jmp continue3
x_SWAP:
	mov ecx, x1
	mov edx, x0
	mov esi, y1
	shl esi, 16
continue3:            ; ecx = x0, edx = x1, esi = fixed_j
	
	jmp for_x_test

for_x_plot:
	mov ebx, esi
	shr ebx, 16
	invoke PLOT, ecx, ebx, color
	add esi, edi ; jixed_j += fixed_inc
	add ecx, 1 ; ecx++

for_x_test:
	cmp ecx, edx
	jle for_x_plot
	jmp Finish
	
else_draw:
	xor eax, eax
	xor ecx, ecx
	xor ebx, ebx
	xor esi, esi
	mov ecx, y1 ; ecx = y1
	sub ecx, y0 ; ecx = y1-y0
	mov eax, x1 ; eax = x1
	sub eax, x0 ; eax = x1-x0
	mov edx, eax 
	sar edx, 16
	sal eax, 16 ; {edx,eax} = fixed (x1-x0)
	idiv ecx
	mov edi, eax ; edi = fixed_inc

	cmp ecx, 0
	jl Y_SWAP ; jump if y1-y0<0
	mov ecx, y0
	mov edx, y1
	mov esi, x0
	shl esi, 16
	jmp continue4
Y_SWAP:
	mov ecx, y1
	mov edx, y0
	mov esi, x1
	shl esi, 16

continue4:           ; ecx = y0, edx = y1, esi = fixed_j

	jmp for_y_test
for_y_plot:
	mov ebx, esi
	shr ebx, 16
	invoke PLOT, ebx, ecx, color
	add esi, edi
	add ecx, 1
for_y_test:
	cmp ecx, edx
	jle for_y_plot

Error:

Finish:
	

	ret        	;;  Don't delete this line...you need it
DrawLine ENDP




END
