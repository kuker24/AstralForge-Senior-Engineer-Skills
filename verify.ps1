# =============================================================================
# AstralForge Senior Engineer Skills - Verifier (Windows)
# =============================================================================
# Verifies that all skills are properly installed
#
# Usage:
#   .\verify.ps1
# =============================================================================

# Configuration
$SkillDir = "$env:USERPROFILE\.pi\agent\skills"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path $ScriptDir "skills"

# Header
Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  AstralForge Senior Engineer Skills - Verifier" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

# Check if source directory exists
if (-not (Test-Path $SourceDir)) {
    Write-Host "Error: Source directory not found: $SourceDir" -ForegroundColor Red
    exit 1
}

# Check if target directory exists
if (-not (Test-Path $SkillDir)) {
    Write-Host "Error: Installation directory not found: $SkillDir" -ForegroundColor Red
    Write-Host ""
    Write-Host "Run install.ps1 first to install skills."
    exit 1
}

# Count skills
$Skills = Get-ChildItem -Path $SourceDir -Directory
$TotalSkills = $Skills.Count
Write-Host "Checking $TotalSkills skills..." -ForegroundColor Green
Write-Host ""

# Verification summary
$Verified = 0
$Missing = @()
$Invalid = @()

# Verify each skill
foreach ($Skill in $Skills) {
    $SkillName = $Skill.Name
    $TargetPath = Join-Path $SkillDir $SkillName
    
    # Check if skill directory exists
    if (-not (Test-Path $TargetPath)) {
        Write-Host "  [X] $SkillName (directory missing)" -ForegroundColor Red
        $Missing += $SkillName
        continue
    }
    
    # Check if SKILL.md exists
    $SkillMdPath = Join-Path $TargetPath "SKILL.md"
    if (-not (Test-Path $SkillMdPath)) {
        Write-Host "  [X] $SkillName (SKILL.md missing)" -ForegroundColor Red
        $Invalid += $SkillName
        continue
    }
    
    # Check if SKILL.md has frontmatter
    $Content = Get-Content -Path $SkillMdPath -Head 10
    $HasFrontmatter = $Content | Where-Object { $_ -match "^---" }
    $HasName = $Content | Where-Object { $_ -match "^name:" }
    $HasDescription = $Content | Where-Object { $_ -match "^description:" }
    
    if (-not $HasFrontmatter) {
        Write-Host "  [!] $SkillName (no frontmatter)" -ForegroundColor Yellow
        $Invalid += $SkillName
        continue
    }
    
    if (-not $HasName) {
        Write-Host "  [!] $SkillName (no name in frontmatter)" -ForegroundColor Yellow
        $Invalid += $SkillName
        continue
    }
    
    if (-not $HasDescription) {
        Write-Host "  [!] $SkillName (no description in frontmatter)" -ForegroundColor Yellow
        $Invalid += $SkillName
        continue
    }
    
    Write-Host "  [OK] $SkillName" -ForegroundColor Green
    $Verified++
}

# Summary
Write-Host ""
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host "  Verification Summary" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "  Total skills checked:  $TotalSkills"
Write-Host "  Verified:              $Verified" -ForegroundColor Green

if ($Missing.Count -gt 0) {
    Write-Host "  Missing:               $($Missing.Count)" -ForegroundColor Red
    Write-Host ""
    Write-Host "  Missing skills:" -ForegroundColor Red
    foreach ($m in $Missing) {
        Write-Host "    - $m"
    }
}

if ($Invalid.Count -gt 0) {
    Write-Host "  Invalid:               $($Invalid.Count)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Invalid skills:" -ForegroundColor Yellow
    foreach ($i in $Invalid) {
        Write-Host "    - $i"
    }
}

Write-Host ""

if ($Missing.Count -eq 0 -and $Invalid.Count -eq 0) {
    Write-Host "All skills verified successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Skills are installed at: $SkillDir"
    Write-Host ""
    Write-Host "To use these skills with Pi/OpenClaude:"
    Write-Host "  1. Start Pi/OpenClaude"
    Write-Host "  2. Skills will be automatically discovered"
    Write-Host "  3. Use /skill:<name> to load a specific skill"
    exit 0
} else {
    Write-Host "WARNING: Some skills need attention." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To fix missing skills, run:"
    Write-Host "  .\install.ps1 -Force"
    exit 1
}
