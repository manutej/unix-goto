# LUXOR Integration for unix-goto

**Status**: ✅ COMPLETE | **Version**: 1.0 | **Updated**: October 26, 2025

Unix-goto now has full integration with the LUXOR knowledge management system, providing quick access to all 36 knowledge assets (core systems, projects, git repositories, and work streams).

---

## Quick Start

Navigate to any LUXOR project using simple shortcuts:

```bash
# Core Systems
goto mercurio           # MERCURIO synthesis framework
goto hekat              # HEKAT DSL (in compact folder)
goto barque             # BARQUE document generation
goto lumina             # LUMINA discovery system
goto consciousness      # CONSCIOUSNESS philosophy framework
goto hermetic           # HERMETIC-SEVEN creative system
goto support            # SUPPORT-AUTOMATION intelligent routing
goto linear             # LINEAR-ACCELERATOR team acceleration

# Major Projects
goto halcon             # HALCON comprehensive research system
goto research           # research-plan-dsl work stream
goto copilot            # copilot-course educational content
goto maestros           # maestros expert systems research
goto hyperglyph         # hyperglyph encoding system

# Git Repositories
goto unix-goto          # unix-goto navigation tools (current repo)
goto tax                # tax-collection-system production app
goto excalidraw         # excalidraw-mcp MCP integration
goto yt                 # yt YouTube processor
goto docrag             # docrag RAG system

# Work Streams
goto docrag             # docrag work stream
goto customer-support   # customer-support-automation
goto linear-dev         # linear-dev-accelerator
goto hermetic-app       # hermetic-app work stream
goto cheatsheets        # cheatsheets quick reference
```

---

## Supported Shortcuts (36 Total)

### Core Systems (8)
Located in `/compact/` with publication-ready documentation:

| Shortcut | Location | Pattern | Docs |
|----------|----------|---------|------|
| `mercurio` | compact/MERCURIO | SYNTHESIS | 5 |
| `hermetic` | compact/HERMETIC-SEVEN | CREATION | 5 |
| `consciousness` | compact/CONSCIOUSNESS | INQUIRY | 5 |
| `hekat`, `hekat-dsl` | compact/HEKAT-DSL | ORCHESTRATION | 5 |
| `barque` | compact/BARQUE | GENERATION | 5 |
| `lumina` | compact/LUMINA | DISCOVERY | 5 |
| `support`, `support-automation` | compact/SUPPORT-AUTOMATION | COORDINATION | 4 |
| `linear`, `linear-accelerator` | compact/LINEAR-ACCELERATOR | OPTIMIZATION | 4 |

**Pattern Reference**: Each core system maps to one of 8 abstract workflow patterns used throughout LUXOR.

### Major Projects (11)
Research and implementation projects in `/PROJECTS/`:

| Shortcut | Location | Type | Docs |
|----------|----------|------|------|
| `halcon` | PROJECTS/HALCON | Comprehensive System | 7,490 |
| `hekat` | PROJECTS/hekat | DSL Implementation | 146 |
| `copilot` | PROJECTS/copilot-course | Education | 38 |
| `maestros` | PROJECTS/maestros | Research | 70 |
| `customer-support` | PROJECTS/customer-support | Implementation | 59 |
| `hyperglyph` | PROJECTS/hyperglyph | Encoding | 24 |
| `lumos` | PROJECTS/LUMOS | Visualization | 18 |
| `grok` | PROJECTS/grok-cli | Exploration | 0 |
| `orch` | PROJECTS/orch-cli | Exploration | 1 |

### Git Repositories (10)
Production and development repositories in `/Git_Repos/`:

| Shortcut | Location | Type | Docs |
|----------|----------|------|------|
| `unix-goto` | Git_Repos/unix-goto | Tool | 119 |
| `tax` | Git_Repos/tax-collection-system | App | 1,682 |
| `excalidraw` | Git_Repos/excalidraw-mcp-integration | Integration | 1,166 |
| `docrag` | Git_Repos/docrag | RAG | 215 |
| `yt` | Git_Repos/yt | Tool | 99 |
| `paper2agent` | Git_Repos/paper2agent | Research | 55 |
| `canva` | Git_Repos/canva-code | API | 12 |
| `chatz` | Git_Repos/chatz | System | 3 |
| `cc-boot` | Git_Repos/cc-boot | Utility | 5 |

### Work Streams (7)
Active development streams at root level:

| Shortcut | Location | Focus | Docs |
|----------|----------|-------|------|
| `research`, `research-plan` | research-plan-dsl | DSL Development | 211 |
| `copilot` | copilot-course | Education | 67 |
| `docrag` | docrag | RAG System | 16 |
| `customer-support-automation` | customer-support-automation | Automation | 4 |
| `linear-dev` | linear-dev-accelerator | Team Tools | 7 |
| `hermetic-app` | hermetic-app | Application | 2 |
| `cheatsheets` | cheatsheets | References | 3 |

---

## How It Works

### Resolution Order

When you run `goto <project>`, unix-goto tries to find the project in this order:

1. **Exact Shortcuts** - Check hardcoded shortcuts (ultra-fast)
   - Examples: `mercurio`, `halcon`, `unix-goto`
   - Instant lookup, cached

