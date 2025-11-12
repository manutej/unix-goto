# bash completion for goto and related commands

_goto_completions() {
    local cur prev
    COMPREPLY=()

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
    local cur prev
    COMPREPLY=()

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
    local cur
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=($(compgen -W "--list --clear --help 1 2 3 4 5" -- "$cur"))
}

_recent_completions() {
    local cur
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=($(compgen -W "--goto --clear --help 5 10 20" -- "$cur"))
}

# Register completions
complete -F _goto_completions goto
complete -F _bookmark_completions bookmark bm
complete -F _back_completions back
complete -F _recent_completions recent
