#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT_DIR/skills"

python3 - "$SKILLS_DIR" <<'PY'
import re
import sys
from collections import Counter
from pathlib import Path

skills_dir = Path(sys.argv[1])
errors: list[str] = []

if not skills_dir.is_dir():
    print(f"ERROR: skills directory not found: {skills_dir}")
    raise SystemExit(1)

skill_dirs = sorted(p for p in skills_dir.iterdir() if p.is_dir())
if not skill_dirs:
    errors.append("No skill directories found")

names: list[str] = []
for skill_dir in skill_dirs:
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        errors.append(f"{skill_dir.name}: missing SKILL.md")
        continue

    text = skill_md.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        errors.append(f"{skill_dir.name}: missing opening frontmatter delimiter")
        continue

    try:
        frontmatter = text.split("---", 2)[1]
    except IndexError:
        errors.append(f"{skill_dir.name}: missing closing frontmatter delimiter")
        continue

    name_match = re.search(r"(?m)^name:\s*[\"']?([^\"'\n]+)[\"']?\s*$", frontmatter)
    desc_match = re.search(r"(?m)^description:\s*(.+?)\s*$", frontmatter)

    if not name_match:
        errors.append(f"{skill_dir.name}: missing name in frontmatter")
    else:
        name = name_match.group(1).strip()
        names.append(name)
        if name != skill_dir.name:
            errors.append(f"{skill_dir.name}: frontmatter name '{name}' does not match folder")

    if not desc_match or not desc_match.group(1).strip().strip('"\''):
        errors.append(f"{skill_dir.name}: missing description in frontmatter")

duplicates = sorted(name for name, count in Counter(names).items() if count > 1)
for name in duplicates:
    errors.append(f"duplicate skill name: {name}")

print("AstralForge source skill verification")
print(f"Total source skills: {len(skill_dirs)}")
print(f"Unique skill names: {len(set(names))}")

if errors:
    print(f"Invalid skills: {len(errors)}")
    for err in errors[:50]:
        print(f"- {err}")
    if len(errors) > 50:
        print(f"... {len(errors) - 50} more")
    raise SystemExit(1)

print("Status: OK")
PY
