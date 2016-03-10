; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;	jma771 John Albers
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include blit.inc

.DATA

	;; If you need to, you can place global variables here
	left1 DWORD ?
	right1 DWORD ?
	top1 DWORD ?
	bottom1 DWORD ?
	left2 DWORD ?
	right2 DWORD ?
	bottom2 DWORD ?
	top2 DWORD ?
	x0 dword ?
	y0 dword ?
	colorz dword ?
	thing dword ?
	temp dword ?
	limit dword 1180
	cosa dword ?
	sina dword ?
	shiftx dword ?
	shifty dword ?
	dstwidth dword ?
	dstheight dword ?
	dstx dword ?
	dsty dword ?
	srcx dword ?
	srcy dword ?


.CODE

Plot PROC USES ebx ecx edx x:DWORD, y:DWORD, color:DWORD
xor ebx, ebx
xor eax, eax
xor ecx, ecx
xor edx, edx
mov ecx, 640
mov eax, y
mov ebx, x
imul ecx
add eax, ebx
xor ebx, ebx
mov ebx, color
mov edx, ScreenBitsPtr
mov BYTE PTR [edx+eax], bl
ret

Plot ENDP

EraseBlit PROC USES ebx ecx edx esi edi ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD

	xor ebx, ebx
	mov esi, ptrBitmap
	mov ecx, (EECS205BITMAP PTR[esi]).dwHeight
	shr ecx, 1
	mov eax, ycenter
	sub eax, ecx ;;eax is leftmost
	mov edx, (EECS205BITMAP PTR[esi]).dwWidth
	shr edx, 1
	mov ecx, xcenter
	sub ecx, edx ;;ecx is topmost
	mov x0, ecx
	mov y0, eax
	mov edx, (EECS205BITMAP PTR[esi]).dwWidth
	mov eax, (EECS205BITMAP PTR[esi]).dwHeight
	mul edx ;;eax now equals the number of pixels
	xor ebx, ebx
	xor edx, edx
	xor ecx, ecx
	mov esi, ptrBitmap
	mov edi, (EECS205BITMAP PTR[esi]).dwWidth
	mov thing, edi
	xor ecx, ecx
	xor edx, edx
	mov eax, (EECS205BITMAP PTR[esi]).dwHeight

CLIP:
	cmp xcenter, eax
	;jle XCLIP ;Needs clip



COND: 
	cmp ebx, limit ;;compares number of pixels to ebx, multiplication isn't working
	jge DONE
	cmp edx, thing ;if x component is less than width
	jl XINC ;edx is x
	jmp YINC ;ecx is y

XINC:
	add edx, x0
	add ecx, y0
	mov esi, ptrBitmap
	mov eax, (EECS205BITMAP PTR[esi]).lpBytes
	mov esi, [eax+ebx]
	mov temp, edx
	mov edx, esi
	mov edi, ptrBitmap
	mov al, (EECS205BITMAP PTR[edi]).bTransparent
	cmp dl, al ;check transparency
	je HERE
	cmp temp, 639 ;bounds checking
	jg HERE
	cmp temp, 16 ;chek more bounds
	jl HERE
	cmp ecx, 0
	jl HERE
	invoke Plot, temp, ecx, 0
HERE:	
	mov edx, temp
	sub edx, x0
	sub ecx, y0
	inc edx
	inc ebx
	jmp COND

YINC:
	add ecx, 1 ;;should just be ++
	xor edx, edx
	jmp COND

DONE:

	ret
EraseBlit ENDP

BasicBlit PROC USES ebx ecx edx esi edi ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD

	xor ebx, ebx
	mov esi, ptrBitmap
	mov ecx, (EECS205BITMAP PTR[esi]).dwHeight
	shr ecx, 1
	mov eax, ycenter
	sub eax, ecx ;;eax is leftmost
	mov edx, (EECS205BITMAP PTR[esi]).dwWidth
	shr edx, 1
	mov ecx, xcenter
	sub ecx, edx ;;ecx is topmost
	mov x0, ecx
	mov y0, eax
	mov edx, (EECS205BITMAP PTR[esi]).dwWidth
	mov eax, (EECS205BITMAP PTR[esi]).dwHeight
	mul edx ;;eax now equals the number of pixels
	xor ebx, ebx
	xor edx, edx
	xor ecx, ecx
	mov esi, ptrBitmap
	mov edi, (EECS205BITMAP PTR[esi]).dwWidth
	mov thing, edi
	xor ecx, ecx
	xor edx, edx
	mov eax, (EECS205BITMAP PTR[esi]).dwHeight

