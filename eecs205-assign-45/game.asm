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

include \masm32\include\windows.inc
include \masm32\include\winmm.inc
includelib \masm32\lib\winmm.lib

include stars.inc
include lines.inc
include blit.inc
include game.inc
include keys.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib
	
.DATA
	time DWORD 0
	score_text BYTE "Score:", 0
	score_string BYTE "0000000000", 0
	score_num DWORD 0
	paused BYTE 0
	pause_message BYTE "PAUSED", 0
	end_message BYTE "Game Over. Final Score: ", 0
	themeSong BYTE "GalagaThemeSong.wav", 0
	
	player EECS205RECT<>	
	player_x DWORD 300
	player_y DWORD 400
	player_angle DWORD 0
	player_hit	BYTE 0
	
	player_shots Shot 10000 DUP(<>)
	shots_on_screen DWORD 0
	
	enemy Enemy<>

	
	quadrant DWORD ?		;The quadrant that the mouse is in

	LatestSprite EECS205RECT<>
	
	PI_OVER_256 = 804
	PI_HALF = 102943           		;;  PI / 2
	PI =  205887	                ;;  PI 
	TWO_PI	= 411774                ;;  2 * PI 
	PI_INC_RECIP =  5340353        	;;  256 / PI   (use this to find the table entry for a given angle
									;;              it is easier to use than divison would be)

	
;; If you need to, you can place global variables here


.CODE


StoreBitRect PROC USES ebx esi ecx edx ptrBitmap:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, sprite:EECS205RECT
	
	xor ebx, ebx
	mov esi, ptrBitmap
	mov ecx, (EECS205BITMAP PTR[esi]).dwHeight
	shr ecx, 1
	mov eax, ycenter
	sub eax, ecx 		;eax = top-most
	mov sprite.dwTop, eax
	
	mov edx, (EECS205BITMAP PTR[esi]).dwWidth
	shr edx, 1
	mov ecx, xcenter
	sub ecx, edx 		;ecx = left-most
	mov sprite.dwLeft, ecx
	
	mov ebx, (EECS205BITMAP PTR[esi]).dwHeight
	add ebx, eax 		;ebx = bottom-most
	mov sprite.dwBottom, ebx
	
	mov edx, (EECS205BITMAP PTR[esi]).dwWidth
	add edx, ecx		;edx = right-most
	mov sprite.dwRight, edx
	
	ret
StoreBitRect ENDP

AbsVal PROC val:DWORD
	cmp val, 0
	jge DONE
	neg val

  DONE:
	mov eax, val
	ret
AbsVal ENDP

AdjustAngleToQuadrant PROC angle:FXPT
	;;Takes reference angle and computes the actual angle based on the quadrant it's in
  	cmp quadrant, 2
	je SECOND_QUADRANT
	cmp quadrant, 3
	je THIRD_QUADRANT
	cmp quadrant, 4
	je FOURTH_QUADRANT
	jmp DONE
	;Else, it's quadrant 1 and we're done
	
  ;;In the comments, ref = reference angle
  SECOND_QUADRANT:		;;In the second quadrant, sin(ref) = sin(pi-ref)
	mov eax, PI
	sub eax, angle
	jmp DONE
	
  THIRD_QUADRANT:		;;In the third quadrant, sin(ref) = sin(pi+ref)
	mov eax, PI
	add eax, angle
	jmp DONE
	
  FOURTH_QUADRANT:		;;In the fourth quadrant, sin(ref) = sin(2*pi - ref)
	mov eax, TWO_PI
	sub eax, angle
  
DONE:
	
	ret
AdjustAngleToQuadrant ENDP

