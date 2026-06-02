#!/bin/bash
# =============================================================================
# Pro Fullstack Developer Skills - Verifier
# =============================================================================
# Verifies that all skills are properly installed
#
# Usage:
#   chmod +x verify.sh && ./verify.sh
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SKILL_DIR="$HOME/.pi/agent/skills"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills"

# Header
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Pro Fullstack Developer Skills - Verifier${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source directory not found: $SOURCE_DIR${NC}"
    exit 1
fi

# Check if target directory exists
if [ ! -d "$SKILL_DIR" ]; then
    echo -e "${RED}Error: Installation directory not found: $SKILL_DIR${NC}"
    echo ""
    echo "Run ./install.sh first to install skills."
    exit 1
fi

# Count skills
TOTAL_SKILLS=$(ls -d "$SOURCE_DIR"/*/ 2>/dev/null | wc -l)
echo -e "Checking ${GREEN}$TOTAL_SKILLS${NC} skills..."
echo ""

# Verification summary
VERIFIED=0
MISSING=()
INVALID=()

# Verify each skill
for skill_path in "$SOURCE_DIR"/*/; do
    skill_name=$(basename "$skill_path")
    
    # Check if skill directory exists
    if [ ! -d "$SKILL_DIR/$skill_name" ]; then
        echo -e "  ${RED}✗${NC} $skill_name (directory missing)"
        MISSING+=("$skill_name")
        continue
    fi
    
    # Check if SKILL.md exists
    if [ ! -f "$SKILL_DIR/$skill_name/SKILL.md" ]; then
        echo -e "  ${RED}✗${NC} $skill_name (SKILL.md missing)"
        INVALID+=("$skill_name")
        continue
    fi
    
    # Check if SKILL.md has frontmatter
    if ! head -n 5 "$SKILL_DIR/$skill_name/SKILL.md" | grep -q "^---"; then
        echo -e "  ${YELLOW}⚠${NC} $skill_name (no frontmatter)"
        INVALID+=("$skill_name")
        continue
    fi
    
    # Check if name is in frontmatter
    if ! head -n 10 "$SKILL_DIR/$skill_name/SKILL.md" | grep -q "^name:"; then
        echo -e "  ${YELLOW}⚠${NC} $skill_name (no name in frontmatter)"
        INVALID+=("$skill_name")
        continue
    fi
    
    # Check if description is in frontmatter
    if ! head -n 10 "$SKILL_DIR/$skill_name/SKILL.md" | grep -q "^description:"; then
        echo -e "  ${YELLOW}⚠${NC} $skill_name (no description in frontmatter)"
        INVALID+=("$skill_name")
        continue
    fi
    
    echo -e "  ${GREEN}✓${NC} $skill_name"
    VERIFIED=$((VERIFIED + 1))
done

# Summary
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Verification Summary${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

echo -e "  Total skills checked:  $TOTAL_SKILLS"
echo -e "  ${GREEN}Verified:              $VERIFIED${NC}"

if [ ${#MISSING[@]} -gt 0 ]; then
    echo -e "  ${RED}Missing:               ${#MISSING[@]}${NC}"
    echo ""
    echo -e "  ${RED}Missing skills:${NC}"
    for m in "${MISSING[@]}"; do
        echo -e "    - $m"
    done
fi

if [ ${#INVALID[@]} -gt 0 ]; then
    echo -e "  ${YELLOW}Invalid:               ${#INVALID[@]}${NC}"
    echo ""
    echo -e "  ${YELLOW}Invalid skills:${NC}"
    for i in "${INVALID[@]}"; do
        echo -e "    - $i"
    done
fi

echo ""

if [ ${#MISSING[@]} -eq 0 ] && [ ${#INVALID[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All skills verified successfully!${NC}"
    echo ""
    echo "Skills are installed at: $SKILL_DIR"
    echo ""
    echo "To use these skills with Pi/OpenClaude:"
    echo "  1. Start Pi/OpenClaude"
    echo "  2. Skills will be automatically discovered"
    echo "  3. Use /skill:<name> to load a specific skill"
    exit 0
else
    echo -e "${YELLOW}⚠ Some skills need attention.${NC}"
    echo ""
    echo "To fix missing skills, run:"
    echo "  ./install.sh --force"
    exit 1
fi
