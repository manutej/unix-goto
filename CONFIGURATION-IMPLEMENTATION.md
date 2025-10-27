# Configuration System Implementation

## Overview

Implemented a flexible configuration system for unix-goto that allows users to customize search paths and shortcuts without modifying source code.

## Changes Made

### 1. Configuration Loading System
- Added `__goto_load_config()` function in `lib/goto-function.sh`
- Loads user configuration from `~/.gotorc` if it exists
- Provides sensible defaults if no configuration file is present

### 2. Removed Hardcoded Paths
Replaced hardcoded paths in the following files:
- `lib/goto-function.sh` - Removed hardcoded shortcuts (luxor, halcon, docs, infra)
- `lib/cache-index.sh` - Uses configured search paths
- `lib/list-command.sh` - Uses configured search paths and shortcuts
- `lib/benchmark-command.sh` - Uses configured search paths

### 3. Configuration File
- Created `.gotorc.example` - Example configuration file with documentation
- Users can copy this to `~/.gotorc` and customize

### 4. Updated Documentation
- Updated README.md with comprehensive configuration instructions
- Explains the "seed directory" concept
- Provides quick setup guide

## Configuration Variables

### GOTO_SEARCH_PATHS
Array of directories to recursively search for folders.
```bash
GOTO_SEARCH_PATHS=(
    "$HOME/projects"
    "$HOME/work"
    "$HOME/Documents"
)
```

### GOTO_SHORTCUTS
Associative array of custom shortcuts for frequently accessed directories.
```bash
declare -A GOTO_SHORTCUTS
GOTO_SHORTCUTS[work]="$HOME/work"
GOTO_SHORTCUTS[docs]="$HOME/Documents"
```

### GOTO_SEARCH_DEPTH
Maximum depth for recursive directory search (default: 3).
```bash
GOTO_SEARCH_DEPTH=3
```

### GOTO_CACHE_TTL
Cache time-to-live in seconds (default: 86400 = 24 hours).
```bash
GOTO_CACHE_TTL=86400
```

## Default Behavior

If no `~/.gotorc` file exists:
- **Search paths**: `$HOME/projects`, `$HOME/Documents`, `$HOME/workspace`
- **Shortcuts**: None (user must configure)
- **Search depth**: 3 levels
- **Cache TTL**: 24 hours

## Benefits

1. **User-specific configuration** - No need to modify source code
2. **Environment flexibility** - Works on any system with any directory structure
3. **Easy onboarding** - Example configuration file with clear documentation
4. **Backward compatible** - Sensible defaults if no config exists
5. **Multi-user friendly** - Each user can have their own configuration

## Migration for Existing Users

For users who may have relied on the old hardcoded shortcuts:

1. Create `~/.gotorc`:
```bash
cp .gotorc.example ~/.gotorc
```

2. Add custom shortcuts for the old behavior (if desired):
```bash
declare -A GOTO_SHORTCUTS
GOTO_SHORTCUTS[luxor]="$HOME/Documents/LUXOR"
GOTO_SHORTCUTS[halcon]="$HOME/Documents/LUXOR/PROJECTS/HALCON"
GOTO_SHORTCUTS[docs]="$HOME/ASCIIDocs"
GOTO_SHORTCUTS[infra]="$HOME/ASCIIDocs/infra"
```

3. Reload shell and rebuild cache:
```bash
source ~/.zshrc
goto index rebuild
```

## Testing

The configuration system has been tested with:
- No config file (uses defaults)
- Custom config file with search paths
- Custom config file with shortcuts
- All configurations load correctly

## Addresses Feedback

This implementation addresses @manutej's feedback:
> "did you make sure paths are not hard coded but instead start from core folders and adapt to each user by unfolding the sub directory tree from core seed directories?"

**Yes** - Paths are now fully configurable via `~/.gotorc`. The "seed directories" concept is implemented through `GOTO_SEARCH_PATHS`, which are recursively searched up to `GOTO_SEARCH_DEPTH` levels. This allows the tool to adapt to any user's directory structure.
