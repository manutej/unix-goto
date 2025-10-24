# unix-goto Implementation Plan

**Last Updated:** 2025-10-17
**Strategic Focus:** Performance, Usability, Scripting Support
**Current Version:** v0.3.0
**Next Release:** v0.4.0 (Phase 1 - Performance Foundation)

---

## 🎯 Strategic Direction

**Prioritization Philosophy:**
1. **Speed First** - Make existing features faster before adding new ones
2. **Usability First** - Remove friction from common workflows
3. **Scripting First** - Enable automation and integration
4. **AI Last** - Defer complex AI features until foundation is solid

This ensures unix-goto becomes a **fast, reliable tool** before adding advanced features.

---

## 📋 Phase 1: Performance Foundation (v0.4.0)

**Goal:** Eliminate speed bottlenecks and improve core usability
**Timeline:** 3-4 weeks
**Status:** Ready to begin

### Feature 1.1: Folder Index Caching System 🔥 **CRITICAL**

**Problem:**
- Every `goto` command triggers `find` across all search paths
- Recursive searches take 2-5+ seconds on large directories
- No persistence between sessions
- Repeated navigation to same folders is inefficient

**Solution:**
Implement a caching layer that pre-scans directory structure and enables instant lookups.

#### Implementation Details

**New File:** `lib/index-cache.sh`
```bash
#!/bin/bash
# Folder index caching system

GOTO_INDEX_FILE="${HOME}/.goto_index"
GOTO_INDEX_VERSION="1.0"

__goto_build_index() {
    # Scan all search paths
    # Build hash table of folder name → full path
    # Include metadata: timestamp, depth, size
    # Write to ~/.goto_index
}

__goto_read_index() {
    # Load cached index into memory
    # Validate version and timestamp
    # Return index data structure
}

__goto_lookup() {
    local folder_name="$1"
    # O(1) lookup in cached index
    # Return full path if found
    # Return null if not in cache
}

__goto_invalidate_cache() {
    # Check if cache is older than 24 hours
    # Check if cache version matches
    # Clear cache if invalid
}

__goto_index_status() {
    # Show cache statistics
    # - Total folders indexed
    # - Cache age
    # - Last rebuild time
    # - Cache file size
}
```

**Updated File:** `lib/goto-function.sh`
```bash
goto() {
    # ... existing code ...

    # NEW: Try cache lookup first
    if command -v __goto_lookup &> /dev/null; then
        local cached_path=$(__goto_lookup "$target")
        if [ -n "$cached_path" ]; then
            __goto_navigate_to "$cached_path"
            return 0
        fi
    fi

    # Fallback to existing search logic
    # ... existing code ...
}
```

**New Commands:**
```bash
goto index rebuild       # Force rebuild cache
goto index status        # Show cache statistics
goto index clear         # Delete cache
goto index auto          # Enable/disable auto-refresh
```

**Success Criteria:**
- [ ] Cache builds in <5 seconds for typical workspace (500+ folders)
- [ ] Cached lookups complete in <100ms
- [ ] Auto-refresh when cache older than 24 hours
- [ ] Graceful fallback if cache missing or corrupted
- [ ] 95%+ speed improvement for cached navigation

---

### Feature 1.2: Quick Bookmark Current Directory 🔥 **HIGH PRIORITY**

**Problem:**
- Users must type full path: `bookmark add proj1 /Users/.../long/path`
- Common workflow: navigate somewhere, *then* decide to bookmark it
- Friction reduces bookmark adoption

**Solution:**
Enable intuitive shorthand for bookmarking current location.

#### Implementation Details

**Updated File:** `lib/bookmark-command.sh`

Add to `__goto_bookmark_add()` function:
```bash
__goto_bookmark_add() {
    local name="$1"
    local path="$2"

    # NEW: Handle "." as current directory
    if [ "$path" = "." ] || [ -z "$path" ]; then
        path="$PWD"
    fi

    # NEW: Handle "." as name - use current folder name
    if [ "$name" = "." ]; then
        name=$(basename "$PWD")
    fi

    # ... existing validation and save logic ...
}

# NEW: Add "here" alias
__goto_bookmark_here() {
    local name="$1"

    if [ -z "$name" ]; then
        # No name provided, use current folder name
        name=$(basename "$PWD")
    fi

    __goto_bookmark_add "$name" "$PWD"
}
```

