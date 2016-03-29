; #########################################################################
;
;   player.inc - Includes for Galaga player
;	Author: Michael Leonard
;
; #########################################################################

_Player STRUCT
 x				DWORD  ?
 y				DWORD  ?
 angle			DWORD  ?
 is_shot		BYTE  0
 shots_fired	DWORD 0
 shots			Shot 10000 DUP(<>)
_Player ENDS

Player TYPEDEF _Player