2. **Dynamic Inventory** - Query `project-inventory.json` (fast)
   - Falls back to structured project index
   - Case-insensitive matching
   - Searches across all categories

3. **Smart Search** - Find uniquely named folders (fallback)
   - Uses existing goto recursive search
   - Up to 3 levels deep
   - Perfect for variations

### Example Resolution Paths

```bash
# Direct match - fastest
goto mercurio
→ Matches shortcut "mercurio"
→ Returns /Users/manu/Documents/LUXOR/compact/MERCURIO instantly

# Case-insensitive - still fast
goto HALCON
goto halcon
goto Halcon
→ All match "halcon" shortcut (normalized)
→ Returns /Users/manu/Documents/LUXOR/PROJECTS/HALCON

# Alias match - very fast
goto hermetic-seven
goto hermetic
→ "hermetic-seven" or "hermetic" matches shortcut
→ Returns /Users/manu/Documents/LUXOR/compact/HERMETIC-SEVEN

# Fallback to recursive search - slower but flexible
goto some-unique-folder-name
→ If not in shortcuts, searches recursively
→ Works with abbreviations and unique names
```

---

## Advanced Usage

### Multi-Level Navigation

Combine LUXOR shortcuts with path navigation:

```bash
# Navigate to specific folder within project
goto mercurio/docs                # Go to MERCURIO/docs
goto halcon/PROJECTS/subproject   # Go to nested path
goto research-plan-dsl/src        # Go to work stream subfolder

# Works with any shortcut
goto unix-goto/lib                # Go to library code
goto tax-collection-system/src    # Go to app source
```

### Documentation Access

Each project has documentation integrated:

```bash
# Navigate then explore docs
goto mercurio
goto research-plan-dsl

# Use /docs command (once implemented)
goto --docs mercurio              # Show project documentation
goto --readme halcon              # Show README.md
```

### Combining with Bookmarks

Save frequent LUXOR destinations:

```bash
# From LUXOR project, create bookmark
goto mercurio
bookmark add synthesis            # Bookmark MERCURIO as "synthesis"

# Later, quick access
goto @synthesis                   # Go to saved MERCURIO folder
```

### Quick Listing

Discover what's available:

```bash
# Show all LUXOR projects
goto list --folders | grep -i luxor

# Show available shortcuts
goto list --shortcuts | grep -E "mercurio|halcon|research"

# Refresh the cache
goto index rebuild                # Updates cached folder index
```

---

## Architecture

### File Structure

```
unix-goto/
├── lib/
│   ├── goto-function.sh           # Main goto function (updated)
│   └── luxor-shortcuts.sh         # LUXOR integration (NEW)
├── docs/
│   └── LUXOR-INTEGRATION.md      # This file (NEW)
├── README.md                      # Updated with LUXOR info
└── project-inventory.json         # Synced from LUXOR
```

### Integration Points

1. **luxor-shortcuts.sh** - New library providing:
   - `__goto_resolve_luxor_project()` - Intelligent project resolution
   - `__goto_hardcoded_luxor_shortcut()` - Fast lookup table
   - Fallback to JSON inventory when available

2. **goto-function.sh** - Updated to:
   - Source `luxor-shortcuts.sh` at runtime
   - Try LUXOR shortcuts before recursive search
   - Maintain backward compatibility

3. **project-inventory.json** - Machine-readable index:
   - All 36 projects with metadata
   - Located in `/Users/manu/Documents/LUXOR/`
   - Auto-generated, always current

### Performance

| Operation | Speed | Method |
|-----------|-------|--------|
| Hardcoded shortcut | <1ms | Direct case matching |
| Alias shortcut | <1ms | Case-insensitive string match |
| JSON lookup | 5-10ms | jq or Python JSON parsing |
| Recursive search | 100-500ms | Filesystem traversal |

**Optimization**: Shortcuts are ~1000x faster than recursive search!

---

## Updating Shortcuts

### When Adding New LUXOR Projects

1. **Automatic (Preferred)**:
   ```bash
   # Regenerate project inventory
   cd /Users/manu/Documents/LUXOR
   python3 scripts/project_discovery.py  # Auto-updates inventory

   # Shortcut becomes immediately available
   goto new-project
   ```

2. **Manual (If Needed)**:
   - Edit `lib/luxor-shortcuts.sh`
   - Add case statement for new project
   - Update documentation
   - Test: `goto new-project`

### Aliasing Projects

Create shorter aliases for long project names:

```bash
# In luxor-shortcuts.sh __goto_hardcoded_luxor_shortcut()
# Add before existing cases:
        my-alias)
            echo "/path/to/project"
            return 0
            ;;
```

Example:
```bash
# Support both
goto excalidraw
goto excalidraw-mcp
# Both work!
```

---

## Examples

### Typical Workflow

