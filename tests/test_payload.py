#!/usr/bin/env python3
from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PAYLOAD = ROOT / "payload"


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def main() -> None:
    manifest = PAYLOAD / "harness" / "manifest.tsv"
    entries: list[tuple[str, str]] = []
    for line_number, line in enumerate(manifest.read_text().splitlines(), 1):
        if not line:
            continue
        parts = line.split("\t")
        require(len(parts) == 2, f"invalid manifest line {line_number}: {line!r}")
        source, destination = parts
        require((PAYLOAD / "harness" / source).is_file(), f"missing payload source: {source}")
        require(not destination.startswith("/"), f"absolute destination: {destination}")
        require(".." not in Path(destination).parts, f"unsafe destination: {destination}")
        entries.append((source, destination))

    destinations = [destination for _, destination in entries]
    require(len(destinations) == len(set(destinations)), "duplicate Harness destinations")
    required = {
        "ARCHITECTURE.md",
        "docs/README.md",
        "docs/harness/DELIVERY_RULES.md",
        "docs/harness/COMMANDS.md",
        "docs/harness/CHECKS.md",
        "harness/verify.sh",
        "harness/verify.ps1",
    }
    require(required.issubset(destinations), "Harness manifest is incomplete")

    agents = (PAYLOAD / "guides" / "AGENTS.harness.md").read_text()
    claude = (PAYLOAD / "guides" / "CLAUDE.harness.md").read_text()
    require("{{PROJECT_NAME}}" in agents and "{{PROJECT_NAME}}" in claude, "guide placeholder missing")
    for phrase in ("Progressive Harness", "DELIVERY_RULES.md", "regression test", "SKILLS.md", "verify.sh", "verify.ps1"):
        require(phrase in agents, f"AGENTS Harness guide missing {phrase}")
        require(phrase in claude, f"CLAUDE Harness guide missing {phrase}")
    require("sh ./harness/verify.sh" in agents and "sh ./harness/verify.sh" in claude, "portable POSIX verification command missing")

    delivery_rules = (PAYLOAD / "harness" / "docs" / "harness" / "DELIVERY_RULES.md").read_text()
    for phrase in ("Every new or changed behavior", "regression test", "test runner and linter", "Before delivery", "Do not delete tests"):
        require(phrase in delivery_rules, f"delivery rules missing {phrase}")

    require(not (PAYLOAD / "harness" / "docs" / "harness" / "BOOTSTRAP_PROMPT.md").exists(), "legacy bootstrap prompt remains")
    require(not (PAYLOAD / "harness" / "harness" / "STATUS").exists(), "legacy Harness status remains")
    for verifier in ("verify.sh", "verify.ps1"):
        text = (PAYLOAD / "harness" / "harness" / verifier).read_text()
        require("AGENTFORGE:PROJECT_CHECKS:START" in text, f"{verifier} lacks project-check marker")
        require("No project-specific checks are registered yet" in text, f"{verifier} lacks progressive empty-project notice")
        require("Project code or a technology manifest exists" in text, f"{verifier} lacks unregistered-code gate")

    skill_files = [line for line in (PAYLOAD / "orchestrate-files.txt").read_text().splitlines() if line]
    require("SKILL.md" in skill_files, "Skill manifest missing SKILL.md")
    require("references/runtime-codex.md" in skill_files, "Skill manifest missing Codex adapter")
    require("references/runtime-claude-code.md" in skill_files, "Skill manifest missing Claude adapter")

    shell = (ROOT / "agentforge.sh").read_text()
    powershell = (ROOT / "agentforge.ps1").read_text()
    require('AGENTFORGE_VERSION="0.2.0"' in shell, "POSIX launcher version mismatch")
    require('$AgentForgeVersion = "0.2.0"' in powershell, "PowerShell launcher version mismatch")
    for token in ("AGENTFORGE_SKILL_SOURCE_DIR", ".agents/skills/orchestrate-parallel-work", ".claude/skills/orchestrate-parallel-work"):
        require(token in shell, f"POSIX launcher missing {token}")
        require(token in powershell, f"PowerShell launcher missing {token}")
    require(len(re.findall(r"prompt_line \"", shell)) == 4, "POSIX launcher must expose exactly four question sites")
    require("Read-Host" in powershell, "PowerShell launcher has no interactive prompts")

    print(f"payload contract passed ({len(entries)} Harness files)")


if __name__ == "__main__":
    main()
