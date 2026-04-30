@echo off
cd /d "%~dp0"
start "" bin\win64\zapret.exe --filter-tcp=443 --hostlist=configs/lists/youtube.txt --hostlist=configs/lists/discord.txt --desync-any-protocol
