# =============================================================================
# Pi Coding Agent - Complete Installer for Windows
# =============================================================================
# Installs Pi with all skills, extensions, and configuration
#
# Usage:
#   .\install-pi-windows.ps1
#
# Options:
#   -Force       Overwrite existing installation
#   -NoSkills    Skip skills installation
#   -DryRun      Show intended actions without writing files
#   -PiHome      Install into a custom Pi home directory
#   -SkipPiCheck Skip checking for pi binary (for CI sandbox tests)
#   -Help        Show this help message
# =============================================================================

param(
    [switch]$Force,
    [switch]$NoSkills,
    [switch]$DryRun,
    [string]$PiHome,
    [switch]$SkipPiCheck,
    [switch]$Help
)

# Configuration
$ErrorActionPreference = "Stop"
$PI_HOME = if ($PiHome) { $PiHome } elseif ($env:ASTRALFORGE_PI_HOME) { $env:ASTRALFORGE_PI_HOME } else { "$env:USERPROFILE\.pi\agent" }
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$CONFIG_DIR = Join-Path $SCRIPT_DIR "config"
$EXTENSIONS_DIR = Join-Path $SCRIPT_DIR "extensions"
$PROMPTS_DIR = Join-Path $SCRIPT_DIR "prompts"
$AGENTS_DIR = Join-Path $SCRIPT_DIR "agents"
$SKILLS_DIR = Join-Path $SCRIPT_DIR "skills"

# Show help
if ($Help) {
    Write-Host "Usage: .\install-pi-windows.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Options:"
    Write-Host "  -Force       Overwrite existing installation"
    Write-Host "  -NoSkills    Skip skills installation"
    Write-Host "  -DryRun      Show intended actions without writing files"
    Write-Host "  -PiHome      Install into a custom Pi home directory"
    Write-Host "  -SkipPiCheck Skip checking for pi binary (for CI sandbox tests)"
    Write-Host "  -Help        Show this help message"
    exit 0
}

# Function to print status
function Write-Status {
    param(
        [string]$Status,
        [string]$Message
    )
    
    switch ($Status) {
        "ok" { Write-Host "  [OK] $Message" -ForegroundColor Green }
        "skip" { Write-Host "  [SKIP] $Message" -ForegroundColor Yellow }
        "error" { Write-Host "  [ERROR] $Message" -ForegroundColor Red }
        "info" { Write-Host "  [INFO] $Message" -ForegroundColor Cyan }
        "header" { Write-Host $Message -ForegroundColor Cyan }
    }
}

# Header
Write-Host ""
Write-Host "=================================================" -ForegroundColor Blue
Write-Host "  Pi Coding Agent - Complete Installer" -ForegroundColor Blue
Write-Host "  Windows Version" -ForegroundColor Blue
Write-Host "=================================================" -ForegroundColor Blue
Write-Host ""

if ($DryRun) {
    Write-Status "info" "DRY RUN - no files will be written"
    Write-Status "info" "Target Pi home: $PI_HOME"
    Write-Status "info" "Config files: $((Get-ChildItem -Path $CONFIG_DIR -File -ErrorAction SilentlyContinue).Count)"
    Write-Status "info" "Extensions: $((Get-ChildItem -Path $EXTENSIONS_DIR -Filter '*.ts' -File -ErrorAction SilentlyContinue).Count)"
    Write-Status "info" "Skills: $((Get-ChildItem -Path $SKILLS_DIR -Directory -ErrorAction SilentlyContinue).Count)"
    exit 0
}

# Check if Pi is installed
Write-Status "header" "Checking Pi installation..."
if ($SkipPiCheck) {
    Write-Status "info" "Skipping Pi binary check"
} else {
    try {
        $piVersion = & pi --version 2>&1
        Write-Status "ok" "Pi found: $piVersion"
    } catch {
        Write-Status "error" "Pi not found in PATH"
        Write-Host ""
        Write-Host "Please install Pi first:"
        Write-Host "  npm install -g @earendil-works/pi-coding-agent"
        Write-Host ""
        Write-Host "Or visit: https://github.com/anthropics/pi"
        exit 1
    }
}

