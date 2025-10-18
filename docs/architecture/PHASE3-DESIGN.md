# Phase 3: Smart Search & Discovery - Design Document

**Date:** 2025-10-08
**Version:** 0.4.0 (planned)
**Status:** Design Phase

---

## 🎯 Goals

1. **finddir command**: Natural language directory search using Claude AI
2. **Enhanced goto list**: Additional filtering and sorting options
3. **Better discovery**: Help users find folders they've forgotten about

---

## 📋 Feature 1: finddir Command

### Overview
A new command that uses natural language to search for directories based on various criteria.

### Examples
```bash
# Time-based search
finddir "projects from last month"
finddir "folders modified this week"
finddir "created in 2024"

# Content-based search
finddir "folders with python code"
finddir "directories containing package.json"
finddir "projects with git repositories"

# Size-based search
finddir "large directories over 1GB"
finddir "small folders under 100MB"

# Name-based search (fuzzy)
finddir "projects like halcon"
finddir "anything with GAI in the name"

# Combined criteria
finddir "python projects from last 3 months over 100MB"
```

### Architecture

#### 1. Query Parser (Claude AI)
```bash
# User input → Claude AI → Structured query
Input: "python projects from last month"
Output: {
  "type": "content",
  "pattern": "*.py",
  "time_range": "last_month",
  "min_files": 3
}
```

#### 2. Search Engine (find/fd integration)
```bash
# Execute appropriate find commands based on parsed query
- Time-based: find -mtime -30
- Content: find -name "*.py"
- Size: find -size +1G
- Git: find -name ".git" -type d
```

#### 3. Result Ranker
```bash
# Rank results by relevance:
1. Number of matching criteria
2. Recency (recently modified higher)
3. Size (configurable: bigger or smaller)
4. Depth (shallower paths higher)
```

#### 4. Output Formatter
```bash
# Display results in easy-to-read format:
📁 Results for "python projects from last month":

  1) halcon-api (Modified: 3 days ago, Size: 245MB)
     → /Users/.../LUXOR/PROJECTS/halcon-api
     🐍 23 Python files

  2) data-processor (Modified: 1 week ago, Size: 89MB)
     → /Users/.../ASCIIDocs/projects/data-processor
     🐍 15 Python files

Total: 2 matching directories
```

### Implementation Plan

#### File: bin/finddir
```bash
#!/usr/bin/env bash
# finddir - Natural language directory search

# 1. Parse natural language query using Claude
# 2. Build find/fd command based on criteria
# 3. Execute search
# 4. Rank results
# 5. Display formatted output
```

#### File: bin/finddir-resolver
```bash
#!/usr/bin/env claude code
# Claude AI script to parse natural language search queries

Input: Natural language query
Output: JSON with search criteria:
{
  "time": {
    "range": "last_month|last_week|today",
    "exact": "2024-01-01"
  },
  "content": {
    "extensions": [".py", ".js"],
    "files": ["package.json", "requirements.txt"],
    "git": true
  },
  "size": {
    "min": "1GB",
    "max": "10GB"
  },
  "name": {
    "pattern": "halcon*",
    "fuzzy": "GAI"
  }
}
```

### Search Criteria Grammar

#### Time-based
- "last N days/weeks/months"
- "this week/month/year"
- "created/modified before/after DATE"
- "older than N days"

#### Content-based
- "with python/javascript/go code"
- "containing FILE"
- "git repositories"
- "node projects" (package.json)
- "python projects" (requirements.txt, setup.py)

#### Size-based
- "over/under SIZE"
- "between SIZE1 and SIZE2"
- "large/small directories"

#### Name-based
- "like PATTERN"
- "containing WORD"
- "starting with PREFIX"

### Edge Cases

1. **No results**: Show helpful message
   ```bash
   finddir "projects from yesterday"
   # ❌ No directories found matching criteria
   # Try: finddir "projects from last week"
   ```

2. **Too many results**: Limit + pagination
   ```bash
   # Show top 20 results, paginate rest
   # Allow: finddir --all to show everything
   ```

3. **Invalid query**: Claude can't parse
   ```bash
   finddir "asdfghjkl"
   # ⚠️  Could not understand search criteria
   # Try: finddir "projects from last month"
   ```

4. **Slow search**: Progress indicator
   ```bash
   finddir "folders over 1GB"
   # 🔍 Searching... (this may take a moment for size calculations)
   ```

---

## 📋 Feature 2: Enhanced goto list

