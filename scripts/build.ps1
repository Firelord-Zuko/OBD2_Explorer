# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 26, 2025
# File: build.ps1
# Description: Builds and launches the OBD-II Explorer Docker image
#              in cached mode with local model and database mounts.
# ===============================================================

# ===============================================================
# 🚗  OBD-II Explorer | Build Script v1.0.0
# ===============================================================

Clear-Host
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "   ___  ____  ____     ___    ____  ____  ____  _      ____  ____" -ForegroundColor Cyan
Write-Host "  / _ \/ ___||  _ \   / _ \  | __ )/  _ \| _  \| |    / ___||  _ \" -ForegroundColor Cyan
Write-Host " | | | \___ \| | | | | | | | | |_) | | | | |_) | |    \___ \| |_) |" -ForegroundColor Cyan
Write-Host " | |_| |___) | |_| | | |_| | | |_) | |_| |  _ <| |___  ___) |  __/" -ForegroundColor Cyan
Write-Host "  \___/|____/|____/   \___/  |____/ \___/|_| \_\_____||____/|_|" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "               🔧  OBD-II Explorer Build Script (Cached Mode)" -ForegroundColor Yellow
Write-Host ""

# -----------------------------------------
# Configuration
# -----------------------------------------
$ErrorActionPreference = "Stop"
$ScriptRoot     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot    = Resolve-Path "$ScriptRoot\.."
$ImageName      = "obd2_explorer"
$ContainerName  = "obd2_explorer"
$DatabasePath   = "$ProjectRoot\data\obd2_codes.db"
$ModelsPath     = "$ProjectRoot\models"
$BuildLog       = Join-Path $ScriptRoot "build_log.txt"

function Timestamp { return "[$(Get-Date -Format 'HH:mm:ss')]" }

# -----------------------------------------
# Build Logic
# -----------------------------------------
try {
    Write-Host "$(Timestamp) 🧱 Preparing to build Docker image (cached)..." -ForegroundColor Cyan
    if (-not (Test-Path "$ProjectRoot\Dockerfile")) {
        Write-Host "$(Timestamp) ❌ Dockerfile not found in project root." -ForegroundColor Red
        exit 1
    }

    if (-not (Test-Path $ModelsPath)) {
        Write-Host "$(Timestamp) ⚠️ Models folder not found: $ModelsPath" -ForegroundColor Yellow
    } else {
        Write-Host "$(Timestamp) ✅ Models folder detected." -ForegroundColor Green
    }

    if (-not (Test-Path $DatabasePath)) {
        Write-Host "$(Timestamp) ⚠️ Database not found: $DatabasePath" -ForegroundColor Yellow
    } else {
        Write-Host "$(Timestamp) ✅ Database detected." -ForegroundColor Green
    }

    Write-Host "$(Timestamp) 🔧 Building Docker image with cache..." -ForegroundColor Cyan
    Set-Location $ProjectRoot
    docker build --progress=auto -t $ImageName . | Tee-Object -FilePath $BuildLog

    if ($LASTEXITCODE -eq 0) {
        Write-Host "$(Timestamp) ✅ Build completed successfully." -ForegroundColor Green
    } else {
        Write-Host "$(Timestamp) ❌ Build failed. Check build_log.txt for details." -ForegroundColor Red
        exit 1
    }

    Write-Host "$(Timestamp) 🚀 Launching container after successful build..." -ForegroundColor Yellow
    docker run -d `
        --name $ContainerName `
        -p 8888:8888 `
        -v "$ModelsPath:/app/models" `
        -v "$ProjectRoot\data:/app/data" `
        $ImageName | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "$(Timestamp) ✅ Container started successfully!" -ForegroundColor Green
        Write-Host "$(Timestamp) 🌐 App running at: http://127.0.0.1:8888" -ForegroundColor Cyan
    } else {
        Write-Host "$(Timestamp) ❌ Failed to start container after build." -ForegroundColor Red
    }
}
catch {
    Write-Host "$(Timestamp) ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Set-Location $ScriptRoot
    Write-Host "$(Timestamp) 🧾 Build log saved to: $BuildLog" -ForegroundColor Cyan
}