CLIP:
	cmp xcenter, eax
	;jle XCLIP ;Needs clip



COND: 
	cmp ebx, limit ;;compares number of pixels to ebx, multiplication isn't working
	jge DONE
	cmp edx, thing ;if x component is less than width
	jl XINC ;edx is x
	jmp YINC ;ecx is y

XINC:
	add edx, x0
	add ecx, y0
	mov esi, ptrBitmap
	mov eax, (EECS205BITMAP PTR[esi]).lpBytes
	mov esi, [eax+ebx]
	mov temp, edx
	mov edx, esi
	mov edi, ptrBitmap
	mov al, (EECS205BITMAP PTR[edi]).bTransparent
	cmp dl, al ;check transparency
	je HERE
	cmp temp, 639 ;bounds checking
	jg HERE
	cmp temp, 16 ;chek more bounds
	jl HERE
	cmp ecx, 0
	jl HERE
	invoke Plot, temp, ecx, esi
HERE:	
	mov edx, temp
	sub edx, x0
	sub ecx, y0
	inc edx
	inc ebx
	jmp COND

YINC:
	add ecx, 1 ;;should just be ++
	xor edx, edx
	jmp COND

DONE:

	ret    	;;  Do not delete this line!

BasicBlit ENDP

RotateBlit PROC USES ebx ecx edx esi edi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
	invoke FixedSin, angle
	mov sina, eax
	invoke FixedCos, angle
	mov cosa, eax
	
	
	mov esi, lpBmp
	mov eax, (EECS205BITMAP PTR[esi]).dwWidth
	imul cosa
	sar eax, 1
	mov shiftx, eax


	mov eax, (EECS205BITMAP PTR[esi]).dwHeight
	mov edx, 0
	imul sina
	sar eax, 1
	sub shiftx, eax ;x1-x2
	
	mov eax, (EECS205BITMAP PTR[esi]).dwHeight
	xor edx, edx
	imul cosa
	sar eax, 1
	mov shifty, eax 

	mov eax, (EECS205BITMAP PTR[esi]).dwWidth
	xor edx, edx
	imul sina
	sar eax, 1
	add shifty, eax ;y1-y2


	mov esi, lpBmp
	mov ebx, (EECS205BITMAP PTR[esi]).dwWidth
	add ebx, (EECS205BITMAP PTR[esi]).dwHeight
	mov dstwidth, ebx
	mov dstheight, ebx
	sar shiftx, 16
	sar shifty, 16
	
SETUP:
	neg ebx
	mov dstx, ebx
	mov dsty, ebx
	jmp OUTERLOOPCOND

OUTERLOOPCOND:
	mov ebx, dstwidth
	cmp dstx, ebx
	jl INNERLOOPCOND
	jmp DONEZO


INNERLOOPCOND:
	mov eax, dstheight	
	cmp dsty, eax
	jl INNERLOOP
	jmp OUTERLOOPINC
	
