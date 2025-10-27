# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 26, 2025
# File: clean.ps1
# Description: Performs a full Docker cleanup — removes stopped
#              containers, dangling images, unused volumes/networks,
#              and build cache, while keeping active containers intact.
# ===============================================================

# ===============================================================
# 🚗  OBD-II Explorer | Cleanup Script v1.0.0
# ===============================================================

Clear-Host
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "   ___  ____  ____     ___    ____  ____  ____  _      ____  ____" -ForegroundColor Cyan
Write-Host "  / _ \/ ___||  _ \   / _ \  | __ )/  _ \| _  \| |    / ___||  _ \" -ForegroundColor Cyan
Write-Host " | | | \___ \| | | | | | | | | |_) | | | | |_) | |    \___ \| |_) |" -ForegroundColor Cyan
Write-Host " | |_| |___) | |_| | | |_| | | |_) | |_| |  _ <| |___  ___) |  __/" -ForegroundColor Cyan
Write-Host "  \___/|____/|____/   \___/  |____/ \___/|_| \_\_____||____/|_|" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "               🧹  OBD-II Explorer Cleanup Script" -ForegroundColor Yellow
Write-Host ""

# -----------------------------------------
# Configuration
# -----------------------------------------
$ErrorActionPreference = "Stop"
$ScriptRoot     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ImageName      = "obd2_explorer"
$ContainerName  = "obd2_explorer"

function Timestamp { return "[$(Get-Date -Format 'HH:mm:ss')]" }

# -----------------------------------------
# Cleanup Logic
# -----------------------------------------
try {
    Write-Host "$(Timestamp) 🧼 Starting cleanup process..." -ForegroundColor Cyan

    # 1️⃣ Stop any stopped or inactive OBD-II container
    Write-Host "$(Timestamp) 🛑 Checking for inactive containers..." -ForegroundColor Yellow
    $inactive = docker ps -a -q -f "status=exited"
    if ($inactive) {
        docker rm $inactive | Out-Null
        Write-Host "$(Timestamp) ✅ Removed stopped containers." -ForegroundColor Green
    } else {
        Write-Host "$(Timestamp) ⚙️ No stopped containers found." -ForegroundColor DarkGray
    }

    # 2️⃣ Remove dangling images (untagged)
    Write-Host "$(Timestamp) 🧱 Removing dangling images..." -ForegroundColor Yellow
    docker image prune -f | Out-Null
    Write-Host "$(Timestamp) ✅ Dangling images removed." -ForegroundColor Green

    # 3️⃣ Clean up unused volumes
    Write-Host "$(Timestamp) 💾 Cleaning unused volumes..." -ForegroundColor Yellow
    docker volume prune -f | Out-Null
    Write-Host "$(Timestamp) ✅ Unused volumes removed." -ForegroundColor Green

    # 4️⃣ Remove unused networks
    Write-Host "$(Timestamp) 🌐 Cleaning unused networks..." -ForegroundColor Yellow
    docker network prune -f | Out-Null
    Write-Host "$(Timestamp) ✅ Unused networks removed." -ForegroundColor Green

    # 5️⃣ Remove build cache safely
    Write-Host "$(Timestamp) 🧰 Cleaning build cache..." -ForegroundColor Yellow
    docker builder prune -f | Out-Null
    Write-Host "$(Timestamp) ✅ Build cache cleaned." -ForegroundColor Green

    # 6️⃣ Confirm space recovery
    Write-Host "$(Timestamp) 📊 Docker disk usage after cleanup:" -ForegroundColor Cyan
    docker system df
    Write-Host "$(Timestamp) 🧾 Cleanup complete!" -ForegroundColor Green
}
catch {
    Write-Host "$(Timestamp) ❌ Error during cleanup: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
