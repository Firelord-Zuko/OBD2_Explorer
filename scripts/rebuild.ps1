# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 26, 2025
# File: rebuild.ps1
# Description: Performs a full Docker rebuild (optionally no-cache)
#              for the OBD-II Explorer project, removing old containers
#              and images, rebuilding from source, and restarting the app.
# ===============================================================

param (
    [switch]$NoCache
)

Clear-Host
$ErrorActionPreference = "Stop"

# -----------------------------------------
# Configuration
# -----------------------------------------
$ScriptRoot     = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ProjectRoot    = Resolve-Path "$ScriptRoot\.."
$ImageName      = "obd2_explorer"
$ContainerName  = "obd2_explorer"
$DatabasePath   = "$ProjectRoot\data\obd2_codes.db"
$ModelsPath     = "$ProjectRoot\models"
$DockerfilePath = "$ProjectRoot\Dockerfile"

function Write-Log {
    param ([string]$Message, [string]$Color = "Gray")
    $timestamp = (Get-Date -Format "HH:mm:ss")
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

# -----------------------------------------
# Rebuild Logic
# -----------------------------------------


try {
    Write-Log "💥 Performing full rebuild (no cache, colorful mode)..." "Red"

    Write-Log "🛑 Stopping container..." "Yellow"
    docker stop $ContainerName 2>$null | Out-Null

    Write-Log "🧹 Removing container..." "Yellow"
    docker rm $ContainerName 2>$null | Out-Null

    Write-Log "🧱 Removing old image if exists..." "Yellow"
    docker rmi $ImageName 2>$null | Out-Null

    if (-not (Test-Path $DockerfilePath)) {
        Write-Log "❌ Dockerfile not found at: $DockerfilePath" "Red"
        exit 1
    }

    if (-not (Test-Path $ModelsPath)) {
        Write-Log "⚠️ Models folder not found: $ModelsPath" "Yellow"
    }

    if (-not (Test-Path $DatabasePath)) {
        Write-Log "⚠️ Database not found, continuing without local mount..." "Yellow"
    }

    $buildArgs = if ($NoCache) { "--no-cache" } else { "" }

    Write-Log "🧰 Running full rebuild ($buildArgs)..." "Cyan"
    Set-Location $ProjectRoot
    docker build $buildArgs -t $ImageName . | Tee-Object -FilePath "$ScriptRoot\build_log.txt"

    if ($LASTEXITCODE -ne 0) {
        Write-Log "❌ Rebuild failed. Check logs above." "Red"
        exit 1
    }

    Write-Log "🚀 Starting container..." "Green"
    docker run -d `
        --name $ContainerName `
        -p 8888:8888 `
        -v "${ModelsPath}:/app/models" `
        -v "${ProjectRoot}\data:/app/data" `
        $ImageName | Out-Null

    Write-Log "✅ Container started successfully at http://localhost:8888" "Green"
}
catch {
    Write-Log "❌ Error during rebuild: $($_.Exception.Message)" "Red"
    exit 1
}
