echo off
set path=%path%;c:\masm32\bin
ml  /c  /coff  /Cp stars.asm || goto :error
ml  /c  /coff  /Cp lines.asm || goto :error
ml  /c  /coff  /Cp blit.asm || goto :error
ml  /c  /coff  /Cp shot.asm || goto :error
ml  /c  /coff  /Cp ship.asm || goto :error
ml  /c  /coff  /Cp player.asm || goto :error
ml  /c  /coff  /Cp game.asm || goto :error
ml  /c  /coff  /Cp galagaShip.asm || goto :error
ml  /c  /coff  /Cp galagaShot.asm || goto :error
ml  /c  /coff  /Cp yellowBug.asm || goto :error
ml  /c  /coff  /Cp galagaStart.asm || goto :error

link /SUBSYSTEM:WINDOWS  /LIBPATH:c:\masm32\lib game.obj player.obj ship.obj shot.obj blit.obj lines.obj stars.obj galagaShip.obj galagaShot.obj yellowBug.obj galagaStart.obj libgame.obj || goto :error

pause
	echo Executable built succesfully.
goto :EOF

:error
echo Failed with error #%errorlevel%
pause



