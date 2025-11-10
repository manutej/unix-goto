# Phase 1 Implementation Plan: Quick Wins

**Target Release:** v0.4.0
**Timeline:** 2-4 weeks
**Goal:** 10x usability improvement with minimal effort

---

## 🎯 Features to Implement

### 1. Fuzzy Matching ⭐⭐⭐
**Priority:** CRITICAL
**Effort:** 2-3 days
**User Value:** No more exact typing required

### 2. Tab Completion ⭐⭐⭐
**Priority:** CRITICAL
**Effort:** 3-4 days
**User Value:** Interactive exploration

### 3. Frecency Algorithm ⭐⭐
**Priority:** HIGH
**Effort:** 2-3 days
**User Value:** Smart suggestions

### 4. Git-Aware Navigation ⭐⭐
**Priority:** HIGH
**Effort:** 1-2 days
**User Value:** Auto-detect repo context

### 5. Quick Stats ⭐
**Priority:** MEDIUM
**Effort:** 1 day
**User Value:** Directory information

---

## 📝 Detailed Implementation

### Feature 1: Fuzzy Matching

#### Algorithm Choice
Use **substring matching + Levenshtein distance** for balance of speed and accuracy.

#### Implementation: `lib/fuzzy-matching.sh`

```bash
#!/bin/bash
# Fuzzy matching helper functions

# Calculate Levenshtein distance (simplified)
__goto_levenshtein() {
    local s1="$1"
    local s2="$2"
    local len1=${#s1}
    local len2=${#s2}

    # Simple substring match first (fast path)
    if [[ "$s2" == *"$s1"* ]]; then
        echo "0"
        return
    fi

    # Simplified distance calculation
    # For performance, we'll use a simpler algorithm
    local -i dist=0
    local -i i

    # Case-insensitive comparison
    s1="${s1,,}"
    s2="${s2,,}"

    # Count matching characters
    for ((i=0; i<len1; i++)); do
        if [[ "${s2}" != *"${s1:$i:1}"* ]]; then
            ((dist++))
        fi
    done

    echo "$dist"
}

# Find fuzzy matches in array
__goto_fuzzy_match() {
    local query="$1"
    shift
    local -a candidates=("$@")
    local -a matches=()
    local -a scores=()

    # Convert query to lowercase for case-insensitive matching
    local query_lower="${query,,}"

    # Score each candidate
    for candidate in "${candidates[@]}"; do
        local candidate_lower="${candidate,,}"
        local score=100

        # Exact match: score 0 (best)
        if [[ "$candidate_lower" == "$query_lower" ]]; then
            score=0
        # Starts with query: score 10
        elif [[ "$candidate_lower" == "$query_lower"* ]]; then
            score=10
        # Contains query: score 20
        elif [[ "$candidate_lower" == *"$query_lower"* ]]; then
            score=20
        # Fuzzy match: calculate distance
        else
            score=$(__goto_levenshtein "$query_lower" "$candidate_lower")
            ((score += 30))  # Offset for fuzzy matches
        fi

        matches+=("$candidate")
        scores+=("$score")
    done

    # Sort by score and return top matches
    local -a sorted=()
    while [ ${#matches[@]} -gt 0 ]; do
        local min_idx=0
        local min_score=${scores[0]}

        for i in "${!scores[@]}"; do
            if [ "${scores[$i]}" -lt "$min_score" ]; then
                min_score="${scores[$i]}"
                min_idx=$i
            fi
        done

        sorted+=("${matches[$min_idx]}:${scores[$min_idx]}")
        unset 'matches[$min_idx]'
        unset 'scores[$min_idx]'
        matches=("${matches[@]}")
        scores=("${scores[@]}")
    done

    # Return top 5 matches with scores
    for i in {0..4}; do
        [ -n "${sorted[$i]}" ] && echo "${sorted[$i]}"
    done
}

# Enhanced goto with fuzzy matching
__goto_fuzzy_search() {
    local query="$1"
    local search_paths=(
        "$HOME/ASCIIDocs"
        "$HOME/Documents/LUXOR"
        "$HOME/Documents/LUXOR/PROJECTS"
    )

    # Gather all directories
    local -a dirs=()
    for base_path in "${search_paths[@]}"; do
        if [ -d "$base_path" ]; then
            while IFS= read -r dir; do
                dirs+=("$(basename "$dir")")
            done < <(find "$base_path" -maxdepth 1 -type d -not -name ".*" -not -path "$base_path" 2>/dev/null)
        fi
    done

    # Get fuzzy matches
    local matches
    matches=$(__goto_fuzzy_match "$query" "${dirs[@]}")

    # Process results
    local match_count=$(echo "$matches" | wc -l)

    if [ "$match_count" -eq 0 ]; then
        echo "❌ No matches found for: $query"
        return 1
    elif [ "$match_count" -eq 1 ]; then
        # Single match - navigate
        local dir=$(echo "$matches" | cut -d: -f1)
        echo "✓ Fuzzy match: $dir"
        goto "$dir"
    else
        # Multiple matches - show options
        echo "🔍 Fuzzy matches for '$query':"
        echo ""
        local i=1
        while IFS=: read -r dir score; do
            echo "  $i) $dir (score: $score)"
            ((i++))
        done <<< "$matches"
        echo ""
        echo "💡 Be more specific or use full name"
    fi
}
```

