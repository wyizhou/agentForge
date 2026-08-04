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
        "docs/harness/README.md",
        "docs/harness/DELIVERY_RULES.md",
        "docs/harness/COMMANDS.md",
        "docs/harness/CHECKS.md",
    }
    require(required.issubset(destinations), "Harness manifest is incomplete")
    require(not any(destination.startswith("harness/") for destination in destinations), "Harness manifest still generates runtime scripts")

    agents = (PAYLOAD / "guides" / "AGENTS.harness.md").read_text()
    claude = (PAYLOAD / "guides" / "CLAUDE.harness.md").read_text()
    agents_bridge = (PAYLOAD / "guides" / "AGENTS.bridge.md").read_text()
    claude_bridge = (PAYLOAD / "guides" / "CLAUDE.bridge.md").read_text()
    require("{{PROJECT_NAME}}" in agents and "{{PROJECT_NAME}}" in claude, "guide placeholder missing")
    for phrase in (
        "Progressive Harness",
        "docs/harness/DELIVERY_RULES.md",
        "docs/harness/COMMANDS.md",
        "docs/harness/CHECKS.md",
        "regression test",
        "test runner and linter",
        "project-native",
        "SKILLS.md",
    ):
        require(phrase in agents, f"AGENTS Harness guide missing {phrase}")
        require(phrase in claude, f"CLAUDE Harness guide missing {phrase}")
    for verifier in ("verify.sh", "verify.ps1"):
        require(verifier not in agents, f"AGENTS Harness guide still references {verifier}")
        require(verifier not in claude, f"CLAUDE Harness guide still references {verifier}")
    for bridge_name, bridge in (("AGENTS", agents_bridge), ("CLAUDE", claude_bridge)):
        for path in (
            "docs/harness/DELIVERY_RULES.md",
            "docs/harness/COMMANDS.md",
            "docs/harness/CHECKS.md",
        ):
            require(path in bridge, f"{bridge_name} compatibility guide missing conditional Harness path: {path}")

    delivery_rules = (PAYLOAD / "harness" / "docs" / "harness" / "DELIVERY_RULES.md").read_text()
    for phrase in (
        "Every new or changed behavior",
        "regression test",
        "test runner and linter",
        "Before delivery",
        "Do not delete tests",
        "project-native check",
        "does not generate or require a unified",
    ):
        require(phrase in delivery_rules, f"delivery rules missing {phrase}")

    require(not (PAYLOAD / "harness" / "docs" / "harness" / "BOOTSTRAP_PROMPT.md").exists(), "legacy bootstrap prompt remains")
    for verifier in ("verify.sh", "verify.ps1"):
        require(not (PAYLOAD / "harness" / "harness" / verifier).exists(), f"generated verifier payload remains: {verifier}")
        require(verifier not in delivery_rules, f"delivery rules still reference {verifier}")

    skill_files = [line for line in (PAYLOAD / "orchestrate-files.txt").read_text().splitlines() if line]
    require("SKILL.md" in skill_files, "Skill manifest missing SKILL.md")
    require("references/runtime-codex.md" in skill_files, "Skill manifest missing Codex adapter")
    require("references/runtime-claude-code.md" in skill_files, "Skill manifest missing Claude adapter")

    shell = (ROOT / "agentforge.sh").read_text()
    powershell = (ROOT / "agentforge.ps1").read_text()
    require('AGENTFORGE_VERSION="0.3.0"' in shell, "POSIX launcher version mismatch")
    require('$AgentForgeVersion = "0.3.0"' in powershell, "PowerShell launcher version mismatch")
    for token in ("AGENTFORGE_SKILL_SOURCE_DIR", ".agents/skills/orchestrate-parallel-work", ".claude/skills/orchestrate-parallel-work"):
        require(token in shell, f"POSIX launcher missing {token}")
        require(token in powershell, f"PowerShell launcher missing {token}")
    require('fetch_payload "harness/manifest.tsv"' in shell, "POSIX launcher does not consume the shared Harness manifest")
    require('Fetch-Payload "harness/manifest.tsv"' in powershell, "PowerShell launcher does not consume the shared Harness manifest")
    require(len(re.findall(r"prompt_line \"", shell)) == 4, "POSIX launcher must expose exactly four question sites")
    require("Read-Host" in powershell, "PowerShell launcher has no interactive prompts")

    print(f"payload contract passed ({len(entries)} Harness files)")


if __name__ == "__main__":
    main()
