param(
    [switch]$AutoDelete = $false,
    [switch]$Help = $false
)

if ($Help) {
    Write-Host @"
CLEANUP ARCHIVE STATUS CHECKER
==============================
Usage: .\check-cleanup-archive.ps1 [options]

Options:
  -AutoDelete    Automatically delete archives older than 30 days without prompting
  -Help          Show this help message

Description:
  Checks .cleanup-archive folder for:
  - Empty subdirectories
  - Directories inactive for 30+ days
  
  Prompts user to delete stale archives or cleans up automatically with -AutoDelete flag.
"@
    exit 0
}

$projectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$archiveRoot = Join-Path $projectRoot ".cleanup-archive"

if (-not (Test-Path $archiveRoot)) {
    Write-Host "No cleanup archive found. Exiting." -ForegroundColor Yellow
    exit 0
}

Write-Host "============================================"
Write-Host "Cleanup Archive Status Check"
Write-Host "============================================"

$archives = Get-ChildItem -Path $archiveRoot -Directory -ErrorAction SilentlyContinue
$thirtyDaysAgo = (Get-Date).AddDays(-30)

$staleArchives = @()
$emptyArchives = @()

foreach ($archive in $archives) {
    $isEmpty = @(Get-ChildItem $archive.FullName -Recurse -ErrorAction SilentlyContinue).Count -eq 0
    $isStale = $archive.LastWriteTime -lt $thirtyDaysAgo
    
    if ($isEmpty) {
        $emptyArchives += $archive
        Write-Host "Empty archive: $($archive.Name)" -ForegroundColor Yellow
    } elseif ($isStale) {
        $staleArchives += $archive
        $daysOld = [math]::Floor(((Get-Date) - $archive.LastWriteTime).TotalDays)
        Write-Host "Stale archive (${daysOld} days): $($archive.Name)" -ForegroundColor Yellow
    } else {
        $daysOld = [math]::Floor(((Get-Date) - $archive.LastWriteTime).TotalDays)
        Write-Host "Active archive (${daysOld} days): $($archive.Name)" -ForegroundColor Green
    }
}

$archivesToDelete = $emptyArchives + $staleArchives

if ($archivesToDelete.Count -eq 0) {
    Write-Host ""
    Write-Host "No stale or empty archives to clean up." -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "Found $($archivesToDelete.Count) archive(s) to delete:" -ForegroundColor Cyan

foreach ($archive in $archivesToDelete) {
    Write-Host "  - $($archive.Name)"
}

if ($AutoDelete) {
    Write-Host ""
    Write-Host "Auto-deleting archives..." -ForegroundColor Cyan
    foreach ($archive in $archivesToDelete) {
        Remove-Item $archive.FullName -Recurse -Force
        Write-Host "  ✓ Deleted: $($archive.Name)" -ForegroundColor Green
    }
} else {
    Write-Host ""
    $response = Read-Host "Delete these archives? (Y/N)"
    if ($response -eq "Y" -or $response -eq "y") {
        foreach ($archive in $archivesToDelete) {
            Remove-Item $archive.FullName -Recurse -Force
            Write-Host "  ✓ Deleted: $($archive.Name)" -ForegroundColor Green
        }
    } else {
        Write-Host "Cleanup cancelled." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "============================================"
Write-Host "Archive check complete!"
Write-Host "============================================"
