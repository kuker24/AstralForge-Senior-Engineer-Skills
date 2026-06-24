#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT_DIR/skills"
REPORTS_DIR="$ROOT_DIR/reports"
CSV_OUT="$REPORTS_DIR/skill-audit-results.csv"
SUMMARY_OUT="$REPORTS_DIR/skill-audit-summary.md"

mkdir -p "$REPORTS_DIR"

python3 - "$SKILLS_DIR" "$CSV_OUT" "$SUMMARY_OUT" <<'PY'
from __future__ import annotations

import csv
import re
import sys
import urllib.error
import urllib.request
from collections import Counter
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import dataclass
from datetime import date
from pathlib import Path
from typing import Iterable

skills_dir = Path(sys.argv[1])
csv_out = Path(sys.argv[2])
summary_out = Path(sys.argv[3])

LINK_TIMEOUT_SECONDS = 8
MAX_WORKERS = 8
WORD_RE = re.compile(r"\b[\w'’-]+\b")
URL_RE = re.compile(r"https?://[^\s)\]<>\"']+")
PLACEHOLDER_PATTERNS = [
    "replace with description of the skill",
    "replace with description",
    "todo:",
    "tbd",
    "lorem ipsum",
    "placeholder",
]


@dataclass(frozen=True)
class LinkResult:
    url: str
    status: str
    code: int | None = None
    error: str | None = None


def strip_url(url: str) -> str:
    return url.rstrip(".,;:!?]})>")


def extract_urls(text: str) -> list[str]:
    return sorted({strip_url(match.group(0)) for match in URL_RE.finditer(text)})


def request_url(url: str, method: str) -> int:
    req = urllib.request.Request(
        url,
        method=method,
        headers={
            "User-Agent": "AstralForge-Skill-Audit/1.0",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        },
    )
    with urllib.request.urlopen(req, timeout=LINK_TIMEOUT_SECONDS) as response:
        return int(response.status)


def check_url(url: str) -> LinkResult:
    try:
        try:
            code = request_url(url, "HEAD")
        except urllib.error.HTTPError as exc:
            if exc.code in {403, 405, 429}:
                code = request_url(url, "GET")
            else:
                code = int(exc.code)
        status = "OK" if 200 <= code < 400 else "BROKEN"
        return LinkResult(url=url, status=status, code=code)
    except Exception as exc:  # timeout/DNS/TLS/etc. count as broken per phase requirement
        return LinkResult(url=url, status="BROKEN", error=exc.__class__.__name__)


def frontmatter(text: str) -> str | None:
    if not text.startswith("---\n"):
        return None
    end = text.find("\n---", 4)
    if end == -1:
        return None
    return text[4:end]


def body(text: str) -> str:
    fm = frontmatter(text)
    if fm is None:
        return text
    end = text.find("\n---", 4)
    return text[end + 4 :]


def yaml_field_exists(fm: str | None, key: str) -> bool:
    if fm is None:
        return False
    lines = fm.splitlines()
    for i, line in enumerate(lines):
        match = re.match(rf"^{re.escape(key)}:\s*(.*)$", line)
        if not match:
            continue
        value = match.group(1).strip().strip("\"'")
        if value and value not in {"|", ">", "|-", ">-", "|+", ">+"}:
            return True
        for next_line in lines[i + 1 :]:
            if re.match(r"^[A-Za-z0-9_-]+:\s*", next_line):
                break
            if next_line.strip():
                return True
        return False
    return False


def yaml_name(fm: str | None) -> str:
    if fm is None:
        return ""
    match = re.search(r"(?m)^name:\s*(.+?)\s*$", fm)
    return match.group(1).strip().strip("\"'") if match else ""


def word_count(markdown_body: str) -> int:
    cleaned = re.sub(r"```.*?```", " ", markdown_body, flags=re.DOTALL)
    cleaned = re.sub(r"https?://\S+", " ", cleaned)
    return len(WORD_RE.findall(cleaned))


