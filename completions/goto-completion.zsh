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
