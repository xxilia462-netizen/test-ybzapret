@echo off
title ybzapret - Select Strategy

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Run as Administrator!
    pause
    exit /b
)

set "BASE_DIR=%~dp0.."
set "BIN=%BASE_DIR%\bin\winws.exe"
set "LIST=%BASE_DIR%\configs\lists\blacklist.txt"

if not exist "%BIN%" (
    echo [ERROR] winws.exe not found in bin\ folder!
    pause
    exit /b
)

:STRAT_MENU
cls
echo =========================================
echo      ybzapret - Choose DPI Strategy
echo =========================================
echo.
echo  [1] ALT 1  (split2 + multisplit)
echo  [2] ALT 2  (fake + split2, TTL 4)
echo  [3] ALT 3  (fake + multisplit, badseq)
echo  [4] ALT 4  (disorder2 + autottl)
echo  [5] ALT 5  (fake + disorder2, md5sig)
echo  [6] ALT 6  (syndata + split2)
echo  [7] ALT 7  (fake + fakedsplit, TTL 5)
echo  [8] ALT 8  (multisplit + seqovl)
echo  [9] ALT 9  (Recommended: fake + multisplit + QUIC)
echo  [10] FAKE ONLY (pure fake packets, TTL 3)
echo  [0] Back to Main Menu
echo.
echo =========================================
set /p strat="Select strategy (0-10): "

if "%strat%"=="0" exit /b

if "%strat%"=="1" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --hostlist=\"%LIST%\" --dpi-desync=split2 --dpi-desync-split-pos=1" & goto RUN
if "%strat%"=="2" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --hostlist=\"%LIST%\" --dpi-desync=fake,split2 --dpi-desync-ttl=4" & goto RUN
if "%strat%"=="3" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --hostlist=\"%LIST%\" --dpi-desync=fake,multisplit --dpi-desync-fooling=badseq" & goto RUN
if "%strat%"=="4" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --hostlist=\"%LIST%\" --dpi-desync=disorder2 --dpi-desync-autottl=2" & goto RUN
if "%strat%"=="5" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --hostlist=\"%LIST%\" --dpi-desync=fake,disorder2 --dpi-desync-fooling=md5sig" & goto RUN
if "%strat%"=="6" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --hostlist=\"%LIST%\" --dpi-desync=syndata,split2" & goto RUN
if "%strat%"=="7" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --hostlist=\"%LIST%\" --dpi-desync=fake,fakedsplit --dpi-desync-ttl=5" & goto RUN
if "%strat%"=="8" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --hostlist=\"%LIST%\" --dpi-desync=multisplit --dpi-desync-split-seqovl=1" & goto RUN
if "%strat%"=="9" set "ARGS=--wf-tcp=80,443 --wf-udp=443,50000-50100 --filter-udp=443 --hostlist=\"%LIST%\" --dpi-desync=fake --dpi-desync-repeats=6 --new --filter-tcp=443 --hostlist=\"%LIST%\" --dpi-desync=fake,multisplit --dpi-desync-split-seqovl=2 --dpi-desync-fooling=badseq" & goto RUN
if "%strat%"=="10" set "ARGS=--wf-tcp=80,443 --wf-udp=443 --filter-tcp=443 --hostlist=\"%LIST%\" --dpi-desync=fake --dpi-desync-ttl=3" & goto RUN

echo [ERROR] Invalid strategy!
timeout /t 1 >nul
goto STRAT_MENU

:RUN
cls
echo [*] Stopping previous instances...
taskkill /F /IM winws.exe >nul 2>&1
echo [*] Starting ybzapret with Strategy #%strat%...
echo [*] Close this window or run Stop Bypass to disable.
echo.
start "ybzapret Engine (ALT %strat%)" "%BIN%" %ARGS%
echo [OK] Bypass is active!
timeout /t 2 >nul
exit /b