def is_placeholder(skill_name: str, text: str) -> bool:
    lowered = text.lower()
    return any(pattern in lowered for pattern in PLACEHOLDER_PATTERNS)


def audit_skill(skill_dir: Path, link_results: dict[str, LinkResult]) -> dict[str, object]:
    skill_name = skill_dir.name
    skill_md = skill_dir / "SKILL.md"
    agent = skill_dir / "agents" / "openai.yaml"
    sources = skill_dir / "references" / "sources.md"

    has_skill_md = skill_md.is_file()
    text = skill_md.read_text(encoding="utf-8", errors="replace") if has_skill_md else ""
    fm = frontmatter(text)
    frontmatter_valid = fm is not None
    has_name = yaml_field_exists(fm, "name")
    has_description = yaml_field_exists(fm, "description")
    words = word_count(body(text)) if has_skill_md else 0
    placeholder = is_placeholder(skill_name, text)

    has_agent_config = agent.is_file()
    agent_config_nonempty = has_agent_config and bool(agent.read_text(encoding="utf-8", errors="replace").strip())
    has_sources = sources.is_file()
    sources_text = sources.read_text(encoding="utf-8", errors="replace") if has_sources else ""
    sources_nonempty = bool(sources_text.strip())
    urls = extract_urls(sources_text) if sources_nonempty else []
    checked = [link_results[url] for url in urls]
    broken = [result for result in checked if result.status == "BROKEN"]

    notes: list[str] = []
    if not has_skill_md:
        notes.append("missing SKILL.md")
    if has_skill_md and not frontmatter_valid:
        notes.append("invalid or missing frontmatter delimiters")
    if frontmatter_valid and yaml_name(fm) != skill_name:
        notes.append(f"frontmatter name mismatch: {yaml_name(fm)!r}")
    if not has_name:
        notes.append("missing name")
    if not has_description:
        notes.append("missing description")
    if words < 150:
        notes.append(f"word count below 150 ({words})")
    if placeholder:
        notes.append("placeholder/template content detected")
    if not has_agent_config:
        notes.append("missing agents/openai.yaml")
    elif not agent_config_nonempty:
        notes.append("empty agents/openai.yaml")
    if not has_sources:
        notes.append("missing references/sources.md")
    elif not sources_nonempty:
        notes.append("empty references/sources.md")
    elif not urls:
        notes.append("sources present but no HTTP URLs; manual review")
    if broken:
        short = "; ".join(
            f"{item.url} ({item.code if item.code is not None else item.error})" for item in broken[:5]
        )
        notes.append(f"broken links: {short}")
        if len(broken) > 5:
            notes.append(f"{len(broken) - 5} additional broken links")

    if not has_skill_md or not frontmatter_valid or not has_name or not has_description:
        verdict = "BROKEN"
    elif words < 150 or placeholder:
        verdict = "STUB"
    elif (not has_agent_config) or (not agent_config_nonempty) or (not has_sources) or (not sources_nonempty) or broken:
        verdict = "BROKEN"
    elif sources_nonempty and not urls:
        verdict = "NEEDS_REVIEW"
    else:
        verdict = "PASS"

    return {
        "skill_name": skill_name,
        "has_skill_md": has_skill_md,
        "frontmatter_valid": frontmatter_valid,
        "has_name": has_name,
        "has_description": has_description,
        "word_count": words,
        "has_agent_config": has_agent_config,
        "agent_config_nonempty": agent_config_nonempty,
        "has_sources": has_sources,
        "sources_nonempty": sources_nonempty,
        "links_checked": len(checked),
        "broken_links": len(broken),
        "verdict": verdict,
        "notes": "; ".join(notes) or "-",
    }


if not skills_dir.is_dir():
    raise SystemExit(f"skills directory not found: {skills_dir}")

