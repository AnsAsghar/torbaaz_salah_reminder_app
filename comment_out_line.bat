@echo off
echo Commenting out the problematic bigLargeIcon line...
powershell -ExecutionPolicy Bypass -File comment_out_line.ps1
pause
