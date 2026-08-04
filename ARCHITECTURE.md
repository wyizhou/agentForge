# Architecture

agentForge is a dependency-free repository scaffold generator with two native
launchers and one shared payload.

## Components

- `agentforge.sh`: POSIX entry point for macOS and Linux.
- `agentforge.ps1`: Windows PowerShell entry point.
- `payload/`: versioned files copied into target projects.
- `tests/`: behavior and payload contract tests.
- `harness/`: this repository's own verification entry points.

## Runtime flow

1. Resolve the target directory and source payload.
2. Inspect the environment and existing Git state.
3. Ask at most four questions, unless equivalent flags were supplied.
4. Build a complete write plan and stop if any target path conflicts.
5. Copy the selected instruction and Harness payload.
6. Optionally download the pinned `orchestrate-parallel-work` payload into both
   Codex and Claude Code project skill locations.
7. Optionally initialize Git when the target is not already in a work tree.
8. Confirm that the progressive Harness is active and development can begin.

## Safety properties

- Preflight happens before writes.
- Existing files are never replaced in v0.2.
- Network payloads use HTTPS and an exact upstream commit after resolution.
- A generated Harness begins with enforceable delivery rules and lightweight
  structural verification, then gains project-specific checks as they become
  applicable.
