@echo off
rem Run as administrator to refresh the Windows firewall and router mappings.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Tools\Enable-PublicServer.ps1"
if errorlevel 1 (
    pause
    exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-local-server.ps1"
pause
