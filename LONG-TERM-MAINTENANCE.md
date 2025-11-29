# Long-Term Maintenance: Config-File Pattern

**Date**: October 27, 2025
**Purpose**: Routine maintenance procedures and health checks
**Audience**: Users maintaining unix-goto with Config-File Pattern

---

## Maintenance Schedule

### Weekly (30 seconds)
Check for public updates:
```bash
cd ~/Documents/LUXOR/Git_Repos/unix-goto
git fetch origin
git log --oneline origin/main -3  # See what's new
```

### Monthly (2 minutes)
Pull updates and test:
```bash
cd ~/Documents/LUXOR/Git_Repos/unix-goto
git pull origin main
exec $SHELL  # Reload to pick up any changes
goto ceti    # Test it works
```

### Quarterly (5 minutes)
Security and permissions audit:
```bash
# Check file permissions
ls -la ~/.goto-config.sh           # Should be readable (644 or 664)
ls -la ~/Documents/LUXOR/.goto-config.sh

# Verify files not in git
git status | grep -i config        # Should show nothing

# Check documentation is current
ls -la ~/Documents/LUXOR/*SETUP*.md
```

### Annual (15 minutes)
Cleanup and refresh:
```bash
# Backup config
cp ~/.goto-config.sh ~/.goto-config.sh.backup.$(date +%Y%m%d)

# Review shortcuts - remove unused ones
nano ~/.goto-config.sh

# Check git history size (should be stable)
du -sh .git/

# Update documentation if patterns changed
vim LOCAL-CUSTOMIZATION.md
```

---

## Health Indicators

| Status | Check | Action |
|--------|-------|--------|
| 🟢 Green | `git pull origin main` succeeds cleanly | Everything working, no action needed |
| 🟡 Yellow | `git pull origin main` has unrelated changes | Review changes, update documentation |
| 🔴 Red | `git pull origin main` fails with conflicts | See Troubleshooting-Advanced.md |

---

## Automation (Optional)

Create `~/.goto-maintenance.sh`:
```bash
#!/bin/bash
# Run monthly maintenance automatically

cd ~/Documents/LUXOR/Git_Repos/unix-goto

echo "📦 Fetching latest updates..."
git fetch origin

echo "🔍 Checking for changes..."
COMMITS=$(git log --oneline origin/main..HEAD | wc -l)
if [ $COMMITS -gt 0 ]; then
    echo "⚠️  New commits available. Run: git pull origin main"
else
    echo "✅ Already up to date"
fi

echo "🧪 Verifying setup..."
source ~/Documents/LUXOR/Git_Repos/unix-goto/lib/goto-function.sh
source ~/.goto-config.sh

if command -v goto &>/dev/null; then
    echo "✅ goto is available"
else
    echo "❌ goto not available"
fi
```

---

## References
- **Setup**: See UNIX-GOTO-SETUP.md
- **Pattern**: See LOCAL-CUSTOMIZATION.md
- **Strategy**: See GIT-STRATEGY-COMPARISON.md
- **Troubleshooting**: See TROUBLESHOOTING-ADVANCED.md
