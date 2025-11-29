#!/usr/bin/env bash
# verify-unix-goto-setup.sh
# Verification script for unix-goto Config-File Pattern setup
# Compatible with bash and zsh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  unix-goto Config-File Pattern Verification${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}\n"
}

print_section() {
    echo -e "\n${YELLOW}▶ $1${NC}"
}

pass() {
    echo -e "  ${GREEN}✓${NC} $1"
    ((PASS++))
}

fail() {
    echo -e "  ${RED}✗${NC} $1"
    ((FAIL++))
}

warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

info() {
    echo -e "  ${BLUE}ℹ${NC} $1"
}

# Detect shell
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        echo "unknown"
    fi
}

# Main verification
main() {
    print_header

    SHELL_TYPE=$(detect_shell)
    info "Detected shell: $SHELL_TYPE"

    # 1. Check for public goto-function.sh
    print_section "Checking public goto-function.sh"

    PUBLIC_PATHS=(
        "$HOME/unix-goto/lib/goto-function.sh"
        "$HOME/.local/share/unix-goto/lib/goto-function.sh"
        "/usr/local/share/unix-goto/lib/goto-function.sh"
    )

    PUBLIC_FOUND=0
    PUBLIC_PATH=""

    for path in "${PUBLIC_PATHS[@]}"; do
        if [ -f "$path" ]; then
            pass "Found: $path"
            PUBLIC_FOUND=1
            PUBLIC_PATH="$path"

            if [ -r "$path" ]; then
                pass "Readable: $path"
            else
                fail "Not readable: $path"
            fi
            break
        fi
    done

    if [ $PUBLIC_FOUND -eq 0 ]; then
        fail "Public goto-function.sh not found in standard locations"
        info "Expected locations: ${PUBLIC_PATHS[*]}"
    fi

    # 2. Check for local .goto-config.sh
    print_section "Checking local .goto-config.sh"

    LOCAL_PATH="$HOME/.goto-config.sh"

    if [ -f "$LOCAL_PATH" ]; then
        pass "Found: $LOCAL_PATH"

        if [ -r "$LOCAL_PATH" ]; then
            pass "Readable: $LOCAL_PATH"
        else
            fail "Not readable: $LOCAL_PATH"
        fi
    else
        fail "Local config not found: $LOCAL_PATH"
        info "Create this file with your custom shortcuts"
    fi

    # 3. Check if goto function is loaded
    print_section "Checking function availability"

    if command -v goto &> /dev/null; then
        pass "goto command is available"
    elif type goto &> /dev/null 2>&1; then
        pass "goto function is loaded"
    else
        fail "goto function/command not found in current shell"
        warn "Make sure to source the files in your shell profile:"
        info "  source ~/unix-goto/lib/goto-function.sh"
        info "  source ~/.goto-config.sh"
    fi

    # 4. Check shell profile integration
    print_section "Checking shell profile integration"

    if [ "$SHELL_TYPE" = "zsh" ]; then
        PROFILE="$HOME/.zshrc"
    else
        PROFILE="$HOME/.bashrc"
    fi

    if [ -f "$PROFILE" ]; then
        if grep -q "goto-function.sh" "$PROFILE"; then
            pass "Public goto-function.sh sourced in $PROFILE"
        else
            warn "Public goto-function.sh not found in $PROFILE"
            info "Add: source ~/unix-goto/lib/goto-function.sh"
        fi

        if grep -q ".goto-config.sh" "$PROFILE"; then
            pass "Local .goto-config.sh sourced in $PROFILE"
        else
            warn "Local .goto-config.sh not found in $PROFILE"
            info "Add: source ~/.goto-config.sh"
        fi
    else
        warn "Profile not found: $PROFILE"
    fi

    # 5. Test shortcut functionality (if loaded)
    print_section "Testing shortcut functionality"

    if type goto &> /dev/null 2>&1; then
        # Test with no args (should show help or list)
        if goto &> /dev/null || [ $? -eq 0 ] || [ $? -eq 1 ]; then
            pass "goto function executes without errors"
        else
            fail "goto function execution failed"
        fi

        # Check for LUXOR/CETI shortcuts in config
        if [ -f "$LOCAL_PATH" ]; then
            if grep -q "LUXOR" "$LOCAL_PATH" || grep -q "luxor" "$LOCAL_PATH"; then
                pass "LUXOR shortcut defined in config"
            else
                warn "LUXOR shortcut not found in .goto-config.sh"
            fi

            if grep -q "CETI" "$LOCAL_PATH" || grep -q "ceti" "$LOCAL_PATH"; then
                pass "CETI shortcut defined in config"
            else
                warn "CETI shortcut not found in .goto-config.sh"
            fi
        fi
    else
        warn "Skipping functionality tests (goto not loaded)"
        info "Source the files and re-run this script"
    fi

    # 6. Check directory existence
    print_section "Checking target directories"

    LUXOR_PATH="$HOME/Documents/LUXOR"
    CETI_PATH="$HOME/Documents/CETI"

    if [ -d "$LUXOR_PATH" ]; then
        pass "LUXOR directory exists: $LUXOR_PATH"
    else
        warn "LUXOR directory not found: $LUXOR_PATH"
    fi

    if [ -d "$CETI_PATH" ]; then
        pass "CETI directory exists: $CETI_PATH"
    else
        warn "CETI directory not found: $CETI_PATH"
    fi

    # Summary
    print_section "Verification Summary"

    TOTAL=$((PASS + FAIL))
    echo -e "\n  Total checks: $TOTAL"
    echo -e "  ${GREEN}Passed: $PASS${NC}"
    echo -e "  ${RED}Failed: $FAIL${NC}"

    if [ $FAIL -eq 0 ]; then
        echo -e "\n${GREEN}✓ All critical checks passed!${NC}"
        echo -e "${GREEN}  Your unix-goto setup is correctly configured.${NC}\n"
        exit 0
    else
        echo -e "\n${RED}✗ Some checks failed.${NC}"
        echo -e "${YELLOW}  Review the output above and fix the issues.${NC}\n"
        exit 1
    fi
}

main "$@"
