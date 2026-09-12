@echo off
powershell -NoProfile -Command "$c=Get-NetTCPConnection -LocalPort 8000 -State Listen -ErrorAction SilentlyContinue; if($c){$c | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force; Write-Host 'RM Enterprises server stopped.' }} else { Write-Host 'No local server was running.' }"
pause
