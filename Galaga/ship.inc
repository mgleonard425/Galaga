; #########################################################################
;
;   ship.inc - Includes for the blueprint for a Galaga ship
;	Author: Michael Leonard
;
; #########################################################################

_Ship STRUCT
 x				DWORD  ?
 y				DWORD  ?
 angle			DWORD  ?
 is_shot		BYTE  0
 shots_fired	DWORD 0
 shots			Shot 10000 DUP(<>)
_Ship ENDS

Ship TYPEDEF _Ship

BalanceShots PROTO my_shots:PTR DWORD