# Workspace Cleanup System

This document explains the automated and manual cleanup system for the welcome-to-docker workspace.

## Overview

The cleanup system manages workspace bloat by archiving and removing unneeded data every 14 days. All cleaned files are archived to `.cleanup-archive/` with Git reflog tracking for 14-day undo capability, and stale archives prompt for deletion after 30 days of inactivity.

## What Gets Cleaned

- **node_modules/** — Node dependencies (reinstall via `npm install`)
- **dist/** — Build output
- **.next/** — Next.js build cache
- **.vscode/chrome/** and **.vscode/opera/** — Browser cache files
- **Old log files** — Any `.log` files older than 7 days
- **Git history** — Old commits and branches (14+ days)

## Manual Cleanup (VS Code Tasks)

Use these tasks from VS Code's **Run Task** menu (Ctrl+Shift+B or Cmd+Shift+B):

### 1. **Cleanup: Workspace (Dry Run)**
Preview what would be deleted without actually removing anything.
```powershell
Task: Cleanup: Workspace (Dry Run)
```

### 2. **Cleanup: Workspace (Manual)**
Perform actual cleanup. Archives files to `.cleanup-archive/[TIMESTAMP]`.
```powershell
Task: Cleanup: Workspace (Manual)
```

### 3. **Cleanup: Check Archive Status**
Check for empty or 30+ day old archives and prompt for deletion.
```powershell
Task: Cleanup: Check Archive Status
```

### 4. **Cleanup: Check Archive Status (Auto-Delete Stale)**
Automatically delete archives older than 30 days without prompting.
```powershell
Task: Cleanup: Check Archive Status (Auto-Delete Stale)
```

## How to Use

### Quick Start

1. Open VS Code and the workspace.
2. Press **Ctrl+Shift+B** (or Cmd+Shift+B on Mac).
3. Select from the cleanup tasks listed above.
4. Monitor output in the terminal panel.

### Example: Manual Cleanup

```powershell
# From PowerShell in workspace directory:
.\scripts\cleanup-workspace.ps1

# Or with dry-run to preview:
.\scripts\cleanup-workspace.ps1 -DryRun

# Or get help:
.\scripts\cleanup-workspace.ps1 -Help
```

### Example: Check Archive Status

```powershell
# Check and prompt before deleting stale archives:
.\scripts\check-cleanup-archive.ps1

# Automatically delete archives 30+ days old:
.\scripts\check-cleanup-archive.ps1 -AutoDelete

# Help:
.\scripts\check-cleanup-archive.ps1 -Help
```

## Archive and Undo

### Archive Location
Cleaned files are timestamped and stored in:
```
.cleanup-archive/
  └── 2026-02-19_143052/          ← Cleanup timestamp
      ├── node_modules/
      ├── dist/
      ├── .next/
      ├── vscode-chrome/
      ├── vscode-opera/
      └── old-logs/
```

### Restore Files (14-day window)

If you need to restore cleaned files within 14 days:

1. **View Git reflog:**
   ```powershell
   git reflog show
   ```

2. **Find the cleanup commit** (look for messages like "archive: cleanup 2026-02-19...")

3. **Restore from archive:**
   ```powershell
   git checkout <commit-hash> -- .cleanup-archive/
   ```

4. **Move files back:**
   ```powershell
   # Example: restore node_modules
   Move-Item .cleanup-archive/2026-02-19_143052/node_modules ./node_modules
   ```

### Cleanup History

All cleanup events are logged in `.cleanup-history.log` for audit purposes.

## Automated GitHub Actions Cleanup

A GitHub Actions workflow runs **every 14 days** (1st and 15th of each month at 02:00 UTC):

- Deletes workflow runs older than 14 days
- Removes workflow artifacts
- Prunes stale branches (except `main` and `develop`)

**Manual trigger:**
Repository Actions tab → "Cleanup Old Data (Every 14 Days)" → "Run workflow"

## 30-Day Stale Archive Deletion Policy

After 30 days of inactivity, the cleanup archive status checker will flag archives for deletion:

- **If you run the manual task**, it will prompt you before deletion.
- **If you run with `-AutoDelete`**, stale archives are deleted without prompting.
- **GitHub Actions** will periodically run the status check but will never delete without Git tracking.

## Troubleshooting

### "Pre-commit is not installed"
If you see errors about pre-commit hooks failing, run:
```powershell
pip install pre-commit
pre-commit install
```

### "Cannot find script"
Ensure you're in the workspace root directory:
```powershell
cd "C:\Users\BlackLight\welcome-to-docker"
.\scripts\cleanup-workspace.ps1
```

### "Git reflog shows nothing"
Git reflog is preserved for ~90 days by default. If cleanup was >90 days ago, rollback may not be possible. Plan cleanup cycles accordingly.

## Best Practices

1. **Run dry-run first** to see what will be deleted.
2. **Commit changes** before cleanup to avoid losing work.
3. **Check archive status periodically** to manage disk space.
4. **Archive old projects** when done to keep active workspace lean.

## Files

| File | Purpose |
|------|---------|
| `scripts/cleanup-workspace.ps1` | Main cleanup script |
| `scripts/check-cleanup-archive.ps1` | Archive status checker |
| `.vscode/tasks.json` | VS Code task definitions |
| `.github/workflows/cleanup-old-data.yml` | Automated GitHub Actions cleanup |
| `.cleanup-archive/` | Archive directory (created after first cleanup) |
| `.cleanup-history.log` | Cleanup event log |

---

**Last updated:** February 19, 2026
