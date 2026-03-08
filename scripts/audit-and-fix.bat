@echo off
REM Dependency Audit & Fix Script (Windows)
REM
REM Purpose: Scan and fix npm vulnerabilities locally
REM Usage: audit-and-fix.bat [OPTIONS]
REM
REM Options:
REM   --dry-run      Show what would be fixed without making changes
REM   --production   Only audit production dependencies
REM   --force        Force install even with conflicts
REM   --help         Display this help message

setlocal enabledelayedexpansion

set "DRY_RUN=0"
set "PRODUCTION_ONLY=0"
set "FORCE_INSTALL=0"

:parse_args
if "%~1"=="" goto parse_done
if /i "%~1"=="--dry-run" (
    set "DRY_RUN=1"
    shift
    goto parse_args
)
if /i "%~1"=="--production" (
    set "PRODUCTION_ONLY=1"
    shift
    goto parse_args
)
if /i "%~1"=="--force" (
    set "FORCE_INSTALL=1"
    shift
    goto parse_args
)
if /i "%~1"=="--help" (
    echo Dependency Audit ^& Fix Script (Windows)
    echo.
    echo Usage: audit-and-fix.bat [OPTIONS]
    echo.
    echo Options:
    echo   --dry-run      Show what would be fixed without making changes
    echo   --production   Only audit production dependencies
    echo   --force        Force install even with conflicts
    echo   --help         Display this help message
    echo.
    echo Examples:
    echo   audit-and-fix.bat
    echo   audit-and-fix.bat --dry-run
    echo   audit-and-fix.bat --production
    exit /b 0
)
shift
goto parse_args

:parse_done
echo.
echo ============================================================
echo   NPM Dependency Audit ^& Fix
echo ============================================================
echo.

REM Get script directory
set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR:~0,-9%"

echo Project Directory: %PROJECT_DIR%
echo.

REM Set audit options
set "AUDIT_OPTS="
if !PRODUCTION_ONLY! equ 1 (
    set "AUDIT_OPTS=--production"
)

REM Step 1: Prepare environment
echo [1/4] Preparing environment...
if exist "%PROJECT_DIR%\node_modules" (
    echo     Removing node_modules...
    rmdir /s /q "%PROJECT_DIR%\node_modules" >nul 2>&1
)
echo.

REM Step 2: Audit
echo [2/4] Running npm audit...
cd /d "%PROJECT_DIR%"
npm audit !AUDIT_OPTS! 2>&1
if errorlevel 1 (
    echo Vulnerabilities detected. Proceeding with fixes...
) else (
    echo No vulnerabilities found.
)
echo.

REM Step 3: Fix vulnerabilities
echo [3/4] Fixing vulnerabilities...
if !DRY_RUN! equ 1 (
    echo (DRY RUN - No changes will be made)
    npm audit fix !AUDIT_OPTS! --dry-run
) else (
    set "FIX_OPTS=!AUDIT_OPTS!"
    if !FORCE_INSTALL! equ 1 (
        set "FIX_OPTS=!FIX_OPTS! --force"
    )
    npm audit fix !FIX_OPTS!
    echo Vulnerabilities fixed.
)
echo.

REM Step 4: Install dependencies
echo [4/4] Installing dependencies...
if !DRY_RUN! equ 1 (
    echo (DRY RUN - Skipping npm ci)
) else (
    npm ci
    echo Dependencies installed.
)

echo.
echo ============================================================
if !DRY_RUN! equ 1 (
    echo Dry run complete. Review changes above.
) else (
    echo Audit and fix complete!
)
echo ============================================================
echo.
echo Next steps:
echo   1. Review package-lock.json changes
echo   2. Run: npm test
echo   3. Commit: git add package*.json ^&^& git commit -m "chore: update dependencies"
echo.

endlocal
