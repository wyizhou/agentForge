# agentForge project instructions

## Scope

This repository builds the cross-platform `agentForge` scaffold generator.
Keep runtime code dependency-free: POSIX environments use `sh`; Windows uses
Windows PowerShell 5.1 or newer.

## Start here

1. Read `ARCHITECTURE.md` and `docs/README.md`.
2. Inspect `harness/STATUS`; normal development requires `READY`.
3. Preserve unrelated user changes and avoid destructive Git commands.
4. For complex work, maintain a plan under `docs/exec-plans/active/`.

## Implementation rules

- Keep `agentforge.sh` and `agentforge.ps1` behaviorally equivalent.
- Put generated content in `payload/`; do not duplicate large templates inside
  the launchers.
- Runtime behavior must not require Node.js, Python, `jq`, or a package manager.
- Interactive mode asks no more than four questions.
- Non-interactive flags must remain available for tests and automation.
- Existing target files must never be overwritten silently.
- Skill downloads must be limited to `orchestrate-parallel-work` and record the
  resolved upstream commit.

## Verification

Run `./harness/verify.sh` before delivery. On Windows, run
`powershell -ExecutionPolicy Bypass -File .\harness\verify.ps1`.

Report the checks run, results, skipped checks, and remaining risks.
