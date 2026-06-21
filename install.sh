#!/bin/bash
# =============================================================================
# AstralForge Senior Engineer Skills - Installer
# =============================================================================
# Installs all skills to ~/.pi/agent/skills/ for use with Pi/OpenClaude
#
# Usage:
#   chmod +x install.sh && ./install.sh
#
# Options:
#   --force           Overwrite existing skills
#   --dry-run         Show what would be installed without actually installing
#   --target-dir DIR  Install to DIR instead of ~/.pi/agent/skills
#   --help            Show this help message
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SKILL_DIR="${ASTRALFORGE_SKILL_DIR:-$HOME/.pi/agent/skills}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/skills"

# Parse arguments
FORCE=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force)
            FORCE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --target-dir)
            if [[ $# -lt 2 ]]; then
                echo -e "${RED}Missing value for --target-dir${NC}"
                exit 1
            fi
            SKILL_DIR="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --force           Overwrite existing skills"
            echo "  --dry-run         Show what would be installed without actually installing"
            echo "  --target-dir DIR  Install to DIR instead of ~/.pi/agent/skills"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Function to print status
print_status() {
    local status=$1
    local message=$2
    case $status in
        "ok")
            echo -e "  ${GREEN}✓${NC} $message"
            ;;
        "skip")
            echo -e "  ${YELLOW}⊘${NC} $message"
            ;;
        "error")
            echo -e "  ${RED}✗${NC} $message"
            ;;
        "info")
            echo -e "  ${BLUE}ℹ${NC} $message"
            ;;
    esac
}

# Header
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  AstralForge Senior Engineer Skills - Installer${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source directory not found: $SOURCE_DIR${NC}"
    exit 1
fi

# Count skills
TOTAL_SKILLS=$(ls -d "$SOURCE_DIR"/*/ 2>/dev/null | wc -l)
echo -e "Found ${GREEN}$TOTAL_SKILLS${NC} skills to install"
echo ""

# Create target directory if it doesn't exist
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$SKILL_DIR"
fi

# Installation summary
INSTALLED=0
SKIPPED=0
ERRORS=0

# Install each skill
echo -e "${BLUE}Installing skills...${NC}"
echo ""

for skill_path in "$SOURCE_DIR"/*/; do
    skill_name=$(basename "$skill_path")
    
    # Check if SKILL.md exists
    if [ ! -f "$skill_path/SKILL.md" ]; then
        print_status "error" "$skill_name (no SKILL.md found)"
        ERRORS=$((ERRORS + 1))
        continue
    fi
    
    # Check if skill already exists
    if [ -d "$SKILL_DIR/$skill_name" ]; then
        if [ "$FORCE" = true ]; then
            if [ "$DRY_RUN" = true ]; then
                print_status "info" "$skill_name (would overwrite)"
            else
                rm -rf "$SKILL_DIR/$skill_name"
                cp -r "$skill_path" "$SKILL_DIR/$skill_name"
                print_status "ok" "$skill_name (overwritten)"
            fi
            INSTALLED=$((INSTALLED + 1))
        else
            print_status "skip" "$skill_name (already exists, use --force to overwrite)"
            SKIPPED=$((SKIPPED + 1))
        fi
    else
        if [ "$DRY_RUN" = true ]; then
            print_status "info" "$skill_name (would install)"
        else
            cp -r "$skill_path" "$SKILL_DIR/$skill_name"
            print_status "ok" "$skill_name"
        fi
        INSTALLED=$((INSTALLED + 1))
    fi
done

# Summary
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Installation Summary${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "  ${YELLOW}DRY RUN - No changes were made${NC}"
    echo ""
fi

echo -e "  Total skills found:    $TOTAL_SKILLS"
echo -e "  ${GREEN}Installed:             $INSTALLED${NC}"
if [ $SKIPPED -gt 0 ]; then
    echo -e "  ${YELLOW}Skipped:               $SKIPPED${NC}"
fi
if [ $ERRORS -gt 0 ]; then
    echo -e "  ${RED}Errors:                $ERRORS${NC}"
fi

echo ""
echo -e "  Installation directory: $SKILL_DIR"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${YELLOW}⚠ Some skills had errors. Check the output above.${NC}"
    exit 1
elif [ "$DRY_RUN" = false ]; then
    echo -e "${GREEN}✓ Installation complete!${NC}"
    echo ""
    echo "To verify installation, run:"
    echo "  ./verify.sh"
else
    echo -e "${BLUE}Run without --dry-run to install.${NC}"
fi

echo ""
