; #########################################################################
;
;   shot.inc - Includes for Galaga shot
;	Author: Michael Leonard
;
; #########################################################################

_Shot STRUCT
 x			DWORD  ?
 y			DWORD  ?
 angle		DWORD  ?
 vx			DWORD  ?
 vy			DWORD  ?
_Shot ENDS

Shot TYPEDEF _Shot