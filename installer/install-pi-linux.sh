#!/bin/bash
# =============================================================================
# Pi Coding Agent - Complete Installer for Linux/macOS
# =============================================================================
# Installs Pi with all skills, extensions, and configuration
#
# Usage:
#   chmod +x install-pi-linux.sh && ./install-pi-linux.sh
#
# Options:
#   --force          Overwrite existing installation
#   --no-skills      Skip skills installation
#   --dry-run        Show intended actions without writing files
#   --pi-home DIR    Install into DIR instead of ~/.pi/agent
#   --skip-pi-check  Skip checking for pi binary (for CI sandbox tests)
#   --help           Show this help message
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PI_HOME="${ASTRALFORGE_PI_HOME:-$HOME/.pi/agent}"
CONFIG_DIR="$SCRIPT_DIR/config"
EXTENSIONS_DIR="$SCRIPT_DIR/extensions"
PROMPTS_DIR="$SCRIPT_DIR/prompts"
AGENTS_DIR="$SCRIPT_DIR/agents"
SKILLS_DIR="$SCRIPT_DIR/skills"

# Parse arguments
FORCE=false
NO_SKILLS=false
DRY_RUN=false
SKIP_PI_CHECK=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force)
            FORCE=true
            shift
            ;;
        --no-skills)
            NO_SKILLS=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --pi-home)
            if [[ $# -lt 2 ]]; then
                echo -e "${RED}Missing value for --pi-home${NC}"
                exit 1
            fi
            PI_HOME="$2"
            shift 2
            ;;
        --skip-pi-check)
            SKIP_PI_CHECK=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --force          Overwrite existing installation"
            echo "  --no-skills      Skip skills installation"
            echo "  --dry-run        Show intended actions without writing files"
            echo "  --pi-home DIR    Install into DIR instead of ~/.pi/agent"
            echo "  --skip-pi-check  Skip checking for pi binary (for CI sandbox tests)"
            echo "  --help           Show this help message"
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
        "header")
            echo -e "${CYAN}$message${NC}"
            ;;
    esac
}

# Header
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Pi Coding Agent - Complete Installer${NC}"
echo -e "${BLUE}  Linux/macOS Version${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""

if [ "$DRY_RUN" = true ]; then
    print_status "info" "DRY RUN - no files will be written"
    print_status "info" "Target Pi home: $PI_HOME"
    print_status "info" "Config files: $(find "$CONFIG_DIR" -maxdepth 1 -type f 2>/dev/null | wc -l)"
    print_status "info" "Extensions: $(find "$EXTENSIONS_DIR" -maxdepth 1 -name '*.ts' -type f 2>/dev/null | wc -l)"
    print_status "info" "Skills: $(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)"
    exit 0
fi

# Check if Pi is installed
print_status "header" "Checking Pi installation..."
if [ "$SKIP_PI_CHECK" = true ]; then
    print_status "info" "Skipping Pi binary check"
elif command -v pi &> /dev/null; then
    PI_VERSION=$(pi --version 2>/dev/null || echo "unknown")
    print_status "ok" "Pi found: $PI_VERSION"
else
    print_status "error" "Pi not found in PATH"
    echo ""
    echo "Please install Pi first:"
    echo "  npm install -g @earendil-works/pi-coding-agent"
    echo ""
    echo "Or visit: https://github.com/anthropics/pi"
    exit 1
fi

# Create directory structure
print_status "header" "Creating directory structure..."
mkdir -p "$PI_HOME"
mkdir -p "$PI_HOME/config"
mkdir -p "$PI_HOME/extensions"
mkdir -p "$PI_HOME/prompts"
mkdir -p "$PI_HOME/agents"
mkdir -p "$PI_HOME/skills"
print_status "ok" "Directory structure created"

# Backup existing configuration
print_status "header" "Backing up existing configuration..."
BACKUP_DIR="$PI_HOME/backup-$(date +%Y%m%d-%H%M%S)"
if [ -d "$PI_HOME/config" ] && [ "$(ls -A $PI_HOME/config 2>/dev/null)" ]; then
    mkdir -p "$BACKUP_DIR"
    cp -r "$PI_HOME/config" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$PI_HOME/extensions" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$PI_HOME/prompts" "$BACKUP_DIR/" 2>/dev/null || true
    cp -r "$PI_HOME/agents" "$BACKUP_DIR/" 2>/dev/null || true
    print_status "ok" "Backup created: $BACKUP_DIR"
else
    print_status "info" "No existing configuration to backup"
fi

# Install configuration
print_status "header" "Installing configuration..."
if [ -f "$CONFIG_DIR/settings.json" ]; then
    if [ -f "$PI_HOME/settings.json" ] && [ "$FORCE" = false ]; then
        print_status "skip" "settings.json (exists, use --force to overwrite)"
    else
        cp "$CONFIG_DIR/settings.json" "$PI_HOME/settings.json"
        print_status "ok" "settings.json"
    fi
fi

if [ -f "$CONFIG_DIR/models.json" ]; then
    if [ -f "$PI_HOME/models.json" ] && [ "$FORCE" = false ]; then
        print_status "skip" "models.json (exists, use --force to overwrite)"
    else
        cp "$CONFIG_DIR/models.json" "$PI_HOME/models.json"
        print_status "ok" "models.json"
    fi
fi

if [ -f "$CONFIG_DIR/presets.json" ]; then
    if [ -f "$PI_HOME/presets.json" ] && [ "$FORCE" = false ]; then
        print_status "skip" "presets.json (exists, use --force to overwrite)"
    else
        cp "$CONFIG_DIR/presets.json" "$PI_HOME/presets.json"
        print_status "ok" "presets.json"
    fi
fi