#### Integration into `goto`

```bash
# Add to lib/goto-function.sh after direct matching

# If no direct match, try fuzzy matching
if ! [[ "$1" == */* ]] && ! [[ "$1" == *" "* ]]; then
    echo "🔍 No exact match, trying fuzzy search..."
    if command -v __goto_fuzzy_search &> /dev/null; then
        __goto_fuzzy_search "$1"
        return $?
    fi
fi
```

---

### Feature 2: Tab Completion

#### Bash Completion: `completions/goto-completion.bash`

```bash
# bash completion for goto and related commands

_goto_completions() {
    local cur prev words cword
    _init_completion || return

    # Get current word being completed
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "$prev" in
        goto)
            # Complete with: shortcuts, bookmarks, directories, flags
            local shortcuts="luxor halcon docs infra list ~"
            local flags="--help --info"

            # Get bookmarks
            local bookmarks=""
            if [ -f ~/.goto_bookmarks ]; then
                bookmarks=$(cut -d'|' -f1 ~/.goto_bookmarks | sed 's/^/@/')
            fi

            # Get directories in search paths
            local dirs=""
            local search_paths=(
                "$HOME/ASCIIDocs"
                "$HOME/Documents/LUXOR"
                "$HOME/Documents/LUXOR/PROJECTS"
            )

            for base_path in "${search_paths[@]}"; do
                if [ -d "$base_path" ]; then
                    dirs="$dirs $(ls -1 "$base_path" 2>/dev/null | grep -v '^\.')"
                fi
            done

            COMPREPLY=($(compgen -W "$shortcuts $bookmarks $dirs $flags" -- "$cur"))
            ;;
        --goto|goto)
            # Numeric completion for recent command
            if [[ "$cur" =~ ^[0-9] ]]; then
                COMPREPLY=($(compgen -W "1 2 3 4 5 6 7 8 9 10" -- "$cur"))
            fi
            ;;
    esac
}

_bookmark_completions() {
    local cur prev words cword
    _init_completion || return

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "$prev" in
        bookmark|bm)
            COMPREPLY=($(compgen -W "add rm list goto --help" -- "$cur"))
            ;;
        goto|rm)
            # Complete with bookmark names
            if [ -f ~/.goto_bookmarks ]; then
                local bookmarks=$(cut -d'|' -f1 ~/.goto_bookmarks)
                COMPREPLY=($(compgen -W "$bookmarks" -- "$cur"))
            fi
            ;;
        add)
            # Complete with directory names
            COMPREPLY=($(compgen -d -- "$cur"))
            ;;
    esac
}

_back_completions() {
    local cur prev words cword
    _init_completion || return

    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=($(compgen -W "--list --clear --help 1 2 3 4 5" -- "$cur"))
}

_recent_completions() {
    local cur prev words cword
    _init_completion || return

    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=($(compgen -W "--goto --clear --help 5 10 20" -- "$cur"))
}

# Register completions
complete -F _goto_completions goto
complete -F _bookmark_completions bookmark bm
complete -F _back_completions back
complete -F _recent_completions recent
```

