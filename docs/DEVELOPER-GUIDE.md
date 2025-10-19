# unix-goto Developer Guide

**Version:** 0.4.0
**Last Updated:** 2025-10-17
**Target Audience:** Contributors, Maintainers, Advanced Users

Comprehensive guide for developers who want to understand, extend, or contribute to the unix-goto project.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Project Structure](#project-structure)
- [Adding New Features](#adding-new-features)
- [Testing Requirements](#testing-requirements)
- [Performance Standards](#performance-standards)
- [Commit Standards](#commit-standards)
- [Linear Issue Workflow](#linear-issue-workflow)
- [Code Style Guide](#code-style-guide)
- [Debugging Tips](#debugging-tips)
- [Release Process](#release-process)

---

## Project Overview

### Mission

Provide the fastest, most intuitive Unix navigation system with natural language support, powerful caching, and comprehensive developer tools.

### Design Principles

1. **Simple** - One-line loading, minimal configuration
2. **Fast** - Sub-100ms navigation performance
3. **Lean** - No bloat, no unnecessary dependencies
4. **Tested** - 100% test coverage for core features
5. **Documented** - Clear, comprehensive documentation

### Technology Stack

- **Language:** Bash 4.0+ / Zsh
- **Testing:** Custom bash test framework
- **Performance:** Built-in benchmark suite
- **AI Integration:** Claude CLI (optional)
- **Version Control:** Git + Linear issue tracking

### Current Status (v0.4.0)

- **Phase 3:** Smart Search & Discovery (In Progress)
- **Completed:** 2/9 features (CET-77, CET-85)
- **Lines of Code:** ~7,000+
- **Test Coverage:** 100% for core features
- **Performance:** 8x speedup with caching (26ms vs 208ms)

---

## Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      User Interface                         │
│  goto, bookmark, recent, back, goto list, goto benchmark   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Core Navigation                          │
│  goto-function.sh - Main routing and path resolution        │
└─────────────────────────────────────────────────────────────┘
                            │
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                 ▼
┌──────────────────┐ ┌──────────────┐ ┌──────────────────┐
│  Cache System    │ │  Bookmarks   │ │  History         │
│  cache-index.sh  │ │  bookmark-   │ │  history-        │
│                  │ │  command.sh  │ │  tracking.sh     │
│  O(1) lookup     │ │              │ │                  │
│  Auto-refresh    │ │  Add/Remove  │ │  Track visits    │
└──────────────────┘ └──────────────┘ └──────────────────┘
          │                 │                 │
          └─────────────────┴─────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Support Modules                          │
│  list-command.sh, back-command.sh, recent-command.sh        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  Performance & Metrics                      │
│  benchmark-command.sh, benchmark-workspace.sh               │
└─────────────────────────────────────────────────────────────┘
```

### Module Dependencies

```
goto.sh (loader)
  ├── history-tracking.sh (no dependencies)
  ├── back-command.sh (depends on: history-tracking.sh)
  ├── recent-command.sh (depends on: history-tracking.sh)
  ├── bookmark-command.sh (no dependencies)
  ├── cache-index.sh (no dependencies)
  ├── list-command.sh (depends on: bookmark-command.sh)
  ├── benchmark-command.sh (depends on: cache-index.sh)
  ├── benchmark-workspace.sh (no dependencies)
  └── goto-function.sh (depends on: all above)
```

**Load Order:** Critical - dependencies must be loaded before dependents.

### Data Flow

```
User Input
    │
    ▼
goto "project"
    │
    ├─► Check special cases (list, index, benchmark, @bookmark)
    │
    ├─► Check multi-level paths (contains /)
    │
    ├─► Try cache lookup (O(1))
    │   │
    │   ├─► Cache hit → Navigate directly
    │   │
    │   └─► Cache miss → Fall through
    │
    ├─► Try direct folder match in search paths
    │
    ├─► Recursive search (max depth 3)
    │   │
    │   ├─► Single match → Navigate
    │   │
    │   └─► Multiple matches → Show disambiguation
    │
    └─► Natural language AI resolution (if spaces)
        │
        └─► Navigate to resolved path
```

---

## Getting Started

### Prerequisites

1. **Operating System:** macOS or Linux
2. **Shell:** Bash 4.0+ or Zsh
3. **Tools:**
   - `git` - Version control
   - `find` - File system traversal
   - `grep` - Pattern matching
   - `python3` - High-precision timing (optional)
4. **Optional:**
   - Claude CLI - Natural language support
   - `glow` - Pretty markdown display

### Initial Setup

```bash
# 1. Clone the repository
git clone https://github.com/manutej/unix-goto.git
cd unix-goto

# 2. Make scripts executable
chmod +x install.sh
chmod +x test-*.sh
chmod +x bin/*

# 3. Load for development
source goto.sh

# 4. Verify installation
goto --help

# 5. Run tests
bash test-cache.sh
bash test-benchmark.sh

# 6. Build initial cache
goto index rebuild
```

### Development Environment

```bash
# Set up development environment variables
export GOTO_SEARCH_DEPTH=3
export GOTO_CACHE_TTL=86400
export GOTO_BENCHMARK_ITERATIONS=10

# Enable verbose output for debugging
set -x  # Enable bash tracing
goto your-test-folder
set +x  # Disable bash tracing
```

---

## Development Workflow

### Standard Development Cycle

```bash
# 1. Start development session
cd /path/to/unix-goto
source goto.sh

# 2. Create feature branch (if not exists)
git checkout -b feature/your-feature-name

# 3. Make changes to lib/ files
vim lib/your-module.sh

# 4. Reload changes
source goto.sh

# 5. Test manually
goto test-case-1
goto test-case-2

# 6. Run automated tests
bash test-cache.sh
bash test-benchmark.sh

# 7. Run benchmarks (if performance-related)
goto benchmark navigation
goto benchmark cache

# 8. Commit changes
git add .
git commit -m "feat: your feature description

Detailed explanation if needed.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 9. Push to remote
git push origin feature/your-feature-name
```

### Quick Test Loop

```bash
# Fast iteration cycle
while true; do
    # 1. Edit code
    vim lib/module.sh

    # 2. Reload
    source goto.sh

    # 3. Test
    goto test-case

    # Repeat
done
```

### Testing Changes

```bash
# Unit tests (module-specific)
bash test-cache.sh           # Cache functionality
bash test-benchmark.sh       # Benchmark functionality

# Integration tests (manual)
goto list                    # Discovery
goto @bookmark               # Bookmarks
back                         # History
recent                       # Recent folders

# Performance validation
goto benchmark all           # Full benchmark suite
goto benchmark report        # Check metrics
```

---

## Project Structure

### Directory Layout

```
unix-goto/
├── goto.sh                      # Single-file loader (ENTRY POINT)
│
├── lib/                         # Core modules
│   ├── goto-function.sh         # Main navigation logic
│   ├── cache-index.sh           # Caching system (CET-77)
│   ├── bookmark-command.sh      # Bookmark management
│   ├── history-tracking.sh      # Navigation history
│   ├── back-command.sh          # Back navigation
│   ├── recent-command.sh        # Recent folders
│   ├── list-command.sh          # Discovery tools
│   ├── benchmark-command.sh     # Benchmarking (CET-85)
│   └── benchmark-workspace.sh   # Test workspace generation
│
├── bin/                         # Executables
│   ├── goto-resolve             # AI resolver script
│   └── benchmark-goto           # Standalone benchmark tool
│
├── test-cache.sh                # Cache system tests
├── test-benchmark.sh            # Benchmark tests
│
├── install.sh                   # Installation script
│
├── docs/                        # Documentation
│   ├── API.md                   # API reference
│   ├── DEVELOPER-GUIDE.md       # This file
│   ├── QUICKSTART.md            # User quick start
│   ├── BENCHMARKS.md            # Benchmark documentation
│   ├── STANDARD-WORKFLOW.md     # Development workflow
│   └── PROJECT-TRACKER.md       # Project status
│
├── examples/                    # Example scripts
│   └── benchmark-examples.sh    # Benchmark usage examples
│
└── README.md                    # Project overview
```

### File Responsibilities

**goto.sh** - Single entry point that loads all modules in correct order

**lib/goto-function.sh** - Core navigation logic:
- `goto` main function
- `__goto_navigate_to` helper
- Path resolution and routing
- AI integration

**lib/cache-index.sh** - High-performance caching:
- `goto index` commands
- `__goto_cache_build` - Build index
- `__goto_cache_lookup` - O(1) lookup
- `__goto_cache_is_valid` - Validation

**lib/bookmark-command.sh** - Bookmark management:
- `bookmark` main function
- Add/remove/list/goto operations
- Persistent storage in `~/.goto_bookmarks`

**lib/history-tracking.sh** - Navigation history:
- `__goto_track` - Record visits
- `__goto_get_history` - Retrieve history
- `__goto_recent_dirs` - Recent unique folders

**lib/back-command.sh** - Stack-based back navigation:
- `back` main function
- `__goto_stack_push/pop` - Stack operations

**lib/recent-command.sh** - Recent folders interface:
- `recent` main function
- Display and navigation

**lib/list-command.sh** - Discovery tools:
- `goto list` commands
- Show shortcuts, bookmarks, folders
- Recent folder display

**lib/benchmark-command.sh** - Performance benchmarking:
- `goto benchmark` commands
- Navigation, cache, parallel benchmarks
- Result recording and reporting

**lib/benchmark-workspace.sh** - Test workspace management:
- Create test environments
- Workspace statistics
- Cleanup tools

---

## Adding New Features

### Step-by-Step Guide

#### 1. Plan Your Feature

**Questions to Answer:**
- What problem does this solve?
- What's the user interface (commands/flags)?
- What's the expected performance?
- What dependencies exist?
- What tests are needed?
- What documentation is required?

**Example: Adding a "favorites" feature**
- Problem: Quick access to most-visited folders
- Interface: `goto favorites` command
- Performance: <10ms (in-memory only)
- Dependencies: history-tracking.sh
- Tests: Count accuracy, sorting, limit handling
- Docs: API.md, README.md updates

#### 2. Create Module (if needed)

```bash
# Create new module file
touch lib/favorites-command.sh
chmod +x lib/favorites-command.sh
```

**Template:**
```bash
#!/bin/bash
# unix-goto - Favorites management
# https://github.com/manutej/unix-goto

# Storage location
GOTO_FAVORITES_FILE="${GOTO_FAVORITES_FILE:-$HOME/.goto_favorites}"

# Main function
goto_favorites() {
    local subcommand="$1"
    shift

    case "$subcommand" in
        list)
            # Implementation
            ;;
        add)
            # Implementation
            ;;
        --help|-h|help|"")
            echo "goto favorites - Manage favorite folders"
            echo ""
            echo "Usage:"
            echo "  goto favorites list     List favorites"
            echo "  goto favorites add      Add current folder"
            echo ""
            ;;
        *)
            echo "Unknown command: $subcommand"
            echo "Try 'goto favorites --help'"
            return 1
            ;;
    esac
}
```

#### 3. Add to Loader

Edit `goto.sh`:
```bash
# Add to load sequence (respect dependencies)
source "$GOTO_LIB_DIR/history-tracking.sh"
source "$GOTO_LIB_DIR/favorites-command.sh"  # NEW
source "$GOTO_LIB_DIR/back-command.sh"
# ...
```

#### 4. Integrate with Main Function

Edit `lib/goto-function.sh`:
```bash
goto() {
    # ... existing code ...

    case "$1" in
        # ... existing cases ...

        favorites)  # NEW
            if command -v goto_favorites &> /dev/null; then
                shift
                goto_favorites "$@"
            else
                echo "⚠️  Favorites command not loaded"
            fi
            return
            ;;
    esac

    # ... rest of function ...
}
```

#### 5. Add Tests

Create `test-favorites.sh`:
```bash
#!/bin/bash
# Test suite for favorites functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load module
source "$SCRIPT_DIR/lib/favorites-command.sh"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper
pass() {
    echo "✓ PASS: $1"
    ((TESTS_PASSED++))
}

fail() {
    echo "✗ FAIL: $1"
    ((TESTS_FAILED++))
}

# Test 1: List empty favorites
test_empty_list() {
    rm -f "$GOTO_FAVORITES_FILE"
    local output=$(goto_favorites list 2>&1)

    if [[ "$output" == *"No favorites"* ]]; then
        pass "Empty favorites list"
    else
        fail "Empty favorites list"
    fi
}

# Run tests
test_empty_list
# Add more tests...

# Summary
echo ""
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    echo "✓ ALL TESTS PASSED"
    exit 0
else
    echo "✗ SOME TESTS FAILED"
    exit 1
fi
```

#### 6. Document API

Add to `API.md`:
```markdown
## Favorites API

### `goto favorites`

Manage most-visited favorite folders.

**Signature:**
```bash
goto favorites <subcommand>
```

**Subcommands:**
- `list` - Show favorite folders
- `add` - Add current folder to favorites
...
```

#### 7. Update User Documentation

Add to `README.md`:
```markdown
### Favorites

Track and navigate to your most-visited folders:

```bash
goto favorites list    # Show favorites
goto favorites add     # Add current folder
goto @fav              # Navigate to favorite
```
```

#### 8. Performance Considerations

```bash
# Add benchmark if performance-critical
goto benchmark favorites 10

# Measure overhead
time goto_favorites list
```

### Feature Checklist

Before submitting:
- [ ] Implementation complete
- [ ] Loaded in `goto.sh`
- [ ] Integrated with main `goto` function
- [ ] Tests written and passing
- [ ] API documented
- [ ] User documentation updated
- [ ] Performance validated (if applicable)
- [ ] Linear issue updated
- [ ] Committed with proper message

---

## Testing Requirements

### Test Coverage Goals

- **Core navigation:** 100%
- **Cache system:** 100%
- **Bookmarks:** 100%
- **History:** 100%
- **Benchmarks:** 100%
- **New features:** 100%

### Writing Tests

**Structure:**
```bash
#!/bin/bash
# Test suite for <feature>

set -e  # Exit on error

# Setup
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/module.sh"

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helpers
pass() { echo "✓ $1"; ((TESTS_PASSED++)); }
fail() { echo "✗ $1"; ((TESTS_FAILED++)); }

# Test functions
test_feature_1() {
    # Arrange
    local input="test"

    # Act
    local result=$(function_under_test "$input")

    # Assert
    if [[ "$result" == "expected" ]]; then
        pass "Feature 1 works"
    else
        fail "Feature 1 failed: got '$result'"
    fi
}

# Run tests
test_feature_1
# ... more tests ...

# Summary
echo ""
echo "Passed: $TESTS_PASSED, Failed: $TESTS_FAILED"
[ $TESTS_FAILED -eq 0 ] && exit 0 || exit 1
```

### Test Categories

**1. Unit Tests** - Test individual functions
```bash
test_cache_lookup() {
    result=$(__goto_cache_lookup "unix-goto")
    [ $? -eq 0 ] && pass || fail
}
```

**2. Integration Tests** - Test module interaction
```bash
test_navigation_with_cache() {
    goto index rebuild
    goto unix-goto
    [ $? -eq 0 ] && pass || fail
}
```

**3. Edge Cases** - Test boundary conditions
```bash
test_empty_input() {
    result=$(goto "" 2>&1)
    [[ "$result" == *"help"* ]] && pass || fail
}
```

**4. Performance Tests** - Validate speed
```bash
test_cache_speed() {
    start=$(date +%s%N)
    __goto_cache_lookup "project"
    end=$(date +%s%N)
    duration=$(((end - start) / 1000000))
    [ $duration -lt 100 ] && pass || fail
}
```

### Running Tests

```bash
# Run all tests
bash test-cache.sh
bash test-benchmark.sh

# Run with verbose output
bash -x test-cache.sh

# Run specific test
# (edit test file to comment out others)
```

---

## Performance Standards

### Navigation Performance

**Targets:**
- Cached navigation: <100ms
- Uncached navigation: <2s
- Cache hit rate: >90%
- Speedup ratio: 20-50x

**Measurement:**
```bash
goto benchmark navigation unix-goto 10
```

**Optimization Tips:**
- Use cache for all lookups
- Limit recursive search depth
- Avoid redundant filesystem operations
- Use `grep` for fast text matching

### Cache Performance

**Targets:**
- Build time: <5s for 500 folders
- Lookup time: <100ms
- Hit rate: >90%

**Measurement:**
```bash
goto benchmark cache typical 10
```

**Optimization Tips:**
- Minimize `find` depth
- Use efficient file formats
- Implement TTL-based refresh
- Avoid frequent rebuilds

### Memory Footprint

**Goals:**
- Cache file: <100KB for 500 folders
- Memory usage: Minimal (shell functions only)
- No persistent processes

### Benchmark All Changes

```bash
# Before changes
goto benchmark all > before.txt

# Make changes
# ...

# After changes
goto benchmark all > after.txt

# Compare
diff before.txt after.txt
```

---

## Commit Standards

### Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

**Example:**
```
feat: implement favorites tracking system (CET-90)

Add favorites management for quick access to most-visited folders.

Features:
- goto favorites list - Show top 10 favorites
- goto favorites add - Add current folder
- Auto-ranking by visit count
- Persistent storage in ~/.goto_favorites

Performance:
- List favorites: <10ms (in-memory)
- Add favorite: <5ms (append-only)

Tests:
- 8/8 tests passing
- 100% coverage for favorites module

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Commit Types

- `feat:` - New feature
- `fix:` - Bug fix
- `perf:` - Performance improvement
- `refactor:` - Code refactoring (no behavior change)
- `test:` - Add or update tests
- `docs:` - Documentation only
- `chore:` - Build, dependencies, or tooling

### Subject Line

- Use imperative mood ("add" not "added")
- No period at end
- Max 50 characters
- Include Linear issue ID if applicable

### Body

- Explain what and why (not how)
- Wrap at 72 characters
- Include performance metrics if applicable
- Include test results

### Footer

- Include Claude Code attribution
- Link to Linear issue
- Reference related commits

---

## Linear Issue Workflow

### Linear Project

**Team:** Ceti-luxor
**Project:** unix-goto - Shell Navigation Tool
**Project ID:** 7232cafe-cb71-4310-856a-0d584e6f3df0

### Issue Lifecycle

```
Backlog → In Progress → Complete
```

### Working with Issues

**1. Pick an Issue**
```bash
# View issues in Linear
# Select from Phase 3 backlog
# Check dependencies
```

**2. Move to "In Progress"**
- Update status in Linear
- Assign to yourself
- Add comment with approach

**3. Create Feature Branch**
```bash
git checkout -b feature/CET-XX-feature-name
```

**4. Implement**
- Follow development workflow
- Write tests
- Update documentation

**5. Test Thoroughly**
```bash
bash test-cache.sh
bash test-benchmark.sh
goto benchmark all
```

**6. Commit**
```bash
git commit -m "feat: implement feature (CET-XX)

Details...

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

**7. Update Linear Issue**
- Add implementation comment
- Include test results
- Include performance metrics
- Link to commit

**8. Move to "Complete"**
- Update status
- Close issue

### Issue Template

When creating issues:

**Title:** Clear, action-oriented
**Description:**
```markdown
## Problem
What problem does this solve?

## Solution
How will we solve it?

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Tests pass
- [ ] Performance targets met

## Performance Targets
- Metric 1: <target>
- Metric 2: <target>

## Dependencies
- Issue CET-XX (if applicable)
```

---

## Code Style Guide

### Shell Script Style

**Naming Conventions:**
```bash
# Public functions: no prefix
goto() { }
bookmark() { }
recent() { }

# Internal functions: double underscore prefix
__goto_navigate_to() { }
__goto_cache_lookup() { }

# Variables: UPPERCASE for globals, lowercase for locals
GOTO_INDEX_FILE="/path"
local folder_name="value"

# Constants: UPPERCASE with underscore
GOTO_CACHE_TTL=86400
GOTO_SEARCH_DEPTH=3
```

**Function Structure:**
```bash
# Good function structure
function_name() {
    local param1="$1"
    local param2="${2:-default}"

    # Validate inputs
    if [ -z "$param1" ]; then
        echo "Error: param1 required"
        return 1
    fi

    # Main logic
    local result=$(process "$param1")

    # Return value
    echo "$result"
    return 0
}
```

**Error Handling:**
```bash
# Always check command success
if ! goto index rebuild; then
    echo "Failed to rebuild cache"
    return 1
fi

# Use return codes
return 0  # Success
return 1  # Error
return 2  # Special case (e.g., multiple matches)
```

**Comments:**
```bash
# Good: Explain why, not what
# Cache lookup is O(1) because we use grep on indexed file

# Bad: Explain what (obvious from code)
# Set folder_name to first parameter
folder_name="$1"
```

### Documentation Style

**Function Documentation:**
```bash
# Brief description
#
# Usage: function_name <arg1> [arg2]
#
# Parameters:
#   arg1 - Required parameter description
#   arg2 - Optional parameter (default: value)
#
# Returns:
#   0 - Success
#   1 - Error
#
# Example:
#   function_name "test" "optional"
function_name() {
    # Implementation
}
```

---

## Debugging Tips

### Enable Bash Tracing

```bash
# Enable for entire script
set -x
source goto.sh
goto test
set +x

# Enable for specific function
set -x
__goto_cache_lookup "project"
set +x
```

### Check Function Existence

```bash
# Verify function is loaded
if declare -f __goto_cache_lookup > /dev/null; then
    echo "Function loaded"
else
    echo "Function NOT loaded"
fi

# List all goto functions
declare -F | grep goto
```

### Inspect Variables

```bash
# Show cache location
echo "Cache: $GOTO_INDEX_FILE"

# Show search paths
echo "Paths: ${search_paths[@]}"

# Show cache status
goto index status
```

### Debug Cache Issues

```bash
# View cache file
cat ~/.goto_index

# Check cache age
stat -f %m ~/.goto_index

# Rebuild and observe
goto index rebuild

# Test lookup directly
__goto_cache_lookup "project"
echo "Status: $?"
```

### Performance Profiling

```bash
# Time specific operations
time goto unix-goto
time __goto_cache_lookup "unix-goto"
time goto index rebuild

# Detailed benchmark
goto benchmark navigation unix-goto 20

# Check disk I/O
iostat 1 10  # While running goto
```

### Common Issues

**Cache not working:**
```bash
# Check cache exists
ls -lh ~/.goto_index

# Check cache valid
goto index status

# Rebuild cache
goto index rebuild
```

**Slow performance:**
```bash
# Check if cache is being used
set -x
goto project
# Look for "cache lookup" in trace
set +x

# Benchmark current performance
goto benchmark navigation
```

**Function not found:**
```bash
# Check load order in goto.sh
cat goto.sh

# Manually source and test
source lib/module.sh
function_name
```

---

## Release Process

### Version Numbering

**Format:** `MAJOR.MINOR.PATCH`

**Increment Rules:**
- MAJOR: Breaking changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

**Current:** v0.4.0

### Release Checklist

**Pre-Release:**
- [ ] All tests passing
- [ ] Benchmarks meet targets
- [ ] Documentation complete
- [ ] CHANGELOG.md updated
- [ ] Version bumped in all files
- [ ] No outstanding Linear issues for phase

**Release Steps:**
1. Create release branch
   ```bash
   git checkout -b release/v0.4.0
   ```

2. Update version numbers
   ```bash
   # Update in: README.md, API.md, DEVELOPER-GUIDE.md, etc.
   ```

3. Update CHANGELOG.md
   ```markdown
   ## [0.4.0] - 2025-10-17

   ### Added
   - Folder index caching system (CET-77)
   - Comprehensive benchmark suite (CET-85)

   ### Performance
   - 8x speedup with caching (26ms vs 208ms)
   ```

4. Run full test suite
   ```bash
   bash test-cache.sh
   bash test-benchmark.sh
   goto benchmark all
   ```

5. Create tag
   ```bash
   git tag -a v0.4.0 -m "Release v0.4.0 - Smart Search & Discovery"
   ```

6. Merge to main
   ```bash
   git checkout main
   git merge release/v0.4.0
   ```

7. Push to remote
   ```bash
   git push origin main
   git push origin v0.4.0
   ```

**Post-Release:**
- [ ] Update Linear project status
- [ ] Announce in team channels
- [ ] Update GitHub release notes
- [ ] Archive release branch

---

## Additional Resources

### Documentation

- **API.md** - Complete API reference
- **BENCHMARKS.md** - Benchmark documentation
- **STANDARD-WORKFLOW.md** - Development workflow
- **PROJECT-TRACKER.md** - Project status and metrics
- **QUICKSTART.md** - User quick start guide

### External Links

- **Linear Project:** https://linear.app/ceti-luxor/project/unix-goto-shell-navigation-tool-cf50166ad361
- **GitHub Repo:** https://github.com/manutej/unix-goto
- **Claude Code:** https://claude.com/claude-code

### Getting Help

**Internal:**
- Read this guide
- Check API.md for function reference
- Review test files for examples
- Check PROJECT-TRACKER.md for status

**External:**
- Open Linear issue
- Contact team in Slack
- Review commit history
- Check git blame for context

---

## Appendix

### Quick Reference Commands

```bash
# Development
source goto.sh                 # Load all modules
goto index rebuild             # Rebuild cache
bash test-cache.sh             # Run tests
goto benchmark all             # Run benchmarks

# Debugging
set -x; goto project; set +x   # Trace execution
declare -F | grep goto         # List functions
cat ~/.goto_index              # View cache

# Git workflow
git checkout -b feature/name   # Create branch
git commit -m "feat: ..."      # Commit with message
git push origin feature/name   # Push to remote

# Performance
time goto project              # Measure navigation
goto benchmark navigation      # Benchmark navigation
goto index status              # Check cache health
```

### File Locations

```
~/.goto_index         - Cache file
~/.goto_bookmarks     - Bookmarks file
~/.goto_history       - History file
~/.goto_stack         - Navigation stack
~/.goto_benchmarks/   - Benchmark results directory
```

### Performance Targets Summary

| Metric | Target | Current |
|--------|--------|---------|
| Cached navigation | <100ms | 26ms ✓ |
| Cache build | <5s | 2s ✓ |
| Cache hit rate | >90% | ~95% ✓ |
| Speedup ratio | 20-50x | 8x ⚠ |

---

**Maintained By:** Manu Tej + Claude Code
**License:** MIT
**Version:** 0.4.0
**Last Updated:** 2025-10-17

For questions or contributions, please see the Linear project or open an issue.
