# Contributing to unix-goto

Thank you for your interest in contributing to unix-goto! This guide will help you get started.

---

## 🚀 Quick Start

1. **Fork and Clone**
   ```bash
   git clone https://github.com/manutej/unix-goto.git
   cd unix-goto
   ```

2. **Create a Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make Changes and Test**
   - Follow the testing guide (TESTING-GUIDE.md)
   - Ensure no regressions

4. **Create Pull Request**
   - Push your branch
   - Open PR on GitHub
   - Wait for review

---

## 📋 Development Workflow

### Branch Protection

**master branch is protected:**
- ❌ No direct pushes allowed
- ✅ All changes must go through Pull Requests
- ✅ PR review required before merge
- ✅ Status checks must pass (when available)

### Branching Strategy

Use descriptive branch names with prefixes:

```bash
feature/branch-name    # New features
fix/branch-name        # Bug fixes
docs/branch-name       # Documentation only
test/branch-name       # Testing improvements
refactor/branch-name   # Code refactoring
```

**Examples:**
- `feature/enhanced-navigation`
- `fix/bookmark-permissions`
- `docs/usage-examples`
- `test/automated-suite`

---

## 🔄 Pull Request Process

### 1. Before Creating PR

- [ ] Run through relevant tests in TESTING-GUIDE.md
- [ ] Verify no regressions (all Phase 1 & 2 features still work)
- [ ] Update documentation if needed
- [ ] Write clear commit messages

### 2. Creating the PR

**Title Format:**
```
[Type] Brief description

Examples:
[Feature] Add multi-level navigation support
[Fix] Resolve bookmark file permission issue
[Docs] Add usage examples for new features
```

**PR Description Should Include:**
```markdown
## What Does This PR Do?
[Brief description of changes]

## Why Is This Needed?
[Problem being solved or feature being added]

## What Changed?
- File 1: [description]
- File 2: [description]

## Testing Done
- [ ] Tested feature X
- [ ] Tested feature Y
- [ ] Ran regression tests

## Related Issues
Closes #123 (if applicable)

## Screenshots/Examples
[If applicable, show before/after or usage examples]
```

### 3. PR Review Checklist

Reviewers will check:
- [ ] Code quality and readability
- [ ] No breaking changes (unless major version)
- [ ] Tests pass (manual until automated suite exists)
- [ ] Documentation updated
- [ ] Commit messages clear and descriptive
- [ ] No merge conflicts

### 4. After Approval

- PR will be merged via GitHub (squash or merge commit)
- Feature branch will be deleted
- Updates will appear in next release

---

## 📝 Commit Message Guidelines

### Format

```
Brief summary (50 chars or less)

Detailed explanation of what changed and why. Wrap at 72 characters.
Include any relevant context or motivation.

- Bullet points for multiple changes
- Reference issues: Fixes #123

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Good Examples

```
Add multi-level navigation support

Implements support for nested folder navigation using path separators.
Users can now use: goto project/subfolder/deep

This maintains backward compatibility with all existing features.
```

```
Fix bookmark file permissions issue

Bookmarks file was created with restrictive permissions causing
failures on some systems. Now uses standard permissions.

Fixes #42
```

### Bad Examples

```
❌ "Fixed stuff"
❌ "WIP"
❌ "Update goto-function.sh"
❌ "asdf"
```

---

## 🧪 Testing Requirements

### Manual Testing (Current)

Before submitting PR:

1. **Run Relevant Tests**
   - See TESTING-GUIDE.md
   - Test new feature thoroughly
   - Run regression tests for affected areas

2. **Document Test Results**
   - Note any issues found
   - Include in PR description

3. **Test on Your System**
   - Ensure works in your shell (zsh/bash)
   - Verify on your directory structure

### Automated Testing (Future)

Once implemented:
- All tests must pass before merge
- CI/CD will run test suite automatically
- Coverage reports will be generated

---

## 📚 Documentation Standards

### When to Update Documentation

Update docs when you:
- Add new features
- Change existing behavior
- Fix bugs that affect usage
- Add new configuration options

### Files to Update

**README.md**
- Add new features to feature list
- Update usage examples
- Update roadmap checklist

**CHANGELOG.md**
- Add entry under [Unreleased]
- Follow format: `- [Type] Description`

**TESTING-GUIDE.md**
- Add test scenarios for new features
- Update regression tests if needed

**PROJECT-STATUS.md**
- Update after major milestones
- Reflect current state accurately

---

## 🎨 Code Style

### Shell Script Style

**General Principles:**
- Use clear, descriptive variable names
- Add comments for complex logic
- Use functions for reusable code
- Handle errors gracefully

**Naming Conventions:**
```bash
# Functions: lowercase with underscores
__goto_navigate_to() { ... }

