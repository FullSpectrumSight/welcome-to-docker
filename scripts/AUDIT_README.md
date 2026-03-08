# Dependency Audit & Fix Scripts

Automated scripts to scan and fix npm vulnerabilities in your project.

## Available Scripts

### Linux/macOS
```bash
./scripts/audit-and-fix.sh [OPTIONS]
```

### Windows (Command Prompt)
```cmd
scripts\audit-and-fix.bat [OPTIONS]
```

## Options

| Option | Description |
|--------|-------------|
| `--dry-run` | Preview what would be fixed without making changes |
| `--production` | Only audit/fix production dependencies (exclude devDependencies) |
| `--force` | Force install even with dependency conflicts |
| `--help` | Display help message |

## Usage Examples

### Full Audit & Fix
```bash
# Linux/macOS
./scripts/audit-and-fix.sh

# Windows
scripts\audit-and-fix.bat
```

### Preview Changes (Dry Run)
```bash
# Linux/macOS
./scripts/audit-and-fix.sh --dry-run

# Windows
scripts\audit-and-fix.bat --dry-run
```

### Production Dependencies Only
```bash
# Linux/macOS
./scripts/audit-and-fix.sh --production

# Windows
scripts\audit-and-fix.bat --production
```

### Force Install on Conflicts
```bash
# Linux/macOS
./scripts/audit-and-fix.sh --force

# Windows
scripts\audit-and-fix.bat --force
```

## What the Script Does

1. **Prepare Environment** - Removes existing node_modules for clean state
2. **Audit Dependencies** - Scans for known vulnerabilities using `npm audit`
3. **Fix Vulnerabilities** - Applies automatic fixes with `npm audit fix`
4. **Install Dependencies** - Installs cleaned dependencies with `npm ci`

## After Running

Always verify changes before committing:

```bash
# Review what changed
git diff package-lock.json

# Run tests to ensure nothing broke
npm test

# Commit if all looks good
git add package*.json
git commit -m "chore: update dependencies and fix vulnerabilities"
```

## Transitive Dependencies

If you see warnings about transitive dependencies (like `stable`), don't worry:
- These are dependencies of your direct dependencies
- They're automatically managed by npm
- The audit fix handles them appropriately
- You don't need to manually manage them

## CI/CD Integration

These scripts are designed to run:
- ✅ Locally for development
- ✅ In CI/CD pipelines
- ✅ As pre-commit hooks
- ✅ On scheduled maintenance

## Troubleshooting

### "node_modules not found after running script"
This is normal - the script cleans it up and reinstalls.

### "Vulnerabilities still exist after fix"
Some vulnerabilities require manual intervention:
1. Run `npm audit` to see detailed report
2. Check each vulnerability for recommended action
3. Update specific packages if needed: `npm update package-name`
4. Review breaking changes in package documentation

### "Conflicts during installation"
Try running with `--force` flag, but review the changes carefully.

## Schedule Regular Audits

Set up a cron job or GitHub Action to run periodically:

```bash
# Daily at 2 AM
0 2 * * * cd /path/to/project && ./scripts/audit-and-fix.sh
```

## References

- [npm audit Documentation](https://docs.npmjs.com/cli/audit)
- [npm audit fix](https://docs.npmjs.com/cli/audit#npm-audit-fix)
- [Node.js Security Best Practices](https://nodejs.org/en/docs/guides/security/)
