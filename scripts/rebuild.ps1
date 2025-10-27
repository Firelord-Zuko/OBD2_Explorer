<#
======================================================================
OBD-II Explorer: Rebuild Script
Author: Sanford Janes Witcher III
Date: October 27, 2025
Version: 1.4
Description:
  Performs a Docker rebuild with conditional image and container
  cleanup behavior based on the -Mode parameter.
======================================================================
#>

param(
    [ValidateSet("cached", "rebuild", "clean")]
    [string]$Mode = "cached"
)

# --- Configuration ---
$containerName = "obd2_explorer"
$imageName = "obd2_explorer"

Write-Host "==============================================================="
Write-Host "  🚗 OBD-II EXPLORER — REBUILD SCRIPT"
Write-Host "==============================================================="
Write-Host "Selected mode: $Mode"
Write-Host ""

# --- Stop running container if active ---
$running = docker ps -q -f "name=$containerName"
if ($running) {
    Write-Host "🛑 Stopping running container..."
    docker stop $containerName | Out-Null
    Write-Host "✅ Container stopped."
} else {
    Write-Host "ℹ️ No running container detected."
}

# --- Conditional cleanup logic ---
switch ($Mode) {
    "cached" {
        Write-Host "🧱 Build (cached): Removing old image before rebuild..."
        docker rmi -f $imageName -ErrorAction SilentlyContinue | Out-Null
        Write-Host "✅ Old image removed."
    }
    "rebuild" {
        Write-Host "🔁 Rebuild (cached): Keeping current image and container."
        # 👉 No removal here — preserves everything
    }
    "clean" {
        Write-Host "🔥 Full clean rebuild: removing container and image..."
        docker rm -f $containerName -ErrorAction SilentlyContinue | Out-Null
        docker rmi -f $imageName -ErrorAction SilentlyContinue | Out-Null
        Write-Host "✅ Container and image removed."
    }
}

# --- Build Phase ---
if ($Mode -eq "clean") {
    Write-Host "🔨 Building image (no cache)..."
    docker build --no-cache -t $imageName . | Tee-Object "$PSScriptRoot\build.log"
} else {
    Write-Host "🔨 Building image (cached layers enabled)..."
    docker build -t $imageName . | Tee-Object "$PSScriptRoot\build.log"
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker build failed. Check build.log for details."
    exit 1
} else {
    Write-Host "✅ Build completed successfully."
}

# --- Restart container ---
Write-Host ""
Write-Host "🚀 Starting container..."
docker run -d -p 8888:8888 `
    --name $containerName `
    -v "${PWD}/models:/app/models" `
    -v "${PWD}/data:/app/data" `
    $imageName

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Container started successfully."
} else {
    Write-Host "❌ Container failed to start. Check logs."
}

Write-Host ""
Write-Host "==============================================================="
Write-Host " Rebuild Completed — Mode: $Mode"
Write-Host "==============================================================="