ArcSin PROC USES ecx ebx edx my_sine:FXPT
	;;The first part of the procedure computes the reference angle for the given sine value
	;;We iterate through SINTAB looking for a match for our given sine value
	;;The result is stored in player_angle
	xor eax, eax
	xor ecx, ecx
	xor ebx, ebx
	xor edx, edx
	jmp NEXT_ENTRY
	
  CHECK_IF_ENTRY:
	cmp ecx, 128							;Exit if we didn't find a match
	jge DONE
	movzx eax, WORD PTR[ecx*2+SINTAB]		;eax = current entry in SINTAB
	movzx edx, WORD PTR[ecx*2+SINTAB]		;edx = current entry in SINTAB
	sub eax, my_sine						;eax = edx - my_sine
	invoke AbsVal, eax						;eax = |eax|
	
	sub dx, WORD PTR[ecx*2-2+SINTAB]
	cmp eax, edx						
	jle IS_GREATER_THAN_ONE				;Jump if our sine is between the current entry in SINTAB and the previous one
  NEXT_ENTRY:
	inc ecx
	jmp CHECK_IF_ENTRY
	
  IS_GREATER_THAN_ONE:
	cmp ecx, 81				;The 82nd entry in sintab is the first corresponding to an angle greater than 1
	jl SINE_TO_ANGLE		;We need to deal with integer components of FXPT numbers differently
	;;If the index is over 81, then the angle is greater than 1 radian
	;;So we add 1:FXPT to the angle, and subtract 81 from the counter
	;;When we jump to SINE_TO_ANGLE, the remainder of the counter can be used to calculate the fractional component
	mov ebx, 65536			;ebx = 1:FXPT
	sub ecx, 81				;Subtract 81 from the count
	
  SINE_TO_ANGLE:
  ;;This part computes the fractional component of the angle
	invoke IntMul, PI_OVER_256, ecx 	;multiply the index of the SINTAB by pi/256
	add eax, ebx						;Adds 1:FXPT if the angle is over 1 radian
	invoke AdjustAngleToQuadrant, eax
  
  DONE:
	mov player_angle, eax
	
	ret
ArcSin ENDP

UpdateScore PROC USES ecx esi edi oldScore:PTR BYTE, newScore:PTR BYTE
	
	mov ecx, 10
	mov esi, newScore
	mov edi, oldScore
	add edi, 6
		rep movsb
	ret
UpdateScore ENDP


GameInit PROC USES edx
	rdtsc
	invoke nseed, eax
	invoke BasicBlit, OFFSET galagaStart, 320, 240
	invoke PlaySound, OFFSET themeSong, 0, SND_FILENAME OR SND_ASYNC
	mov enemy.x, 300
	mov enemy.y, 100
	ret         ;; Do not delete this line!!!
GameInit ENDP

