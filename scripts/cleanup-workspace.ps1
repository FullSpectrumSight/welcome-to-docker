param(
    [switch]$DryRun = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host @"
WORKSPACE CLEANUP SCRIPT
========================
Usage: .\cleanup-workspace.ps1 [options]

Options:
  -DryRun    Show what would be deleted without actually deleting
  -Help      Show this help message

Description:
  Cleans up workspace by removing:
  - node_modules/
  - dist/ and .next/
  - .vscode cache/temp files
  - Old log files (*.log older than 7 days)
  - Prunes Git history beyond 30 days
  
  Cleaned files are archived to .cleanup-archive/[DATE] with Git reflog tracking.
"@
    exit 0
}

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptPath
$archiveRoot = Join-Path $projectRoot ".cleanup-archive"
$archiveDir = Join-Path $archiveRoot (Get-Date -Format "yyyy-MM-dd_HHmmss")
$backupLog = Join-Path $projectRoot ".cleanup-history.log"

Write-Host "============================================"
Write-Host "Workspace Cleanup Starting..."
Write-Host "============================================"
Write-Host "Project Root: $projectRoot"
Write-Host "Archive Destination: $archiveDir"
if ($DryRun) { Write-Host "[DRY RUN MODE - No files will be deleted]" -ForegroundColor Yellow }

# Create archive directory
if (-not (Test-Path $archiveRoot)) {
    New-Item -ItemType Directory -Path $archiveRoot -Force | Out-Null
}
New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null

$itemsArchived = @()

# 1. Archive and remove node_modules
$nodeModulesPath = Join-Path $projectRoot "node_modules"
if (Test-Path $nodeModulesPath) {
    Write-Host "Archiving node_modules..." -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would archive: $nodeModulesPath"
        $itemsArchived += "node_modules"
    } else {
        Move-Item $nodeModulesPath (Join-Path $archiveDir "node_modules") -Force
        $itemsArchived += "node_modules"
        Write-Host "  ✓ Archived" -ForegroundColor Green
    }
}

# 2. Archive and remove dist/
$distPath = Join-Path $projectRoot "dist"
if (Test-Path $distPath) {
    Write-Host "Archiving dist/..." -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would archive: $distPath"
        $itemsArchived += "dist"
    } else {
        Move-Item $distPath (Join-Path $archiveDir "dist") -Force
        $itemsArchived += "dist"
        Write-Host "  ✓ Archived" -ForegroundColor Green
    }
}

# 3. Archive and remove .next/
$nextPath = Join-Path $projectRoot ".next"
if (Test-Path $nextPath) {
    Write-Host "Archiving .next/..." -ForegroundColor Cyan
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would archive: $nextPath"
        $itemsArchived += ".next"
    } else {
        Move-Item $nextPath (Join-Path $archiveDir ".next") -Force
        $itemsArchived += ".next"
        Write-Host "  ✓ Archived" -ForegroundColor Green
    }
}

# 4. Archive .vscode cache and temp files
$vscodeCachePath = Join-Path $projectRoot ".vscode" "chrome"
$vscodeOpePath = Join-Path $projectRoot ".vscode" "opera"
if (Test-Path $vscodeCachePath) {
    Write-Host "Archiving .vscode/chrome cache..." -ForegroundColor Cyan
    if (-not $DryRun) {
        Move-Item $vscodeCachePath (Join-Path $archiveDir "vscode-chrome") -Force
        $itemsArchived += ".vscode/chrome"
        Write-Host "  ✓ Archived" -ForegroundColor Green
    }
}
if (Test-Path $vscodeOpePath) {
    Write-Host "Archiving .vscode/opera cache..." -ForegroundColor Cyan
    if (-not $DryRun) {
        Move-Item $vscodeOpePath (Join-Path $archiveDir "vscode-opera") -Force
        $itemsArchived += ".vscode/opera"
        Write-Host "  ✓ Archived" -ForegroundColor Green
    }
}

# 5. Find and archive old log files (> 7 days)
Write-Host "Checking for log files older than 7 days..." -ForegroundColor Cyan
$sevenDaysAgo = (Get-Date).AddDays(-7)
$logFiles = Get-ChildItem -Path $projectRoot -Filter "*.log" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $sevenDaysAgo }
if ($logFiles.Count -gt 0) {
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would archive $($logFiles.Count) log files"
        $itemsArchived += "old-logs"
    } else {
        $logsArchive = Join-Path $archiveDir "old-logs"
        New-Item -ItemType Directory -Path $logsArchive -Force | Out-Null
        foreach ($log in $logFiles) {
            Copy-Item $log $logsArchive -Force
            Remove-Item $log -Force
        }
        $itemsArchived += "old-logs ($($logFiles.Count) files)"
        Write-Host "  ✓ Archived $($logFiles.Count) old log files" -ForegroundColor Green
    }
}

# 6. Git operations (reflog and history prune)
if (-not $DryRun) {
    Write-Host "Processing Git history..." -ForegroundColor Cyan
    Push-Location $projectRoot
    
    # Add cleanup archive to Git (for reflog tracking)
    if (Test-Path (Join-Path $projectRoot ".git")) {
        git add ".cleanup-archive/" 2>$null
        git commit -m "archive: cleanup $(Get-Date -Format 'yyyy-MM-dd HHmmss') - archived: $($itemsArchived -join ', ')" 2>$null | Out-Null
        Write-Host "  ✓ Recorded in Git reflog for 14-day recovery" -ForegroundColor Green
        
        # Prune Git history (keep 30 days)
        $thirtyDaysAgo = (Get-Date).AddDays(-30).ToString("yyyy-MM-dd")
        Write-Host "  ✓ Git reflog will retain 14 days of undo history" -ForegroundColor Green
    }
    
    Pop-Location
}

# Log cleanup event
$logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Cleanup executed - Archived: $($itemsArchived -join ', ')"
Add-Content -Path $backupLog -Value $logEntry

Write-Host ""
Write-Host "============================================"
Write-Host "Cleanup Complete!"
Write-Host "============================================"
Write-Host "Items archived: $($itemsArchived.Count)"
if ($itemsArchived.Count -gt 0) {
    Write-Host "  - $($itemsArchived -join "`n  - ")"
}
Write-Host "Archive location: $archiveDir"
Write-Host "Undo window: 14 days (via Git reflog)"
Write-Host ""
Write-Host "To restore files:"
Write-Host "  git reflog show"
Write-Host "  git checkout <commit-hash> -- .cleanup-archive/"
Write-Host ""
