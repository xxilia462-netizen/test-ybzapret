
$Host.UI.RawUI.WindowTitle = "ybzapret - Lists & Folders Generator"

# Base paths relative to scripts folder
$BaseDir = Resolve-Path "$PSScriptRoot\.."
$ConfigsDir = Join-Path $BaseDir "configs"
$ListsDir = Join-Path $ConfigsDir "lists"
$BinDir = Join-Path $BaseDir "bin"

# Predefined domain lists
$YoutubeDomains = @(
    "youtube.com",
    "youtu.be",
    "googlevideo.com",
    "ytimg.com",
    "ggpht.com",
    "://googleapis.com"
)

$DiscordDomains = @(
    "discord.com",
    "discordapp.com",
    "discordapp.net",
    "discord.gg",
    "discord.media",
    "://discordapp.com",
    "gateway.discord.gg"
)

$RobloxDomains = @(
    "roblox.com",
    "rbxcdn.com",
    "robloxlabs.com",
    "rbxinfra.net"
)

function Ensure-Folders {
    $folders = @($ConfigsDir, $ListsDir, $BinDir)
    foreach ($folder in $folders) {
        if (-not (Test-Path $folder)) {
            New-Item -ItemType Directory -Path $folder -Force | Out-Null
            Write-Host "[CREATED] Folder: $folder" -ForegroundColor Green
        } else {
            Write-Host "[OK] Folder exists: $folder" -ForegroundColor DarkGray
        }
    }
}

function Write-DomainList {
    param (
        [string]$FileName,
        [string[]]$Domains
    )
    $FilePath = Join-Path $ListsDir $FileName
    $Domains | Set-Content -Path $FilePath -Encoding UTF8
    Write-Host "[OK] Saved $FileName ($($Domains.Count) domains)" -ForegroundColor Cyan
}

Clear-Host
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   ybzapret - Folders & Lists Setup      " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Create folder structure automatically
Ensure-Folders
Write-Host ""

# 2. Menu for generating lists
Write-Host "Select which domain lists to generate in configs\lists\:"
Write-Host "1. Generate ALL separate lists (youtube.txt, discord.txt, roblox.txt)"
Write-Host "2. Generate ONE combined blacklist.txt (All-in-One)"
Write-Host "3. Create empty custom list"
Write-Host "0. Exit"
Write-Host ""

$choice = Read-Host "Enter option (0-3)"

switch ($choice) {
    "1" {
        Write-DomainList -FileName "youtube.txt" -Domains $YoutubeDomains
        Write-DomainList -FileName "discord.txt" -Domains $DiscordDomains
        Write-DomainList -FileName "roblox.txt" -Domains $RobloxDomains
    }
    "2" {
        $AllDomains = $YoutubeDomains + $DiscordDomains + $RobloxDomains
        Write-DomainList -FileName "blacklist.txt" -Domains $AllDomains
    }
    "3" {
        $customName = Read-Host "Enter list filename (e.g., games.txt)"
        if (-not [string]::IsNullOrWhiteSpace($customName)) {
            if (-not $customName.EndsWith(".txt")) { $customName += ".txt" }
            $customPath = Join-Path $ListsDir $customName
            if (-not (Test-Path $customPath)) {
                New-Item -ItemType File -Path $customPath -Force | Out-Null
                Write-Host "[OK] Created empty list: $customName" -ForegroundColor Green
            } else {
                Write-Host "[!] File $customName already exists." -ForegroundColor Yellow
            }
        }
    }
    "0" { exit }
    default { Write-Host "[ERROR] Invalid option." -ForegroundColor Red }
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
Pause
