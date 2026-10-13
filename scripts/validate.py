#!/usr/bin/env python3
"""Validate the shipped skill bundle and relative resource links using stdlib."""

import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parents[1]
SKILL = ROOT / "skills" / "my-dev-team"
ROLES = {
    "po", "technical-lead", "senior-developer", "design-lead",
    "senior-designer", "design-tester", "qa-lead", "senior-qa",
    "devops", "cybersecurity",
}


def validate():
    errors = []
    entry = SKILL / "SKILL.md"
    if not entry.is_file():
        return ["Missing skills/my-dev-team/SKILL.md"]
    text = entry.read_text(encoding="utf-8")
    parts = text.split("---", 2)
    if len(parts) != 3 or parts[0].strip():
        errors.append("SKILL.md needs YAML frontmatter")
    else:
        fields = {}
        for line in parts[1].strip().splitlines():
            key, sep, value = line.partition(":")
            if not sep or key in fields:
                errors.append(f"Invalid or duplicate frontmatter field: {line}")
            fields[key] = value.strip()
        if fields.get("name") != "my-dev-team":
            errors.append("Skill name must match its install directory: my-dev-team")
        if not fields.get("description"):
            errors.append("Skill description is missing")
        if fields.get("description") and len(fields["description"]) > 1024:
            errors.append("Skill description exceeds 1024 characters")

    guides = {p.stem for p in (SKILL / "roles").glob("*.md")}
    if guides != ROLES:
        errors.append(f"Role guide mismatch: missing={sorted(ROLES - guides)}, extra={sorted(guides - ROLES)}")
    linked_roles = set(re.findall(r"\]\(roles/([a-z-]+)\.md\)", text))
    if linked_roles != ROLES:
        errors.append("The skill entrypoint must link all ten role guides")

    # Follow Markdown resource links from the entrypoint. Templates may contain
    # illustrative paths as prose/code; only real Markdown links are resolved.
    visited, pending = set(), [entry]
    while pending:
        source = pending.pop()
        if source in visited:
            continue
        visited.add(source)
        content = source.read_text(encoding="utf-8")
        if not content.strip():
            errors.append(f"Empty resource: {source.relative_to(ROOT)}")
        if source.suffix != ".md":
            continue
        # Do not interpret example Markdown inside fenced code blocks as links.
        content = re.sub(r"^```[^\n]*\n.*?^```\s*$", "", content, flags=re.M | re.S)
        for raw in re.findall(r"\[[^\]\n]*\]\(([^)\n]+)\)", content):
            target = raw.strip().strip("<>")
            parsed = urlsplit(target)
            if parsed.scheme or parsed.netloc or not parsed.path:
                continue
            path = (source.parent / unquote(parsed.path)).resolve()
            try:
                path.relative_to(SKILL)
            except ValueError:
                errors.append(f"Resource escapes installed skill: {source.name}: {target}")
                continue
            if not path.is_file():
                errors.append(f"Broken link: {source.relative_to(ROOT)} -> {target}")
            elif path not in visited:
                pending.append(path)

    for folder in ("roles", "references", "assets"):
        for path in (SKILL / folder).rglob("*"):
            if path.is_file() and path not in visited:
                errors.append(f"Unreachable resource: {path.relative_to(ROOT)}")

    # Project documents are HTML, indexed by README.md files; the only other
    # Markdown the team writes is under .AI/. Catch guidance that names a
    # project doc as Markdown.
    for source in sorted(p for p in visited if p.suffix == ".md"):
        prose = re.sub(r"\]\([^)\n]+\)", "]", source.read_text(encoding="utf-8"))
        for token in re.findall(r"[\w{}./~-]+\.md\b", prose):
            if token.startswith(".AI/"):
                continue
            if token.rsplit("/", 1)[-1] not in ("README.md", "SKILL.md"):
                errors.append(f"Project docs are HTML, not Markdown: {source.relative_to(ROOT)} names {token}")
    if SKILL / "assets/document.html" not in visited:
        errors.append("Missing or unlinked HTML doc template: assets/document.html")

    for relative in ("agents/openai.yaml",):
        if not (SKILL / relative).is_file():
            errors.append(f"Missing skill metadata: {relative}")
    for command in ("my-dev-team", "my-po", "my-design-lead", "my-tech-lead", "my-qa-lead"):
        if not (ROOT / "commands" / f"{command}.md").is_file():
            errors.append(f"Missing command wrapper: commands/{command}.md")
    # Role skills are the commands on hosts where a skill is called by name.
    for skill in ("my-po", "my-design-lead", "my-tech-lead", "my-qa-lead"):
        role_entry = ROOT / "skills" / skill / "SKILL.md"
        if not role_entry.is_file():
            errors.append(f"Missing role skill: skills/{skill}/SKILL.md")
            continue
        role_text = role_entry.read_text(encoding="utf-8")
        if f"\nname: {skill}\n" not in role_text or "\ndescription: " not in role_text:
            errors.append(f"Role skill needs matching name and a description: skills/{skill}/SKILL.md")
        if "](../my-dev-team/SKILL.md)" not in role_text:
            errors.append(f"Role skill must link the team skill: skills/{skill}/SKILL.md")
    for relative in ("install.sh", "check.sh"):
        script = ROOT / relative
        if not script.is_file():
            errors.append(f"Missing script: {relative}")
        elif not script.stat().st_mode & 0o111:
            errors.append(f"Script must be executable: {relative}")
    return errors


if __name__ == "__main__":
    problems = validate()
    for problem in problems:
        print(f"FAIL: {problem}", file=sys.stderr)
    if not problems:
        print("Bundle valid: skill identity, ten role guides, reachable resources, local links, and HTML doc rule.")
    sys.exit(bool(problems))
