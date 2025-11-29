# Contributing to unix-goto

**Date**: October 27, 2025
**Purpose**: Guide for contributing improvements back to the public repository
**Audience**: Users who want to share their general-purpose shortcuts

---

## What to Contribute vs. Keep Local

### Keep Local (.goto-config.sh)
- Project-specific shortcuts (LUXOR, CETI)
- Private paths
- User-specific preferences

### Contribute to Public (lib/goto-function.sh)
- General-purpose shortcuts
- Utilities useful to other users
- Bug fixes
- Documentation improvements

---

## Contribution Workflow

### 1. Create Feature Branch
```bash
cd ~/Documents/LUXOR/Git_Repos/unix-goto
git checkout -b feature/my-shortcut
```

### 2. Edit lib/goto-function.sh
```bash
# Add your shortcut (NOT to .goto-config.sh)
nano lib/goto-function.sh
```

### 3. Test Thoroughly
```bash
# Test in bash and zsh
bash -c 'source lib/goto-function.sh && goto my_shortcut'
zsh -c 'source lib/goto-function.sh && goto my_shortcut'
```

### 4. Commit & Push
```bash
git add lib/goto-function.sh
git commit -m "Add: my_shortcut for community use"
git push origin feature/my-shortcut
```

### 5. Create Pull Request
Go to GitHub and describe your contribution

---

## Good Commit Messages
- `Add: new shortcut for XYZ`
- `Fix: shortcut not working on Linux`
- `Improve: documentation clarity`

---

## Code Review Expectations
- General-purpose (not user-specific)
- Works in bash AND zsh
- No hardcoded absolute paths
- Uses $HOME, $PWD variables
- Clear documentation

---

## References
- See GIT-STRATEGY-COMPARISON.md for why local is separate
- See LOCAL-CUSTOMIZATION.md for keeping local config safe
- See UNIX-GOTO-SETUP.md for setup verification