INNERLOOP:
	mov eax, dstx
	xor edx, edx
	imul cosa
	mov srcx, 0
	mov srcy, 0
	mov srcx, eax
	mov ebx, sina
	mov eax, dsty
	xor edx, edx
	imul ebx
	add srcx, eax
	mov ebx, cosa
	mov eax, dsty
	xor edx, edx
	imul ebx
	mov srcy, eax
	mov ebx, sina
	mov eax, dstx
	xor edx, edx
	imul ebx
	sub srcy, eax
	sar srcx, 16 ;fxpt to int
	sar srcy, 16 ;fxpt to int

	
	
	
	
	
	
	mov esi, lpBmp
	mov eax, (EECS205BITMAP PTR[esi]).dwWidth
	mov ebx, (EECS205BITMAP PTR[esi]).dwHeight

	cmp srcx, 0
	jl NOPLOT
	cmp srcx, eax
	jge NOPLOT
	cmp srcy, 0
	jl NOPLOT
	cmp srcy, ebx
	jge NOPLOT
	mov eax, xcenter
	add eax, dstx
	sub eax, shiftx
	cmp eax, 0
	jle NOPLOT
	cmp eax, 639
	jge NOPLOT
	mov eax, ycenter
	add eax, dsty
	sub eax, shifty
	cmp eax, 0
	jle NOPLOT
	cmp eax, 479
	jge NOPLOT
	mov esi, lpBmp
	mov ebx, dsty
	add ebx, dstx
	mov esi, lpBmp
	mov ecx, (EECS205BITMAP PTR[esi]).dwWidth
	mov edi, (EECS205BITMAP PTR[esi]).lpBytes
	mov eax, srcy
	mul ecx
	add eax, srcx
	mov esi, [edi+eax]
	mov eax, xcenter
	add eax, dstx
	sub eax, shiftx
	mov ebx, ycenter
	add ebx, dsty
	sub ebx, shifty
	mov edi, lpBmp
	mov cl, (EECS205BITMAP PTR[edi]).bTransparent
	mov edx, esi
	cmp cl, dl
	je NOPLOT
	invoke Plot, eax, ebx, esi


NOPLOT:
	inc dsty	
	jmp INNERLOOPCOND
	

OUTERLOOPINC:
	mov eax, dstheight
	add dsty, eax
	neg dsty
	add dstx, 1
	jmp OUTERLOOPCOND

DONEZO:
		
	ret  	;;  Do not delete this line!
	
RotateBlit ENDP	








CheckIntersectRect PROC USES ebx edx ecx esi one:PTR EECS205RECT, two:PTR EECS205RECT

	mov ebx, one								;ebx = rectangle 1
	mov edx, two								;edx = rectange 2
	xor eax, eax								;eax = 0
	jmp CHECK_VERTICAL_COLLISION

  COLLISION:
	inc eax 									;eax = 1
	jmp DONE
	
  CHECK_VERTICAL_COLLISION:
	;;Check the top of one against the top of two
	mov ecx, (EECS205RECT PTR[ebx]).dwTop		;ecx = top of rectangle 1
	mov esi, (EECS205RECT PTR[edx]).dwTop		;esi = top of rectangle 2
	cmp ecx, esi
	jle CHECK_BOX_ONE_HIGHER_COLLISION
	;;Check the top of one against the bottom of two
	mov esi, (EECS205RECT PTR[edx]).dwBottom	;esi = bottom of rectangle 2
	cmp ecx, esi
	jge COLLISION
	jmp CHECK_HORIZONTAL_COLLISION

  CHECK_BOX_ONE_HIGHER_COLLISION:
	;;Check the bottom of one against the top of two
	mov ecx, (EECS205RECT PTR[ebx]).dwBottom	;ecx = bottom of rectangle 1
	cmp ecx, esi
	jle COLLISION
	
  CHECK_HORIZONTAL_COLLISION:
	;;Check the left edge of one against the left edge of two
	mov ecx, (EECS205RECT PTR[ebx]).dwLeft		;ecx = left edge of rectangle 1
	mov esi, (EECS205RECT PTR[edx]).dwLeft		;esi = left edge of rectangle 2
	cmp ecx, esi
	jle CHECK_BOX_ONE_LEFT_COLLISION
	;;Check the left edge of one against the right edge of two
	mov esi, (EECS205RECT PTR[edx]).dwRight		;esi = right edge of rectangle 2
	cmp ecx, esi
	jge COLLISION
	jmp DONE

  CHECK_BOX_ONE_LEFT_COLLISION:
	;;Check the right edge of one against the left edge of two
	mov ecx, (EECS205RECT PTR[ebx]).dwRight		;ecx = right edge of rectangle 1
	cmp ecx, esi
	jle COLLISION
	
  DONE:
	ret  	;;  Do not delete this line!
	
CheckIntersectRect ENDP

END
 
