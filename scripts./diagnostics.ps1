$Host.UI.RawUI.WindowTitle = "ybzapret - Network & Config Diagnostics"

$BaseDir = Resolve-Path "$PSScriptRoot\.."
$BinFile = Join-Path $BaseDir "bin\winws.exe"
$WinDivertSys = Join-Path $BaseDir "bin\WinDivert64.sys"
$ConfFile = Join-Path $BaseDir "ybzapret.conf"
$BlacklistFile = Join-Path $BaseDir "configs\lists\blacklist.txt"

function Test-Environment {
    Write-Host "=== 1. Checking Required Files ===" -ForegroundColor Cyan
    
    $files = @(
        @{ Name = "Config (ybzapret.conf)"; Path = $ConfFile },
        @{ Name = "Engine (winws.exe)"; Path = $BinFile },
        @{ Name = "Driver (WinDivert64.sys)"; Path = $WinDivertSys },
        @{ Name = "Domain List (blacklist.txt)"; Path = $BlacklistFile }
    )

    foreach ($item in $files) {
        if (Test-Path $item.Path) {
            Write-Host "[OK]   $($item.Name)" -ForegroundColor Green
        } else {
            Write-Host "[MISS] $($item.Name) -> Not found!" -ForegroundColor Red
        }
    }
    Write-Host ""
}

function Optimize-Blacklist {
    Write-Host "=== 2. Cleaning & Sorting blacklist.txt ===" -ForegroundColor Cyan
    if (-not (Test-Path $BlacklistFile)) {
        Write-Host "[ERROR] blacklist.txt not found." -ForegroundColor Red
        return
    }

    $rawLines = Get-Content $BlacklistFile
    $beforeCount = $rawLines.Count

    # Trim spaces, convert to lowercase, remove empty lines and duplicates
    $cleanLines = $rawLines | ForEach-Object { $_.Trim().ToLower() } | Where-Object { $_ -ne "" -and -not $_.StartsWith("#") } | Select-Object -Unique | Sort-Object

    $cleanLines | Set-Content -Path $BlacklistFile -Encoding UTF8
    $afterCount = $cleanLines.Count
    $removed = $beforeCount - $afterCount

    Write-Host "[OK] Optimization complete! Removed $removed duplicate/empty lines." -ForegroundColor Green
    Write-Host "[INFO] Total unique domains: $afterCount" -ForegroundColor Yellow
    Write-Host ""
}

function Test-Targets {
    Write-Host "=== 3. Testing Connection to Target Domains ===" -ForegroundColor Cyan
    $targets = @("youtube.com", "discord.com", "roblox.com")

    foreach ($site in $targets) {
        Write-Host "Checking $site ... " -NoNewline
        try {
            $response = Invoke-WebRequest -Uri "https://$site" -Method Head -TimeoutSec 4 -UseBasicParsing -ErrorAction Stop
            Write-Host "[REACHABLE] (HTTP $($response.StatusCode))" -ForegroundColor Green
        } catch {
            Write-Host "[BLOCKED / TIMEOUT]" -ForegroundColor Red
        }
    }
    Write-Host ""
}

# Menu loop
while ($true) {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "     ybzapret - Diagnostics & Tools      " -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Check files & drivers (winws / WinDivert)"
    Write-Host "2. Clean & sort blacklist.txt (remove duplicates)"
    Write-Host "3. Test connection (YouTube, Discord, Roblox)"
    Write-Host "4. Run ALL checks"
    Write-Host "0. Exit"
    Write-Host ""

    $opt = Read-Host "Select tool (0-4)"
    Clear-Host

    switch ($opt) {
        "1" { Test-Environment; Pause }
        "2" { Optimize-Blacklist; Pause }
        "3" { Test-Targets; Pause }
        "4" { Test-Environment; Optimize-Blacklist; Test-Targets; Pause }
        "0" { exit }
        default { Write-Host "Invalid choice." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}