GamePlay PROC USES edx ecx ebx esi edi
	LOCAL x:DWORD, y:DWORD
	
	xor eax, eax
	
	cmp player_hit, 0
	jne DONE
	;cmp time, 120
	;jl START_SCREEN
	
	cmp paused, 0
	jne PAUSED
	
	inc score_num
	invoke dwtoa, score_num, OFFSET score_string
	invoke UpdateScore, OFFSET score_text, OFFSET score_string
	

	;;Players will be able to use the arrow keys or WASD to move the sprite
	cmp KeyPress, VK_LEFT
	je KEY_LEFT
	cmp KeyPress, VK_A
	je KEY_LEFT
	
	cmp KeyPress, VK_RIGHT
	je KEY_RIGHT
	cmp KeyPress, VK_D
	je KEY_RIGHT
	
	cmp KeyPress, VK_DOWN
	je KEY_DOWN
	cmp KeyPress, VK_S
	je KEY_DOWN
	
	cmp KeyPress, VK_UP
	je KEY_UP
	cmp KeyPress, VK_W
	je KEY_UP
	
	jmp ROTATE
	
  KEY_LEFT:
	cmp player_x, 0
	jg MOVE_LEFT
	mov player_x, 639
	jmp ROTATE
  MOVE_LEFT:
	sub player_x, 5
	jmp ROTATE
	
  KEY_RIGHT:
	cmp player_x, 639
	jl MOVE_RIGHT
	mov player_x, 0
	jmp ROTATE
  MOVE_RIGHT:
	add player_x, 5
	jmp ROTATE
	
  KEY_DOWN:
	cmp player_y, 479
	jl MOVE_DOWN
	mov player_y, 0
	jmp ROTATE
  MOVE_DOWN:
	add player_y, 5
	jmp ROTATE

	
  KEY_UP:
	cmp player_y, 0
	jg MOVE_UP
	mov player_y, 479
	jmp ROTATE
  MOVE_UP:
	sub player_y, 5
	jmp ROTATE


  ROTATE:
  ;;Here, we rotate the sprite to face the mouse
  ;;We treat the sprite as the origin of a polar coordinate plane
  ;;And the mouse as a coordinate point in that coordinate plane
	
	mov edx, MouseStatus.horiz
	sub edx, player_x					;;edx = horizontal distance from sprite 1 to the mouse
	mov x, edx
	
	mov ecx, MouseStatus.vert
	sub ecx, player_y					;;ecx = vertical distance from sprite 1 to the mouse
	mov y, ecx
	
	cmp x, 0
	je UP_OR_DOWN					;;Here, the mouse is either directly above or below the sprite
	
	cmp y, 0
	je LEFT_OR_RIGHT
	
	;;We now know that the mouse is not on one of the axes of the coordinate plane
	;;So we first find the quadrant that the mouse is in
	;;And we take the absolute value of its coordinates
	
	cmp x, 0
	jl TWO_OR_THREE			;The mouse is left of the sprite, so it's in either quadrant 2 or 3
							;Otherwise, it's in quadrant 1 or 4
  ONE_OR_FOUR:
	cmp y, 0
	jl FOUR					;The mouse is right of and below the sprite, so it's in quadrant four
  ONE:
	mov quadrant, 1
	jmp HYPOTENUSE
  FOUR:
	mov quadrant, 4
	jmp HYPOTENUSE
	
  TWO_OR_THREE:
	cmp y, 0
	jl THREE				;The mouse is left of and below the sprite, so it's in quadrant three
  TWO:
	mov quadrant, 2
	jmp HYPOTENUSE
  THREE:
	mov quadrant, 3
  
  ;;Next, we compute the length of the hypotenuse
  ;;In the comments, x = horizontal distance from sprite 1 to the mouse
  ;;				 y = vertical distance from sprite 2 to the mouse
  HYPOTENUSE:
	invoke AbsVal, x
	mov x, eax
	invoke AbsVal, y
	mov y, eax
	
	xor eax, eax
	invoke IntMul, x, x		;eax = x^2
	mov ebx, eax			;ebx = x^2
	
	xor eax, eax
	invoke IntMul, y, y

	add ebx, eax			;ebx = x^2 + y^2
	xor eax, eax
	invoke IntSqrt, ebx		;eax = sqrt(x^2 + y^2)
	mov ebx, eax

  CALCULATE_SINE:
	;;We now have the length of the hypotenuse, so we calculate the sine of our angle
	mov eax, y				;eax = y
	shl eax, 16				;eax = y:FXPT
	invoke IntDiv, eax, ebx	;eax = y/sqrt(x^2+y^2):FXPT = sin(angle):FXPT
	
	invoke ArcSin, eax
	jmp IS_CLICKED
	
  ;;Now we know the quadrant that the mouse is in
  ;;And we have the absolute value of the x and y coordinates of the mouse
  ;;So we can divide the y coordinate by the x coordinate
  ;;Which will give us the sine of the mouse's reference angle
  
  
  LEFT_OR_RIGHT:
	cmp x, 0
	jl LEFT 					;jump if the mouse is left of sprite, otherwise continue
	je IS_CLICKED				;jump if the mouse is on the sprite, otherwise continue
  RIGHT:
	mov player_angle, 0			;Mouse is directly right of sprite, so sprite faces directly right
	jmp IS_CLICKED
  LEFT:
	mov player_angle, PI		;Mouse is directly left of sprite, so sprite faces directly left
	jmp IS_CLICKED
	
  UP_OR_DOWN:
	cmp y, 0
	jg BELOW					;jump if the mouse is below the sprite, otherwise continue
	je IS_CLICKED				;jump if the mouse is on the sprite, otherwise continue
  ABOVE:
	mov player_angle, PI_HALF	;Mouse is directly above sprite, so sprite faces directly upward
	jmp IS_CLICKED
  BELOW:
	mov player_angle, PI_HALF
	neg player_angle			;Mouse is directly below sprite, so sprite faces directly downward
	jmp IS_CLICKED

	
  SHOTS_FIRED:
	mov eax, TYPE player_shots
	mov ecx, shots_on_screen
	mul ecx
	add eax, OFFSET player_shots
	mov esi, eax
	inc shots_on_screen
	
	mov eax, player_x
	mov (Shot PTR[esi]).x, eax
	
	mov eax, player_y
	mov (Shot PTR[esi]).y, eax
	
	mov eax, player_angle
	mov (Shot PTR[esi]).angle, eax
	
	;Compute v_x
	invoke FixedCos, player_angle
	invoke AbsVal, eax
	shr eax, 11							;Multiply by 32 and convert to int
	cmp quadrant, 1
	je SET_VX
	cmp quadrant, 4
	je SET_VX
	neg eax
  SET_VX:
	mov (Shot PTR[esi]).vx, eax
	
	;Compute v_y
	invoke FixedSin, player_angle
	invoke AbsVal, eax
	shr eax, 11							;Multiply by 32 and convert to int
	cmp quadrant, 1
	je SET_VY
	cmp quadrant, 2
	je SET_VY
	neg eax
  SET_VY:
	mov (Shot PTR[esi]).vy, eax
	
	jmp REDRAW
  
  IS_CLICKED:
	mov eax, MouseStatus.buttons
	cmp eax, MK_LBUTTON
	je SHOTS_FIRED
	

  REDRAW:
  	invoke BlackStarField
	invoke DrawStr, OFFSET score_text, 520, 430, 0ffh
	
	invoke RotateBlit, OFFSET galagaShip, player_x, player_y, player_angle
	invoke StoreBitRect, OFFSET galagaShip, player_x, player_y, player
	
	mov ecx, shots_on_screen
	cmp ecx, 0
	je DRAW_ENEMY
	
  DRAW_SHOT:
	mov eax, TYPE player_shots
	mul ecx
	add eax, OFFSET player_shots
	mov esi, eax
	mov eax, (Shot PTR[esi]).vx
	add (Shot PTR[esi]).x, eax
	mov eax, (Shot PTR[esi]).vy
	add (Shot PTR[esi]).y, eax
	
	mov eax, (Shot PTR[esi]).x
	sub eax, enemy.x
	invoke AbsVal, eax
	cmp eax, 12
	jge NO_HIT
	mov eax, (Shot PTR[esi]).y
	sub eax, enemy.y
	invoke AbsVal, eax
	cmp eax, 18
	jge NO_HIT
	shl (Shot PTR[esi]).x, 10
	shl (Shot PTR[esi]).y, 10
	inc enemy.is_shot
	add score_num, 50
	jmp CHECK_UNPAUSE
	
  NO_HIT:
  	invoke RotateBlit, OFFSET galagaShot, (Shot PTR[esi]).x, (Shot PTR[esi]).y, (Shot PTR[esi]).angle
	invoke StoreBitRect, OFFSET galagaShot, (Shot PTR[esi]).x, (Shot PTR[esi]).y, (Shot PTR[esi]).rect
	dec ecx
	jne DRAW_SHOT
	
  DRAW_ENEMY:
	cmp enemy.is_shot, 0
	jne CHECK_UNPAUSE
	
	cmp enemy.x, 8
	jle ENEMY_RIGHT
	cmp enemy.x, 632
	jge ENEMY_LEFT
	cmp enemy.y, 8
	jle ENEMY_DOWN
	cmp enemy.y, 472
	jge ENEMY_UP
	
	invoke nrandom, 3
	dec eax
	sal eax, 3
	add enemy.x, eax
	invoke nrandom, 3
	dec eax
	sal eax, 3
	add enemy.y, eax
	jmp MOVE_ENEMY
	
  ENEMY_RIGHT:
	add enemy.x, 8
	jmp MOVE_ENEMY
  ENEMY_LEFT:
	sub enemy.x, 8
	jmp MOVE_ENEMY
  ENEMY_DOWN:
	add enemy.y, 8
	jmp MOVE_ENEMY
  ENEMY_UP:
	sub enemy.y, 8
	
  MOVE_ENEMY:	
	invoke BasicBlit, OFFSET yellowBug, enemy.x, enemy.y
	invoke StoreBitRect, OFFSET yellowBug, enemy.x, enemy.y, enemy.rect
	
	invoke nrandom, 10
	cmp eax, 0
	je NEW_SHOT
	cmp enemy.shots_fired, 0
	je IS_PLAYER_HIT
	jmp DRAW_ENEMY_SHOTS
	
  NEW_SHOT:
  	mov ecx, enemy.shots_fired
	inc enemy.shots_fired
	
	mov enemy.shots[ecx].vx, 5
	mov enemy.shots[ecx].vy, 0
	
	mov eax, enemy.x
	mov enemy.shots[ecx].x, eax
	
	mov eax, enemy.y
	mov enemy.shots[ecx].y, eax
	
  DRAW_ENEMY_SHOTS:
	mov ecx, enemy.shots_fired
	dec ecx
  ENEMY_SHOT_BODY:
	mov eax, enemy.shots[ecx].vx
	add enemy.shots[ecx].x, eax
	mov eax, enemy.shots[ecx].vy
	add enemy.shots[ecx].y, eax
	
