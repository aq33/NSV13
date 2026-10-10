@echo off
rem Buduje gałąź byond-516 kompilatorem 516 i uruchamia serwer oraz klienta 516.
setlocal
set "BYOND516=C:\Program Files (x86)\byond 516\BYOND\bin"
cd /d "%~dp0"

echo === Zamykam stare procesy BYOND ===
taskkill /F /IM dreamdaemon.exe >nul 2>&1
taskkill /F /IM dreamseeker.exe >nul 2>&1
taskkill /F /IM byond.exe >nul 2>&1

echo === Budowanie (TGUI + DM) kompilatorem 516 ===
set "DM_EXE=%BYOND516%\dm.exe"
call tools\build\build.bat
if errorlevel 1 (
	echo.
	echo BLAD BUDOWANIA - zobacz komunikaty powyzej.
	pause
	exit /b 1
)

echo === Start serwera 516 na porcie 1337 ===
start "" "%BYOND516%\dreamdaemon.exe" "%~dp0nsv13.dmb" 1337 -trusted

echo Czekam 70 s na inicjalizacje serwera...
timeout /t 70 /nobreak >nul

echo === Start klienta 516 ===
start "" "%BYOND516%\dreamseeker.exe" byond://127.0.0.1:1337
endlocal
