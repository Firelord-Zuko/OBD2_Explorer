# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 26, 2025
# File: startup.ps1
# Description: Launches the OBD-II Explorer environment.
#              Ensures Docker Desktop is running, verifies the
#              engine connection, removes old containers, builds
#              the image, and starts the web app container.
# ===============================================================

# ===============================
#  OBD-II Explorer Startup Script
# ===============================
Write-Host "🚗 Starting OBD-II Explorer environment..." -ForegroundColor Cyan

# --- Ensure Docker is running ---
Write-Host "⏳ Checking Docker Desktop status..."
$dockerStatus = (Get-Process -Name "Docker Desktop" -ErrorAction SilentlyContinue)
if (-not $dockerStatus) {
    Write-Host "⚙️  Launching Docker Desktop..."
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    Start-Sleep -Seconds 15
}

# --- Wait for Docker engine ---
$maxRetries = 10
$connected = $false
for ($i = 1; $i -le $maxRetries; $i++) {
    Write-Host "🔍 Checking Docker engine (attempt $i of $maxRetries)..."
    try {
        docker info | Out-Null
        $connected = $true
        break
    } catch {
        Start-Sleep -Seconds 5
    }
}
if (-not $connected) {
    Write-Host "❌ Docker engine not responding. Please start Docker Desktop manually." -ForegroundColor Red
    exit 1
}

# --- Stop and remove old container if exists ---
if ($(docker ps -a --format "{{.Names}}" | Select-String -Pattern "^obd2_explorer$")) {
    Write-Host "🧹 Removing previous container..."
    docker rm -f obd2_explorer | Out-Null
}

# --- Build the image ---
Write-Host "🔨 Building Docker image (obd2_explorer)..."
docker build -t obd2_explorer "C:\Users\switc\Projects\obd2_explorer" | Out-Null

# --- Run the container ---
Write-Host "🚀 Starting container..."
docker run -d -p 8888:8888 `
  -v "C:\Users\switc\Projects\obd2_explorer:/app" `
  -v "C:\Users\switc\Projects\obd2_explorer\obd2_codes.db:/app/obd2_codes.db" `
  --name obd2_explorer obd2_explorer | Out-Null

Write-Host "✅ OBD-II Explorer is running!"
Write-Host "🌐 Visit: http://localhost:8888" -ForegroundColor Green
