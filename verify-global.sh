#!/bin/bash
# =============================================================================
# AstralForge Senior Engineer Skills - Global Verifier
# =============================================================================
# Verifies that all skills are properly installed on all platforms
#
# Usage:
#   chmod +x verify-global.sh && ./verify-global.sh [--home DIR]
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills"

# Target directories
TARGET_HOME="${ASTRALFORGE_HOME:-$HOME}"
PI_SKILLS="$TARGET_HOME/.pi/agent/skills"
OPENCODE_SKILLS="$TARGET_HOME/.config/opencode/skills"
CLAUDE_SKILLS="$TARGET_HOME/.claude/skills"
CODEX_SKILLS="$TARGET_HOME/.codex/skills"
AGENTS_SKILLS="$TARGET_HOME/.agents/skills"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --home)
            if [[ $# -lt 2 ]]; then
                echo -e "${RED}Missing value for --home${NC}"
                exit 1
            fi
            TARGET_HOME="$2"
            PI_SKILLS="$TARGET_HOME/.pi/agent/skills"
            OPENCODE_SKILLS="$TARGET_HOME/.config/opencode/skills"
            CLAUDE_SKILLS="$TARGET_HOME/.claude/skills"
            CODEX_SKILLS="$TARGET_HOME/.codex/skills"
            AGENTS_SKILLS="$TARGET_HOME/.agents/skills"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [--home DIR]"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Header
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  AstralForge Senior Engineer Skills - Global Verifier${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source directory not found: $SOURCE_DIR${NC}"
    exit 1
fi

# Count skills
TOTAL_SKILLS=$(ls -d "$SOURCE_DIR"/*/ 2>/dev/null | wc -l)
echo -e "Checking ${GREEN}$TOTAL_SKILLS${NC} skills..."
echo ""

# Verification summary
TOTAL_VERIFIED=0
TOTAL_MISSING=0
TOTAL_INVALID=0

# Function to verify platform
verify_platform() {
    local platform_name=$1
    local target_dir=$2
    
    echo -e "${BLUE}Verifying $platform_name...${NC}"
    echo ""
    
    local verified=0
    local missing=()
    local invalid=()
    
    for skill_path in "$SOURCE_DIR"/*/; do
        skill_name=$(basename "$skill_path")
        
        # Check if skill directory exists
        if [ ! -d "$target_dir/$skill_name" ]; then
            echo -e "  ${RED}✗${NC} $skill_name (directory missing)"
            missing+=("$skill_name")
            continue
        fi
        
        # Check if SKILL.md exists
        if [ ! -f "$target_dir/$skill_name/SKILL.md" ]; then
            echo -e "  ${RED}✗${NC} $skill_name (SKILL.md missing)"
            invalid+=("$skill_name")
            continue
        fi
        
        # Check if SKILL.md has frontmatter
        if ! head -n 5 "$target_dir/$skill_name/SKILL.md" | grep -q "^---"; then
            echo -e "  ${YELLOW}⚠${NC} $skill_name (no frontmatter)"
            invalid+=("$skill_name")
            continue
        fi
        
        # Check if name is in frontmatter
        if ! head -n 10 "$target_dir/$skill_name/SKILL.md" | grep -q "^name:"; then
            echo -e "  ${YELLOW}⚠${NC} $skill_name (no name in frontmatter)"
            invalid+=("$skill_name")
            continue
        fi
        
        # Check if description is in frontmatter
        if ! head -n 10 "$target_dir/$skill_name/SKILL.md" | grep -q "^description:"; then
            echo -e "  ${YELLOW}⚠${NC} $skill_name (no description in frontmatter)"
            invalid+=("$skill_name")
            continue
        fi
        
        # Check if symlink is valid
        if [ -L "$target_dir/$skill_name" ] && [ ! -e "$target_dir/$skill_name" ]; then
            echo -e "  ${RED}✗${NC} $skill_name (broken symlink)"
            invalid+=("$skill_name")
            continue
        fi
        
        echo -e "  ${GREEN}✓${NC} $skill_name"
        verified=$((verified + 1))
    done
    
    echo ""
    echo -e "  $platform_name Summary:"
    echo -e "    Verified: $verified"
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "    Missing: ${#missing[@]}"
    fi
    if [ ${#invalid[@]} -gt 0 ]; then
        echo -e "    Invalid: ${#invalid[@]}"
    fi
    echo ""
    
    TOTAL_VERIFIED=$((TOTAL_VERIFIED + verified))
    TOTAL_MISSING=$((TOTAL_MISSING + ${#missing[@]}))
    TOTAL_INVALID=$((TOTAL_INVALID + ${#invalid[@]}))
    
    return $((${#missing[@]} + ${#invalid[@]}))
}

# Verify all platforms
TOTAL_ERRORS=0

verify_platform "Pi" "$PI_SKILLS" || TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
verify_platform "OpenCode" "$OPENCODE_SKILLS" || TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
verify_platform "Claude" "$CLAUDE_SKILLS" || TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
verify_platform "Codex" "$CODEX_SKILLS" || TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
verify_platform "Agents" "$AGENTS_SKILLS" || TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

# Summary
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Global Verification Summary${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

echo -e "  Total skills checked:  $TOTAL_SKILLS × 5 platforms"
echo -e "  ${GREEN}Verified:              $TOTAL_VERIFIED${NC}"

if [ $TOTAL_MISSING -gt 0 ]; then
    echo -e "  ${RED}Missing:               $TOTAL_MISSING${NC}"
fi

if [ $TOTAL_INVALID -gt 0 ]; then
    echo -e "  ${YELLOW}Invalid:               $TOTAL_INVALID${NC}"
fi

echo ""

if [ $TOTAL_ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All skills verified successfully on all platforms!${NC}"
    echo ""
    echo "Platforms verified:"
    echo "  ✓ Pi        → $PI_SKILLS"
    echo "  ✓ OpenCode  → $OPENCODE_SKILLS"
    echo "  ✓ Claude    → $CLAUDE_SKILLS"
    echo "  ✓ Codex     → $CODEX_SKILLS"
    echo "  ✓ Agents    → $AGENTS_SKILLS"
    exit 0
else
    echo -e "${YELLOW}⚠ Some skills need attention.${NC}"
    echo ""
    echo "To fix missing skills, run:"
    echo "  ./install-global.sh --force"
    exit 1
fi
