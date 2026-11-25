$Host.UI.RawUI.WindowTitle = "ybzapret - Binary Updater"

$BaseDir = Resolve-Path "$PSScriptRoot\.."
$BinDir = Join-Path $BaseDir "bin"
$TempZip = Join-Path $env:TEMP "zapret-win-bundle.zip"
$TempExtract = Join-Path $env:TEMP "zapret-extract"

# Official zapret-win-bundle repository URL
$BundleUrl = "https://github.com"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "   ybzapret - Downloading Engine Files   " -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Ensure bin directory exists
if (-not (Test-Path $BinDir)) {
    New-Item -ItemType Directory -Path $BinDir -Force | Out-Null
}

try {
    Write-Host "[1/4] Downloading zapret-win-bundle from GitHub..." -ForegroundColor Yellow
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri $BundleUrl -OutFile $TempZip -UseBasicParsing

    Write-Host "[2/4] Extracting archive..." -ForegroundColor Yellow
    if (Test-Path $TempExtract) { Remove-Item $TempExtract -Recurse -Force }
    Expand-Archive -Path $TempZip -DestinationPath $TempExtract -Force

    Write-Host "[3/4] Copying winws.exe and WinDivert drivers to bin\..." -ForegroundColor Yellow
    $WinwsFolder = Get-ChildItem -Path $TempExtract -Recurse -Filter "winws.exe" | Select-Object -First 1 -ExpandProperty DirectoryName

    if ($WinwsFolder) {
        Copy-Item -Path "$WinwsFolder\*" -Destination $BinDir -Force
        Write-Host "[OK] Engine files successfully installed to: $BinDir" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] Could not locate winws.exe inside the downloaded archive." -ForegroundColor Red
    }

    Write-Host "[4/4] Cleaning up temporary files..." -ForegroundColor Yellow
    Remove-Item $TempZip -Force -ErrorAction SilentlyContinue
    Remove-Item $TempExtract -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "Done! Ready to launch." -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to download files: $($_.Exception.Message)" -ForegroundColor Red
}

Pause