#### Zsh Completion: `completions/goto-completion.zsh`

```zsh
#compdef goto bookmark bm back recent

# goto completion
_goto() {
    local -a shortcuts bookmarks dirs flags

    shortcuts=(
        'luxor:LUXOR root directory'
        'halcon:HALCON project'
        'docs:ASCIIDocs root'
        'infra:Infrastructure folder'
        'list:List all destinations'
        '~:Home directory'
    )

    flags=(
        '--help:Show help message'
        '--info:Show directory information'
    )

    # Get bookmarks
    if [[ -f ~/.goto_bookmarks ]]; then
        while IFS='|' read -r name path _; do
            bookmarks+=("@$name:$path")
        done < ~/.goto_bookmarks
    fi

    # Get directories
    local search_paths=(
        "$HOME/ASCIIDocs"
        "$HOME/Documents/LUXOR"
        "$HOME/Documents/LUXOR/PROJECTS"
    )

    for base_path in $search_paths; do
        if [[ -d "$base_path" ]]; then
            for dir in "$base_path"/*(/); do
                dirs+=("${dir:t}:Directory in ${base_path:t}")
            done
        fi
    done

    _arguments \
        '1: :->args' \
        && return 0

    case $state in
        args)
            _describe 'shortcuts' shortcuts
            _describe 'bookmarks' bookmarks
            _describe 'directories' dirs
            _describe 'flags' flags
            ;;
    esac
}

# bookmark completion
_bookmark() {
    local -a commands
    commands=(
        'add:Add a bookmark'
        'rm:Remove a bookmark'
        'list:List all bookmarks'
        'goto:Navigate to bookmark'
    )

    _arguments \
        '1: :->command' \
        '2: :->arg' \
        && return 0

    case $state in
        command)
            _describe 'commands' commands
            ;;
        arg)
            case $words[2] in
                goto|rm)
                    # Complete with bookmark names
                    if [[ -f ~/.goto_bookmarks ]]; then
                        local -a bookmarks
                        while IFS='|' read -r name path _; do
                            bookmarks+=("$name:$path")
                        done < ~/.goto_bookmarks
                        _describe 'bookmarks' bookmarks
                    fi
                    ;;
                add)
                    _directories
                    ;;
            esac
            ;;
    esac
}

# back completion
_back() {
    _arguments \
        '1: :->arg' \
        && return 0

    case $state in
        arg)
            local -a options
            options=(
                '--list:Show navigation history'
                '--clear:Clear navigation history'
                '--help:Show help message'
            )
            _describe 'options' options
            _message 'number of steps to go back'
            ;;
    esac
}

# recent completion
_recent() {
    _arguments \
        '1: :->arg' \
        && return 0

    case $state in
        arg)
            local -a options
            options=(
                '--goto:Navigate to recent folder'
                '--clear:Clear recent history'
                '--help:Show help message'
            )
            _describe 'options' options
            _message 'number of recent folders to show'
            ;;
    esac
}

_goto "$@"
```

#### Installation Update

Add to `install.sh`:

```bash
# Install completions
echo "📝 Installing shell completions..."

if [ -n "$ZSH_VERSION" ]; then
    # Zsh completion
    COMP_DIR="${ZDOTDIR:-$HOME}/.zsh/completions"
    mkdir -p "$COMP_DIR"
    cp "$REPO_DIR/completions/goto-completion.zsh" "$COMP_DIR/_goto"

    # Add to fpath if not already there
    if ! grep -q "fpath.*goto" "$SHELL_CONFIG"; then
        echo "fpath=($COMP_DIR \$fpath)" >> "$SHELL_CONFIG"
        echo "autoload -Uz compinit && compinit" >> "$SHELL_CONFIG"
    fi
elif [ -n "$BASH_VERSION" ]; then
    # Bash completion
    COMP_DIR="$HOME/.bash_completions"
    mkdir -p "$COMP_DIR"
    cp "$REPO_DIR/completions/goto-completion.bash" "$COMP_DIR/goto"

    # Source in bashrc if not already there
    if ! grep -q "goto.*completion" "$SHELL_CONFIG"; then
        echo "source $COMP_DIR/goto" >> "$SHELL_CONFIG"
    fi
fi

echo "✓ Completions installed"
```

---

### Feature 3: Frecency Algorithm

#### Implementation: `lib/frecency.sh`

```bash
#!/bin/bash
# Frecency-based directory ranking
# Formula: score = (frequency * 0.5) + (recency * 0.3) + (context * 0.2)

FRECENCY_FILE="${FRECENCY_FILE:-$HOME/.goto_frecency}"

# Initialize frecency database
__goto_frecency_init() {
    if [ ! -f "$FRECENCY_FILE" ]; then
        touch "$FRECENCY_FILE"
    fi
}

# Update frecency score for a directory
__goto_frecency_update() {
    local dir="$1"
    local now=$(date +%s)

    __goto_frecency_init

    # Check if entry exists
    local entry=$(grep "^${dir}|" "$FRECENCY_FILE")

    if [ -n "$entry" ]; then
        # Update existing entry
        local count=$(echo "$entry" | cut -d'|' -f2)
        local last_visit=$(echo "$entry" | cut -d'|' -f3)

        # Increment count
        ((count++))

        # Update entry
        grep -v "^${dir}|" "$FRECENCY_FILE" > "$FRECENCY_FILE.tmp"
        echo "$dir|$count|$now" >> "$FRECENCY_FILE.tmp"
        mv "$FRECENCY_FILE.tmp" "$FRECENCY_FILE"
    else
        # New entry
        echo "$dir|1|$now" >> "$FRECENCY_FILE"
    fi
}

# Calculate frecency score
__goto_frecency_score() {
    local dir="$1"
    local now=$(date +%s)

    __goto_frecency_init

    local entry=$(grep "^${dir}|" "$FRECENCY_FILE")

    if [ -z "$entry" ]; then
        echo "0"
        return
    fi

    local count=$(echo "$entry" | cut -d'|' -f2)
    local last_visit=$(echo "$entry" | cut -d'|' -f3)

    # Time decay: more recent = higher score
    local time_diff=$((now - last_visit))
    local days=$((time_diff / 86400))

    # Recency score (0-100): decay over 30 days
    local recency_score=100
    if [ $days -gt 30 ]; then
        recency_score=0
    else
        recency_score=$((100 - (days * 3)))
    fi

    # Frequency score (0-100): cap at 50 visits
    local freq_score=$((count * 2))
    [ $freq_score -gt 100 ] && freq_score=100

    # Context score (0-100): is it in current git repo?
    local context_score=0
    if git rev-parse --git-dir &>/dev/null; then
        local repo_root=$(git rev-parse --show-toplevel)
        if [[ "$dir" == "$repo_root"* ]]; then
            context_score=100
        fi
    fi

    # Combined score: weighted average
    local score=$(((freq_score * 5 + recency_score * 3 + context_score * 2) / 10))

    echo "$score"
}

# Get ranked directories
__goto_frecency_rank() {
    local query="$1"
    local -a results=()

    __goto_frecency_init

    # Get all directories matching query
    while IFS='|' read -r dir count last_visit; do
        if [[ "$dir" == *"$query"* ]] && [ -d "$dir" ]; then
            local score=$(__goto_frecency_score "$dir")
            results+=("$score|$dir")
        fi
    done < "$FRECENCY_FILE"

    # Sort by score (descending) and output
    printf '%s\n' "${results[@]}" | sort -t'|' -k1 -nr | head -10
}

# Show top directories
frecency() {
    case "$1" in
        --clear)
            rm -f "$FRECENCY_FILE"
            echo "✓ Frecency database cleared"
            ;;
        --stats)
            __goto_frecency_init
            echo "📊 Frecency Statistics:"
            echo ""
            while IFS='|' read -r dir count last_visit; do
                local score=$(__goto_frecency_score "$dir")
                printf "  %3d  %3d visits  %s\n" "$score" "$count" "$dir"
            done < "$FRECENCY_FILE" | sort -nr | head -20
            ;;
        *)
            echo "frecency - Show directory rankings"
            echo ""
            echo "Usage:"
            echo "  frecency --stats    Show top directories"
            echo "  frecency --clear    Clear database"
            ;;
    esac
}

# Integrate with goto navigation
__goto_navigate_to_with_frecency() {
    local target_dir="$1"

    # Call original navigation
    __goto_navigate_to "$target_dir"

    # Update frecency
    __goto_frecency_update "$target_dir"
}

# Override __goto_navigate_to
alias __goto_navigate_to='__goto_navigate_to_with_frecency'
```

