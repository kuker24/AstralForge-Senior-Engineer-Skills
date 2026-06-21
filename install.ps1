# =============================================================================
# AstralForge Senior Engineer Skills - Installer (Windows)
# =============================================================================
# Installs all skills to ~/.pi/agent/skills/ for use with Pi/OpenClaude
#
# Usage:
#   .\install.ps1
#
# Options:
#   -Force    Overwrite existing skills
#   -DryRun   Show what would be installed without actually installing
# =============================================================================

param(
    [switch]$Force,
    [switch]$DryRun
)

# Configuration
$SkillDir = "$env:USERPROFILE\.pi\agent\skills"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path $ScriptDir "skills"

# Colors
function Write-Status {
    param(
        [string]$Status,
        [string]$Message
    )
    switch ($Status) {
        "ok"    { Write-Host "  [OK] $Message" -ForegroundColor Green }
        "skip"  { Write-Host "  [SKIP] $Message" -ForegroundColor Yellow }
        "error" { Write-Host "  [ERROR] $Message" -ForegroundColor Red }
        "info"  { Write-Host "  [INFO] $Message" -ForegroundColor Cyan }
    }
}

# Header
Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  AstralForge Senior Engineer Skills - Installer" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Check if source directory exists
if (-not (Test-Path $SourceDir)) {
    Write-Host "Error: Source directory not found: $SourceDir" -ForegroundColor Red
    exit 1
}

# Count skills
$Skills = Get-ChildItem -Path $SourceDir -Directory
$TotalSkills = $Skills.Count
Write-Host "Found $TotalSkills skills to install" -ForegroundColor Green
Write-Host ""

# Create target directory if it doesn't exist
if (-not $DryRun) {
    if (-not (Test-Path $SkillDir)) {
        New-Item -ItemType Directory -Path $SkillDir -Force | Out-Null
    }
}

# Installation summary
$Installed = 0
$Skipped = 0
$Errors = 0

# Install each skill
Write-Host "Installing skills..." -ForegroundColor Cyan
Write-Host ""

foreach ($Skill in $Skills) {
    $SkillName = $Skill.Name
    $SkillPath = $Skill.FullName
    $TargetPath = Join-Path $SkillDir $SkillName
    
    # Check if SKILL.md exists
    if (-not (Test-Path (Join-Path $SkillPath "SKILL.md"))) {
        Write-Status "error" "$SkillName (no SKILL.md found)"
        $Errors++
        continue
    }
    
    # Check if skill already exists
    if (Test-Path $TargetPath) {
        if ($Force) {
            if ($DryRun) {
                Write-Status "info" "$SkillName (would overwrite)"
            } else {
                Remove-Item -Path $TargetPath -Recurse -Force
                Copy-Item -Path $SkillPath -Destination $TargetPath -Recurse
                Write-Status "ok" "$SkillName (overwritten)"
            }
            $Installed++
        } else {
            Write-Status "skip" "$SkillName (already exists, use -Force to overwrite)"
            $Skipped++
        }
    } else {
        if ($DryRun) {
            Write-Status "info" "$SkillName (would install)"
        } else {
            Copy-Item -Path $SkillPath -Destination $TargetPath -Recurse
            Write-Status "ok" "$SkillName"
        }
        $Installed++
    }
}

# Summary
Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  Installation Summary" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "  DRY RUN - No changes were made" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "  Total skills found:    $TotalSkills"
Write-Host "  Installed:             $Installed" -ForegroundColor Green
if ($Skipped -gt 0) {
    Write-Host "  Skipped:               $Skipped" -ForegroundColor Yellow
}
if ($Errors -gt 0) {
    Write-Host "  Errors:                $Errors" -ForegroundColor Red
}

Write-Host ""
Write-Host "  Installation directory: $SkillDir"
Write-Host ""

if ($Errors -gt 0) {
    Write-Host "WARNING: Some skills had errors. Check the output above." -ForegroundColor Yellow
    exit 1
} elseif (-not $DryRun) {
    Write-Host "Installation complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "To verify installation, run:"
    Write-Host "  .\verify.ps1"
} else {
    Write-Host "Run without -DryRun to install." -ForegroundColor Cyan
}

Write-Host ""
