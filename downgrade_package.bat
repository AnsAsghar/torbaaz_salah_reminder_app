@echo off
echo Downgrading flutter_local_notifications package...
powershell -ExecutionPolicy Bypass -File downgrade_package.ps1
pause
