; #########################################################################
;
;   game.asm - Main assembly file for Galage
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
include player.inc
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
	
	player Player<>
	
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
	;;The result is stored in player.angle
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
;	mov player.angle, eax
	
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

FindSpriteAngle PROC USES edx ecx ebx my_x:DWORD, my_y:DWORD, target_x:DWORD, target_y:DWORD
	LOCAL x:DWORD, y:DWORD

  ;;Here, we rotate the sprite to face the mouse
  ;;We treat the sprite as the origin of a polar coordinate plane
  ;;And the mouse as a coordinate point in that coordinate plane
	
	mov edx, target_x
	sub edx, my_x						;;edx = horizontal distance from sprite to target
	mov x, edx
	
	mov ecx, target_y
	sub ecx, my_y						;;ecx = vertical distance from sprite to target
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
	jmp DONE
	
  ;;Now we know the quadrant that the mouse is in
  ;;And we have the absolute value of the x and y coordinates of the mouse
  ;;So we can divide the y coordinate by the x coordinate
  ;;Which will give us the sine of the mouse's reference angle
  
  
  LEFT_OR_RIGHT:
	cmp x, 0
	jl LEFT 					;jump if the mouse is left of sprite, otherwise continue
	je DONE						;jump if the mouse is on the sprite, otherwise continue
  RIGHT:
	mov eax, 0					;Mouse is directly right of sprite, so sprite faces directly right
	jmp DONE
  LEFT:
	mov eax, PI					;Mouse is directly left of sprite, so sprite faces directly left
	jmp DONE
	
  UP_OR_DOWN:
	cmp y, 0
	jl BELOW					;jump if the mouse is below the sprite, otherwise continue
	je DONE						;jump if the mouse is on the sprite, otherwise continue
  ABOVE:
	mov eax, PI_HALF			;Mouse is directly above sprite, so sprite faces directly upward
	jmp DONE
  BELOW:
	mov eax, PI_HALF
	neg eax						;Mouse is directly below sprite, so sprite faces directly downward
	
  DONE:
	ret
FindSpriteAngle ENDP


GameInit PROC USES edx
	rdtsc
	invoke nseed, eax
	
	invoke BasicBlit, OFFSET galagaStart, 320, 240
	invoke PlaySound, OFFSET themeSong, 0, SND_FILENAME OR SND_ASYNC
	
	mov player.x, 300
	mov player.y, 400
	mov player.angle, PI_HALF
	mov player.is_shot, 0
	
	mov enemy.x, 300
	mov enemy.y, 100
	ret         ;; Do not delete this line!!!
GameInit ENDP