;	mov eax, (Shot PTR[esi]).x
;	sub eax, enemy.x
;	invoke AbsVal, eax
;	cmp eax, 12
;	jge NO_HIT
;	mov eax, (Shot PTR[esi]).y
;	sub eax, enemy.y
;	invoke AbsVal, eax
;	cmp eax, 18
;	jge NO_HIT
;	shl (Shot PTR[esi]).x, 10
;	shl (Shot PTR[esi]).y, 10
;	inc enemy.is_shot
;	add score_num, 50
;	jmp CHECK_UNPAUSE
;	
;  PLAYER_ALIVE:
;	cmp enemy.shots[ecx].x, 0
;	jle ERASE_ENEMY_SHOT
;	cmp enemy.shots[ecx].x, 639
;	jge ERASE_ENEMY_SHOT
;	cmp enemy.shots[ecx].y, 0
;	jle ERASE_ENEMY_SHOT
;	cmp enemy.shots[ecx].y, 479
;	jge ERASE_ENEMY_SHOT
	
  	invoke RotateBlit, OFFSET galagaShot, enemy.shots[ecx].x, enemy.shots[ecx].y, 0
	;invoke StoreBitRect, OFFSET galagaShot, [OFFSET enemy + 13 + 36*ecx], [enemy + 17 + 36*ecx], (Shot PTR[esi]).rect
	jmp ENEMY_DECREMENT
	