**New Usage Patterns:**
```bash
# Bookmark current directory with folder name
bookmark .                    # Auto-names as current folder
bookmark add .                # Same as above

# Bookmark current directory with custom name
bookmark here                 # Auto-names as current folder
bookmark here proj1           # Names as "proj1"
bookmark add proj1 .          # Alternative syntax
```

**Success Criteria:**
- [ ] `bookmark .` creates bookmark with current folder name
- [ ] `bookmark here <name>` bookmarks current dir with custom name
- [ ] Error if bookmark name conflicts
- [ ] Backward compatible with existing syntax
- [ ] Updated help documentation

---

### Feature 1.3: Configurable Search Depth

**Problem:**
- Search depth hard-coded at 3 levels
- Cannot find deeply nested folders
- Cannot optimize speed by reducing depth
- No user control

**Solution:**
Implement `~/.gotorc` configuration file with user-controlled settings.

#### Implementation Details

**New File:** `lib/config-manager.sh`
```bash
#!/bin/bash
# Configuration file management

GOTO_CONFIG_FILE="${HOME}/.gotorc"

__goto_load_config() {
    # Source ~/.gotorc if it exists
    # Set defaults if not found

    # Defaults
    GOTO_SEARCH_DEPTH=${GOTO_SEARCH_DEPTH:-3}
    GOTO_CACHE_TTL=${GOTO_CACHE_TTL:-86400}  # 24 hours
    GOTO_PARALLEL_SEARCH=${GOTO_PARALLEL_SEARCH:-false}
    GOTO_FUZZY=${GOTO_FUZZY:-false}
}

__goto_get_config() {
    local key="$1"

    case "$key" in
        depth)
            echo "$GOTO_SEARCH_DEPTH"
            ;;
        cache_ttl)
            echo "$GOTO_CACHE_TTL"
            ;;
        parallel)
            echo "$GOTO_PARALLEL_SEARCH"
            ;;
        *)
            echo "Unknown config key: $key" >&2
            return 1
            ;;
    esac
}

__goto_set_config() {
    local key="$1"
    local value="$2"

    # Validate value
    # Update ~/.gotorc
    # Reload config
}

__goto_config_show() {
    # Display all current configuration
    echo "Current goto configuration:"
    echo "  Search Depth:     $GOTO_SEARCH_DEPTH"
    echo "  Cache TTL:        $GOTO_CACHE_TTL seconds"
    echo "  Parallel Search:  $GOTO_PARALLEL_SEARCH"
    echo "  Fuzzy Matching:   $GOTO_FUZZY"
}
```

**Example ~/.gotorc:**
```bash
# unix-goto configuration file

# Search depth for recursive folder search (default: 3)
GOTO_SEARCH_DEPTH=5

# Cache time-to-live in seconds (default: 86400 = 24 hours)
GOTO_CACHE_TTL=43200  # 12 hours

# Enable parallel search across multiple paths (default: false)
GOTO_PARALLEL_SEARCH=true

# Enable fuzzy matching for folder names (default: false)
# Note: Fuzzy matching is implemented in Phase 3
GOTO_FUZZY=false

# Custom search paths (optional - overrides defaults)
GOTO_SEARCH_PATHS=(
    "$HOME/projects"
    "$HOME/work"
    "$HOME/Documents/LUXOR"
)
```

**New Commands:**
```bash
goto config                  # Show all configuration
goto config get depth        # Get specific value
goto config set depth 5      # Set specific value
goto config reset            # Reset to defaults
goto config edit             # Open ~/.gotorc in $EDITOR
```

**Updated File:** `lib/goto-function.sh`
```bash
goto() {
    # Load config at function start
    __goto_load_config

    # NEW: Handle --depth flag
    local depth="$GOTO_SEARCH_DEPTH"
    if [[ "$1" == "--depth" ]]; then
        depth="$2"
        shift 2
    fi

    # Use $depth in find commands instead of hard-coded 3
    find "$search_path" -maxdepth "$depth" ...
}
```

**Success Criteria:**
- [ ] `~/.gotorc` file support implemented
- [ ] Config loads automatically on goto invocation
- [ ] `goto config` commands work correctly
- [ ] `--depth N` flag overrides default
- [ ] Backward compatible (defaults to depth=3)
- [ ] Configuration persists across sessions