GamePlay PROC USES edx ecx ebx esi edi
	LOCAL x:DWORD, y:DWORD
	
	xor eax, eax
	
	cmp player.is_shot, 0
	jne DONE
	cmp time, 120
	jl START_SCREEN
	
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
	cmp player.x, 0
	jg MOVE_LEFT
	mov player.x, 639
	jmp ROTATE
  MOVE_LEFT:
	sub player.x, 5
	jmp ROTATE
	
  KEY_RIGHT:
	cmp player.x, 639
	jl MOVE_RIGHT
	mov player.x, 0
	jmp ROTATE
  MOVE_RIGHT:
	add player.x, 5
	jmp ROTATE
	
  KEY_DOWN:
	cmp player.y, 479
	jl MOVE_DOWN
	mov player.y, 0
	jmp ROTATE
  MOVE_DOWN:
	add player.y, 5
	jmp ROTATE

	
  KEY_UP:
	cmp player.y, 0
	jg MOVE_UP
	mov player.y, 479
	jmp ROTATE
  MOVE_UP:
	sub player.y, 5
	jmp ROTATE

  ROTATE:
	invoke FindSpriteAngle, player.x, player.y, MouseStatus.horiz, MouseStatus.vert
	mov player.angle, eax
	jmp IS_CLICKED

	
  SHOTS_FIRED:
	mov eax, TYPE player.shots
	mov ecx, shots_on_screen
	mul ecx
	add eax, OFFSET player.shots
	mov esi, eax
	inc shots_on_screen
	
	mov eax, player.x
	mov (Shot PTR[esi]).x, eax
	
	mov eax, player.y
	mov (Shot PTR[esi]).y, eax
	
	mov eax, player.angle
	mov (Shot PTR[esi]).angle, eax
	
	;Compute v_x
	invoke FixedCos, player.angle
	invoke AbsVal, eax
	shr eax, 12							;Multiply by 16 and convert to int
	cmp quadrant, 1
	je SET_VX
	cmp quadrant, 4
	je SET_VX
	neg eax
  SET_VX:
	mov (Shot PTR[esi]).vx, eax
	
	;Compute v_y
	invoke FixedSin, player.angle
	invoke AbsVal, eax
	shr eax, 12							;Multiply by 16 and convert to int
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
	
	invoke RotateBlit, OFFSET galagaShip, player.x, player.y, player.angle
	
	mov ecx, shots_on_screen
	cmp ecx, 0
	je DRAW_ENEMY
	
  DRAW_SHOT:
	mov eax, TYPE player.shots
	mul ecx
	add eax, OFFSET player.shots
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
	invoke FindSpriteAngle, enemy.x, enemy.y, player.x, player.y
	mov enemy.angle, eax
	invoke RotateBlit, OFFSET yellowBug, enemy.x, enemy.y, enemy.angle
	
	invoke nrandom, 20					;eax = random int between 0 and 19
	cmp eax, 0							;if eax = 0, fire a new shot
	je NEW_SHOT							;jump to new shot
	cmp enemy.shots_fired, 0			;if no shots on screen, skip drawing shots
	je IS_PLAYER_HIT
	jmp DRAW_ENEMY_SHOTS				;otherwise, draw the new shots
	
  NEW_SHOT:
	mov eax, TYPE enemy.shots
	mov ecx, enemy.shots_fired
	mul ecx
	add eax, OFFSET enemy.shots
	mov esi, eax

  	mov ecx, enemy.shots_fired			;ecx = number of shots previously fired
	inc enemy.shots_fired
	
	;Compute v_x
	invoke FixedCos, enemy.angle
	invoke AbsVal, eax
	shr eax, 12							;Multiply by 16 and convert to int
	cmp quadrant, 1
	je SET_ENEMY_VX
	cmp quadrant, 4
	je SET_ENEMY_VX
	neg eax
  SET_ENEMY_VX:
	mov (Shot PTR[esi]).vx, eax
	
	;Compute v_y
	invoke FixedSin, enemy.angle
	invoke AbsVal, eax
	shr eax, 12							;Multiply by 16 and convert to int
	cmp quadrant, 1
	je SET_ENEMY_VY
	cmp quadrant, 2
	je SET_ENEMY_VY
	neg eax
  SET_ENEMY_VY:
	mov (Shot PTR[esi]).vy, eax
	
	mov eax, enemy.x
	mov (Shot PTR[esi]).x, eax
	mov eax, enemy.y
	mov (Shot PTR[esi]).y, eax
	
  DRAW_ENEMY_SHOTS:
	mov ecx, enemy.shots_fired
	dec ecx
	mov eax, TYPE enemy.shots
	mul ecx
	mov ecx, OFFSET enemy.shots
	add eax, ecx
	mov esi, eax
  ENEMY_SHOT_BODY:
	mov eax, (Shot PTR[esi]).vx
	add (Shot PTR[esi]).x, eax
	mov eax, (Shot PTR[esi]).vy
	add (Shot PTR[esi]).y, eax
	
  	invoke RotateBlit, OFFSET galagaShot, (Shot PTR[esi]).x, (Shot PTR[esi]).y, enemy.angle
	
	;check if the shot hit the player
	mov eax, player.x
	sub eax, (Shot PTR[esi]).x
	invoke AbsVal, eax
	cmp eax, 22
	jge ENEMY_DECREMENT
	mov eax, player.y
	sub eax, (Shot PTR[esi]).y
	invoke AbsVal, eax
	cmp eax, 19
	jge ENEMY_DECREMENT
	jmp GAME_OVER
	
  ENEMY_DECREMENT:
  	sub esi, TYPE enemy.shots
	cmp esi, ecx
	jge ENEMY_SHOT_BODY
	
  IS_PLAYER_HIT:
	mov eax, player.x
	sub eax, enemy.x
	invoke AbsVal, eax
	cmp eax, 30
	jge CHECK_UNPAUSE
	mov eax, player.y
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
	inc player.is_shot
	invoke BlackStarField
	mov ecx, 10
	mov esi, OFFSET score_string
	mov edi, OFFSET end_message
	add edi, 24
		rep movsb
	invoke DrawStr, offset end_message, 240, 240, 0ffh
  DONE:
	
	ret         ;; Do not delete this line!!!
GamePlay ENDP
	

END