# Create directory structure
Write-Status "header" "Creating directory structure..."
$dirs = @(
    $PI_HOME,
    "$PI_HOME\config",
    "$PI_HOME\extensions",
    "$PI_HOME\prompts",
    "$PI_HOME\agents",
    "$PI_HOME\skills"
)

foreach ($dir in $dirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}
Write-Status "ok" "Directory structure created"

# Backup existing configuration
Write-Status "header" "Backing up existing configuration..."
$backupDir = "$PI_HOME\backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$hasExisting = $false

foreach ($dir in @("$PI_HOME\config", "$PI_HOME\extensions", "$PI_HOME\prompts", "$PI_HOME\agents")) {
    if ((Test-Path $dir) && (Get-ChildItem $dir -ErrorAction SilentlyContinue)) {
        $hasExisting = $true
        break
    }
}

if ($hasExisting) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Copy-Item -Path "$PI_HOME\config" -Destination "$backupDir\" -Recurse -ErrorAction SilentlyContinue
    Copy-Item -Path "$PI_HOME\extensions" -Destination "$backupDir\" -Recurse -ErrorAction SilentlyContinue
    Copy-Item -Path "$PI_HOME\prompts" -Destination "$backupDir\" -Recurse -ErrorAction SilentlyContinue
    Copy-Item -Path "$PI_HOME\agents" -Destination "$backupDir\" -Recurse -ErrorAction SilentlyContinue
    Write-Status "ok" "Backup created: $backupDir"
} else {
    Write-Status "info" "No existing configuration to backup"
}

# Install configuration
Write-Status "header" "Installing configuration..."
$configFiles = @("settings.json", "models.json", "presets.json")

foreach ($file in $configFiles) {
    $source = Join-Path $CONFIG_DIR $file
    $dest = Join-Path $PI_HOME $file
    
    if (Test-Path $source) {
        if ((Test-Path $dest) -and !$Force) {
            Write-Status "skip" "$file (exists, use -Force to overwrite)"
        } else {
            Copy-Item -Path $source -Destination $dest -Force
            Write-Status "ok" "$file"
        }
    }
}

# Install extensions
Write-Status "header" "Installing extensions..."
$extensions = Get-ChildItem -Path $EXTENSIONS_DIR -Filter "*.ts" -File

foreach ($ext in $extensions) {
    $dest = Join-Path "$PI_HOME\extensions" $ext.Name
    
    if ((Test-Path $dest) -and !$Force) {
        Write-Status "skip" "$($ext.Name) (exists)"
    } else {
        Copy-Item -Path $ext.FullName -Destination $dest -Force
        Write-Status "ok" $ext.Name
    }
}

# Install subagent extensions
$subagentDir = Join-Path $EXTENSIONS_DIR "subagent"
if (Test-Path $subagentDir) {
    $destSubagentDir = Join-Path "$PI_HOME\extensions" "subagent"
    if (!(Test-Path $destSubagentDir)) {
        New-Item -ItemType Directory -Path $destSubagentDir -Force | Out-Null
    }
    
    $subagentExtensions = Get-ChildItem -Path $subagentDir -Filter "*.ts" -File
    foreach ($ext in $subagentExtensions) {
        $dest = Join-Path $destSubagentDir $ext.Name
        
        if ((Test-Path $dest) -and !$Force) {
            Write-Status "skip" "subagent\$($ext.Name) (exists)"
        } else {
            Copy-Item -Path $ext.FullName -Destination $dest -Force
            Write-Status "ok" "subagent\$($ext.Name)"
        }
    }
}

# Install prompts
Write-Status "header" "Installing prompts..."
$prompts = Get-ChildItem -Path $PROMPTS_DIR -Filter "*.md" -File

foreach ($prompt in $prompts) {
    $dest = Join-Path "$PI_HOME\prompts" $prompt.Name
    
    if ((Test-Path $dest) -and !$Force) {
        Write-Status "skip" "$($prompt.Name) (exists)"
    } else {
        Copy-Item -Path $prompt.FullName -Destination $dest -Force
        Write-Status "ok" $prompt.Name
    }
}

# Install agents
Write-Status "header" "Installing agents..."
$agents = Get-ChildItem -Path $AGENTS_DIR -Filter "*.md" -File

