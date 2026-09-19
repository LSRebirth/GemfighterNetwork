@echo off
REM Double-clickable Windows launcher for the Gemnet server emulator.
REM Delegates to run-server.ps1 (the real launcher). Pass -SkipDbCheck etc. straight through.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-server.ps1" %*
if errorlevel 1 pause
