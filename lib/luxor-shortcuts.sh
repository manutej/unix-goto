#!/bin/bash
# luxor-shortcuts.sh - LUXOR project navigation shortcuts
# Dynamically loads all 36 LUXOR projects (core systems, projects, git repos, work streams)
# Generated from project-inventory.json and PROJECT-INDEX.md

# Inventory file location
LUXOR_INVENTORY="/Users/manu/Documents/LUXOR/project-inventory.json"

# Function to load LUXOR shortcuts from inventory
__goto_load_luxor_shortcuts() {
    # Check if inventory file exists
    if [ ! -f "$LUXOR_INVENTORY" ]; then
        echo "⚠️  LUXOR inventory not found at $LUXOR_INVENTORY" >&2
        return 1
    fi

    # Check if jq is available for JSON parsing
    if ! command -v jq &> /dev/null; then
        echo "⚠️  jq not found. Installing via homebrew..." >&2
        # For environments without jq, we'll use python instead
        return 0
    fi

    return 0
}

# Function to resolve LUXOR project from any category
# Usage: __goto_resolve_luxor_project <name>
# Returns the full path to the project
__goto_resolve_luxor_project() {
    local project_name="$1"
    local inventory_file="/Users/manu/Documents/LUXOR/project-inventory.json"

    # If inventory doesn't exist, fall back to hardcoded shortcuts
    if [ ! -f "$inventory_file" ]; then
        __goto_hardcoded_luxor_shortcut "$project_name"
        return $?
    fi

    # Try to parse with jq if available
    if command -v jq &> /dev/null; then
        # Search in all categories
        local result=$(jq -r ".projects[]? | select(.name | ascii_downcase == \"$project_name\" | ascii_downcase) | .path" "$inventory_file" 2>/dev/null | head -1)

        if [ -z "$result" ]; then
            result=$(jq -r ".git_repos[]? | select(.name | ascii_downcase == \"$project_name\" | ascii_downcase) | .path" "$inventory_file" 2>/dev/null | head -1)
        fi

        if [ -z "$result" ]; then
            result=$(jq -r ".work_streams[]? | select(.name | ascii_downcase == \"$project_name\" | ascii_downcase) | .path" "$inventory_file" 2>/dev/null | head -1)
        fi

        if [ -z "$result" ]; then
            result=$(jq -r ".core_systems[]? | select(.name | ascii_downcase == \"$project_name\" | ascii_downcase) | .path" "$inventory_file" 2>/dev/null | head -1)
        fi

        if [ -n "$result" ]; then
            echo "$result"
            return 0
        fi
    else
        # Fallback to Python for JSON parsing if jq is not available
        python3 << PYTHON_EOF 2>/dev/null
import json
import sys
project_name = sys.argv[1].lower()
try:
    with open('$inventory_file', 'r') as f:
        data = json.load(f)
        for category in ['projects', 'git_repos', 'work_streams', 'core_systems']:
            for item in data.get(category, []):
                if item['name'].lower() == project_name:
                    print(item['path'])
                    sys.exit(0)
except:
    pass
PYTHON_EOF
        [ $? -eq 0 ] && return 0
    fi

    # Fallback to hardcoded shortcuts
    __goto_hardcoded_luxor_shortcut "$project_name"
    return $?
}