---

## 📋 Phase 2: Developer Experience (v0.5.0)

**Goal:** Enable scripting, automation, and developer workflows
**Timeline:** 2-3 weeks
**Status:** Planned after Phase 1 completion

### Feature 2.1: Tab Completion for Bash/Zsh

**Problem:**
- Must type full command/folder names
- No discoverability via tab
- Slower workflow, more typos

**Solution:**
Bash and Zsh completion scripts with intelligent completion.

#### Implementation Details

**New File:** `completions/goto-completion.bash`
```bash
# Bash completion for goto command

_goto_completions() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "$prev" in
        goto)
            # Complete subcommands, shortcuts, bookmarks, folders
            local subcommands="list index config --help --depth"
            local shortcuts="luxor halcon docs infra"
            local bookmarks=$(grep -v '^#' ~/.goto_bookmarks 2>/dev/null | cut -d'=' -f1 | sed 's/^/@/')

            COMPREPLY=($(compgen -W "$subcommands $shortcuts $bookmarks" -- "$cur"))
            ;;
        list)
            # Complete list flags
            COMPREPLY=($(compgen -W "--shortcuts --folders --bookmarks --format --sort" -- "$cur"))
            ;;
        index)
            # Complete index subcommands
            COMPREPLY=($(compgen -W "rebuild status clear" -- "$cur"))
            ;;
        config)
            # Complete config operations
            COMPREPLY=($(compgen -W "get set reset edit" -- "$cur"))
            ;;
    esac
}

complete -F _goto_completions goto
```

**New File:** `completions/goto-completion.zsh`
```bash
# Zsh completion for goto command

#compdef goto

_goto() {
    local -a subcommands shortcuts bookmarks

    subcommands=(
        'list:Show available destinations'
        'index:Manage folder index cache'
        'config:Manage configuration'
    )

    shortcuts=(
        'luxor:Navigate to LUXOR directory'
        'halcon:Navigate to HALCON project'
        'docs:Navigate to ASCIIDocs'
        'infra:Navigate to infrastructure'
    )

    # Read bookmarks from ~/.goto_bookmarks
    bookmarks=(${(f)"$(grep -v '^#' ~/.goto_bookmarks 2>/dev/null | cut -d'=' -f1 | sed 's/^/@/')"})

    _arguments \
        '1: :->command' \
        '*::arg:->args'

    case $state in
        command)
            _describe 'subcommand' subcommands
            _describe 'shortcut' shortcuts
            _describe 'bookmark' bookmarks
            ;;
    esac
}

_goto "$@"
```

**Updated File:** `install.sh`
```bash
# Add completion installation
install_completions() {
    local shell_type="$1"

    if [ "$shell_type" = "bash" ]; then
        # Install bash completion
        if [ -d /usr/local/etc/bash_completion.d ]; then
            cp completions/goto-completion.bash /usr/local/etc/bash_completion.d/goto
        elif [ -d ~/.bash_completion.d ]; then
            cp completions/goto-completion.bash ~/.bash_completion.d/goto
        fi
    elif [ "$shell_type" = "zsh" ]; then
        # Install zsh completion
        local zsh_comp_dir="${HOME}/.zsh/completions"
        mkdir -p "$zsh_comp_dir"
        cp completions/goto-completion.zsh "$zsh_comp_dir/_goto"

        # Add to fpath if not already there
        grep -q "$zsh_comp_dir" ~/.zshrc || \
            echo "fpath=(~/.zsh/completions \$fpath)" >> ~/.zshrc
    fi
}
```

**Success Criteria:**
- [ ] Tab completion works in bash
- [ ] Tab completion works in zsh
- [ ] Completes all subcommands
- [ ] Completes bookmark names with @ prefix
- [ ] Completes shortcuts
- [ ] install.sh handles completion setup
- [ ] Completion updates when bookmarks change

---

### Feature 2.2: Batch-Friendly Output Modes

**Problem:**
- Output is human-readable only (emojis, colors, explanatory text)
- Cannot parse in shell scripts
- No JSON for programmatic access
- Progress messages clutter script output

**Solution:**
Add multiple output formats and scripting-friendly modes.

#### Implementation Details

