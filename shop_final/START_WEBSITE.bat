@echo off
setlocal
cd /d "%~dp0"
set PORT=8000

echo ============================================
echo   RM ENTERPRISES - WEBSITE SERVER
echo ============================================
echo.

echo Checking port %PORT%...
powershell -NoProfile -Command "$c=Get-NetTCPConnection -LocalPort %PORT% -State Listen -ErrorAction SilentlyContinue; if($c){exit 0}else{exit 1}" >nul 2>&1
if %errorlevel%==0 (
  echo A server is already running on port %PORT%.
  start "" "http://127.0.0.1:%PORT%/index.html"
  exit /b 0
)

echo Starting built-in Windows PowerShell server...
start "RM Enterprises Server" powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0server.ps1" -Port %PORT%

echo Waiting for server...
for /l %%i in (1,1,20) do (
  powershell -NoProfile -Command "$c=Get-NetTCPConnection -LocalPort %PORT% -State Listen -ErrorAction SilentlyContinue; if($c){exit 0}else{exit 1}" >nul 2>&1
  if not errorlevel 1 goto READY
  timeout /t 1 /nobreak >nul
)
echo.
echo ERROR: The local server did not start.
echo Please take a screenshot of this window and send it to me.
pause
exit /b 1

:READY
echo Server is ready!
echo Opening website...
start "" "http://127.0.0.1:%PORT%/index.html"
echo.
echo KEEP the black server window open while using the website.
echo.
endlocal