### Current State
```bash
goto list                 # All destinations
goto list --shortcuts     # Only shortcuts
goto list --folders       # Only folders
goto list --bookmarks     # Only bookmarks
```

### Enhancements

#### 1. Recent Filter
```bash
goto list --recent        # Show recent folders (from history)
goto list --recent 20     # Show last 20 recent

# Output:
📂 Recent Folders:

  1) unix-goto (visited 5 minutes ago)
     → /Users/.../LUXOR/Git_Repos/unix-goto

  2) halcon (visited 2 hours ago)
     → /Users/.../LUXOR/PROJECTS/HALCON
```

#### 2. Sorting Options
```bash
goto list --sort name      # Alphabetical
goto list --sort recent    # Most recent first
goto list --sort size      # Largest first
goto list --sort modified  # Recently modified first
```

#### 3. Search/Filter
```bash
goto list --search python  # Filter by keyword
goto list --search GAI     # Show only GAI projects
```

#### 4. Format Options
```bash
goto list --format simple  # Just names (for scripting)
goto list --format full    # Full details with sizes, dates
goto list --format tree    # Tree view
```

### Implementation

#### File: lib/list-command.sh (update existing)
```bash
# Add new functions:
__goto_list_recent()     # Show recent from history
__goto_list_sorted()     # Sort by various criteria
__goto_list_search()     # Filter by keyword
__goto_list_format()     # Format output
```

---

## 🔧 Technical Considerations

### Performance
- **finddir**: May be slow for size calculations
  - Solution: Cache results, show progress
- **goto list --sort size**: Requires stat calls
  - Solution: Limit depth, use fd instead of find

### Dependencies
- **fd** (optional but faster): `brew install fd`
- **ripgrep** (optional for content search): `brew install ripgrep`
- Falls back to standard find/grep if not available

### Claude AI Integration
- Reuse existing goto-resolve pattern
- Create finddir-resolver script
- Handle API errors gracefully

---

## 📊 Success Criteria

### finddir
- [ ] Parses natural language queries accurately (80%+ success rate)
- [ ] Returns relevant results ranked appropriately
- [ ] Completes searches in < 5 seconds for typical queries
- [ ] Handles edge cases gracefully
- [ ] Clear, helpful output format

### Enhanced goto list
- [ ] --recent filter works with history integration
- [ ] Sorting options work correctly
- [ ] Search/filter returns relevant results
- [ ] Multiple format options available
- [ ] Backward compatible with existing usage

---

## 🧪 Testing Strategy

### finddir Tests
1. Time-based queries (last week, last month, etc.)
2. Content-based queries (python, git, etc.)
3. Size-based queries (over 1GB, etc.)
4. Combined criteria
5. Edge cases (no results, too many, invalid)

### goto list Tests
1. Recent filter with various limits
2. Each sort option
3. Search/filter functionality
4. Format options
5. Backward compatibility

---

## 📝 Documentation Plan

1. Update README.md with finddir examples
2. Update CHANGELOG.md for v0.4.0
3. Create PHASE3-TESTS.md with test scenarios
4. Update CONTRIBUTING.md if needed
5. Update PROJECT-STATUS.md

---

## ⏱️ Implementation Timeline

### Week 1: finddir Core
- Day 1-2: Claude AI query parser
- Day 3-4: Search engine implementation
- Day 5: Result ranking and formatting

### Week 2: Enhancements
- Day 1-2: Enhanced goto list features
- Day 3: Testing and bug fixes
- Day 4-5: Documentation

### Week 3: Polish
- Day 1-2: Performance optimization
- Day 3: Edge case handling
- Day 4: Final testing
- Day 5: PR and release

---

## 🚦 Decision Points

### 1. fd vs find
**Decision**: Support both, prefer fd if available
**Reason**: fd is faster but not always installed

### 2. Claude AI fallback
**Decision**: If Claude fails, show helpful error
**Reason**: Don't want command to be completely unusable if API is down

### 3. Result limit
**Decision**: Default to 20 results, --all for more
**Reason**: Balance between usefulness and overwhelming

### 4. Cache search results?
**Decision**: Not initially, evaluate after testing
**Reason**: Added complexity, may not be needed

---

## 🎯 Next Steps

1. ✅ Create this design document
2. Review with stakeholder (you!)
3. Create feature branch: feature/phase3-smart-search
4. Implement finddir command
5. Enhance goto list
6. Test thoroughly
7. Document and release v0.4.0

---

**Questions/Feedback?** Add notes here before implementation begins.
