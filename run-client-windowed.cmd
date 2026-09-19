@echo off
REM Launch only the repository client using its native windowed mode.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0client\gemnet_launch.ps1" -GamePath "%~dp0RF Client\RumbleFighter\RumbleFighter.exe" -Windowed
if errorlevel 1 pause