**Updated File:** `lib/goto-function.sh`
```bash
# Global output mode (set by flags)
GOTO_OUTPUT_MODE="human"  # human|json|simple|quiet

__goto_format_output() {
    local type="$1"
    local data="$2"

    case "$GOTO_OUTPUT_MODE" in
        json)
            __goto_json_output "$type" "$data"
            ;;
        simple)
            __goto_simple_output "$type" "$data"
            ;;
        quiet)
            # Suppress all output except errors
            ;;
        human|*)
            __goto_human_output "$type" "$data"
            ;;
    esac
}

__goto_json_output() {
    # Output JSON format
    echo "{\"type\": \"$1\", \"data\": \"$2\"}"
}

__goto_simple_output() {
    # Output simple format (one path per line)
    echo "$2"
}

goto() {
    # Parse output format flags
    while [[ "$1" == --* ]]; do
        case "$1" in
            --format)
                GOTO_OUTPUT_MODE="$2"
                shift 2
                ;;
            --quiet|-q)
                GOTO_OUTPUT_MODE="quiet"
                shift
                ;;
            --json)
                GOTO_OUTPUT_MODE="json"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    # ... existing navigation logic with __goto_format_output ...
}
```

**New Subcommands:**
```bash
# Print path without navigating
goto pwd <target>            # Prints full path to stdout
echo $(goto pwd @proj1)      # Use in scripts

# Check if target exists (exit code only)
goto check <target>          # Returns 0 if exists, 1 if not
if goto check unix-goto --quiet; then
    echo "Found"
fi
```

**Updated File:** `lib/list-command.sh`
```bash
__goto_list() {
    local format="${GOTO_OUTPUT_MODE:-human}"

    case "$format" in
        json)
            # Output JSON array
            echo '{"shortcuts": [...], "bookmarks": [...], "folders": [...]}'
            ;;
        simple)
            # One path per line
            for path in "${all_paths[@]}"; do
                echo "$path"
            done
            ;;
        csv)
            # CSV format
            echo "name,type,path"
            echo "luxor,shortcut,/Users/.../LUXOR"
            ;;
        human|*)
            # Existing human-readable output
            ;;
    esac
}
```

**Success Criteria:**
- [ ] `--format json` outputs valid JSON
- [ ] `--format simple` outputs one path per line
- [ ] `--format csv` outputs CSV format
- [ ] `--quiet` suppresses all non-error output
- [ ] `goto pwd <target>` returns path only
- [ ] `goto check <target>` returns exit code
- [ ] Backward compatible (default is human-readable)
- [ ] Works with all goto subcommands

---

### Feature 2.3: Execute Commands in Target Directory

**Problem:**
- Must navigate, execute, navigate back manually
- Clutters navigation history with temporary visits
- Inefficient for one-off commands

**Solution:**
`goto exec` command that runs in target and returns.

#### Implementation Details

**New File:** `lib/exec-command.sh`
```bash
#!/bin/bash
# Execute command in target directory

__goto_exec() {
    local stay_flag=false
    local target=""
    local command=""

    # Parse flags
    if [[ "$1" == "--stay" ]]; then
        stay_flag=true
        shift
    fi

    target="$1"
    shift
    command="$*"

    # Resolve target using existing goto logic
    local target_path=$(__goto_resolve_target "$target")

    if [ -z "$target_path" ]; then
        echo "❌ Target not found: $target"
        return 1
    fi

    # Save current directory
    local original_dir="$PWD"

    # Navigate to target
    cd "$target_path" || return 1

    # Execute command
    eval "$command"
    local exit_code=$?

    # Return to original directory (unless --stay)
    if [ "$stay_flag" = false ]; then
        cd "$original_dir"
    else
        # Update goto history
        __goto_track "$target_path"
    fi

    return $exit_code
}
```

**Usage Examples:**
```bash
# Execute and return
goto exec luxor "git status"
goto exec @proj1 "npm test"
goto exec GAI-3101 "ls -la"

# Execute and stay in directory
goto exec --stay luxor "git pull"

# Use in scripts
result=$(goto exec halcon "git rev-parse --short HEAD")
echo "Current commit: $result"

# Conditional execution
if goto exec proj1 "npm run lint" --quiet; then
    echo "Lint passed"
fi
```

**Success Criteria:**
- [ ] Executes command in target directory
- [ ] Returns to original directory by default
- [ ] `--stay` flag navigates and stays
- [ ] Preserves command exit code
- [ ] Works with all target types (shortcuts, bookmarks, folders)
- [ ] Outputs command stdout/stderr
- [ ] Does not pollute navigation history (unless --stay)

