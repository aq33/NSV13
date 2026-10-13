@echo off
rem Builds the game with BYOND 516 and starts a local 516 server and client.
rem BYOND 516 is found automatically: the BYOND516 variable (path to its bin folder),
rem the usual install folders, the registry, or the copy the build downloads into tools\bootstrap\.cache.
rem .gitattributes keeps .bat files with LF endings, so this script uses no labels or goto.
rem The BYOND path may contain "(x86)", which breaks ( ) blocks when expanded with %%, hence delayed expansion.
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set "BYOND_BIN="
set "PF86=%ProgramFiles(x86)%"
for %%D in ("!BYOND516!" "!PF86!\byond 516\BYOND\bin" "!PF86!\BYOND\bin" "!ProgramFiles!\BYOND\bin" "!ProgramFiles!\byond 516\BYOND\bin") do (
	if not defined BYOND_BIN if exist "%%~D\dreamdaemon.exe" (
		"%%~D\dm.exe" 2>&1 | findstr /c:"version 516" >nul && set "BYOND_BIN=%%~D"
	)
)
for %%K in ("HKLM\SOFTWARE\WOW6432Node\Dantom\BYOND" "HKLM\SOFTWARE\Dantom\BYOND" "HKCU\Software\Dantom\BYOND") do (
	for /f "skip=2 tokens=2,*" %%A in ('reg query %%K /v installpath 2^>nul') do (
		if not defined BYOND_BIN if exist "%%B\bin\dreamdaemon.exe" (
			"%%B\bin\dm.exe" 2>&1 | findstr /c:"version 516" >nul && set "BYOND_BIN=%%B\bin"
		)
	)
)

echo === Closing old BYOND processes ===
taskkill /F /IM dreamdaemon.exe >nul 2>&1
taskkill /F /IM dreamseeker.exe >nul 2>&1
taskkill /F /IM byond.exe >nul 2>&1

if defined BYOND_BIN set "DM_EXE=%BYOND_BIN%\dm.exe"
if defined BYOND_BIN echo === BYOND 516: %BYOND_BIN% ===
if not defined BYOND_BIN echo === BYOND 516 not installed, the build will download it into tools\bootstrap\.cache ===

echo === Building (TGUI + DM) ===
call tools\build\build.bat
if errorlevel 1 (
	echo.
	echo BUILD FAILED - see the messages above.
	pause
	exit /b 1
)

if not defined BYOND_BIN for /d %%D in ("tools\bootstrap\.cache\byond-516.*") do (
	if exist "%%~fD\byond\bin\dreamdaemon.exe" set "BYOND_BIN=%%~fD\byond\bin"
)
if not defined BYOND_BIN (
	echo.
	echo BYOND 516 not found. Install it or set BYOND516 to its bin folder.
	pause
	exit /b 1
)

echo === Starting the 516 server on port 1337 ===
start "" "%BYOND_BIN%\dreamdaemon.exe" "%~dp0nsv13.dmb" 1337 -trusted

echo Waiting 70 s for the server to initialize...
timeout /t 70 /nobreak >nul

echo === Starting the 516 client ===
start "" "%BYOND_BIN%\dreamseeker.exe" byond://127.0.0.1:1337
endlocal
