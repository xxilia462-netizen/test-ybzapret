
@echo off
title ybzapret - Stop Bypass

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please run this script as Administrator!
    pause
    exit /b
)

echo =====================================
echo       Stopping ybzapret service...
echo =====================================
echo.

:: Kill main bypass process
taskkill /F /IM winws.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Process winws.exe stopped.
) else (
    echo [-] Process winws.exe was not running.
)

:: Stop and remove WinDivert driver services
sc stop WinDivert >nul 2>&1
sc delete WinDivert >nul 2>&1
sc stop WinDivert14 >nul 2>&1
sc delete WinDivert14 >nul 2>&1
echo [OK] WinDivert drivers unloaded.

echo.о
echo Done! Network settings restored.
timeout /t 3 >nul