;  ERASE_ENEMY_SHOT:
;	mov ebx, ecx
;	mov ecx, enemy.shots_fired
;	sub ecx, ebx
;  ERASE_BODY:
;	lea eax, enemy.shots[ecx+1]
;	lea edx, enemy.shots[ecx]
;	mov [edx], eax
;	inc ecx
;	cmp ecx, enemy.shots_fired
;	jle ERASE_BODY
	
;	dec enemy.shots_fired
;	mov ecx, ebx
;	dec ecx

	;mov ebx, ecx
	;mov ecx, enemy.shots_fired
	;sub ecx, ebx
	;dec enemy.shots_fired
	;mov edi, enemy.shots_fired
	;lea esi, [enemy.shots[ebx+1]]
	;lea edi, [enemy.shots[ebx]]
;		rep MOVSD
;	mov ecx, enemy.shots_fired
;	dec ecx
  ENEMY_DECREMENT:
	dec ecx
	cmp ecx, 0
	jge ENEMY_SHOT_BODY
	
  IS_PLAYER_HIT:
	mov eax, player_x
	sub eax, enemy.x
	invoke AbsVal, eax
	cmp eax, 30
	jge CHECK_UNPAUSE
	mov eax, player_y
	sub eax, enemy.y
	invoke AbsVal, eax
	cmp eax, 36
	jge CHECK_UNPAUSE
	jmp GAME_OVER
	
  PAUSED:
	mov paused, 1
	invoke BlackStarField
	invoke DrawStr, offset pause_message, 300, 240, 0ffh
  CHECK_UNPAUSE:
	cmp KeyPress, VK_SPACE
	jne DONE
	xor paused, 1
	jmp DONE
	
  START_SCREEN:
	invoke BlackStarField
	invoke BasicBlit, OFFSET galagaStart, 320, 240
	inc time
	jmp DONE
	
  GAME_OVER:
	inc player_hit
	invoke BlackStarField
	mov ecx, 10
	lea esi, score_string
	lea edi, end_message
	add edi, 24
		rep movsb
	invoke DrawStr, offset end_message, 240, 240, 0ffh
  DONE:
	
	ret         ;; Do not delete this line!!!
GamePlay ENDP
	

END
