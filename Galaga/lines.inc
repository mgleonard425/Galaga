; #########################################################################
;
;   lines.inc - Includes for Sine/Cosine and Line Drawing Procedures
;	Author: Prof. Russ Joseph, Northwestern University EECS
;
; #########################################################################

externdef SINTAB:WORD
externdef ScreenBitsPtr:DWORD

FixedSin proto angle:FXPT
FixedCos proto angle:FXPT
DrawLine proto x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
