# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 26, 2025
# File: start_container.ps1
# Description: Starts the OBD-II Explorer Docker container using
#              an existing image, mounts the database, and follows
#              logs after launch for live diagnostics.
# ===============================================================

<#
.SYNOPSIS
  Starts the OBD-II Explorer container using the existing image.

.DESCRIPTION
  This script:
    • Checks if an image named "obd2_explorer" exists
    • Runs it on port 8888
    • Mounts the local obd2_codes.db file
    • Displays container logs after startup
#>

$ContainerName = "obd2_explorer"
$ImageName = "obd2_explorer"
$ProjectPath = (Get-Location).Path
$DbPath = "$ProjectPath\data\obd2_codes.db"
$Port = 8888

Write-Host "🚀 Starting '$ContainerName'..." -ForegroundColor Cyan

# Verify image exists
$ImageExists = docker images -q $ImageName
if (-not $ImageExists) {
    Write-Host "❌ No image named '$ImageName' found. Please run .\build.ps1 or .\rebuild.ps1 first." -ForegroundColor Red
    exit 1
}

# Verify DB file exists
if (!(Test-Path $DbPath)) {
    Write-Host "⚠️ Database not found at: $DbPath" -ForegroundColor Yellow
    Write-Host "Please ensure obd2_codes.db exists in the 'data' folder."
    exit 1
}

# Run the container
Write-Host "📦 Launching container on port $Port..." -ForegroundColor Yellow
docker run -d -p ${Port}:${Port} `
    --name $ContainerName `
    -v "${DbPath}:/app/data/obd2_codes.db" `
    $ImageName | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Container is running at http://localhost:$Port" -ForegroundColor Green
    Write-Host "🧭 Following logs (Ctrl+C to stop):`n" -ForegroundColor Cyan
    docker logs -f $ContainerName
} else {
    Write-Host "❌ Failed to start container. Try running .\rebuild.ps1 -Force" -ForegroundColor Red
}
