#!/usr/bin/env bash
# GIT-WORKFLOW-AUTOMATION.sh
# Production-ready git workflow functions for unix-goto Config-File Pattern

WORKFLOW_LOG="$HOME/.goto-workflow.log"

log_operation() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$WORKFLOW_LOG"
}

# Update public repo safely
update-public() {
    local repo_dir="$HOME/Documents/LUXOR/Git_Repos/unix-goto"
    
    echo "📦 Updating public unix-goto repository..."
    log_operation "START: update-public"
    
    cd "$repo_dir" || return 1
    
    # Check for local changes
    if [ -n "$(git status --short)" ]; then
        echo "⚠️  Local changes detected. Stashing..."
        git stash
        log_operation "STASHED: local changes"
    fi
    
    # Pull updates
    if git pull origin main; then
        log_operation "SUCCESS: git pull completed"
        echo "✅ Updated successfully"
        
        # Run tests
        if bash unix-goto.test.sh > /dev/null 2>&1; then
            echo "✅ All tests passed"
            log_operation "TESTS: all passed"
        else
            echo "⚠️  Some tests failed. Review: bash unix-goto.test.sh"
            log_operation "WARNING: tests failed"
        fi
    else
        echo "❌ Pull failed. Check for conflicts."
        log_operation "ERROR: git pull failed"
        return 1
    fi
    
    # Reload shell
    exec $SHELL
}

# Check for shortcut name conflicts
check-conflicts() {
    local public_file="$HOME/Documents/LUXOR/Git_Repos/unix-goto/lib/goto-function.sh"
    local local_file="$HOME/.goto-config.sh"
    
    echo "🔍 Checking for shortcut name conflicts..."
    
    if [ ! -f "$public_file" ] || [ ! -f "$local_file" ]; then
        echo "❌ Config files not found"
        return 1
    fi
    
    # Extract function names from both files
    PUBLIC_FUNCS=$(grep -o '^[a-z_-]*()' "$public_file" | sed 's/()//' | sort)
    LOCAL_FUNCS=$(grep -o '^[a-z_-]*()' "$local_file" | sed 's/()//' | sort)
    
    # Find conflicts (functions in both)
    CONFLICTS=$(comm -12 <(echo "$PUBLIC_FUNCS") <(echo "$LOCAL_FUNCS"))
    
    if [ -z "$CONFLICTS" ]; then
        echo "✅ No conflicts detected"
        return 0
    else
        echo "⚠️  Name conflicts found (local will override):"
        echo "$CONFLICTS" | sed 's/^/   /'
        log_operation "WARNING: name conflicts detected"
    fi
}

# Verify local customizations are gitignored
verify-locals() {
    local repo_dir="$HOME/Documents/LUXOR/Git_Repos/unix-goto"
    
    echo "🔐 Verifying local config safety..."
    cd "$repo_dir" || return 1
    
    if git check-ignore -q .goto-config.sh 2>/dev/null; then
        echo "✅ .goto-config.sh is properly gitignored"
        log_operation "VERIFIED: .goto-config.sh ignored"
        return 0
    else
        echo "❌ .goto-config.sh is NOT gitignored!"
        echo "   Adding to .gitignore now..."
        echo ".goto-config.sh" >> .gitignore
        git add .gitignore
        log_operation "FIXED: .goto-config.sh added to .gitignore"
        echo "✅ Fixed. Commit this change."
        return 1
    fi
}

# Preview what would happen with git pull
test-pull() {
    local repo_dir="$HOME/Documents/LUXOR/Git_Repos/unix-goto"
    
    echo "🧪 Previewing pull (dry-run)..."
    cd "$repo_dir" || return 1
    
    git fetch origin
    
    if [ -z "$(git log --oneline HEAD..origin/main)" ]; then
        echo "✅ Already up to date"
    else
        echo "📋 Changes available:"
        git log --oneline HEAD..origin/main | sed 's/^/   /'
    fi
}

# Show usage
goto-workflow-help() {
    cat << 'HELP'
Git Workflow Functions for unix-goto:

  update-public        Pull latest updates (with safety checks)
  check-conflicts      Detect shortcut name conflicts
  verify-locals        Ensure .goto-config.sh is gitignored
  test-pull            Preview updates without applying
  goto-workflow-help   Show this help

Log location: ~/.goto-workflow.log

Examples:
  update-public        # Safe update with tests
  check-conflicts      # Find naming issues
  verify-locals        # Verify safety setup
HELP
}

# Export functions
export -f log_operation
export -f update-public
export -f check-conflicts
export -f verify-locals
export -f test-pull
export -f goto-workflow-help