---

## 📋 Phase 3: Advanced Optimization (v0.6.0)

**Goal:** Performance optimization and intelligent matching
**Timeline:** 2-3 weeks
**Status:** Planned after Phase 2 completion

### Feature 3.1: Parallel Search Across Multiple Paths

**Problem:**
- Sequential search across search paths
- Large first path delays entire search
- No parallelization

**Solution:**
Launch searches in parallel across all configured paths.

#### Implementation Details

**Updated File:** `lib/goto-function.sh`
```bash
__goto_parallel_search() {
    local folder_name="$1"
    local depth="$2"

    # Check if parallel search enabled
    if [ "$GOTO_PARALLEL_SEARCH" != "true" ]; then
        __goto_sequential_search "$folder_name" "$depth"
        return
    fi

    # Create temp file for results
    local results_file=$(mktemp)

    # Launch background searches
    for search_path in "${GOTO_SEARCH_PATHS[@]}"; do
        (
            # Search this path
            find "$search_path" -maxdepth "$depth" -type d -name "$folder_name" 2>/dev/null
        ) >> "$results_file" &
    done

    # Wait for all searches to complete
    wait

    # Read and deduplicate results
    local results=($(sort -u "$results_file"))
    rm "$results_file"

    # Return results
    echo "${results[@]}"
}
```

**Success Criteria:**
- [ ] Searches run in parallel when `GOTO_PARALLEL_SEARCH=true`
- [ ] Total search time reduced by ~50% for multi-path searches
- [ ] Results collected correctly from all paths
- [ ] No duplicate results
- [ ] Configurable via ~/.gotorc
- [ ] Falls back to sequential if disabled

---

### Feature 3.2: Fuzzy Matching for Folder Names

**Problem:**
- Exact name match only
- Typos result in "not found"
- Must remember exact folder names

**Solution:**
Levenshtein distance-based fuzzy matching with interactive selection.

#### Implementation Details

**New File:** `lib/fuzzy-match.sh`
```bash
#!/bin/bash
# Fuzzy matching for folder names

__goto_levenshtein_distance() {
    local string1="$1"
    local string2="$2"

    # Calculate Levenshtein distance
    # (Bash implementation or call to external tool)
}

__goto_fuzzy_score() {
    local input="$1"
    local candidate="$2"

    # Calculate similarity score (0.0 to 1.0)
    # - Levenshtein distance
    # - Substring matching bonus
    # - Prefix matching bonus
    # - Case-insensitive comparison

    local distance=$(__goto_levenshtein_distance "$input" "$candidate")
    local max_length=$(( ${#input} > ${#candidate} ? ${#input} : ${#candidate} ))
    local score=$(bc <<< "scale=2; 1 - ($distance / $max_length)")

    echo "$score"
}

__goto_fuzzy_search() {
    local input="$1"
    local threshold="${GOTO_FUZZY_THRESHOLD:-0.6}"

    # Get all candidate folders
    local candidates=($(find "${GOTO_SEARCH_PATHS[@]}" -type d -maxdepth 3 2>/dev/null))

    # Score each candidate
    local -A scores
    for candidate in "${candidates[@]}"; do
        local folder_name=$(basename "$candidate")
        local score=$(__goto_fuzzy_score "$input" "$folder_name")

        if (( $(bc <<< "$score >= $threshold") )); then
            scores["$candidate"]=$score
        fi
    done

    # Sort by score and return top matches
    # (Implementation details for sorting associative array)
}

__goto_fuzzy_select() {
    local matches=("$@")

    if [ ${#matches[@]} -eq 0 ]; then
        return 1
    elif [ ${#matches[@]} -eq 1 ]; then
        echo "${matches[0]}"
        return 0
    else
        # Interactive selection
        echo "⚠️  Multiple fuzzy matches found:"
        for i in "${!matches[@]}"; do
            echo "  $((i+1))) ${matches[$i]}"
        done
        read -p "Select: " selection
        echo "${matches[$((selection-1))]}"
    fi
}
```