---

### Feature 4: Git-Aware Navigation

#### Implementation: `lib/git-aware.sh`

```bash
#!/bin/bash
# Git-aware navigation helpers

# Check if we're in a git repository
__goto_is_git_repo() {
    git rev-parse --git-dir &>/dev/null
}

# Get git repository root
__goto_git_root() {
    if __goto_is_git_repo; then
        git rev-parse --show-toplevel
    fi
}

# Navigate to git root
goto_root() {
    if ! __goto_is_git_repo; then
        echo "❌ Not in a git repository"
        return 1
    fi

    local root=$(__goto_git_root)
    __goto_navigate_to "$root"
}

# Show git context
__goto_git_info() {
    if ! __goto_is_git_repo; then
        return 1
    fi

    local branch=$(git branch --show-current 2>/dev/null)
    local status=$(git status --porcelain 2>/dev/null | wc -l)
    local remote=$(git remote -v 2>/dev/null | head -1 | awk '{print $2}')

    echo "📦 Git Repository"
    echo "  Branch: $branch"
    echo "  Status: $status file(s) changed"
    [ -n "$remote" ] && echo "  Remote: $remote"
}

# Add 'root' special command to goto
# This will be integrated into main goto function:
# case "$1" in
#     root)
#         goto_root
#         return
#         ;;
# esac
```

---

### Feature 5: Quick Stats

#### Implementation: Add to `lib/goto-function.sh`

```bash
# Add --info flag handling
if [[ "$1" == "--info" ]] || [[ "$2" == "--info" ]]; then
    local target="${1}"
    [ "$1" == "--info" ] && target="$2"

    # Find the directory
    for base_path in "${search_paths[@]}"; do
        if [ -d "$base_path/$target" ]; then
            local dir="$base_path/$target"

            echo "📁 Directory Information: $target"
            echo ""

            # Size
            if command -v du &>/dev/null; then
                local size=$(du -sh "$dir" 2>/dev/null | cut -f1)
                echo "  Size: $size"
            fi

            # File count
            local file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
            echo "  Files: $file_count"

            # Last modified
            if command -v stat &>/dev/null; then
                local modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$dir" 2>/dev/null)
                [ -z "$modified" ] && modified=$(stat -c "%y" "$dir" 2>/dev/null | cut -d' ' -f1)
                echo "  Modified: $modified"
            fi

            # Git info if applicable
            if [ -d "$dir/.git" ]; then
                cd "$dir"
                __goto_git_info
                cd - >/dev/null
            fi

            return
        fi
    done

    echo "❌ Directory not found: $target"
    return 1
fi
```

---

## 📋 Implementation Checklist

