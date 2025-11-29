# Advanced Troubleshooting: Config-File Pattern

**Date**: October 27, 2025
**Purpose**: Resolve complex issues with unix-goto Config-File Pattern
**Audience**: Users with git or shell compatibility issues

---

## Issue 1: Merge Conflicts After Git Pull

**Symptom**: `git pull origin main` shows merge conflicts

**Cause**: Extremely rare - should not happen with Config-File Pattern

**Resolution**:
```bash
# Check what's conflicting
git status

# If issue persists, see troubleshooting in UNIX-GOTO-SETUP.md
```

---

## Issue 2: "goto: command not found"

**Symptom**: `bash: goto: command not found`

**Cause**: Files not sourced in shell profile

**Solution**:
Add to ~/.bashrc or ~/.zshrc:
```bash
if [ -f ~/Documents/LUXOR/Git_Repos/unix-goto/lib/goto-function.sh ]; then
    source ~/Documents/LUXOR/Git_Repos/unix-goto/lib/goto-function.sh
fi

if [ -f ~/.goto-config.sh ]; then
    source ~/.goto-config.sh
fi
```

Then reload: `exec $SHELL`

---

## Issue 3: Different Results in Bash vs Zsh

**Symptom**: Works in bash but not zsh

**Solution**: Use POSIX-compatible syntax. Avoid bash-specific features in .goto-config.sh

---

## Issue 4: Performance Issues

**Symptom**: Shell startup is slow

**Diagnosis**:
```bash
# Time shell startup
time bash -i -c exit
time zsh -i -c exit
```

**Solution**: Keep .goto-config.sh simple with just function definitions

---

## Issue 5: Multiple Users / Shared Environments

**Solution**: Use $HOME variable instead of hardcoded paths
```bash
# ✅ Correct
function luxor() {
    echo "$HOME/Documents/LUXOR"
}

# ❌ Wrong
function luxor() {
    echo "/Users/alice/Documents/LUXOR"
}
```

---

## References
- See LONG-TERM-MAINTENANCE.md for routine checks
- See UNIX-GOTO-SETUP.md for initial troubleshooting
- See verify-unix-goto-setup.sh for automated diagnostics