foreach ($agent in $agents) {
    $dest = Join-Path "$PI_HOME\agents" $agent.Name
    
    if ((Test-Path $dest) -and !$Force) {
        Write-Status "skip" "$($agent.Name) (exists)"
    } else {
        Copy-Item -Path $agent.FullName -Destination $dest -Force
        Write-Status "ok" $agent.Name
    }
}

# Install skills
if (!$NoSkills) {
    Write-Status "header" "Installing 83 skills..."
    $installed = 0
    $skipped = 0
    
    $skills = Get-ChildItem -Path $SKILLS_DIR -Directory
    
    foreach ($skill in $skills) {
        $skillMd = Join-Path $skill.FullName "SKILL.md"
        
        if (!(Test-Path $skillMd)) {
            Write-Status "error" "$($skill.Name) (no SKILL.md)"
            continue
        }
        
        $dest = Join-Path "$PI_HOME\skills" $skill.Name
        
        if ((Test-Path $dest) -and !$Force) {
            Write-Status "skip" "$($skill.Name) (exists)"
            $skipped++
        } else {
            if (Test-Path $dest) {
                Remove-Item -Path $dest -Recurse -Force
            }
            Copy-Item -Path $skill.FullName -Destination $dest -Recurse -Force
            Write-Status "ok" $skill.Name
            $installed++
        }
    }
    
    Write-Host ""
    Write-Host "  Skills Summary:"
    Write-Host "    Installed: $installed"
    Write-Host "    Skipped: $skipped"
}

# Setup API Key
Write-Status "header" "API Key Configuration..."
Write-Host ""
Write-Host "  [WARN] API Key not included for security" -ForegroundColor Yellow
Write-Host ""
Write-Host "  To configure your API key:"
Write-Host ""
Write-Host "  1. Edit $PI_HOME\models.json"
Write-Host "  2. Replace 'YOUR_API_KEY_HERE' with your actual API key"
Write-Host ""
Write-Host "  Or set environment variable:"
Write-Host "  `$env:GATEWAY_API_KEY = 'your-api-key-here'"
Write-Host ""

# Verification
Write-Status "header" "Verifying installation..."
Write-Host ""

# Check configuration
if (Test-Path "$PI_HOME\settings.json") {
    Write-Status "ok" "settings.json"
} else {
    Write-Status "error" "settings.json missing"
}

if (Test-Path "$PI_HOME\models.json") {
    Write-Status "ok" "models.json"
} else {
    Write-Status "error" "models.json missing"
}

if (Test-Path "$PI_HOME\presets.json") {
    Write-Status "ok" "presets.json"
} else {
    Write-Status "error" "presets.json missing"
}

# Count extensions
$extCount = (Get-ChildItem -Path "$PI_HOME\extensions" -Filter "*.ts" -File).Count
Write-Status "ok" "Extensions: $extCount"

# Count skills
$skillCount = (Get-ChildItem -Path "$PI_HOME\skills" -Directory).Count
Write-Status "ok" "Skills: $skillCount"

# Summary
Write-Host ""
Write-Host "=================================================" -ForegroundColor Blue
Write-Host "  Installation Summary" -ForegroundColor Blue
Write-Host "=================================================" -ForegroundColor Blue
Write-Host ""
Write-Host "  [OK] Pi Home:        $PI_HOME" -ForegroundColor Green
Write-Host "  [OK] Configuration:  $PI_HOME\config\" -ForegroundColor Green
Write-Host "  [OK] Extensions:     $PI_HOME\extensions\" -ForegroundColor Green
Write-Host "  [OK] Prompts:        $PI_HOME\prompts\" -ForegroundColor Green
Write-Host "  [OK] Agents:         $PI_HOME\agents\" -ForegroundColor Green
Write-Host "  [OK] Skills:         $PI_HOME\skills\" -ForegroundColor Green
Write-Host ""
Write-Host "  [WARN] Remember: Add your API key to models.json" -ForegroundColor Yellow
Write-Host ""

if (Test-Path $backupDir) {
    Write-Host "  [INFO] Backup:        $backupDir" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "[OK] Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "To start Pi:"
Write-Host "  pi"
Write-Host ""
Write-Host "To load a specific skill:"
Write-Host "  pi --skill nodejs-express"
Write-Host ""