skill_dirs = sorted(path for path in skills_dir.iterdir() if path.is_dir())
all_urls: set[str] = set()
for skill_dir in skill_dirs:
    sources = skill_dir / "references" / "sources.md"
    if sources.is_file():
        all_urls.update(extract_urls(sources.read_text(encoding="utf-8", errors="replace")))

link_results: dict[str, LinkResult] = {}
with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
    futures = {executor.submit(check_url, url): url for url in sorted(all_urls)}
    for future in as_completed(futures):
        result = future.result()
        link_results[result.url] = result

rows = [audit_skill(skill_dir, link_results) for skill_dir in skill_dirs]
columns = [
    "skill_name",
    "has_skill_md",
    "frontmatter_valid",
    "has_name",
    "has_description",
    "word_count",
    "has_agent_config",
    "agent_config_nonempty",
    "has_sources",
    "sources_nonempty",
    "links_checked",
    "broken_links",
    "verdict",
    "notes",
]
with csv_out.open("w", newline="", encoding="utf-8") as handle:
    writer = csv.DictWriter(handle, fieldnames=columns, lineterminator="\n")
    writer.writeheader()
    writer.writerows(rows)

counts = Counter(str(row["verdict"]) for row in rows)
problem_rows = [row for row in rows if row["verdict"] != "PASS"]
problem_rows.sort(key=lambda row: (str(row["verdict"]), str(row["skill_name"])))

summary_lines: list[str] = [
    "# Skill Audit Summary",
    "",
    f"Date: {date.today().isoformat()}",
    "",
    "This report audits source skills for substance and support files. It does not move, delete, or rename any skill.",
    "",
    "## Verdict Counts",
    "",
    "| Verdict | Count |",
    "|---------|------:|",
]
for verdict in ["PASS", "NEEDS_REVIEW", "STUB", "BROKEN"]:
    summary_lines.append(f"| {verdict} | {counts.get(verdict, 0)} |")
summary_lines += [
    f"| **Total** | **{len(rows)}** |",
    "",
    "## Audit Criteria",
    "",
    "- `SKILL.md` exists.",
    "- Frontmatter delimiters are present.",
    "- `name:` and `description:` exist.",
    "- Body has at least 150 substantive words.",
    "- Placeholder/template-only content is flagged.",
    "- `agents/openai.yaml` exists and is non-empty.",
    "- `references/sources.md` exists and is non-empty.",
    "- HTTP links in `references/sources.md` are checked with timeout; 4xx/5xx/timeouts are treated as broken.",
    "",
    "## Top Issues (first 20 non-PASS rows)",
    "",
    "| Skill | Verdict | Notes |",
    "|-------|---------|-------|",
]
for row in problem_rows[:20]:
    notes = str(row["notes"]).replace("|", "\\|") or "-"
    summary_lines.append(f"| `{row['skill_name']}` | {row['verdict']} | {notes} |")
if not problem_rows:
    summary_lines.append("| - | - | No non-PASS skills found. |")

recommendation = (
    "Do not change the README skill count yet. The README can continue to state 83 source skill folders, "
    "but later phases should distinguish verified skills from skills needing review if any non-PASS rows remain."
    if problem_rows
    else "All audited skills passed these criteria; later README updates can truthfully report 83 audited skills."
)
summary_lines += [
    "",
    "## README Recommendation",
    "",
    recommendation,
    "",
    "## Output Files",
    "",
    f"- CSV: `{csv_out.relative_to(csv_out.parents[1])}`",
    f"- Summary: `{summary_out.relative_to(summary_out.parents[1])}`",
]
summary_out.write_text("\n".join(summary_lines) + "\n", encoding="utf-8")

print("AstralForge skill audit complete")
print(f"Total skills: {len(rows)}")
for verdict in ["PASS", "NEEDS_REVIEW", "STUB", "BROKEN"]:
    print(f"{verdict}: {counts.get(verdict, 0)}")
print(f"CSV: {csv_out}")
print(f"Summary: {summary_out}")
PY
