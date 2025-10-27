# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 27, 2025
# File: menu.ps1
# Description: Provides an interactive PowerShell dashboard to manage
#              Docker container lifecycle, build operations, logs,
#              and system maintenance for the OBD-II Explorer project.
# ===============================================================

# ===============================================================
# 🚗  OBD-II Explorer | Control Dashboard v1.1.0
# ===============================================================

# --- Always run from the project root ---
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition)
Write-Host "📂 Working Directory: $(Get-Location)" -ForegroundColor DarkGray
Clear-Host

Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "   ___  ____  ____     ___    ____  ____  ____  _      ____  ____" -ForegroundColor Cyan
Write-Host "  / _ \/ ___||  _ \   / _ \  | __ )/  _ \| _  \| |    / ___||  _ \" -ForegroundColor Cyan
Write-Host " | | | \___ \| | | | | | | | | |_) | | | | |_) | |    \___ \| |_) |" -ForegroundColor Cyan
Write-Host " | |_| |___) | |_| | | |_| | | |_) | |_| |  _ <| |___  ___) |  __/" -ForegroundColor Cyan
Write-Host "  \___/|____/|____/   \___/  |____/ \___/|_| \_\_____||____/|_|" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "               🚗  OBD-II Explorer Control Dashboard  v1.1.0" -ForegroundColor Yellow
Write-Host ""

# -----------------------------------------
# Configuration
# -----------------------------------------
$ProjectRoot    = Get-Location
$ScriptsDir     = Join-Path $ProjectRoot "scripts"
$ImageName      = "obd2_explorer"
$ContainerName  = "obd2_explorer"
$DatabasePath   = Join-Path $ProjectRoot "data\obd2_codes.db"
$ModelsPath     = Join-Path $ProjectRoot "models"
$RebuildScript  = Join-Path $ScriptsDir "rebuild.ps1"
$StartScript    = Join-Path $ScriptsDir "start_container.ps1"
$StopScript     = Join-Path $ScriptsDir "stop_container.ps1"
$BuildLog       = Join-Path $ScriptsDir "build_log.txt"

function Timestamp { return "[$(Get-Date -Format 'HH:mm:ss')]" }

# -----------------------------------------
# Menu
# -----------------------------------------
function Show-Menu {
    Write-Host ""
    Write-Host "1.  🚀  Build (cached)" -ForegroundColor Green
    Write-Host "2.  🔨  Rebuild (cached)" -ForegroundColor Green
    Write-Host "3.  💥  Rebuild (force, no cache)" -ForegroundColor Yellow
    Write-Host "4.  ▶️  Start container" -ForegroundColor Yellow
    Write-Host "5.  ⏹   Stop container" -ForegroundColor Yellow
    Write-Host "6.  🧹  Remove container" -ForegroundColor Yellow
    Write-Host "7.  🧭  View container logs (live)" -ForegroundColor Cyan
    Write-Host "8.  📄  View container logs (snapshot)" -ForegroundColor Cyan
    Write-Host "9.  📖  View build log" -ForegroundColor Cyan
    Write-Host "10. 🧾  Export system info" -ForegroundColor Cyan
    Write-Host "11. 📊  System monitor (live)" -ForegroundColor Magenta
    Write-Host "12. 💾  Backup database" -ForegroundColor Magenta
    Write-Host "13. 🧹  Clean old logs" -ForegroundColor Magenta
    Write-Host "0.  ❌  Exit" -ForegroundColor Red
    Write-Host ""
}

# -----------------------------------------
# Utility
# -----------------------------------------
function Remove-Container {
    Write-Host "$(Timestamp) 🧹 Removing container..." -ForegroundColor Yellow
    docker rm $ContainerName 2>$null | Out-Null
}

# -----------------------------------------
# Core Actions
# -----------------------------------------
function Build-Image {
    Write-Host "$(Timestamp) 🚀 Build (cached) selected — deleting old image first..." -ForegroundColor Green
    docker rmi -f $ImageName -ErrorAction SilentlyContinue | Out-Null
    Write-Host "$(Timestamp) ✅ Old image removed." -ForegroundColor DarkGray
    & $RebuildScript -Mode "cached"
}

function Rebuild-Image {
    Write-Host "$(Timestamp) 🔨 Rebuild (cached) selected — stop, rebuild, restart (keep image)..." -ForegroundColor Cyan
    & $StopScript
    & $RebuildScript -Mode "rebuild"
}

function Force-Rebuild {
    Write-Host "$(Timestamp) 💥 Force rebuild (no cache) selected — deleting container and image..." -ForegroundColor Red
    & $StopScript
    Remove-Container
    & $RebuildScript -Mode "clean"
}

function Start-Container {
    Write-Host "$(Timestamp) ▶️ Starting container..." -ForegroundColor Yellow
    & $StartScript
}

function Stop-Container {
    Write-Host "$(Timestamp) ⏹ Stopping container..." -ForegroundColor Yellow
    & $StopScript
}

function View-Logs-Live { docker logs -f $ContainerName }
function View-Logs-Snapshot { docker logs $ContainerName --tail 50 }
function View-Build-Log { Get-Content $BuildLog -Tail 50 }

function Export-System-Info {
    Write-Host "$(Timestamp) 📦 Exporting system info..." -ForegroundColor Cyan
    systeminfo | Out-File "$ScriptsDir\system_info.txt"
    Write-Host "$(Timestamp) ✅ System info exported." -ForegroundColor Green
}

function Monitor-System { docker stats }

function Backup-Database {
    if (Test-Path $DatabasePath) {
        $BackupFile = "backup_obd2_codes_$(Get-Date -Format yyyyMMdd_HHmmss).db"
        Copy-Item $DatabasePath "$ScriptsDir\$BackupFile" -Force
        Write-Host "$(Timestamp) ✅ Database backup complete: $BackupFile" -ForegroundColor Green
    } else {
        Write-Host "$(Timestamp) ⚠️ Database not found at: $DatabasePath" -ForegroundColor Yellow
    }
}

function Clean-Old-Logs {
    Get-ChildItem -Path $ScriptsDir -Filter "*.log" -ErrorAction SilentlyContinue | Remove-Item -Force
    Write-Host "$(Timestamp) ✅ Logs cleaned." -ForegroundColor Green
}

# -----------------------------------------
# Main Loop
# -----------------------------------------
do {
    Show-Menu
    $choice = Read-Host "Select an option (0-13)"
    switch ($choice) {
        1  { Build-Image }
        2  { Rebuild-Image }
        3  { Force-Rebuild }
        4  { Start-Container }
        5  { Stop-Container }
        6  { Remove-Container }
        7  { View-Logs-Live }
        8  { View-Logs-Snapshot }
        9  { View-Build-Log }
        10 { Export-System-Info }
        11 { Monitor-System }
        12 { Backup-Database }
        13 { Clean-Old-Logs }
        0  { Write-Host "$(Timestamp) 👋 Exiting OBD-II Explorer Dashboard..." -ForegroundColor Red }
        Default { Write-Host "$(Timestamp) ❌ Invalid selection. Try again." -ForegroundColor Red }
    }
} while ($choice -ne 0)
