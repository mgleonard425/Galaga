; #########################################################################
;
;   game.inc - Main includes for Galaga
;	Author: Prof. Russ Joseph, Northwestern University EECS
;
; #########################################################################

;; Library Definitions
MouseInfo STRUCT
 horiz DWORD ?
 vert  DWORD ?
 buttons DWORD ?
MouseInfo ENDS


_Enemy STRUCT
 x				DWORD  ?
 y				DWORD  ?
 angle			DWORD  ?
 is_shot		BYTE  0
 shots_fired	DWORD 0
 shots 			Shot 10000 DUP(<>)
_Enemy ENDS

Enemy TYPEDEF _Enemy

MK_CONTROL  = 0008h  ;; The CTRL key is down.
MK_LBUTTON  = 0001h  ;; The left mouse button is down.
MK_MBUTTON  = 0010h  ;; The middle mouse button is down.
MK_RBUTTON  = 0002h  ;; The right mouse button is down.
MK_SHIFT    = 0004h  ;; The SHIFT key is down.
MK_XBUTTON1 = 0020h  ;; The first X button is down.
MK_XBUTTON2 = 0040h  ;; The second X button is down.

;; Library Functions
BlackStarField	PROTO
DrawStr PROTO myStr:PTR BYTE, x:DWORD, y:DWORD, color:DWORD

;; Library Data
EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF galagaStart:EECS205BITMAP
EXTERNDEF galagaShip:EECS205BITMAP
EXTERNDEF galagaShot:EECS205BITMAP
EXTERNDEF yellowBug:EECS205BITMAP

EXTERNDEF MouseStatus:MouseInfo
EXTERNDEF KeyUp:DWORD
EXTERNDEF KeyDown:DWORD
EXTERNDEF KeyPress:DWORD

;; User Defined Functions
GameInit PROTO
GamePlay PROTO






