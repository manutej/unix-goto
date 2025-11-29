#!/usr/bin/env bash
# PRE-COMMIT-HOOK.sh
# Git pre-commit hook for unix-goto Config-File Pattern
# Prevents accidental commits of local customization files

set -e

REPO_DIR=$(git rev-parse --git-dir)
HOOK_NAME="pre-commit"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔐 Pre-commit safety checks...${NC}"

# Check 1: Prevent committing .goto-config.sh
if git diff --cached --name-only | grep -q "\.goto-config\.sh"; then
    echo -e "${RED}❌ BLOCKED: .goto-config.sh should not be committed${NC}"
    echo "   This file is for local customizations only."
    echo "   Add to .gitignore if not already there."
    exit 1
fi

# Check 2: Prevent committing lib/luxor-shortcuts.sh
if git diff --cached --name-only | grep -q "lib/luxor-shortcuts\.sh"; then
    echo -e "${RED}❌ BLOCKED: lib/luxor-shortcuts.sh should not be committed${NC}"
    echo "   Use .goto-config.sh instead (outside repo)."
    exit 1
fi

# Check 3: Ensure .gitignore has local config patterns
if ! grep -q "\.goto-config\.sh" .gitignore 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Adding .goto-config.sh to .gitignore${NC}"
    echo ".goto-config.sh" >> .gitignore
    git add .gitignore
fi

# Check 4: Run test suite (optional - disable if too slow)
if [ -f "unix-goto.test.sh" ]; then
    echo -e "${YELLOW}🧪 Running test suite...${NC}"
    if bash unix-goto.test.sh > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Tests passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Tests failed (non-blocking)${NC}"
        echo "   Run: bash unix-goto.test.sh"
    fi
fi

echo -e "${GREEN}✅ Pre-commit checks complete${NC}"
exit 0
