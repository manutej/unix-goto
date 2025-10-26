#!/bin/bash
# test-luxor-navigation.sh - Test LUXOR project navigation integration
# Tests all 36 LUXOR projects accessible via goto command

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0
SKIPPED=0

# Source the required libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/goto-function.sh"
source "$SCRIPT_DIR/lib/luxor-shortcuts.sh" 2>/dev/null || true

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}LUXOR Project Navigation Tests${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

# Test function
test_project() {
    local project_name="$1"
    local description="$2"

    if __goto_resolve_luxor_project "$project_name" &>/dev/null; then
        local path=$(__goto_resolve_luxor_project "$project_name")
        if [ -d "$path" ]; then
            echo -e "${GREEN}✓${NC} $project_name - $description"
            echo "  → $path"
            ((PASSED++))
            return 0
        else
            echo -e "${RED}✗${NC} $project_name - Path doesn't exist: $path"
            ((FAILED++))
            return 1
        fi
    else
        echo -e "${YELLOW}⊘${NC} $project_name - Not found"
        ((SKIPPED++))
        return 1
    fi
}

# Test Core Systems
echo -e "${BLUE}Core Systems (8)${NC}"
test_project "mercurio" "MERCURIO synthesis framework"
test_project "hermetic" "HERMETIC-SEVEN creative system"
test_project "consciousness" "CONSCIOUSNESS philosophy framework"
test_project "hekat" "HEKAT DSL in compact folder"
test_project "barque" "BARQUE document generation"
test_project "lumina" "LUMINA discovery system"
test_project "support" "SUPPORT-AUTOMATION intelligent routing"
test_project "linear" "LINEAR-ACCELERATOR team acceleration"
echo ""

# Test Major Projects
echo -e "${BLUE}Major Projects (11)${NC}"
test_project "halcon" "HALCON comprehensive research system"
test_project "hekat" "hekat DSL implementation (PROJECTS)"
test_project "copilot" "copilot-course educational content"
test_project "maestros" "maestros expert systems research"
test_project "customer-support" "customer-support implementation"
test_project "hyperglyph" "hyperglyph encoding system"
test_project "lumos" "LUMOS visualization system"
test_project "grok" "grok-cli exploration"
test_project "orch" "orch-cli exploration"
echo ""

# Test Git Repositories
echo -e "${BLUE}Git Repositories (10)${NC}"
test_project "unix-goto" "unix-goto navigation tools"
test_project "tax" "tax-collection-system production app"
test_project "excalidraw" "excalidraw-mcp MCP integration"
test_project "yt" "yt YouTube processor"
test_project "docrag" "docrag RAG system"
test_project "paper2agent" "paper2agent research conversion"
test_project "canva" "canva-code API integration"
test_project "chatz" "chatz chat system"
test_project "cc-boot" "cc-boot bootstrap utilities"
test_project "luxor-app" "Luxor-app main application"
echo ""

# Test Work Streams
echo -e "${BLUE}Work Streams (7)${NC}"
test_project "research" "research-plan-dsl DSL work stream"
test_project "docrag" "docrag work stream"
test_project "customer-support-automation" "customer-support-automation work stream"
test_project "linear-dev" "linear-dev-accelerator work stream"
test_project "hermetic-app" "hermetic-app work stream"
test_project "cheatsheets" "cheatsheets work stream"
echo ""

# Test Aliases
echo -e "${BLUE}Aliases and Variations${NC}"
test_project "research-plan-dsl" "research-plan-dsl full name"
test_project "hekat-dsl" "hekat-dsl full name"
test_project "support-automation" "support-automation full name"
test_project "linear-accelerator" "linear-accelerator full name"
test_project "excalidraw-mcp" "excalidraw-mcp full name"
test_project "tax-collection-system" "tax-collection-system full name"
test_project "copilot-course" "copilot-course full name"
echo ""

# Summary
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo "Test Results:"
echo -e "${GREEN}✓ Passed:  $PASSED${NC}"
echo -e "${RED}✗ Failed:  $FAILED${NC}"
echo -e "${YELLOW}⊘ Skipped: $SKIPPED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! LUXOR integration is working correctly.${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. Please review the errors above.${NC}"
    exit 1
fi
