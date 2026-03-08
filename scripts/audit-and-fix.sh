#!/bin/bash
################################################################################
# Dependency Audit & Fix Script
#
# Purpose: Scan and fix npm vulnerabilities locally
# Usage: ./scripts/audit-and-fix.sh [OPTIONS]
#
# Options:
#   --dry-run      Show what would be fixed without making changes
#   --production   Only audit production dependencies (skip devDependencies)
#   --force        Force install even with conflicts
#   --help         Display this help message
#
# Examples:
#   ./scripts/audit-and-fix.sh                    # Full audit and fix
#   ./scripts/audit-and-fix.sh --dry-run          # Preview changes
#   ./scripts/audit-and-fix.sh --production       # Production only
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Defaults
DRY_RUN=false
PRODUCTION_ONLY=false
FORCE_INSTALL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --production)
      PRODUCTION_ONLY=true
      shift
      ;;
    --force)
      FORCE_INSTALL=true
      shift
      ;;
    --help)
      sed -n '2,/^$/p' "$0" | sed 's/^# //'
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  NPM Dependency Audit & Fix${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${YELLOW}Project Directory:${NC} $PROJECT_DIR"
echo ""

# Step 1: Clean up node_modules and lock file (optional for consistency)
echo -e "${YELLOW}[1/4]${NC} Preparing environment..."
if [ -d "$PROJECT_DIR/node_modules" ]; then
  echo "    Removing node_modules..."
  rm -rf "$PROJECT_DIR/node_modules"
fi

# Step 2: Audit current dependencies
echo ""
echo -e "${YELLOW}[2/4]${NC} Running npm audit..."
AUDIT_OPTS=""
if [ "$PRODUCTION_ONLY" = true ]; then
  AUDIT_OPTS="--production"
fi

if npm audit $AUDIT_OPTS 2>&1 | tee /tmp/audit-output.txt; then
  echo -e "${GREEN}✓ No vulnerabilities found${NC}"
else
  echo -e "${YELLOW}Vulnerabilities detected. Proceeding with fixes...${NC}"
fi

# Step 3: Fix vulnerabilities
echo ""
echo -e "${YELLOW}[3/4]${NC} Fixing vulnerabilities..."

if [ "$DRY_RUN" = true ]; then
  echo -e "${BLUE}(DRY RUN - No changes will be made)${NC}"
  npm audit fix $AUDIT_OPTS --dry-run
else
  FIX_OPTS="$AUDIT_OPTS"
  if [ "$FORCE_INSTALL" = true ]; then
    FIX_OPTS="$FIX_OPTS --force"
  fi
  npm audit fix $FIX_OPTS
  echo -e "${GREEN}✓ Vulnerabilities fixed${NC}"
fi

# Step 4: Install dependencies
echo ""
echo -e "${YELLOW}[4/4]${NC} Installing dependencies..."
if [ "$DRY_RUN" = false ]; then
  npm ci
  echo -e "${GREEN}✓ Dependencies installed${NC}"
else
  echo -e "${BLUE}(DRY RUN - Skipping npm ci)${NC}"
fi

# Summary
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
if [ "$DRY_RUN" = true ]; then
  echo -e "${GREEN}Dry run complete. Review changes above.${NC}"
else
  echo -e "${GREEN}✓ Audit and fix complete!${NC}"
fi
echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Review package-lock.json changes"
echo "  2. Run: npm test"
echo "  3. Commit: git add package*.json && git commit -m 'chore: update dependencies'"
echo ""