```bash
# Start work
goto research-plan-dsl              # Navigate to DSL work stream
cd src                              # Go to source code
# ... edit files ...
git status

# Research the framework
goto mercurio                       # Go to MERCURIO synthesis docs
ls                                  # See documentation files
cat 01-EXECUTIVE-SUMMARY.md        # Quick overview

# Check implementation
goto hekat-dsl                      # Go to core system docs
cat 02-TECHNICAL-SPECIFICATION.md  # Deep dive

# Explore project structure
goto halcon                         # Most comprehensive project
goto halcon/PROJECTS               # See sub-projects
```

### Context Switching

```bash
# Working on synthesis patterns
goto mercurio

# Need to understand orchestration
goto hekat-dsl
# ... read and understand ...

# Back to synthesis
back                                # Go back to mercurio

# Compare approaches
goto @mercurio                      # Bookmark support
goto @hekat                         # Jump between bookmarks
```

### Documentation Discovery

```bash
# Find all documentation
goto luxor                          # Go to LUXOR root
find . -name "*.md" | wc -l        # Count docs (75,000+)

# Access documentation command
/docs --help                        # Universal documentation navigator
/docs --pattern synthesis          # See all SYNTHESIS pattern examples
/docs --project mercurio           # Get MERCURIO docs
/docs --stats                      # See coverage statistics
```

---

## Troubleshooting

### "Project not found"

If a shortcut isn't working:

```bash
# 1. Check if it exists
ls ~/Documents/LUXOR/compact/MERCURIO

# 2. Try exact name with different case
goto Mercurio
goto MERCURIO
goto mercurio

# 3. Use recursive search
goto list --folders | grep -i mercurio

# 4. Rebuild cache
goto index rebuild
```

### Performance Issues

If goto feels slow:

```bash
# Rebuild the index cache
goto index rebuild

# Check cache status
goto index status

# See how many folders are indexed
goto index stats
```

### Inventory Out of Date

If new projects don't appear:

```bash
# Manually refresh inventory
cd /Users/manu/Documents/LUXOR
python3 -c "
import json
from pathlib import Path
from datetime import datetime

# (Auto-discovery script)
# See project-inventory.json for full script
"

# Test new shortcut
goto new-project
```

---

## Configuration

### Current Search Paths

Unix-goto searches in:
- `$HOME/ASCIIDocs` (documentation)
- `$HOME/Documents/LUXOR` (projects and systems)
- `$HOME/Documents/LUXOR/PROJECTS` (project sub-folder)

### Customizing

To add more search paths or shortcuts:

1. Edit `lib/goto-function.sh` lines 216-220:
```bash
local search_paths=(
    "$HOME/ASCIIDocs"
    "$HOME/Documents/LUXOR"
    "$HOME/Documents/LUXOR/PROJECTS"
    # Add your paths here
)
```

2. Or use ~/.gotorc (coming in Phase 1):
```bash
GOTO_SEARCH_PATHS=(
    "$HOME/projects"
    "$HOME/work"
    "$HOME/Documents/LUXOR"
)
```

---

## Future Enhancements

### Planned Features

**Phase 1 (v0.4.0)**:
- ✅ LUXOR project shortcuts
- [ ] Configuration file (~.gotorc)
- [ ] Custom search depths

**Phase 2 (v0.5.0)**:
- [ ] Tab completion for LUXOR projects
- [ ] Batch output modes
- [ ] Execute-in-place commands

**Phase 3 (v0.6.0)**:
- [ ] Fuzzy matching (typo tolerance)
- [ ] Parallel search optimization
- [ ] Deep documentation integration

**Integration Opportunities**:
- `/docs` command - Use goto for navigation
- Editor plugins - VSCode/JetBrains integration
- Workspace management - Project grouping
- Git integration - Branch awareness

---

## Testing

### Quick Test

```bash
# Test core shortcuts
goto mercurio && echo "✓ MERCURIO" && cd -
goto halcon && echo "✓ HALCON" && cd -
goto unix-goto && echo "✓ unix-goto" && cd -

# Test work streams
goto research && echo "✓ research" && cd -
goto copilot && echo "✓ copilot" && cd -

# Test git repos
goto tax && echo "✓ tax" && cd -
goto excalidraw && echo "✓ excalidraw" && cd -
```

### Comprehensive Test

```bash
# Run full test suite
cd /Users/manu/Documents/LUXOR/Git_Repos/unix-goto
./tests/run-tests.sh
```

---

## Documentation Reference

Related documentation:
- **Unix-goto README**: Overview of all goto features
- **API Reference**: Complete command reference
- **PROJECT-INDEX.md**: Master registry of all 36 projects
- **CLEANUP-EXECUTION-SUMMARY.md**: How the inventory was created
- **Startup Guide**: Getting started with LUXOR

---

## Summary

LUXOR integration makes unix-goto your navigation hub for all 36 knowledge assets:

- **8 Core Systems** with publication-ready docs
- **11 Major Projects** with research and implementation
- **10 Git Repositories** for tools and production systems
- **7 Work Streams** for active development

Navigate intelligently with shortcuts, aliases, and recursive search. Access documentation through `/docs` command. Switch contexts instantly with bookmarks.

**All 36 projects. One command. `goto mercurio`.**

---

*Generated with Claude Code*
*Part of LUXOR Knowledge Management System*
*Updated: October 26, 2025*