# Install extensions
print_status "header" "Installing extensions..."
for ext in "$EXTENSIONS_DIR"/*.ts; do
    if [ -f "$ext" ]; then
        ext_name=$(basename "$ext")
        if [ -f "$PI_HOME/extensions/$ext_name" ] && [ "$FORCE" = false ]; then
            print_status "skip" "$ext_name (exists)"
        else
            cp "$ext" "$PI_HOME/extensions/$ext_name"
            print_status "ok" "$ext_name"
        fi
    fi
done

# Install subagent extensions
if [ -d "$EXTENSIONS_DIR/subagent" ]; then
    mkdir -p "$PI_HOME/extensions/subagent"
    for ext in "$EXTENSIONS_DIR/subagent"/*.ts; do
        if [ -f "$ext" ]; then
            ext_name=$(basename "$ext")
            if [ -f "$PI_HOME/extensions/subagent/$ext_name" ] && [ "$FORCE" = false ]; then
                print_status "skip" "subagent/$ext_name (exists)"
            else
                cp "$ext" "$PI_HOME/extensions/subagent/$ext_name"
                print_status "ok" "subagent/$ext_name"
            fi
        fi
    done
fi

# Install prompts
print_status "header" "Installing prompts..."
for prompt in "$PROMPTS_DIR"/*.md; do
    if [ -f "$prompt" ]; then
        prompt_name=$(basename "$prompt")
        if [ -f "$PI_HOME/prompts/$prompt_name" ] && [ "$FORCE" = false ]; then
            print_status "skip" "$prompt_name (exists)"
        else
            cp "$prompt" "$PI_HOME/prompts/$prompt_name"
            print_status "ok" "$prompt_name"
        fi
    fi
done

# Install agents
print_status "header" "Installing agents..."
for agent in "$AGENTS_DIR"/*.md; do
    if [ -f "$agent" ]; then
        agent_name=$(basename "$agent")
        if [ -f "$PI_HOME/agents/$agent_name" ] && [ "$FORCE" = false ]; then
            print_status "skip" "$agent_name (exists)"
        else
            cp "$agent" "$PI_HOME/agents/$agent_name"
            print_status "ok" "$agent_name"
        fi
    fi
done

# Install skills
if [ "$NO_SKILLS" = false ]; then
    print_status "header" "Installing 83 skills..."
    installed=0
    skipped=0
    
    for skill in "$SKILLS_DIR"/*/; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            
            # Check if SKILL.md exists
            if [ ! -f "$skill/SKILL.md" ]; then
                print_status "error" "$skill_name (no SKILL.md)"
                continue
            fi
            
            if [ -d "$PI_HOME/skills/$skill_name" ] && [ "$FORCE" = false ]; then
                print_status "skip" "$skill_name (exists)"
                skipped=$((skipped + 1))
            else
                if [ -d "$PI_HOME/skills/$skill_name" ]; then
                    rm -rf "$PI_HOME/skills/$skill_name"
                fi
                cp -r "$skill" "$PI_HOME/skills/$skill_name"
                print_status "ok" "$skill_name"
                installed=$((installed + 1))
            fi
        fi
    done
    
    echo ""
    echo -e "  Skills Summary:"
    echo -e "    Installed: $installed"
    echo -e "    Skipped: $skipped"
fi

# Setup API Key
print_status "header" "API Key Configuration..."
echo ""
echo -e "  ${YELLOW}⚠ API Key not included for security${NC}"
echo ""
echo "  To configure your API key:"
echo ""
echo "  1. Edit ~/.pi/agent/models.json"
echo "  2. Replace 'YOUR_API_KEY_HERE' with your actual API key"
echo ""
echo "  Or set environment variable:"
echo "  export GATEWAY_API_KEY='your-api-key-here'"
echo ""

# Verification
print_status "header" "Verifying installation..."
echo ""

# Check configuration
if [ -f "$PI_HOME/settings.json" ]; then
    print_status "ok" "settings.json"
else
    print_status "error" "settings.json missing"
fi

if [ -f "$PI_HOME/models.json" ]; then
    print_status "ok" "models.json"
else
    print_status "error" "models.json missing"
fi

if [ -f "$PI_HOME/presets.json" ]; then
    print_status "ok" "presets.json"
else
    print_status "error" "presets.json missing"
fi

# Count extensions
ext_count=$(ls -1 "$PI_HOME/extensions"/*.ts 2>/dev/null | wc -l)
print_status "ok" "Extensions: $ext_count"

# Count skills
skill_count=$(ls -1d "$PI_HOME/skills"/*/ 2>/dev/null | wc -l)
print_status "ok" "Skills: $skill_count"

# Summary
echo ""
echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}  Installation Summary${NC}"
echo -e "${BLUE}=================================================${NC}"
echo ""
echo -e "  ${GREEN}✓ Pi Home:${NC}        $PI_HOME"
echo -e "  ${GREEN}✓ Configuration:${NC}  $PI_HOME/config/"
echo -e "  ${GREEN}✓ Extensions:${NC}     $PI_HOME/extensions/"
echo -e "  ${GREEN}✓ Prompts:${NC}        $PI_HOME/prompts/"
echo -e "  ${GREEN}✓ Agents:${NC}         $PI_HOME/agents/"
echo -e "  ${GREEN}✓ Skills:${NC}         $PI_HOME/skills/"
echo ""
echo -e "  ${YELLOW}⚠ Remember:${NC} Add your API key to models.json"
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo -e "  ${BLUE}ℹ Backup:${NC}        $BACKUP_DIR"
    echo ""
fi

echo -e "${GREEN}✓ Installation complete!${NC}"
echo ""
echo "To start Pi:"
echo "  pi"
echo ""
echo "To load a specific skill:"
echo "  pi --skill nodejs-express"
echo ""
