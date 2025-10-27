<#
.SYNOPSIS
  Automates adding, committing, and pushing project updates to GitHub.

.DESCRIPTION
  This script:
    • Checks for uncommitted changes
    • Prompts for a custom commit message
    • Adds, commits, and pushes all tracked files to GitHub main branch
#>

# Configuration
$RepoName = "OBD2_Explorer"
$GitHubUser = "Firelord-Zuko"
$RepoURL = "https://github.com/$GitHubUser/$RepoName.git"
$Branch = "main"

# Move to project root
$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $ProjectRoot

Write-Host "📂 Working directory: $ProjectRoot" -ForegroundColor Cyan

# Ensure Git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "🧩 Initializing new Git repository..." -ForegroundColor Yellow
    git init | Out-Null
}

# Ensure correct remote origin
$remote = git remote get-url origin 2>$null
if (-not $remote) {
    Write-Host "🔗 Setting remote to: $RepoURL" -ForegroundColor Yellow
    git remote add origin $RepoURL
} elseif ($remote -ne $RepoURL) {
    Write-Host "♻️ Updating remote URL to: $RepoURL" -ForegroundColor Yellow
    git remote set-url origin $RepoURL
}

# Show repo status
Write-Host "`n📋 Current status:" -ForegroundColor Cyan
git status

# Check for changes
$changes = git status --porcelain
if (-not $changes) {
    Write-Host "`n✅ No new changes to commit." -ForegroundColor Green
    exit 0
}

# Prompt for commit message
$CommitMessage = Read-Host "`n📝 Enter commit message"
if (-not $CommitMessage) {
    $CommitMessage = "Automated commit – $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
}

# Stage and commit
Write-Host "`n📦 Adding files..." -ForegroundColor Yellow
git add .

Write-Host "💾 Committing changes..." -ForegroundColor Yellow
git commit -m "$CommitMessage"

# Ensure correct branch
git branch -M $Branch

# Push to GitHub
Write-Host "🚀 Pushing to GitHub ($Branch branch)..." -ForegroundColor Cyan
git push -u origin $Branch

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n✅ Push complete! Check your repo at:" -ForegroundColor Green
    Write-Host "🌐 https://github.com/$GitHubUser/$RepoName" -ForegroundColor Blue
} else {
    Write-Host "`n❌ Push failed. Check your authentication or network connection." -ForegroundColor Red
}
