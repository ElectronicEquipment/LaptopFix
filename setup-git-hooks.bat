@echo off
setlocal

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-git-hooks.ps1"

if errorlevel 1 (
    echo.
    echo Failed to install Git hooks.
    exit /b 1
)

echo.
echo Git hooks installed successfully.
pause