**Usage Examples:**
```bash
goto halcn           # Fuzzy match → HALCON
goto gai3            # Fuzzy match → GAI-3101
goto unx-gt          # Fuzzy match → unix-goto

# Interactive selection when multiple matches:
goto proj
# ⚠️  Multiple fuzzy matches found:
#   1) project-alpha (score: 0.85)
#   2) proj-beta (score: 0.80)
#   3) old-project (score: 0.60)
# Select: _
```

**Success Criteria:**
- [ ] Finds folders with minor typos
- [ ] Partial name matching works
- [ ] Interactive selection for multiple matches
- [ ] Configurable fuzzy threshold (0.0-1.0)
- [ ] Can disable: `GOTO_FUZZY=false`
- [ ] Exact matches always preferred

---

### Feature 3.3: Performance Benchmark Suite

**Problem:**
- No way to measure performance improvements
- Cannot track regression
- No data to justify optimizations

**Solution:**
Automated benchmark script that measures and reports performance.

#### Implementation Details

**New File:** `bin/benchmark-goto`
```bash
#!/bin/bash
# Performance benchmark suite for unix-goto

benchmark_direct_shortcuts() {
    echo "Benchmarking direct shortcuts..."
    time goto luxor
    time goto halcon
    time goto docs
}

benchmark_recursive_search() {
    echo "Benchmarking recursive search..."

    # Clear cache
    goto index clear

    # Cold search (no cache)
    time goto unix-goto

    # Rebuild cache
    goto index rebuild

    # Warm search (with cache)
    time goto unix-goto
}

benchmark_multi_level() {
    echo "Benchmarking multi-level navigation..."
    time goto LUXOR/Git_Repos/unix-goto
    time goto PROJECTS/HALCON/config
}

benchmark_cache_build() {
    echo "Benchmarking cache build time..."
    goto index clear
    time goto index rebuild
}

generate_report() {
    echo ""
    echo "unix-goto Performance Benchmark Report"
    echo "========================================"
    echo "System: $(uname -s) $(uname -r)"
    echo "Shell: $SHELL"
    echo "Search Paths: ${#GOTO_SEARCH_PATHS[@]}"
    echo ""

    # Output results in table format
}

# Run all benchmarks
benchmark_direct_shortcuts
benchmark_recursive_search
benchmark_multi_level
benchmark_cache_build
generate_report
```

**Success Criteria:**
- [ ] Automated benchmark script
- [ ] Measures all key operations
- [ ] Generates comparison reports
- [ ] Can run before/after changes
- [ ] Documents performance improvements in BENCHMARKS.md

---

## 📊 Success Metrics

### Phase 1 Success Criteria
- [ ] Average navigation time: <100ms (currently ~2-5s)
- [ ] Cache hit rate: >80%
- [ ] Quick bookmarking adoption: >50% of bookmarks use new syntax
- [ ] Configuration file usage: >30% of users create ~/.gotorc

### Phase 2 Success Criteria
- [ ] Tab completion works in 100% of supported shells
- [ ] Script integration examples documented
- [ ] goto exec usage: >20% of power users
- [ ] Batch mode adoption in automation scripts

### Phase 3 Success Criteria
- [ ] Parallel search: 50%+ speed improvement
- [ ] Fuzzy matching: 90%+ accuracy for common typos
- [ ] Performance benchmarks show consistent improvements

---

## 🚀 Release Planning

### v0.4.0 - Performance Foundation
**Target:** 4 weeks from start
**Features:** Folder caching, quick bookmarking, configurable depth
**Breaking Changes:** None (fully backward compatible)

### v0.5.0 - Developer Experience
**Target:** 3 weeks after v0.4.0
**Features:** Tab completion, batch modes, goto exec
**Breaking Changes:** None

### v0.6.0 - Advanced Optimization
**Target:** 3 weeks after v0.5.0
**Features:** Parallel search, fuzzy matching, benchmarks
**Breaking Changes:** None

---

## 📝 Documentation Requirements

Each phase must include:
- [ ] Updated README.md with new features
- [ ] Updated CHANGELOG.md with version notes
- [ ] Updated TESTING-GUIDE.md with test scenarios
- [ ] Example usage in examples/ directory
- [ ] Update PROJECT-STATUS.md with completion
- [ ] Create BENCHMARKS.md (Phase 3)

---

**Maintained By:** Manu Tej + Claude Code
**Repository:** https://github.com/manutej/unix-goto
**Update Policy:** Update this plan with EVERY phase milestone
