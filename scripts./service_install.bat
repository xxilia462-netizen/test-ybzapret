
@echo off
title ybzapret - Install Windows Service

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Please run this script as Administrator!
    pause
    exit /b
)

:: Paths (adjust if your exe or blacklist are in different folders)
set "BASE_DIR=%~dp0.."
set "BIN_PATH=%BASE_DIR%\bin\winws.exe"
set "LIST_PATH=%BASE_DIR%\configs\lists\blacklist.txt"
set "SERVICE_NAME=ybzapret"

echo =====================================
echo    Installing ybzapret Service...
echo =====================================
echo.

:: Check if winws.exe exists
if not exist "%BIN_PATH%" (
    echo [ERROR] File not found: %BIN_PATH%
    echo Make sure winws.exe is placed in the bin folder.
    pause
    exit /b
)

:: Remove old service if it already exists
sc query "%SERVICE_NAME%" >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Removing existing service...
    sc stop "%SERVICE_NAME%" >nul 2>&1
    sc delete "%SERVICE_NAME%" >nul 2>&1
    timeout /t 2 >nul
)

:: Create and start the new service with basic DPI bypass args
sc create "%SERVICE_NAME%" binPath= "\"%BIN_PATH%\" --wf-tcp=80,443 --wf-udp=443,50000-50100 --filter-tcp=443 --hostlist=\"%LIST_PATH%\" --dpi-desync=fake,split2 --dpi-desync-ttl=4" start= auto DisplayName= "ybzapret DPI Bypass" >nul

if %errorlevel% equ 0 (
    echo [OK] Service "%SERVICE_NAME%" created successfully!
    sc start "%SERVICE_NAME%" >nul
    if %errorlevel% equ 0 (
        echo [OK] Service started and running in background.
    ) else (
        echo [!] Service created, but failed to start. Check your arguments.
    )
) else (
    echo [ERROR] Failed to create Windows service.
)

echo.
pause