### Week 1
- [ ] Day 1-2: Implement fuzzy matching
  - [ ] Create `lib/fuzzy-matching.sh`
  - [ ] Add to goto function
  - [ ] Test with various inputs
  - [ ] Write tests

- [ ] Day 3-4: Create tab completions
  - [ ] Create bash completion script
  - [ ] Create zsh completion script
  - [ ] Update install.sh
  - [ ] Test in both shells

### Week 2
- [ ] Day 5-6: Implement frecency
  - [ ] Create `lib/frecency.sh`
  - [ ] Integrate with navigation
  - [ ] Add frecency command
  - [ ] Test ranking algorithm

- [ ] Day 7: Git-aware navigation
  - [ ] Create `lib/git-aware.sh`
  - [ ] Add `goto root` command
  - [ ] Add git context detection
  - [ ] Test in various repos

### Week 3
- [ ] Day 8: Quick stats
  - [ ] Add --info flag
  - [ ] Implement stats gathering
  - [ ] Format output nicely
  - [ ] Test on different systems

- [ ] Day 9-10: Integration & Testing
  - [ ] Integrate all features
  - [ ] Create comprehensive tests
  - [ ] Fix bugs
  - [ ] Performance testing

### Week 4
- [ ] Day 11-12: Documentation
  - [ ] Update README with new features
  - [ ] Create feature guides
  - [ ] Update CHANGELOG
  - [ ] Create demo GIFs/videos

- [ ] Day 13-14: Release
  - [ ] Final testing
  - [ ] Create release notes
  - [ ] Tag v0.4.0
  - [ ] Push to GitHub
  - [ ] Announce release

---

## 🧪 Testing Strategy

### Unit Tests
```bash
# Test fuzzy matching
test_fuzzy_exact_match
test_fuzzy_substring_match
test_fuzzy_levenshtein_distance

# Test frecency
test_frecency_score_calculation
test_frecency_ranking
test_frecency_time_decay

# Test git awareness
test_git_root_detection
test_git_context_info
```

### Integration Tests
```bash
# Test complete workflows
test_goto_with_fuzzy_then_exact
test_frecency_updates_on_navigation
test_completion_suggests_frecent_dirs
test_git_root_from_subdirectory
```

### Performance Tests
```bash
# Benchmark operations
benchmark_fuzzy_search_1000_dirs
benchmark_frecency_score_100_entries
benchmark_tab_completion_response_time
```

---

## 📚 Documentation Updates

### README.md Updates

Add section:
```markdown
## Advanced Features (v0.4.0+)

### Fuzzy Matching
Don't remember the exact name? No problem!
\`\`\`bash
goto gai        # Matches GAI-3101
goto hlcn       # Matches HALCON
\`\`\`

### Tab Completion
Press TAB to explore available options:
\`\`\`bash
goto <TAB>      # Shows: luxor, halcon, docs, GAI-3101, ...
goto @<TAB>     # Shows: @work, @personal, ...
\`\`\`

### Smart Suggestions (Frecency)
Most-used directories appear first automatically!

### Git-Aware Navigation
\`\`\`bash
goto root       # Jump to repository root
goto myproj --info  # See git status
\`\`\`
```

---

## 🎯 Success Criteria

### Performance Targets
- Fuzzy search: < 100ms for 1000 directories
- Tab completion: < 50ms response time
- Frecency calculation: < 10ms per directory

### Usability Metrics
- Fuzzy match accuracy: > 95%
- Tab completion coverage: 100% of commands
- Frecency ranking: Top 3 directories are correct 80% of time

### Adoption Goals
- 50% of users discover fuzzy matching in first week
- 70% of users use tab completion regularly
- Frecency improves navigation speed by 30%

---

## 🚀 Next Steps

1. **Review this plan** with user
2. **Create feature branch**: `feature/phase-1-quick-wins`
3. **Start implementation** following weekly schedule
4. **Regular testing** throughout development
5. **Documentation** as features are completed
6. **Release v0.4.0** when all features tested

---

**Ready to start implementation? Let's build these quick wins!** 🎉
