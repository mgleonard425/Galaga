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

include stars.inc
include lines.inc
include blit.inc
include game.inc
include keys.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\masm32.lib
	
.DATA

galagaShip EECS205BITMAP <36, 36, 0,, offset galagaShip + sizeof galagaShip>
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,020h
	BYTE 020h,020h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,096h,096h,0b6h,0b6h,0b6h,0b6h,096h,092h,0b6h,096h,092h,0b2h
	BYTE 0b6h,08dh,064h,064h,069h,044h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,0dfh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0f2h,0c5h,0e9h,0e8h,0a4h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0b2h,0b7h,0dfh,0dfh
	BYTE 0dfh,0ffh,0ffh,0fbh,0dbh,092h,096h,092h,0b2h,0a9h,080h,0c0h,0c0h,080h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,072h,0ffh,0ffh,0ffh,0ffh,0dfh,0dfh,0b6h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,06dh,0dbh,0dbh,0ffh,0ffh,0dfh,0dfh,0dah,06dh,06dh,024h
	BYTE 024h,020h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,028h,0dbh,0ffh,0ffh,0ffh
	BYTE 0dfh,0ffh,0dbh,029h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,049h
	BYTE 0dfh,0dbh,0ffh,0ffh,0ffh,0ffh,0dfh,06dh,000h,000h,000h,000h,004h,024h,020h,020h
	BYTE 020h,020h,020h,020h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,049h,045h,0b7h,0ffh,0ffh,0ffh,0dfh,0bfh,0bbh,052h,009h,053h
	BYTE 0dbh,0dbh,0dbh,0d6h,0a9h,0a4h,0c4h,0c4h,045h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0b6h,0dfh,0ffh,0ffh,0dfh,0dfh
	BYTE 0dfh,04eh,009h,077h,0ffh,0ffh,0ffh,0ffh,0adh,0a4h,0e9h,0c9h,045h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,040h,084h,0a4h,0a4h,080h,0f6h,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0fbh,0b7h,097h,097h,077h,097h,072h,092h,069h,044h,064h,044h
	BYTE 040h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,064h,0c9h,0c9h
	BYTE 0c9h,0a4h,0f6h,0ffh,0ffh,0fbh,0ffh,0ffh,0ffh,0ffh,0dfh,09bh,005h,005h,000h,000h
	BYTE 000h,020h,000h,000h,020h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,084h,0c9h,0e8h,0e4h,0e4h,0edh,0f2h,0fbh,0ffh,0dfh,0ffh,0ffh,0ffh,0ffh,0dbh
	BYTE 0bah,0b6h,0b6h,0b2h,000h,004h,024h,020h,020h,020h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,064h,0c9h,0e4h,0e4h,0e0h,0c0h,080h,0d6h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0dfh,0dfh,0ffh,0dbh,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,044h,089h,089h,0b1h,0cdh,0d2h,0b2h
	BYTE 0d7h,0ffh,0fbh,0f6h,0f6h,0f6h,0f6h,0fbh,0ffh,0ffh,0ffh,0dbh,06dh,08eh,06dh,06eh
	BYTE 071h,071h,071h,06dh,06dh,024h,000h,000h,000h,000h,000h,000h,000h,020h,020h,064h
	BYTE 0fah,0fbh,0fbh,0fbh,0ffh,0ffh,0fah,084h,0a9h,0a9h,084h,0d2h,0ffh,0ffh,0dfh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0dfh,0dfh,0ffh,0ffh,0dbh,049h,000h,000h,000h,000h,000h,000h
	BYTE 004h,024h,000h,049h,0dfh,0dfh,0dfh,0ffh,0ffh,0dfh,0fah,080h,0a4h,0e9h,0e4h,0edh
	BYTE 0fbh,0fbh,0ffh,0dfh,0ffh,0ffh,0dfh,0ffh,0ffh,0ffh,0dfh,0ffh,0ffh,06dh,000h,024h
	BYTE 024h,024h,024h,024h,0dbh,0dbh,0dbh,0dbh,0dfh,0dfh,0ffh,0ffh,0ffh,0dfh,0fbh,0f6h
	BYTE 0f2h,0e9h,0e4h,0c9h,0cdh,0d6h,0ffh,0dfh,0ffh,0ffh,0ffh,0dfh,0ffh,0ffh,0ffh,0dfh
	BYTE 0ffh,0dbh,0dbh,0dbh,0dbh,0dbh,0dbh,0b6h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dfh
	BYTE 0ffh,0dfh,0ffh,0ffh,0fbh,0e9h,0e5h,0c9h,0a0h,0cdh,0ffh,0dfh,0ffh,0fbh,0ffh,0dfh
	BYTE 0ffh,0dfh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,092h,092h,092h,092h
	BYTE 0ffh,0ffh,0ffh,0ffh,0fbh,0dfh,0fbh,0d2h,0f2h,0e9h,0c4h,0edh,0f2h,0f6h,0ffh,0dfh
	BYTE 0ffh,0ffh,0ffh,0ffh,0dfh,0ffh,0dfh,0ffh,0ffh,0b6h,092h,092h,092h,092h,092h,06dh
	BYTE 000h,000h,000h,040h,0fbh,0ffh,0ffh,0ffh,0ffh,0ffh,0f6h,0a0h,0a0h,0c4h,0a0h,0f1h
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dfh,0ffh,0dfh,0ffh,0ffh,049h,000h,000h
	BYTE 000h,000h,000h,000h,000h,024h,044h,089h,0d6h,0fbh,0dbh,0b6h,0fbh,0ffh,0fbh,0edh
	BYTE 0edh,0edh,0e9h,0f2h,0ffh,0ffh,0ffh,0ffh,0dbh,0dbh,0b7h,0bbh,0bbh,0bbh,0bbh,0dbh
	BYTE 0b6h,049h,000h,000h,000h,000h,000h,000h,000h,064h,0c9h,0e4h,0e4h,0c0h,0c4h,0c0h
	BYTE 0d7h,0ffh,0ffh,0ffh,0dfh,0dfh,0ffh,0dfh,0ffh,0ffh,0ffh,0b6h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,064h,0c9h,0e4h
	BYTE 0e4h,0e5h,0e5h,0c1h,0d6h,0ffh,0ffh,0ffh,0dfh,0ffh,0ffh,0dfh,0dbh,0fbh,0ffh,0dbh
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,064h,0c9h,0c4h,0e9h,0c4h,0d2h,0fbh,0dfh,0dfh,0ffh,0ffh,0ffh,0ffh,0ffh,0bbh
	BYTE 012h,032h,049h,045h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,044h,0a9h,0c4h,0e9h,0a4h,0f6h,0ffh,0ffh,0dfh,0ffh,0ffh
	BYTE 0ffh,0dbh,0dbh,0bbh,00eh,009h,000h,000h,000h,004h,000h,000h,020h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,044h,024h,024h,000h,0d6h,0ffh
	BYTE 0ffh,0ffh,0ffh,0dfh,0dfh,072h,02eh,057h,0dbh,0dfh,0dbh,0dah,0a9h,0a4h,0c4h,0c4h
	BYTE 044h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,000h,000h
	BYTE 000h,000h,0b6h,0ffh,0ffh,0ffh,0ffh,0dfh,0dfh,052h,009h,077h,0ffh,0ffh,0ffh,0fbh
	BYTE 0cdh,0c5h,0e9h,0e5h,065h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,044h,0b2h,096h,0dbh,0ffh,0ffh,0ffh,0ffh,096h,072h,029h,004h,04dh
	BYTE 092h,092h,092h,091h,069h,044h,064h,068h,020h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,004h,000h,000h,044h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,049h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,020h,020h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,024h,06dh,072h,0dfh,0ffh,0dfh,0ffh
	BYTE 0dfh,0b7h,0b6h,045h,000h,000h,000h,000h,020h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,092h,0ffh,0ffh
	BYTE 0dfh,0ffh,0ffh,0dfh,0bbh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,092h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0b7h,000h,000h,000h,000h,020h,040h,040h
	BYTE 020h,040h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,0dbh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dbh,0dfh,0dbh
	BYTE 0fbh,0b2h,084h,0a9h,0a9h,084h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0dbh,0dbh,0dbh,0ffh,0ffh,0dbh,0ffh
	BYTE 0dbh,0ffh,0ffh,0ffh,0fbh,0d2h,089h,0a9h,0a9h,084h,000h,000h,000h,000h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,024h,024h,049h,049h
	BYTE 049h,049h,049h,049h,049h,025h,024h,049h,044h,044h,040h,060h,040h,040h,000h,000h
	BYTE 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h

end