# Hardcoded LUXOR shortcuts (fallback)
__goto_hardcoded_luxor_shortcut() {
    local name="$1"
    # Convert to lowercase for case-insensitive matching using tr
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]')

    case "$name" in
        # Core Systems (compact folder)
        mercurio)
            echo "$HOME/Documents/LUXOR/compact/MERCURIO"
            return 0
            ;;
        hermetic|hermetic-seven)
            echo "$HOME/Documents/LUXOR/compact/HERMETIC-SEVEN"
            return 0
            ;;
        consciousness)
            echo "$HOME/Documents/LUXOR/compact/CONSCIOUSNESS"
            return 0
            ;;
        hekat|hekat-dsl)
            echo "$HOME/Documents/LUXOR/compact/HEKAT-DSL"
            return 0
            ;;
        barque)
            echo "$HOME/Documents/LUXOR/compact/BARQUE"
            return 0
            ;;
        lumina)
            echo "$HOME/Documents/LUXOR/compact/LUMINA"
            return 0
            ;;
        support|support-automation)
            echo "$HOME/Documents/LUXOR/compact/SUPPORT-AUTOMATION"
            return 0
            ;;
        linear|linear-accelerator)
            echo "$HOME/Documents/LUXOR/compact/LINEAR-ACCELERATOR"
            return 0
            ;;
        # Major Projects
        halcon)
            echo "$HOME/Documents/LUXOR/PROJECTS/HALCON"
            return 0
            ;;
        halcon)
            echo "$HOME/Documents/LUXOR/PROJECTS/LUMINA"
            return 0
            ;;
        hekat)
            echo "$HOME/Documents/LUXOR/PROJECTS/hekat"
            return 0
            ;;
        copilot|copilot-course)
            echo "$HOME/Documents/LUXOR/PROJECTS/copilot-course"
            return 0
            ;;
        maestros)
            echo "$HOME/Documents/LUXOR/PROJECTS/maestros"
            return 0
            ;;
        customer-support)
            echo "$HOME/Documents/LUXOR/PROJECTS/customer-support"
            return 0
            ;;
        hyperglyph)
            echo "$HOME/Documents/LUXOR/PROJECTS/hyperglyph"
            return 0
            ;;
        lumos)
            echo "$HOME/Documents/LUXOR/PROJECTS/LUMOS"
            return 0
            ;;
        grok|grok-cli)
            echo "$HOME/Documents/LUXOR/PROJECTS/grok-cli"
            return 0
            ;;
        orch|orch-cli)
            echo "$HOME/Documents/LUXOR/PROJECTS/orch-cli"
            return 0
            ;;
        # Work Streams
        research|research-plan|research-plan-dsl)
            echo "$HOME/Documents/LUXOR/research-plan-dsl"
            return 0
            ;;
        docrag)
            echo "$HOME/Documents/LUXOR/docrag"
            return 0
            ;;
        customer-support-automation)
            echo "$HOME/Documents/LUXOR/customer-support-automation"
            return 0
            ;;
        linear-dev|linear-dev-accelerator)
            echo "$HOME/Documents/LUXOR/linear-dev-accelerator"
            return 0
            ;;
        hermetic-app)
            echo "$HOME/Documents/LUXOR/hermetic-app"
            return 0
            ;;
        cheatsheets)
            echo "$HOME/Documents/LUXOR/cheatsheets"
            return 0
            ;;
        # Git Repos
        unix-goto)
            echo "$HOME/Documents/LUXOR/Git_Repos/unix-goto"
            return 0
            ;;
        tax|tax-collection|tax-collection-system)
            echo "$HOME/Documents/LUXOR/Git_Repos/tax-collection-system"
            return 0
            ;;
        excalidraw|excalidraw-mcp)
            echo "$HOME/Documents/LUXOR/Git_Repos/excalidraw-mcp-integration"
            return 0
            ;;
        yt)
            echo "$HOME/Documents/LUXOR/Git_Repos/yt"
            return 0
            ;;
        paper2agent)
            echo "$HOME/Documents/LUXOR/Git_Repos/paper2agent"
            return 0
            ;;
        canva|canva-code)
            echo "$HOME/Documents/LUXOR/Git_Repos/canva-code"
            return 0
            ;;
        chatz)
            echo "$HOME/Documents/LUXOR/Git_Repos/chatz"
            return 0
            ;;
        cc-boot)
            echo "$HOME/Documents/LUXOR/Git_Repos/cc-boot"
            return 0
            ;;
        luxor-app)
            echo "$HOME/Documents/LUXOR/Git_Repos/Luxor-app"
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Export functions for use in goto
export -f __goto_resolve_luxor_project
export -f __goto_hardcoded_luxor_shortcut
