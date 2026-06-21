#!/bin/bash
# =============================================================================
# AstralForge Senior Engineer Skills - Global Installer
# =============================================================================
# Installs all skills to all platforms: Pi, OpenCode, Claude, Codex, Agents
#
# Usage:
#   chmod +x install-global.sh && ./install-global.sh
#
# Options:
#   --force    Overwrite existing skills
#   --dry-run  Show what would be installed without actually installing
#   --help     Show this help message
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
PI_SKILLS="$HOME/.pi/agent/skills"
OPENCODE_SKILLS="$HOME/.config/opencode/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"
CODEX_SKILLS="$HOME/.codex/skills"
AGENTS_SKILLS="$HOME/.agents/skills"

# Parse arguments
FORCE=false
DRY_RUN=false

for arg in "$@"; do
    case $arg in
        --force)
            FORCE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --force    Overwrite existing skills"
            echo "  --dry-run  Show what would be installed without actually installing"
            echo "  --help     Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $arg${NC}"
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
echo -e "${BLUE}  AstralForge Senior Engineer Skills - Global Installer${NC}"
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

# Create target directories if they don't exist
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$PI_SKILLS"
    mkdir -p "$OPENCODE_SKILLS"
    mkdir -p "$CLAUDE_SKILLS"
    mkdir -p "$CODEX_SKILLS"
    mkdir -p "$AGENTS_SKILLS"
fi

# Function to install skills to a platform
install_to_platform() {
    local platform_name=$1
    local target_dir=$2
    
    echo -e "${BLUE}Installing to $platform_name...${NC}"
    echo ""
    
    local installed=0
    local skipped=0
    local errors=0
    
    for skill_path in "$SOURCE_DIR"/*/; do
        skill_name=$(basename "$skill_path")
        
        # Check if SKILL.md exists
        if [ ! -f "$skill_path/SKILL.md" ]; then
            print_status "error" "$skill_name (no SKILL.md found)"
            errors=$((errors + 1))
            continue
        fi
        
        # Check if skill already exists
        if [ -e "$target_dir/$skill_name" ]; then
            if [ "$FORCE" = true ]; then
                if [ "$DRY_RUN" = true ]; then
                    print_status "info" "$skill_name (would overwrite)"
                else
                    rm -rf "$target_dir/$skill_name"
                    ln -s "$(cd "$skill_path" && pwd)" "$target_dir/$skill_name"
                    print_status "ok" "$skill_name (overwritten)"
                fi
                installed=$((installed + 1))
            else
                print_status "skip" "$skill_name (exists)"
                skipped=$((skipped + 1))
            fi
        else
            if [ "$DRY_RUN" = true ]; then
                print_status "info" "$skill_name (would symlink)"
            else
                ln -s "$(cd "$skill_path" && pwd)" "$target_dir/$skill_name"
                print_status "ok" "$skill_name (symlinked)"
            fi
            installed=$((installed + 1))
        fi
    done
    
    echo ""
    echo -e "  $platform_name Summary:"
    echo -e "    Installed: $installed"
    echo -e "    Skipped: $skipped"
    if [ $errors -gt 0 ]; then
        echo -e "    Errors: $errors"
    fi
    echo ""
    
    return $errors
}

# Install to all platforms
TOTAL_ERRORS=0

install_to_platform "Pi" "$PI_SKILLS" || TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
install_to_platform "OpenCode" "$OPENCODE_SKILLS" || TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
install_to_platform "Claude" "$CLAUDE_SKILLS" || TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
install_to_platform "Codex" "$CODEX_SKILLS" || TOTAL_ERRORS=$((TOTAL_ERRORS + $?))
install_to_platform "Agents" "$AGENTS_SKILLS" || TOTAL_ERRORS=$((TOTAL_ERRORS + $?))

# Verification
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Verification${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

if [ "$DRY_RUN" = false ]; then
    echo "Checking symlink integrity..."
    echo ""
    
    BROKEN_LINKS=0
    for dir in "$PI_SKILLS" "$OPENCODE_SKILLS" "$CLAUDE_SKILLS" "$CODEX_SKILLS" "$AGENTS_SKILLS"; do
        platform_name=$(basename "$(dirname "$(dirname "$dir")")")
        broken=0
        total=0
        for link in "$dir"/*/; do
            total=$((total + 1))
            if [ -L "$link" ] && [ ! -e "$link" ]; then
                echo -e "  ${RED}✗${NC} Broken link: $(basename "$link")"
                broken=$((broken + 1))
                BROKEN_LINKS=$((BROKEN_LINKS + 1))
            fi
        done
        if [ $broken -eq 0 ]; then
            echo -e "  ${GREEN}✓${NC} $platform_name: All $total symlinks valid"
        else
            echo -e "  ${YELLOW}⚠${NC} $platform_name: $broken broken links"
        fi
    done
    
    echo ""
    
    if [ $BROKEN_LINKS -gt 0 ]; then
        echo -e "${YELLOW}⚠ Found $BROKEN_LINKS broken links. Run with --force to fix.${NC}"
    fi
fi

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

echo -e "  Total skills:        $TOTAL_SKILLS"
echo -e "  Platforms:           5"
echo ""
echo -e "  ${GREEN}✓ Pi${NC}        → $PI_SKILLS"
echo -e "  ${GREEN}✓ OpenCode${NC}  → $OPENCODE_SKILLS"
echo -e "  ${GREEN}✓ Claude${NC}    → $CLAUDE_SKILLS"
echo -e "  ${GREEN}✓ Codex${NC}     → $CODEX_SKILLS"
echo -e "  ${GREEN}✓ Agents${NC}    → $AGENTS_SKILLS"
echo ""

if [ $TOTAL_ERRORS -gt 0 ]; then
    echo -e "${YELLOW}⚠ Some skills had errors. Check the output above.${NC}"
    exit 1
elif [ "$DRY_RUN" = false ]; then
    echo -e "${GREEN}✓ Global installation complete!${NC}"
    echo ""
    echo "To verify installation, run:"
    echo "  ./verify-global.sh"
else
    echo -e "${BLUE}Run without --dry-run to install.${NC}"
fi

echo ""