# Variables: lowercase with underscores
local target_dir="$1"

# Constants: UPPERCASE
GOTO_HISTORY_FILE="$HOME/.goto_history"

# Private functions: prefix with __goto_
__goto_internal_helper() { ... }

# Public commands: no prefix
goto() { ... }
bookmark() { ... }
```

**Error Handling:**
```bash
# Always check for errors
if [ ! -d "$path" ]; then
    echo "❌ Error: Directory does not exist: $path"
    return 1
fi

# Return appropriate exit codes
return 0  # Success
return 1  # Error
```

**macOS Compatibility:**
```bash
# Use explicit paths for macOS commands
/usr/bin/grep "pattern" file
/bin/date +%s
/usr/bin/find . -name "*.sh"

# This avoids conflicts with user-installed tools
```

---

## 🐛 Reporting Issues

### Before Opening an Issue

1. Check if issue already exists
2. Search closed issues too
3. Try latest version from master

### Issue Template

```markdown
**Description**
[Clear description of the problem]

**Expected Behavior**
[What should happen]

**Actual Behavior**
[What actually happens]

**Steps to Reproduce**
1. ...
2. ...
3. ...

**Environment**
- OS: [macOS 14, Ubuntu 22.04, etc.]
- Shell: [zsh, bash]
- unix-goto version: [v0.2.0, commit hash]

**Additional Context**
[Any other relevant information]
```

---

## 🎯 Project Roadmap

See [ROADMAP.md](ROADMAP.md) for planned features.

**Current Phase:** Phase 2 Complete → Pre-Phase 3 Improvements

**Areas Needing Help:**
1. **Testing** - Automated test suite implementation
2. **Documentation** - More usage examples
3. **Features** - Phase 3 planning and implementation
4. **Cross-platform** - Linux compatibility testing

---

## 💡 Feature Requests

Have an idea for a new feature?

1. Open an issue with `[Feature Request]` in title
2. Describe the feature and use case
3. Explain why it would be useful
4. Suggest implementation approach (optional)

**We welcome:**
- Navigation improvements
- Performance optimizations
- Better error messages
- New commands
- Integration with other tools

---

## 🏷️ Release Process

### Version Numbers

Follow [Semantic Versioning](https://semver.org/):
- **Major** (1.0.0): Breaking changes
- **Minor** (0.1.0): New features, backward compatible
- **Patch** (0.0.1): Bug fixes

### Release Checklist

1. Update CHANGELOG.md
2. Update version in README.md
3. Run full test suite
4. Create git tag: `git tag -a v0.x.0 -m "..."`
5. Push tag: `git push origin v0.x.0`
6. Create GitHub release with notes

---

## 📞 Getting Help

- **Issues:** https://github.com/manutej/unix-goto/issues
- **Discussions:** (when enabled)
- **Email:** [Project maintainer email if available]

---

## 🙏 Code of Conduct

### Our Standards

- Be respectful and inclusive
- Welcome newcomers
- Focus on constructive feedback
- Respect differing opinions

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or insulting comments
- Publishing others' private information

---

## 📜 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to unix-goto!** 🚀

Your contributions help make terminal navigation better for everyone.
