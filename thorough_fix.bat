@echo off
echo Finding and commenting out ALL instances of bigLargeIcon...
powershell -ExecutionPolicy Bypass -File thorough_fix.ps1
pause
