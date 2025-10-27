# ===============================================================
# Author: Sanford Janes Witcher III
# Date: October 26, 2025
# File: stop_container.ps1
# Description: Stops and removes the running OBD-II Explorer
#              container if active. Performs a clean shutdown
#              and Docker removal process.
# ===============================================================

<#
.SYNOPSIS
  Stops and removes the running OBD-II Explorer container.

.DESCRIPTION
  This script:
    • Stops the container if it’s running
    • Removes it cleanly from Docker
#>

$ContainerName = "obd2_explorer"

Write-Host "🛑 Checking for running container..." -ForegroundColor Cyan
$Container = docker ps -a -q -f "name=$ContainerName"

if ($Container) {
    Write-Host "🛑 Stopping '$ContainerName'..." -ForegroundColor Yellow
    docker stop $ContainerName | Out-Null

    Write-Host "🧹 Removing '$ContainerName'..." -ForegroundColor Yellow
    docker rm $ContainerName | Out-Null

    Write-Host "✅ Container stopped and removed successfully." -ForegroundColor Green
} else {
    Write-Host "ℹ️ No container named '$ContainerName' is running." -ForegroundColor Gray
}
