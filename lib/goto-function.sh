#!/bin/bash
# unix-goto - Smart project navigation with natural language support
# https://github.com/manutej/unix-goto

# Quick project navigation with natural language support
goto() {
    # Handle --help flag
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        echo "goto - Smart project navigation with natural language support"
        echo ""
        echo "Usage:"
        echo "  goto <project>           Navigate to project folder"
        echo "  goto ~                   Return to home directory"
        echo "  goto zshrc               Source and display .zshrc"
        echo "  goto --help              Show this help"
        echo ""
        echo "Direct shortcuts:"
        echo "  luxor                    LUXOR root"
        echo "  halcon                   HALCON project"
        echo "  docs                     ASCIIDocs root"
        echo "  infra                    ASCIIDocs/infra"
        echo ""
        echo "Folder names:"
        echo "  GAI-3101, WA3590, etc.   Any subfolder in search paths"
        echo ""
        echo "Natural language (powered by Claude):"
        echo "  'the halcon project'"
        echo "  'infrastructure folder'"
        echo "  'that GAI project from March'"
        echo ""
        return
    fi

    # Handle empty input
    if [ -z "$1" ]; then
        goto --help
        return
    fi

    # Handle special cases
    case "$1" in
        "~")
            cd "$HOME"
            echo "→ $HOME"
            return
            ;;
        zshrc)
            echo "Sourcing ~/.zshrc..."
            source "$HOME/.zshrc"
            echo ""
            echo "Current .zshrc contents:"
            glow "$HOME/.zshrc" 2>/dev/null || cat "$HOME/.zshrc"
            return
            ;;
        bashrc)
            echo "Sourcing ~/.bashrc..."
            source "$HOME/.bashrc"
            echo ""
            echo "Current .bashrc contents:"
            glow "$HOME/.bashrc" 2>/dev/null || cat "$HOME/.bashrc"
            return
            ;;
        luxor)
            cd "$HOME/Documents/LUXOR"
            echo "→ $PWD"
            return
            ;;
        halcon)
            cd "$HOME/Documents/LUXOR/PROJECTS/HALCON"
            echo "→ $PWD"
            return
            ;;
        docs)
            cd "$HOME/ASCIIDocs"
            echo "→ $PWD"
            return
            ;;
        infra)
            cd "$HOME/ASCIIDocs/infra"
            echo "→ $PWD"
            return
            ;;
    esac

    # Search paths for direct folder matching
    # Customize these paths for your environment
    local search_paths=(
        "$HOME/ASCIIDocs"
        "$HOME/Documents/LUXOR"
        "$HOME/Documents/LUXOR/PROJECTS"
    )

    # Try direct folder match first
    local target_dir
    for base_path in "${search_paths[@]}"; do
        if [ -d "$base_path/$1" ]; then
            target_dir="$base_path/$1"
            cd "$target_dir"
            echo "→ $PWD"
            return
        fi
    done

    # If no direct match and input contains spaces or looks like natural language, use Claude AI
    if [[ "$*" == *" "* ]] || [[ ${#1} -gt 20 ]]; then
        echo "🤖 Using natural language processing..."

        # Try to find goto-resolve in PATH or in the installed location
        local resolver
        if command -v goto-resolve &> /dev/null; then
            resolver="goto-resolve"
        elif [ -f "$HOME/bin/goto-resolve" ]; then
            resolver="$HOME/bin/goto-resolve"
        else
            echo "⚠️  goto-resolve not found. Install unix-goto properly or add to PATH."
            return 1
        fi

        local resolved_folder=$($resolver "$*" 2>/dev/null)

        if [ -n "$resolved_folder" ] && [ "$resolved_folder" != "" ]; then
            # Try the resolved folder name
            goto "$resolved_folder"
            return
        fi
    fi

    # Not found
    echo "❌ Project not found: $*"
    echo "Try 'goto --help' for usage examples"
}
