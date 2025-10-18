# unix-goto API Reference

**Version:** 0.4.0
**Last Updated:** 2025-10-17
**Status:** Production Ready

Complete API reference for all public functions, commands, and interfaces in the unix-goto navigation system.

---

## Table of Contents

- [Core Navigation API](#core-navigation-api)
- [Cache Management API](#cache-management-api)
- [Bookmark API](#bookmark-api)
- [History API](#history-api)
- [List & Discovery API](#list--discovery-api)
- [Benchmark API](#benchmark-api)
- [Configuration](#configuration)
- [Return Codes](#return-codes)
- [Data Formats](#data-formats)

---

## Core Navigation API

### `goto`

Primary navigation function with natural language support and smart path resolution.

**Signature:**
```bash
goto [options] <destination>
goto --help
```

**Parameters:**
- `destination` - Target folder name, path, bookmark, or natural language query
- `--help`, `-h` - Display help information

**Returns:**
- `0` - Navigation successful
- `1` - Navigation failed (folder not found, ambiguous, or error)

**Examples:**
```bash
# Direct shortcuts
goto luxor                      # Navigate to LUXOR root
goto halcon                     # Navigate to HALCON project
goto docs                       # Navigate to ASCIIDocs root
goto infra                      # Navigate to ASCIIDocs/infra

# Direct folder access
goto GAI-3101                   # Navigate to folder by name
goto WA3590                     # Navigate to any indexed folder

# Multi-level navigation
goto GAI-3101/docs              # Navigate to nested folder
goto LUXOR/Git_Repos/unix-goto  # Full path navigation
goto project/sub/deep/nested    # Any depth supported

# Smart search (recursive)
goto unix-goto                  # Finds uniquely named folder automatically
# Output: ✓ Found: /Users/.../LUXOR/Git_Repos/unix-goto

# Bookmark navigation
goto @work                      # Navigate using bookmark
goto @proj1                     # Short bookmark syntax

# Special commands
goto ~                          # Return to home directory
goto zshrc                      # Source and display .zshrc
goto bashrc                     # Source and display .bashrc

# Subcommands
goto list                       # List all destinations
goto index rebuild              # Rebuild cache index
goto benchmark all              # Run all benchmarks
```

**Search Behavior:**
1. Check for bookmark syntax (`@name`)
2. Check for special cases (list, index, benchmark, ~, zshrc, etc.)
3. Check multi-level paths (contains `/`)
4. Try cache lookup (O(1) performance if cache valid)
5. Try direct folder match in search paths
6. Recursive search for unique folders (max depth 3)
7. Natural language AI resolution (if input contains spaces)

**Output:**
- Success: `→ /full/path/to/destination`
- Cache hit: `✓ Found in cache: /path/to/folder`
- Searching: `🔍 Searching in subdirectories (cache miss)...`
- Multiple matches: Lists all matches with selection prompt
- Not found: `❌ Project not found: <destination>`

---

### `__goto_navigate_to`

Internal navigation helper that handles directory change, history tracking, and stack management.

**Signature:**
```bash
__goto_navigate_to <target_directory>
```

**Parameters:**
- `target_directory` - Absolute path to navigate to

**Side Effects:**
- Pushes current directory to navigation stack
- Changes to target directory
- Tracks navigation in history
- Prints navigation confirmation

**Used By:**
- `goto` function
- `bookmark goto` command
- All navigation operations

---

## Cache Management API

### `goto index`

Manage the folder index cache system for high-performance navigation.

**Signature:**
```bash
goto index <subcommand> [options]
goto index --help
```

**Subcommands:**

#### `goto index rebuild`

Build or rebuild the folder index cache from scratch.

```bash
goto index rebuild
```

**Process:**
1. Scans all configured search paths
2. Indexes folders up to configured depth (default: 3)
3. Stores index in `~/.goto_index`
4. Reports total folders and build time

**Output:**
```
Building folder index cache...
  Search paths: 3
  Max depth: 3

  Scanning: /Users/manu/ASCIIDocs
  Scanning: /Users/manu/Documents/LUXOR
  Scanning: /Users/manu/Documents/LUXOR/PROJECTS

✓ Cache built successfully
  Total folders indexed: 487
  Build time: 2s
  Cache file: /Users/manu/.goto_index
  Cache size: 42K
```

**Performance:**
- Typical workspace (50 folders): ~1-2s
- Large workspace (500+ folders): ~3-5s

---

#### `goto index status`

Display cache statistics, age, and health information.

```bash
goto index status
```

**Output:**
```
╔══════════════════════════════════════════════════════════════════╗
║              FOLDER INDEX CACHE STATUS                           ║
╚══════════════════════════════════════════════════════════════════╝

Cache Information:
  Location:         /Users/manu/.goto_index
  Version:          1.0
  Status:           ✓ Fresh

Statistics:
  Total entries:    487 folders
  Cache size:       42K
  Search depth:     3 levels

Age:
  Built:            2025-10-17 14:23:15
  Age:              2h 15m
  TTL:              24h (1440m)
  Auto-refresh:     Not needed

Sample Entries (first 5):
  GAI-3101 → /Users/manu/Documents/LUXOR/PROJECTS/GAI-3101
  HALCON → /Users/manu/Documents/LUXOR/PROJECTS/HALCON
  unix-goto → /Users/manu/Documents/LUXOR/Git_Repos/unix-goto
  ...

Performance:
  Lookup time:      <100ms (O(1) hash table)
  Expected speedup: 20-50x vs recursive search
```

---

#### `goto index clear`

Delete the cache file. Next navigation will trigger cache rebuild if auto-refresh is enabled.

```bash
goto index clear
```

**Output:**
```
✓ Cache cleared: /Users/manu/.goto_index
```

---

#### `goto index refresh`

Auto-refresh cache if stale (age > TTL).

```bash
goto index refresh
```

**Behavior:**
- Checks cache validity
- Rebuilds if stale or missing
- Silent if cache is fresh

---

### Cache Internal Functions

#### `__goto_cache_build`

Build cache index by scanning all search paths.

**Signature:**
```bash
__goto_cache_build
```

**Algorithm:**
1. Create temporary index file
2. Write metadata header (version, timestamp, depth)
3. Scan each search path with `find -maxdepth`
4. Store entries in format: `folder_name|full_path|depth|mtime`
5. Move temp file to permanent location

**Performance:** O(n) where n is total folders

---

#### `__goto_cache_lookup`

Look up folder in cache with O(1) hash table performance.

**Signature:**
```bash
__goto_cache_lookup <folder_name>
```

**Parameters:**
- `folder_name` - Folder to find

**Returns:**
- `0` - Single match found, path written to stdout
- `1` - Not found in cache
- `2` - Multiple matches found, all paths written to stdout

**Algorithm:**
1. Validate cache
2. Use grep for fast lookup: `grep "^$folder_name|" ~/.goto_index`
3. Verify folder still exists on disk
4. Return match(es)

**Performance:** O(1) average case, <100ms target

---

#### `__goto_cache_is_valid`

Check if cache exists and is not stale.

**Signature:**
```bash
__goto_cache_is_valid
```

**Returns:**
- `0` - Cache is valid
- `1` - Cache is invalid (missing, unreadable, or stale)

**Checks:**
1. File exists
2. File is readable
3. Contains valid timestamp
4. Age < TTL (default 24 hours)

---

## Bookmark API

### `bookmark`

Manage bookmarks for favorite locations.

**Signature:**
```bash
bookmark <subcommand> [args...]
bookmark --help
```

**Alias:** `bm`

**Subcommands:**

#### `bookmark add`

Add a bookmark for current or specified directory.

```bash
bookmark add <name> [path]
```

**Parameters:**
- `name` - Bookmark name (required)
- `path` - Directory to bookmark (optional, defaults to `$PWD`)

**Returns:**
- `0` - Bookmark added successfully
- `1` - Error (invalid name, path doesn't exist, or name already exists)

**Examples:**
```bash
bookmark add work                   # Bookmark current directory as 'work'
bookmark add api ~/code/api-server  # Bookmark specific path
bm add proj1                        # Using alias
```

**Storage Format:**
```
work|/Users/manu/work|1697558122
api|/Users/manu/code/api-server|1697558130
```

---

#### `bookmark remove`

Remove a bookmark by name.

```bash
bookmark remove <name>
bookmark rm <name>
bookmark delete <name>
bookmark del <name>
```

**Parameters:**
- `name` - Bookmark name to remove

**Returns:**
- `0` - Bookmark removed successfully
- `1` - Bookmark not found

**Examples:**
```bash
bookmark rm work
bm delete old-project
```

---

#### `bookmark list`

List all saved bookmarks.

```bash
bookmark list
bookmark ls
bookmark l
```

**Output:**
```
Saved bookmarks:

  work                  → /Users/manu/work
  api                   → /Users/manu/code/api-server
  proj1                 → /Users/manu/projects/proj1

Total: 3 bookmarks

Usage: goto @name  or  bookmark goto name
```

**Returns:**
- `0` - Always (even if no bookmarks)

---

#### `bookmark goto`

Navigate to a bookmarked location.

```bash
bookmark goto <name>
bookmark go <name>
bookmark g <name>
goto @<name>         # Shortcut syntax
```

**Parameters:**
- `name` - Bookmark name

**Returns:**
- `0` - Navigation successful
- `1` - Bookmark not found or directory doesn't exist

**Examples:**
```bash
bookmark goto work
goto @work          # Preferred shortcut
bm g api
```

---

### Bookmark Internal Functions

#### `__goto_bookmark_add`

Internal function to add bookmark with validation.

#### `__goto_bookmark_remove`

Internal function to remove bookmark.

#### `__goto_bookmark_get`

Internal function to retrieve bookmark path by name.

**Signature:**
```bash
__goto_bookmark_get <name>
```

**Returns:** Bookmark path to stdout, or empty if not found

#### `__goto_bookmark_list`

Internal function to list all bookmarks.

#### `__goto_bookmark_goto`

Internal function to navigate to bookmark.

---

## History API

### `back`

Navigate backward through directory history using a persistent stack.

**Signature:**
```bash
back [N]
back --list
back --clear
back --help
```

**Parameters:**
- `N` - Number of directories to go back (optional, default: 1)
- `--list`, `-l` - Show navigation history
- `--clear` - Clear navigation history
- `--help`, `-h` - Show help

**Returns:**
- `0` - Navigation successful
- `1` - Already at first directory or invalid input

**Examples:**
```bash
back             # Go back one directory
back 3           # Go back three directories
back --list      # Show navigation stack
back --clear     # Clear history
```

**Output:**
```bash
# Single back
← /Users/manu/Documents/LUXOR

# Already at first
⚠️  Already at the first directory

# List output
Navigation history (most recent last):

  [0]   /Users/manu
  [1]   /Users/manu/Documents
  [2]   /Users/manu/Documents/LUXOR
  [3] → /Users/manu/Documents/LUXOR/Git_Repos (current)
```

---

### `recent`

Show and navigate to recently visited folders.

**Signature:**
```bash
recent [N]
recent --goto <index>
recent --clear
recent --help
```

**Parameters:**
- `N` - Number of recent folders to show (optional, default: 10)
- `--goto <index>`, `-g <index>` - Navigate to indexed recent folder
- `--clear` - Clear recent history
- `--help`, `-h` - Show help

**Returns:**
- `0` - Success
- `1` - Error (invalid index, folder doesn't exist)

**Examples:**
```bash
recent              # Show 10 recent folders
recent 20           # Show 20 recent folders
recent --goto 3     # Navigate to 3rd recent folder
recent -g 5         # Short form
recent --clear      # Clear history
```

**Output:**
```
Recently visited folders:

   1. unix-goto (current)
   2. LUXOR
   3. GAI-3101
   4. HALCON
   5. infra

Tip: Use 'recent --goto <N>' to navigate to a folder
```

---

### History Internal Functions

#### `__goto_track`

Track directory change in history file.

**Signature:**
```bash
__goto_track <target_directory>
```

**Storage Format:**
```
1697558122|/Users/manu/work
1697558130|/Users/manu/Documents/LUXOR
1697558145|/Users/manu/Documents/LUXOR/Git_Repos/unix-goto
```

**Behavior:**
- Appends timestamp and directory to history
- Maintains max entries (default: 100)
- Auto-trims on each write

---

#### `__goto_get_history`

Retrieve complete navigation history.

**Signature:**
```bash
__goto_get_history
```

**Returns:** Full history file contents to stdout

---

#### `__goto_recent_dirs`

Get unique recent directories in reverse chronological order.

**Signature:**
```bash
__goto_recent_dirs [limit]
```

**Parameters:**
- `limit` - Maximum number of directories (default: 10)

**Algorithm:**
1. Read history in reverse order
2. Use awk to filter unique directories
3. Limit to requested count

---

#### `__goto_stack_push`

Push current directory to navigation stack.

**Signature:**
```bash
__goto_stack_push <directory>
```

**Behavior:**
- Appends to stack file
- Maintains max 50 entries
- Auto-trims oldest entries

---

#### `__goto_stack_pop`

Pop from stack and navigate to previous directory.

**Signature:**
```bash
__goto_stack_pop
```

**Returns:**
- `0` - Navigation successful
- `1` - At first directory or error

**Behavior:**
- Removes last entry from stack
- Navigates to previous directory
- Recursively pops if directory no longer exists

---

## List & Discovery API

### `goto list`

Show available destinations and discovery tools.

**Signature:**
```bash
goto list [filter] [args...]
goto list --help
```

**Filters:**
- (none) - Show all destinations (shortcuts, bookmarks, folders)
- `--shortcuts`, `-s` - Show only predefined shortcuts
- `--folders`, `-f` - Show only folders in search paths
- `--bookmarks`, `-b` - Show only bookmarks
- `--recent`, `-r` - Show recently visited folders
- `--recent N` - Show N recent folders

**Examples:**
```bash
goto list                  # Show everything
goto list --shortcuts      # Only shortcuts
goto list --folders        # Only available folders
goto list --bookmarks      # Only bookmarks
goto list --recent         # Recent folders
goto list --recent 20      # 20 recent folders
```

**Output (all):**
```
Available destinations:

  ⚡ Shortcuts:
     luxor     → /Users/manu/Documents/LUXOR
     halcon    → /Users/manu/Documents/LUXOR/PROJECTS/HALCON
     docs      → /Users/manu/ASCIIDocs
     infra     → /Users/manu/ASCIIDocs/infra

  🔖 Bookmarks:
     @work      → /Users/manu/work
     @api       → /Users/manu/code/api-server

  📁 Available Folders:
     GAI-3101       (in PROJECTS)
     HALCON         (in PROJECTS)
     WA3590         (in PROJECTS)
     unix-goto      (in Git_Repos)

  💡 Tips:
     Use 'goto <name>' to navigate
     Use 'goto @<bookmark>' for bookmarked locations
     Use 'goto "natural language"' for AI-powered search
```

---

### List Internal Functions

#### `__goto_list_all`

Display all available destinations with optional filtering.

**Signature:**
```bash
__goto_list_all [show_shortcuts] [show_folders] [show_bookmarks]
```

**Parameters:**
- `show_shortcuts` - "true" or "false" (default: "true")
- `show_folders` - "true" or "false" (default: "true")
- `show_bookmarks` - "true" or "false" (default: "true")

---

#### `__goto_list_recent`

Display recently visited folders with timestamps and paths.

**Signature:**
```bash
__goto_list_recent [limit]
```

**Parameters:**
- `limit` - Number of folders to show (default: 10)

---

## Benchmark API

### `goto benchmark`

Performance benchmarking suite for navigation, cache, and search operations.

**Signature:**
```bash
goto benchmark <subcommand> [args...]
goto benchmark --help
```

**Subcommands:**

#### `goto benchmark navigation`

Test folder navigation performance (uncached vs cached).

```bash
goto benchmark navigation [target] [iterations]
```

**Parameters:**
- `target` - Folder to benchmark (default: "unix-goto")
- `iterations` - Number of test runs (default: 10)

**Measures:**
- Uncached lookup time (cold start with find)
- Cached lookup time (warm start with grep)
- Speedup ratio
- Min/max/mean/median statistics

**Performance Targets:**
- Cached navigation: <100ms
- Speedup ratio: 20-50x

**Output:**
```
╔══════════════════════════════════════════════════════════════════╗
║            NAVIGATION PERFORMANCE BENCHMARK                      ║
╚══════════════════════════════════════════════════════════════════╝

Target: unix-goto
Iterations: 10

Phase 1: Uncached Navigation (Cold Start)
─────────────────────────────────────────────
  Run 1: 208ms
  Run 2: 195ms
  ...

Uncached Results:
  Min:    195ms
  Max:    220ms
  Mean:   208ms
  Median: 207ms

Phase 2: Cached Navigation (Warm Start)
────────────────────────────────────────
  Run 1: 26ms
  Run 2: 24ms
  ...

Cached Results:
  Min:    24ms
  Max:    28ms
  Mean:   26ms
  Median: 26ms

Performance Improvement:
  Speedup: 8x faster with cache
  Target:  20-50x (as per specifications)
  Status:  ⚠ BELOW TARGET

Target: Navigation time <100ms
Status: ✓ MEETS TARGET (26ms)
```

---

#### `goto benchmark cache`

Test cache build time and hit rate.

```bash
goto benchmark cache [workspace_size] [iterations]
```

**Parameters:**
- `workspace_size` - "small", "typical", or "large" (default: "typical")
- `iterations` - Number of test runs (default: 10)

**Workspace Sizes:**
- small: 10 folders
- typical: 50 folders (default)
- large: 200+ folders

**Measures:**
- Cache build time
- Cache hit rate (simulated)

**Performance Targets:**
- Hit rate: >90%
- Build time: <5s for typical workspace

---

#### `goto benchmark parallel`

Test sequential vs parallel search performance.

```bash
goto benchmark parallel [iterations]
```

**Parameters:**
- `iterations` - Number of test runs (default: 10)

**Measures:**
- Sequential search time (one path at a time)
- Parallel search time (background jobs)
- Speedup ratio

---

#### `goto benchmark report`

Generate comprehensive summary of all benchmark results.

```bash
goto benchmark report
```

**Output:**
```
╔══════════════════════════════════════════════════════════════════╗
║           UNIX-GOTO PERFORMANCE BENCHMARK REPORT                 ║
╚══════════════════════════════════════════════════════════════════╝

System Information:
  OS:           Darwin 23.1.0
  Shell:        /bin/zsh
  Date:         2025-10-17 14:35:22
  Total Runs:   45

Navigation Benchmarks:
──────────────────────
  Uncached (cold):  208ms
  Cached (warm):    26ms
  Speedup:          8x

Cache Benchmarks:
─────────────────
  Build time:       3217ms
  Hit rate:         92%
  Target:           >90%

Parallel Search Benchmarks:
────────────────────────────
  Sequential:       2477ms
  Parallel:         1177ms
  Speedup:          2.10x

Raw data available at: /Users/manu/.goto_benchmarks/results.csv
```

---

#### `goto benchmark all`

Run complete benchmark suite (navigation + cache + parallel).

```bash
goto benchmark all
```

**Process:**
1. Navigation benchmark (5 iterations)
2. Cache benchmark (5 iterations)
3. Parallel search benchmark (5 iterations)
4. Generate report

**Execution Time:** ~2-5 minutes

---

#### `goto benchmark workspace`

Manage test workspaces for benchmarking.

```bash
goto benchmark workspace create <type> [--force]
goto benchmark workspace stats
goto benchmark workspace clean
```

**Workspace Types:**
- `small` - 10 folders, 2 levels deep
- `typical` - 50 folders, 3 levels deep
- `large` - 200+ folders, 4 levels deep

**Examples:**
```bash
goto benchmark workspace create typical
goto benchmark workspace stats
goto benchmark workspace clean
```

---

### Benchmark Internal Functions

#### `__goto_benchmark_init`

Initialize benchmark directory and results file.

**Creates:**
- `~/.goto_benchmarks/` directory
- `~/.goto_benchmarks/results.csv` with headers

---

#### `__goto_benchmark_record`

Record benchmark result to CSV file.

**Signature:**
```bash
__goto_benchmark_record <type> <test_case> <duration_ms> <cache_status> <workspace_size> [info]
```

**CSV Format:**
```csv
timestamp,benchmark_type,test_case,duration_ms,cache_status,workspace_size,additional_info
1697558122,navigation,uncached_run_1,208,cold,typical,unix-goto
1697558123,navigation,cached_run_1,26,warm,typical,unix-goto
```

---

#### `__goto_benchmark_stats`

Calculate min/max/mean/median statistics.

**Signature:**
```bash
__goto_benchmark_stats <value1> [value2] [value3] ...
```

**Returns:** Pipe-delimited stats: `min|max|mean|median`

---

## Configuration

### Environment Variables

#### Cache Configuration

```bash
# Cache file location (default: ~/.goto_index)
export GOTO_INDEX_FILE="/custom/path/to/index"

# Cache TTL in seconds (default: 86400 = 24 hours)
export GOTO_CACHE_TTL=43200  # 12 hours

# Search depth for indexing (default: 3)
export GOTO_SEARCH_DEPTH=4
```

#### History Configuration

```bash
# History file location (default: ~/.goto_history)
export GOTO_HISTORY_FILE="/custom/path/to/history"

# Maximum history entries (default: 100)
export GOTO_HISTORY_MAX=200

# Stack file location (default: ~/.goto_stack)
export GOTO_STACK_FILE="/custom/path/to/stack"
```

#### Bookmark Configuration

```bash
# Bookmarks file location (default: ~/.goto_bookmarks)
export GOTO_BOOKMARKS_FILE="/custom/path/to/bookmarks"
```

#### Benchmark Configuration

```bash
# Benchmark iterations (default: 10)
export GOTO_BENCHMARK_ITERATIONS=20

# Warmup iterations (default: 3)
export GOTO_BENCHMARK_WARMUP=5

# Results directory (default: ~/.goto_benchmarks)
export GOTO_BENCHMARK_DIR="/custom/path/to/benchmarks"
```

---

## Return Codes

### Standard Return Codes

All functions follow standard bash conventions:

- `0` - Success
- `1` - General error (not found, invalid input, etc.)
- `2` - Multiple matches found (cache lookup only)

### Specific Behaviors

**Cache Lookup (`__goto_cache_lookup`):**
- `0` - Single match found
- `1` - Not found in cache
- `2` - Multiple matches found

**Navigation Functions:**
- `0` - Navigation successful
- `1` - Navigation failed

**Management Commands:**
- `0` - Command successful
- `1` - Command failed or invalid input

---

## Data Formats

### Cache Index Format

**File:** `~/.goto_index`

**Header:**
```
# unix-goto folder index cache
# Version: 1.0
# Built: 1697558122
# Depth: 3
# Format: folder_name|full_path|depth|last_modified
#---
```

**Entries:**
```
unix-goto|/Users/manu/Documents/LUXOR/Git_Repos/unix-goto|8|1697558100
GAI-3101|/Users/manu/Documents/LUXOR/PROJECTS/GAI-3101|6|1697558050
HALCON|/Users/manu/Documents/LUXOR/PROJECTS/HALCON|6|1697558075
```

**Fields:**
1. `folder_name` - Basename of folder
2. `full_path` - Absolute path
3. `depth` - Number of path separators
4. `last_modified` - Unix timestamp of last modification

---

### Bookmark Format

**File:** `~/.goto_bookmarks`

**Format:**
```
work|/Users/manu/work|1697558122
api|/Users/manu/code/api-server|1697558130
proj1|/Users/manu/projects/proj1|1697558145
```

**Fields:**
1. `name` - Bookmark name
2. `path` - Absolute path
3. `timestamp` - Unix timestamp of creation

---

### History Format

**File:** `~/.goto_history`

**Format:**
```
1697558122|/Users/manu/work
1697558130|/Users/manu/Documents/LUXOR
1697558145|/Users/manu/Documents/LUXOR/Git_Repos/unix-goto
```

**Fields:**
1. `timestamp` - Unix timestamp of navigation
2. `directory` - Absolute path visited

---

### Stack Format

**File:** `~/.goto_stack`

**Format:**
```
/Users/manu
/Users/manu/Documents
/Users/manu/Documents/LUXOR
/Users/manu/Documents/LUXOR/Git_Repos
/Users/manu/Documents/LUXOR/Git_Repos/unix-goto
```

Each line is an absolute path, most recent last.

---

### Benchmark Results Format

**File:** `~/.goto_benchmarks/results.csv`

**Header:**
```csv
timestamp,benchmark_type,test_case,duration_ms,cache_status,workspace_size,additional_info
```

**Example Entries:**
```csv
1697558122,navigation,uncached_run_1,208,cold,typical,unix-goto
1697558123,navigation,cached_run_1,26,warm,typical,unix-goto
1697558124,cache,build_run_1,3217,cold,typical,folder_count=50
1697558125,cache,hit_rate,92,warm,typical,hits=92/total=100
1697558126,parallel,sequential_run_1,2477,cold,typical,paths=3
1697558127,parallel,parallel_run_1,1177,cold,typical,paths=3
```

---

## Performance Guarantees

### Cached Navigation
- **Target:** <100ms
- **Typical:** 20-50ms
- **Algorithm:** O(1) hash table lookup

### Cache Build
- **Target:** <5s for 500 folders
- **Typical:** 1-3s for typical workspace
- **Algorithm:** O(n) filesystem scan

### Cache Hit Rate
- **Target:** >90%
- **Typical:** 92-95%
- **Depends on:** Workspace stability and TTL

### Speedup Ratio
- **Target:** 20-50x (cached vs uncached)
- **Achieved:** 8-25x (depends on workspace)
- **Factors:** Workspace size, depth, disk speed

---

## Integration Examples

### Use in Scripts

```bash
#!/bin/bash
# Navigate to project and run command

# Source goto functions
source /path/to/unix-goto/goto.sh

# Navigate to project
if goto my-project; then
    # Run commands in project directory
    git status
    npm test
else
    echo "Failed to navigate to project"
    exit 1
fi
```

### Check Path Without Navigation

```bash
# Get path without navigating
project_path=$(__goto_cache_lookup "my-project" 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "Project found at: $project_path"
    # Use path without navigating
    ls -la "$project_path"
fi
```

### Batch Operations

```bash
# Rebuild cache for all projects
goto index rebuild

# List all folders and process
goto list --folders | while read -r line; do
    folder=$(echo "$line" | awk '{print $1}')
    echo "Processing: $folder"
done
```

---

## Version History

### v0.4.0 (2025-10-17)
- Added folder index caching system (CET-77)
- Added comprehensive benchmark suite (CET-85)
- 8x performance improvement with caching
- Complete API documentation

### v0.3.0
- Multi-level navigation support
- Smart recursive search
- Bookmark system
- Navigation history
- Discovery tools

### v0.2.0
- Natural language support
- Claude AI integration
- Basic shortcuts

### v0.1.0
- Initial release
- Core navigation

---

**Maintained By:** Manu Tej + Claude Code
**License:** MIT
**Repository:** https://github.com/manutej/unix-goto

For complete usage examples, see [QUICKSTART.md](QUICKSTART.md)
For developer guide, see [DEVELOPER-GUIDE.md](DEVELOPER-GUIDE.md)
For benchmark details, see [BENCHMARKS.md](BENCHMARKS.md)
