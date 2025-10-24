# Standard Workflow - Going Forward

## For ALL Future Use

### Quick Test (Development)
```bash
cd /path/to/unix-goto
source goto.sh
```

### Permanent Install (End Users)
```bash
echo "source /path/to/unix-goto/goto.sh" >> ~/.bashrc
source ~/.bashrc
```

**That's it. Always.**

---

## Development Workflow

### 1. Start Development
```bash
cd /path/to/unix-goto
source goto.sh
```

### 2. Make Changes
Edit files in `lib/`

### 3. Test Changes
```bash
# Re-source to load changes
source goto.sh

# Test your feature
goto <your-feature>

# Run automated tests
bash test-cache.sh
bash test-benchmark.sh
```

### 4. Commit
```bash
git add .
git commit -m "feat: your feature"
```

---

## Key Principles (ALWAYS Follow)

### 1. Simple
**ONE line to load everything:**
```bash
source goto.sh
```

No complex installation. No multi-step process.

### 2. Fast
- Cache provides 8x speedup
- Navigation <100ms
- Benchmarks prove it

### 3. Lean
- No bloat
- No unnecessary dependencies
- Minimal overhead

### 4. Tested
- 27 automated tests
- 100% passing
- Performance validated

---

## File Structure (Standard)

```
unix-goto/
├── goto.sh                    # ← ONE-LINE LOADER (use this!)
├── QUICKSTART.md              # ← Simple user instructions
├── lib/
│   ├── cache-index.sh        # Cache system
│   ├── benchmark-command.sh  # Benchmarks
│   ├── goto-function.sh      # Main goto
│   └── ...other modules
├── test-cache.sh             # Cache tests
├── test-benchmark.sh         # Benchmark tests
└── STANDARD-WORKFLOW.md      # This file
```

---

## Standard Commands

### Cache (Always Use This)
```bash
goto index rebuild    # Build cache (one-time)
goto index status     # Check cache
goto index --help     # See options
```

### Navigation (Instant After Cache)
```bash
goto HALCON          # 26ms (instant!)
goto chatz           # 26ms (instant!)
goto <any-folder>    # Fast cached lookup
```

### Benchmarks (Validate Performance)
```bash
goto benchmark --help
goto benchmark report
```

---

## Documentation Standards

### For New Features

**Always Include:**
1. One-line usage example
2. Performance impact (if any)
3. Test coverage
4. Update QUICKSTART.md if user-facing

**Keep It Simple:**
- Short, clear examples
- No verbose explanations
- Fast reference format

---

## Testing Standards

### Before Commit

**Always Run:**
```bash
bash test-cache.sh        # Cache tests
bash test-benchmark.sh    # Benchmark tests
```

**Both must pass 100%**

### For New Features

**Add Tests:**
- Create test in appropriate test file
- Cover edge cases
- Validate performance

---

## Commit Standards

### Format
```bash
git commit -m "type: description

Details if needed.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### Types
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `test:` - Testing only
- `refactor:` - Code refactoring

---

## What Changed (For Reference)

### Old Way ❌
```bash
# Complex multi-step installation
source lib/history-tracking.sh
source lib/back-command.sh
source lib/recent-command.sh
source lib/bookmark-command.sh
source lib/cache-index.sh
source lib/list-command.sh
source lib/benchmark-command.sh
source lib/benchmark-workspace.sh
source lib/goto-function.sh
```

### New Way ✅
```bash
# ONE line
source goto.sh
```

---

## Future Development

### All New Features

**Must Follow:**
1. Load via `goto.sh` (no separate installation)
2. Include tests
3. Document in QUICKSTART.md
4. Keep it simple
5. Keep it fast
6. Keep it lean

### No Exceptions

**Simple. Fast. Lean.**

That's the standard. Always.

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────┐
│  UNIX-GOTO STANDARD WORKFLOW                        │
├─────────────────────────────────────────────────────┤
│                                                      │
│  Test:      source goto.sh                          │
│  Install:   echo 'source /path/goto.sh' >> ~/.bashrc│
│                                                      │
│  Cache:     goto index rebuild                      │
│  Navigate:  goto <folder>                           │
│  Test:      bash test-*.sh                          │
│                                                      │
│  Simple. Fast. Lean.                                │
│                                                      │
└─────────────────────────────────────────────────────┘
```

---

**This is the standard. Going forward. Always.** ✅
