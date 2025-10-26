# unix-goto Skill Knowledge Base

**Version:** 1.0
**Created:** 2025-10-17
**Purpose:** Knowledge extraction from unix-goto project for Claude skill creation
**Target Skills:**
- `unix-goto-development` (comprehensive development skill)
- `shell-testing-framework` (testing-focused skill)
- `performance-benchmark-specialist` (performance optimization skill)

---

## Table of Contents

- [Executive Summary](#executive-summary)
- [Architecture Patterns](#architecture-patterns)
- [Development Workflow](#development-workflow)
- [Core API Patterns](#core-api-patterns)
- [Testing Framework Patterns](#testing-framework-patterns)
- [Performance Benchmarking Methodology](#performance-benchmarking-methodology)
- [Linear Workflow Integration](#linear-workflow-integration)
- [Best Practices & Standards](#best-practices--standards)
- [Skill Implementation Templates](#skill-implementation-templates)

---

## Executive Summary

### Project Overview

**unix-goto** is a high-performance Unix navigation system with:
- Natural language support via Claude AI
- Sub-100ms cached navigation (26ms actual)
- 100% test coverage for core features
- Comprehensive benchmark suite
- Simple one-line installation: `source goto.sh`

### Key Metrics

| Metric | Target | Achieved | Status |
|--------|--------|----------|--------|
| Cached navigation | <100ms | 26ms | ✅ Exceeded |
| Cache hit rate | >90% | 92-95% | ✅ Exceeded |
| Speedup ratio | 20-50x | 8x | ⏳ On track |
| Test coverage | 100% | 100% | ✅ Met |
| Cache build time | <5s | 3-5s | ✅ Met |

### Design Principles

1. **Simple** - ONE-line loading, minimal configuration
2. **Fast** - Sub-100ms navigation performance
3. **Lean** - No bloat, no unnecessary dependencies
4. **Tested** - 100% test coverage for core features
5. **Documented** - Clear, comprehensive documentation

---

## Architecture Patterns

### High-Level System Architecture

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
```

### Module Dependencies

**Critical Load Order** (dependencies must load before dependents):

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

### Cache System Architecture

**Implementation:** `lib/cache-index.sh`

**Key Components:**
- `__goto_cache_build` - O(n) index building
- `__goto_cache_lookup` - O(1) hash table lookup
- `__goto_cache_is_valid` - TTL-based validation
- Auto-refresh on stale cache (24-hour TTL)

**Cache File Format:**
```
# unix-goto folder index cache
# Version: 1.0
# Built: 1697558122
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
unix-goto|/Users/manu/Documents/LUXOR/Git_Repos/unix-goto|8|1697558100
GAI-3101|/Users/manu/Documents/LUXOR/PROJECTS/GAI-3101|6|1697558050
```

**Performance:**
- Build time: O(n) - 3-5s for 1200+ folders
- Lookup time: O(1) - <100ms target, 26ms actual
- Storage: ~42KB for 487 folders

### Navigation Data Flow

```
User Input → goto "project"
    │
    ├─► Check special cases (list, index, benchmark, @bookmark)
    ├─► Check multi-level paths (contains /)
    ├─► Try cache lookup (O(1)) → Cache hit → Navigate
    ├─► Try direct folder match in search paths
    ├─► Recursive search (max depth 3)
    │   ├─► Single match → Navigate
    │   └─► Multiple matches → Show disambiguation
    └─► Natural language AI resolution (if spaces)
```

### Bookmark System Architecture

**Storage:** `~/.goto_bookmarks`

**Format:**
```
work|/Users/manu/work|1697558122
api|/Users/manu/code/api-server|1697558130
```

**Key Functions:**
- `__goto_bookmark_add` - Add with validation
- `__goto_bookmark_remove` - Remove by name
- `__goto_bookmark_get` - Retrieve path (O(1) grep)
- `__goto_bookmark_goto` - Navigate to bookmark

**Performance Target:** <10ms lookup time

### History Tracking Architecture

**Storage:** `~/.goto_history`

**Format:**
```
1697558122|/Users/manu/work
1697558130|/Users/manu/Documents/LUXOR
```

**Key Functions:**
- `__goto_track` - Append with auto-trim (max 100 entries)
- `__goto_get_history` - Retrieve full history
- `__goto_recent_dirs` - Get unique directories in reverse chronological order
- `__goto_stack_push/pop` - Stack-based back navigation

---

## Development Workflow

### Standard 9-Step Feature Addition Process

#### Step 1: Plan Your Feature

**Questions to Answer:**
- What problem does this solve?
- What's the user interface (commands/flags)?
- What's the expected performance?
- What dependencies exist?
- What tests are needed?
- What documentation is required?

**Example Planning Template:**
```
Feature: [Name]
Problem: [User pain point]
Interface: [Commands/flags]
Performance: [Target metrics]
Dependencies: [Module dependencies]
Tests: [Test scenarios]
Docs: [API.md, README.md sections]
```

#### Step 2: Create Module (if needed)

**Template:**
```bash
#!/bin/bash
# unix-goto - [Module purpose]
# https://github.com/manutej/unix-goto

# Storage location
GOTO_MODULE_FILE="${GOTO_MODULE_FILE:-$HOME/.goto_module}"

# Main function
goto_module() {
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
            echo "goto module - [Description]"
            echo ""
            echo "Usage:"
            echo "  goto module list     [Description]"
            echo "  goto module add      [Description]"
            ;;
        *)
            echo "Unknown command: $subcommand"
            return 1
            ;;
    esac
}
```

#### Step 3: Add to Loader

Edit `goto.sh`:
```bash
# Add to load sequence (respect dependencies)
source "$GOTO_LIB_DIR/history-tracking.sh"
source "$GOTO_LIB_DIR/module.sh"  # NEW - add after dependencies
source "$GOTO_LIB_DIR/back-command.sh"
```

#### Step 4: Integrate with Main Function

Edit `lib/goto-function.sh`:
```bash
goto() {
    case "$1" in
        module)  # NEW
            if command -v goto_module &> /dev/null; then
                shift
                goto_module "$@"
            else
                echo "⚠️  Module command not loaded"
            fi
            return
            ;;
    esac
}
```

#### Step 5: Add Tests

**Test File Template:**
```bash
#!/bin/bash
# Test suite for [feature] functionality

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/module.sh"

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

# Test 1: [Description]
test_feature() {
    # Arrange
    local input="test"

    # Act
    local result=$(function_under_test "$input")

    # Assert
    if [[ "$result" == "expected" ]]; then
        pass "Feature works"
    else
        fail "Feature failed: got '$result'"
    fi
}

# Run tests
test_feature

# Summary
echo ""
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"

[ $TESTS_FAILED -eq 0 ] && exit 0 || exit 1
```

#### Step 6: Document API

Add to `docs/API.md`:
```markdown
## Module API

### `goto module`

[Description]

**Signature:**
```bash
goto module <subcommand>
```

**Subcommands:**
- `list` - [Description]
- `add` - [Description]

**Performance:** [Target metrics]

**Examples:**
```bash
goto module list
goto module add value
```
```

#### Step 7: Update User Documentation

Add to `README.md`:
```markdown
### Module

[User-facing description]

```bash
goto module list    # [Description]
goto module add     # [Description]
```
```

#### Step 8: Performance Validation

```bash
# Add benchmark if performance-critical
goto benchmark module 10

# Measure overhead
time goto_module list
```

#### Step 9: Linear Issue Update & Commit

```bash
# Update Linear issue with progress
# Commit with proper format
git commit -m "feat: implement module feature (CET-XX)

[Detailed explanation]

Features:
- Feature 1
- Feature 2

Performance:
- Metric: value

Tests:
- X/X tests passing
- 100% coverage

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
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

### Quick Development Loop

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

---

## Core API Patterns

### Function Naming Conventions

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

### Standard Function Structure

```bash
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

### Return Code Standards

**All functions follow:**
- `0` - Success
- `1` - General error (not found, invalid input, etc.)
- `2` - Multiple matches found (cache lookup only)

**Cache-specific:**
```bash
__goto_cache_lookup "folder"
# Returns:
#   0 - Single match found (path to stdout)
#   1 - Not found in cache
#   2 - Multiple matches found (all paths to stdout)
```

### Error Handling Pattern

```bash
# Always check command success
if ! goto index rebuild; then
    echo "Failed to rebuild cache"
    return 1
fi

# Use meaningful error messages
if [ ! -d "$target_dir" ]; then
    echo "❌ Directory not found: $target_dir"
    return 1
fi
```

### Data File Format Pattern

**Standard format:** Pipe-delimited with metadata header

```bash
# Module data file
# Version: 1.0
# Built: [timestamp]
# Format: field1|field2|field3
#---
value1|value2|value3
value1|value2|value3
```

### Configuration Environment Variables

```bash
# Cache configuration
GOTO_INDEX_FILE="${GOTO_INDEX_FILE:-$HOME/.goto_index}"
GOTO_CACHE_TTL="${GOTO_CACHE_TTL:-86400}"
GOTO_SEARCH_DEPTH="${GOTO_SEARCH_DEPTH:-3}"

# History configuration
GOTO_HISTORY_FILE="${GOTO_HISTORY_FILE:-$HOME/.goto_history}"
GOTO_HISTORY_MAX="${GOTO_HISTORY_MAX:-100}"

# Benchmark configuration
GOTO_BENCHMARK_ITERATIONS="${GOTO_BENCHMARK_ITERATIONS:-10}"
GOTO_BENCHMARK_WARMUP="${GOTO_BENCHMARK_WARMUP:-3}"
```

---

## Testing Framework Patterns

### Test Structure Template

```bash
#!/bin/bash
# Test suite for [feature]

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
test_feature() {
    # Arrange
    local input="test"

    # Act
    local result=$(function_under_test "$input")

    # Assert
    if [[ "$result" == "expected" ]]; then
        pass "Feature works"
    else
        fail "Feature failed: got '$result'"
    fi
}

# Run tests
test_feature

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

### Assertion Patterns

```bash
# Success/failure assertions
assert_success "command"
assert_failure "command"

# Value assertions
assert_equal "expected" "actual"
assert_contains "haystack" "needle"

# File system assertions
assert_file_exists "/path/to/file"
assert_dir_exists "/path/to/dir"
assert_file_contains "file" "text"
assert_line_count "file" 10
```

### Test Coverage Requirements

**Core Goals:**
- Core navigation: 100%
- Cache system: 100%
- Bookmarks: 100%
- History: 100%
- Benchmarks: 100%
- New features: 100%

**Current Achievement:**
- Total test suites: 8
- Test cases: 78+
- Assertions: 48+
- Coverage: 100% of core features
- Execution time: ~2-3 seconds

---

## Performance Benchmarking Methodology

### Benchmark Structure Template

```bash
#!/bin/bash
# [Benchmark description]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."

source "$SCRIPT_DIR/bench-helpers.sh"
source "$REPO_DIR/lib/module.sh"

main() {
    bench_header "Benchmark Title"

    echo "Configuration: ..."
    echo ""

    benchmark_feature

    generate_summary
}

benchmark_feature() {
    bench_section "Benchmark Section"

    # Setup
    local workspace=$(bench_create_workspace "medium")

    # Warmup
    bench_warmup "command" 3

    # Run benchmark
    local stats=$(bench_run "name" "command" 10)

    # Extract statistics
    IFS=',' read -r min max mean median stddev <<< "$stats"

    # Print results
    bench_print_stats "$stats" "Results"

    # Assert target
    bench_assert_target "$mean" 100 "Mean time"

    # Cleanup
    bench_cleanup_workspace "$workspace"
}

main
exit 0
```

### Performance Targets

| Metric | Target | Rationale |
|--------|--------|-----------|
| Cached navigation | <100ms | Sub-100ms feels instant |
| Bookmark lookup | <10ms | Near-instant access |
| Cache speedup | >20x | Significant improvement |
| Cache hit rate | >90% | Most lookups hit cache |
| Cache build | <5s | Fast initial setup |

### Benchmark Best Practices

1. **Warmup**: Always run 3+ warmup iterations to reduce noise
2. **Sample size**: Use at least 10 iterations for statistical validity
3. **Isolation**: Run benchmarks on idle system
4. **Consistency**: Use same configuration for comparisons
5. **Documentation**: Document what each benchmark measures

### Statistics Calculation

```bash
bench_calculate_stats value1 value2 value3 ...
# Returns: min,max,mean,median,stddev

# Example usage:
stats=$(bench_calculate_stats 25 27 28 26 30 29 27 28 26 27)
IFS=',' read -r min max mean median stddev <<< "$stats"
```

### Results Storage Format

**CSV Format:**
```csv
timestamp,benchmark_name,operation,min_ms,max_ms,mean_ms,median_ms,stddev,metadata
1704123456,cached_vs_uncached,uncached,25,32,28,28,2.1,
1704123456,cached_vs_uncached,cached,15,22,18,19,1.8,
```

### Benchmark Output Format

```
╔══════════════════════════════════════════════════════════════════╗
║  [Benchmark Title]                                               ║
╚══════════════════════════════════════════════════════════════════╝

Configuration: [Config details]

[Benchmark Section]
─────────────────────────────────────────────────────────────────

Phase 1: [Phase name]
─────────────────────────────────
  Run  1: 27ms
  Run  2: 28ms
  ...

Results:
  Min:                                             27ms
  Max:                                             30ms
  Mean:                                            28ms
  Median:                                          28ms
  Std Dev:                                       0.89ms

✓ [Metric] meets target: 28ms (target: <100ms)
```

### Benchmark Helper Functions

```bash
# Timing
bench_time_ms command args        # High-precision timing (ms)

# Statistics
bench_calculate_stats val1 val2   # Returns stats CSV
bench_compare baseline optimized  # Calculate speedup

# Workspace
bench_create_workspace "size"     # Create test environment
bench_cleanup_workspace "path"    # Remove test environment

# Output
bench_header "Title"              # Print header
bench_section "Section"           # Print section
bench_result "Label" "value"      # Print result
bench_print_stats "csv" "Label"   # Print stats block

# Results
bench_init                        # Initialize results dir
bench_save_result "name" "stats"  # Save to CSV
bench_assert_target actual target # Assert performance
```

---

## Linear Workflow Integration

### Linear Project Details

**Team:** Ceti-luxor
**Project:** unix-goto - Shell Navigation Tool
**Project ID:** 7232cafe-cb71-4310-856a-0d584e6f3df0

### Issue Lifecycle

```
Backlog → In Progress → Complete
```

### Standard Issue Workflow

**1. Pick an Issue**
- View issues in Linear
- Select from Phase 3 backlog
- Check dependencies

**2. Move to "In Progress"**
- Update status in Linear
- Assign to yourself
- Add comment with approach

**3. Create Feature Branch**
```bash
git checkout -b feature/CET-XX-feature-name
```

**4. Implement**
- Follow 9-step development workflow
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

### Linear Issue Template

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

## Best Practices & Standards

### Code Style Guide

**Shell Script Style:**
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

**Comments:**
```bash
# Good: Explain why, not what
# Cache lookup is O(1) because we use grep on indexed file

# Bad: Explain what (obvious from code)
# Set folder_name to first parameter
folder_name="$1"
```

### Documentation Standards

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

### Commit Standards

**Format:**
```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `perf:` - Performance improvement
- `refactor:` - Code refactoring
- `test:` - Add or update tests
- `docs:` - Documentation only
- `chore:` - Build, dependencies, or tooling

**Subject:**
- Use imperative mood ("add" not "added")
- No period at end
- Max 50 characters
- Include Linear issue ID if applicable

**Footer:**
- Include Claude Code attribution
- Link to Linear issue

### Performance Optimization Tips

**Cache System:**
- Use cache for all lookups
- Limit recursive search depth
- Avoid redundant filesystem operations
- Use `grep` for fast text matching

**Memory:**
- Cache file: <100KB for 500 folders
- Memory usage: Minimal (shell functions only)
- No persistent processes

### Debugging Tips

**Enable Bash Tracing:**
```bash
set -x
source goto.sh
goto test
set +x
```

**Check Function Existence:**
```bash
if declare -f __goto_cache_lookup > /dev/null; then
    echo "Function loaded"
fi
```

**Debug Cache Issues:**
```bash
# View cache file
cat ~/.goto_index

# Check cache age
stat -f %m ~/.goto_index

# Rebuild and observe
goto index rebuild
```

---

## Skill Implementation Templates

### Template 1: unix-goto-development Skill

**Purpose:** Comprehensive development skill for adding features to unix-goto

**Core Knowledge Areas:**
1. Architecture patterns (cache, bookmarks, history)
2. 9-step feature addition process
3. Testing requirements (100% coverage)
4. Performance standards (<100ms navigation)
5. Linear workflow integration
6. Code style and documentation standards

**Key Capabilities:**
- Implement new navigation features
- Add cache-based optimizations
- Create comprehensive tests
- Document APIs and user guides
- Update Linear issues
- Follow commit standards

**Example Prompt:**
```
I need to add a new feature to unix-goto that [description].

Requirements:
- Performance target: [metric]
- Dependencies: [modules]
- Linear issue: CET-XX

Please follow the standard 9-step development workflow and ensure:
1. Proper module creation with dependency handling
2. Integration with main goto function
3. 100% test coverage
4. Performance validation
5. Complete documentation (API.md, README.md)
6. Linear issue updates
7. Proper commit format
```

### Template 2: shell-testing-framework Skill

**Purpose:** Testing-focused skill for creating comprehensive bash test suites

**Core Knowledge Areas:**
1. Test structure templates
2. Assertion patterns
3. Test categories (unit, integration, edge cases, performance)
4. 100% coverage requirements
5. Test helper functions
6. Performance test patterns

**Key Capabilities:**
- Create test suites with proper structure
- Implement all test categories
- Use assertion patterns correctly
- Achieve 100% coverage
- Write performance tests
- Generate test reports

**Example Prompt:**
```
I need to create a comprehensive test suite for [module].

Requirements:
- Test file: test-[module].sh
- Coverage: 100%
- Test categories: unit, integration, edge cases, performance

Please create tests following the standard template with:
1. Proper test structure (setup, counters, helpers)
2. All test categories covered
3. Assertion patterns for validation
4. Performance tests if applicable
5. Clear pass/fail reporting
```

### Template 3: performance-benchmark-specialist Skill

**Purpose:** Performance optimization and benchmarking skill

**Core Knowledge Areas:**
1. Benchmark structure templates
2. Performance targets (<100ms, >90% hit rate, >20x speedup)
3. Statistics calculation (min, max, mean, median, stddev)
4. Workspace management
5. Results storage format (CSV)
6. Benchmark helper functions

**Key Capabilities:**
- Create custom benchmarks
- Measure performance accurately
- Calculate statistics
- Generate performance reports
- Validate against targets
- Optimize based on metrics

**Example Prompt:**
```
I need to benchmark [feature] to validate performance.

Requirements:
- Target: [metric] <100ms
- Iterations: 10
- Warmup: 3 runs
- Workspace: medium (50 folders)

Please create a benchmark following the standard template with:
1. Proper benchmark structure
2. Warmup and main iterations
3. Statistics calculation (min/max/mean/median/stddev)
4. Performance target validation
5. Results storage in CSV format
6. Summary report generation
```

---

## Appendix: Quick Reference

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
| Cache build | <5s | 3-5s ✓ |
| Cache hit rate | >90% | 92-95% ✓ |
| Speedup ratio | 20-50x | 8x ⚠ |
| Test coverage | 100% | 100% ✓ |

### Essential Commands

```bash
# Development
source goto.sh                 # Load all modules
goto index rebuild             # Rebuild cache
bash test-cache.sh             # Run cache tests
bash test-benchmark.sh         # Run benchmark tests
goto benchmark all             # Run all benchmarks

# Debugging
set -x; goto project; set +x   # Trace execution
declare -F | grep goto         # List functions
cat ~/.goto_index              # View cache

# Git workflow
git checkout -b feature/CET-XX # Create branch
git commit -m "feat: ..."      # Commit with proper format
git push origin feature/CET-XX # Push to remote

# Performance
time goto project              # Measure navigation
goto benchmark navigation      # Benchmark navigation
goto index status              # Check cache health
```

---

**Document Version:** 1.0
**Created:** 2025-10-17
**Maintained By:** Manu Tej + Claude Code
**Purpose:** Foundation for creating Claude skills for unix-goto development

This knowledge base extracted from:
- `/Users/manu/Documents/LUXOR/Git_Repos/unix-goto/README.md`
- `/Users/manu/Documents/LUXOR/Git_Repos/unix-goto/docs/DEVELOPER-GUIDE.md`
- `/Users/manu/Documents/LUXOR/Git_Repos/unix-goto/docs/API.md`
- `/Users/manu/Documents/LUXOR/Git_Repos/unix-goto/PROGRESS.md`
- `/Users/manu/Documents/LUXOR/Git_Repos/unix-goto/docs/STANDARD-WORKFLOW.md`
- `/Users/manu/Documents/LUXOR/Git_Repos/unix-goto/docs/testing/TESTING-README.md`
- `/Users/manu/Documents/LUXOR/Git_Repos/unix-goto/docs/testing/BENCHMARKS-README.md`
