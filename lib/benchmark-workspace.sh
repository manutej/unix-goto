#!/bin/bash
# unix-goto - Benchmark workspace generation utility
# Creates test workspaces for benchmarking performance

GOTO_BENCHMARK_WORKSPACE="${HOME}/.goto_benchmark_workspace"

# Generate test workspace with specified number of folders
__goto_benchmark_create_workspace() {
    local workspace_type="${1:-typical}"
    local force="${2:-false}"

    local folder_count
    local depth

    case "$workspace_type" in
        small)
            folder_count=10
            depth=2
            ;;
        typical)
            folder_count=50
            depth=3
            ;;
        large)
            folder_count=200
            depth=4
            ;;
        *)
            echo "❌ Invalid workspace type: $workspace_type"
            echo "Valid types: small, typical, large"
            return 1
            ;;
    esac

    echo "Creating $workspace_type benchmark workspace..."
    echo "  Location: $GOTO_BENCHMARK_WORKSPACE"
    echo "  Folders:  $folder_count"
    echo "  Depth:    $depth levels"
    echo ""

    # Check if workspace already exists
    if [ -d "$GOTO_BENCHMARK_WORKSPACE" ] && [ "$force" != "true" ]; then
        echo "⚠ Workspace already exists at $GOTO_BENCHMARK_WORKSPACE"
        echo "Use --force to recreate it"
        return 1
    fi

    # Remove existing workspace if forcing
    if [ -d "$GOTO_BENCHMARK_WORKSPACE" ] && [ "$force" = "true" ]; then
        echo "Removing existing workspace..."
        rm -rf "$GOTO_BENCHMARK_WORKSPACE"
    fi

    # Create base directory
    mkdir -p "$GOTO_BENCHMARK_WORKSPACE"

    # Generate folder structure
    echo "Generating folder structure..."

    local created=0
    local level_dirs=()

    # Create top-level project folders
    for i in $(seq 1 $((folder_count / depth))); do
        local project_name="project-$i"
        mkdir -p "$GOTO_BENCHMARK_WORKSPACE/$project_name"
        level_dirs+=("$project_name")
        created=$((created + 1))

        # Add some metadata files
        echo "# Project $i" > "$GOTO_BENCHMARK_WORKSPACE/$project_name/README.md"
        touch "$GOTO_BENCHMARK_WORKSPACE/$project_name/.gitkeep"
    done

    # Create nested folders (second level)
    if [ $depth -ge 2 ]; then
        for base_dir in "${level_dirs[@]}"; do
            for j in $(seq 1 3); do
                if [ $created -ge $folder_count ]; then
                    break 2
                fi

                local sub_dir="module-$j"
                mkdir -p "$GOTO_BENCHMARK_WORKSPACE/$base_dir/$sub_dir"
                echo "# Module $j" > "$GOTO_BENCHMARK_WORKSPACE/$base_dir/$sub_dir/README.md"
                created=$((created + 1))
            done
        done
    fi

    # Create deeper nesting (third level)
    if [ $depth -ge 3 ]; then
        for base_dir in "${level_dirs[@]}"; do
            for j in $(seq 1 2); do
                for k in $(seq 1 2); do
                    if [ $created -ge $folder_count ]; then
                        break 3
                    fi

                    local deep_dir="module-$j/component-$k"
                    mkdir -p "$GOTO_BENCHMARK_WORKSPACE/$base_dir/$deep_dir"
                    echo "# Component $k" > "$GOTO_BENCHMARK_WORKSPACE/$base_dir/$deep_dir/info.txt"
                    created=$((created + 1))
                done
            done
        done
    fi

    # Create very deep nesting (fourth level)
    if [ $depth -ge 4 ]; then
        for base_dir in "${level_dirs[@]}"; do
            local deep_path="module-1/component-1/subcomponent-1"
            if [ $created -ge $folder_count ]; then
                break
            fi

            mkdir -p "$GOTO_BENCHMARK_WORKSPACE/$base_dir/$deep_path"
            echo "# Subcomponent 1" > "$GOTO_BENCHMARK_WORKSPACE/$base_dir/$deep_path/notes.txt"
            created=$((created + 1))
        done
    fi

    echo ""
    echo "✓ Workspace created successfully"
    echo "  Total folders: $created"
    echo "  Max depth:     $depth"
    echo ""

    # Generate statistics
    __goto_benchmark_workspace_stats
}

# Show workspace statistics
__goto_benchmark_workspace_stats() {
    if [ ! -d "$GOTO_BENCHMARK_WORKSPACE" ]; then
        echo "❌ No benchmark workspace found"
        echo "Create one with: goto benchmark workspace create <type>"
        return 1
    fi

    echo "Benchmark Workspace Statistics:"
    echo "────────────────────────────────"
    echo "  Location: $GOTO_BENCHMARK_WORKSPACE"
    echo ""

    # Count directories
    local total_dirs=$(find "$GOTO_BENCHMARK_WORKSPACE" -type d | wc -l | tr -d ' ')
    echo "  Total directories: $total_dirs"

    # Count files
    local total_files=$(find "$GOTO_BENCHMARK_WORKSPACE" -type f | wc -l | tr -d ' ')
    echo "  Total files:       $total_files"

    # Maximum depth
    local max_depth=$(find "$GOTO_BENCHMARK_WORKSPACE" -type d -exec sh -c 'echo $(echo "$1" | tr -cd "/" | wc -c)' _ {} \; | sort -n | tail -1)
    echo "  Maximum depth:     $max_depth"

    # Disk usage
    local disk_usage=$(du -sh "$GOTO_BENCHMARK_WORKSPACE" 2>/dev/null | cut -f1)
    echo "  Disk usage:        $disk_usage"
    echo ""
}

# Clean up workspace
__goto_benchmark_workspace_clean() {
    if [ ! -d "$GOTO_BENCHMARK_WORKSPACE" ]; then
        echo "No workspace to clean"
        return 0
    fi

    echo "Removing benchmark workspace at $GOTO_BENCHMARK_WORKSPACE"
    rm -rf "$GOTO_BENCHMARK_WORKSPACE"
    echo "✓ Workspace removed"
}

# Workspace management command
__goto_benchmark_workspace() {
    local action="$1"
    shift

    case "$action" in
        create|c)
            __goto_benchmark_create_workspace "$@"
            ;;
        stats|s|info)
            __goto_benchmark_workspace_stats
            ;;
        clean|remove|rm)
            __goto_benchmark_workspace_clean
            ;;
        --help|-h|help|"")
            echo "goto benchmark workspace - Test workspace management"
            echo ""
            echo "Usage:"
            echo "  goto benchmark workspace create <type> [--force]   Create test workspace"
            echo "  goto benchmark workspace stats                     Show workspace info"
            echo "  goto benchmark workspace clean                     Remove workspace"
            echo "  goto benchmark workspace --help                    Show this help"
            echo ""
            echo "Workspace Types:"
            echo "  small      10 folders, 2 levels deep"
            echo "  typical    50 folders, 3 levels deep (default)"
            echo "  large      200 folders, 4 levels deep"
            echo ""
            echo "Examples:"
            echo "  goto benchmark workspace create typical"
            echo "  goto benchmark workspace create large --force"
            echo "  goto benchmark workspace stats"
            echo "  goto benchmark workspace clean"
            echo ""
            ;;
        *)
            echo "Unknown workspace command: $action"
            echo "Try 'goto benchmark workspace --help' for usage"
            return 1
            ;;
    esac
}
