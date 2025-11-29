# Git Workflow Reference: Config-File Pattern

**Quick reference for day-to-day operations**

---

## Quick Start

Source the automation functions:
```bash
source ~/Documents/LUXOR/Git_Repos/unix-goto/GIT-WORKFLOW-AUTOMATION.sh
```

Then use:
```bash
update-public        # Pull latest safely
check-conflicts      # Detect naming conflicts
verify-locals        # Ensure gitignore is correct
test-pull           # Preview updates
```

---

## Daily Operations

### Pull Updates
```bash
update-public
```
- Stashes local changes if needed
- Pulls from GitHub
- Runs test suite
- Reloads shell

### Preview Changes
```bash
test-pull
```
- Shows commits available from public repo
- Non-destructive

### Check for Issues
```bash
check-conflicts
```
- Lists shortcuts with same name in public and local
- Local version takes precedence (no error)

---

## Adding Custom Shortcuts

1. Edit local config:
```bash
nano ~/.goto-config.sh
```

2. Add function:
```bash
my_shortcut() {
    echo "/path/to/thing"
}
```

3. Reload shell:
```bash
exec $SHELL
```

4. Test:
```bash
goto my_shortcut
```

---

## Contributing Back

1. Create feature branch:
```bash
cd ~/Documents/LUXOR/Git_Repos/unix-goto
git checkout -b feature/useful-shortcut
```

2. Edit public file (NOT local):
```bash
nano lib/goto-function.sh
```

3. Test in bash AND zsh:
```bash
bash -c 'source lib/goto-function.sh && goto my_shortcut'
zsh -c 'source lib/goto-function.sh && goto my_shortcut'
```

4. Commit and push:
```bash
git add lib/goto-function.sh
git commit -m "Add: useful-shortcut"
git push origin feature/useful-shortcut
```

5. Create PR on GitHub

---

## Troubleshooting

### "goto: command not found"
```bash
source ~/Documents/LUXOR/Git_Repos/unix-goto/lib/goto-function.sh
source ~/.goto-config.sh
```

### Test failing
```bash
bash ~/Documents/LUXOR/Git_Repos/unix-goto/unix-goto.test.sh
```

### Check operation log
```bash
tail ~/.goto-workflow.log
```

---

## File Reference

| File | Purpose | In Git? |
|------|---------|---------|
| lib/goto-function.sh | Public shortcuts | ✅ Yes |
| .goto-config.sh | Your local shortcuts | ❌ No |
| unix-goto.test.sh | Test suite | ✅ Yes |
| GIT-WORKFLOW-AUTOMATION.sh | Workflow functions | ✅ Yes |

---

## Best Practices

✅ Keep .goto-config.sh outside git repo
✅ Always run tests before pull
✅ Check conflicts before updating
✅ Contribute general shortcuts back
✅ Use `update-public` for safe merges

---

## Emergency Recovery

If something breaks:
```bash
cd ~/Documents/LUXOR/Git_Repos/unix-goto
git reset --hard HEAD
exec $SHELL
bash verify-unix-goto-setup.sh
```
