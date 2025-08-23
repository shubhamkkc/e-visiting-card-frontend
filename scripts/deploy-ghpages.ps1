<#!
PowerShell script to build Flutter web app and deploy ONLY the build to a gh-pages branch.

Usage examples:
  # Basic (uses default backend & slug)
  ./scripts/deploy-ghpages.ps1 -RepoName e_visiting_card

  # With explicit backend URL
  ./scripts/deploy-ghpages.ps1 -RepoName e_visiting_card -BackendUrl https://e-visiting-card-backend.onrender.com

Parameters:
  -RepoName     Your GitHub repository name (the part after github.com/<user>/)
  -BackendUrl   The Render (or other) backend base URL (no trailing slash required)
  -SkipBuild    If set, skips flutter build (just re-publishes last build)
  -CommitMsg    Custom commit message (default: Deploy <timestamp>)
Requires:
  - git, flutter in PATH
  - An existing remote named 'origin'
!#>

param(
  [Parameter(Mandatory=$true)][string]$RepoName,
  [string]$BackendUrl = 'https://e-visiting-card-backend.onrender.com',
  [switch]$SkipBuild,
  [string]$CommitMsg
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $CommitMsg) { $CommitMsg = "Deploy $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" }

Write-Host "Repository name: $RepoName" -ForegroundColor Cyan
Write-Host "Backend URL   : $BackendUrl" -ForegroundColor Cyan

if (-not $SkipBuild) {
  Write-Host "Building Flutter web..." -ForegroundColor Yellow
  flutter build web --release --base-href "/$RepoName/" --dart-define=API_BASE_URL=$BackendUrl
}

if (-not (Test-Path build/web/index.html)) {
  throw 'build/web/index.html not found. Build step failed or was skipped incorrectly.'
}

$deployDir = 'deploy-gh'

# Prepare worktree for gh-pages branch
Write-Host "Preparing gh-pages worktree..." -ForegroundColor Yellow
git fetch origin 2>$null | Out-Null

# If branch does not exist locally, try to create tracking it (or orphan if remote missing)
$branchExists = (git branch --list gh-pages) -ne $null
if (-not $branchExists) {
  try { git rev-parse --verify origin/gh-pages 2>$null | Out-Null } catch { }
  if ($LASTEXITCODE -eq 0) {
    git checkout -b gh-pages origin/gh-pages
    git checkout -  # go back
  } else {
    git checkout --orphan gh-pages
    Remove-Item -Recurse -Force * -ErrorAction SilentlyContinue
    git commit --allow-empty -m "chore: create gh-pages orphan"
    git checkout -  # return
  }
}

# Remove old worktree dir
if (Test-Path $deployDir) {
  try { git worktree remove -f $deployDir } catch { Remove-Item -Recurse -Force $deployDir }
}

git worktree add $deployDir gh-pages | Out-Null

# Clean deploy dir (keep .git contents)
Get-ChildItem -Path $deployDir -Force | Where-Object { $_.Name -ne '.git' } | Remove-Item -Recurse -Force

Copy-Item build/web/* $deployDir -Recurse

Push-Location $deployDir
git add .
if ((git status --porcelain) -ne $null) {
  git commit -m $CommitMsg
  git push origin gh-pages
  Write-Host "Deployed to gh-pages." -ForegroundColor Green
} else {
  Write-Host "No changes to deploy." -ForegroundColor Yellow
}
Pop-Location

Write-Host "GitHub Pages URL: https://<your-user>.github.io/$RepoName/" -ForegroundColor Cyan
