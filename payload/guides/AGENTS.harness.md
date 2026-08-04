# {{PROJECT_NAME}} project instructions

## Scope

This file is the repository-level map for AI coding agents. Higher-priority
system and user instructions take precedence. Keep detailed project knowledge
in `docs/`; do not turn this file into an encyclopedia.

## Start every task

1. Inspect the working directory and Git status.
2. Read `harness/STATUS`.
3. Read `docs/README.md` and the documents relevant to the task.
4. Check `docs/exec-plans/active/` for an existing plan.
5. Read `SKILLS.md` and load a Skill only when its trigger matches.

## Harness gate

- If `harness/STATUS` is `INCOMPLETE`, read and execute the instructions in
  `docs/harness/BOOTSTRAP_PROMPT.md` before normal feature development.
- Inspect the real codebase and configure formatting, linting, type checks,
  tests, builds, security checks, and CI for the actual technology stack.
- Run every configured check. Change the status to `READY` only after the full
  verification entry point succeeds.
- Never claim that an incomplete Harness is ready, and never weaken a check
  merely to make it pass.

## Repository knowledge map

- `ARCHITECTURE.md`: system boundaries and dependency direction.
- `docs/design-docs/`: design decisions and engineering principles.
- `docs/product-specs/`: product behavior and acceptance criteria.
- `docs/exec-plans/`: plans for complex work and technical debt.
- `docs/quality/`: quality, reliability, and security requirements.
- `docs/harness/COMMANDS.md`: authoritative development and validation commands.

## Planning and implementation

- Handle small, single-scope tasks directly.
- Create or update an execution plan for complex, cross-module, or long-running
  work. Record progress, decisions, evidence, and unresolved risks.
- Understand existing behavior and boundaries before editing.
- Preserve unrelated user changes. Do not guess interfaces, schemas, or
  dependencies when repository evidence can resolve them.
- Add or update tests for behavior changes and documentation for architecture or
  product changes.
- Prefer existing abstractions over parallel implementations.

## Skills

- `SKILLS.md` is the project Skill catalog.
- Codex discovers project Skills under `.agents/skills/`.
- Claude Code discovers project Skills under `.claude/skills/`.
- Use `orchestrate-parallel-work` only for genuinely multi-part work with
  independently verifiable workstreams; do not parallelize simple tasks.

## Verification

Before delivery, run the repository's unified verification entry point:

- macOS/Linux: `sh ./harness/verify.sh`
- Windows: `powershell -ExecutionPolicy Bypass -File .\harness\verify.ps1`

Report the checks run, results, skipped checks and reasons, and remaining risks.
Never delete tests or reduce enforcement to obtain a passing result.

## Git and external effects

- Preserve uncommitted work and avoid destructive Git operations.
- Do not commit, push, merge, deploy, or create remote resources unless the user
  requests that external effect.
- Isolate concurrent work with branches or worktrees and do not assign two
  workers to the same write scope.

## Completion report

Summarize completed work, important files, validation evidence, documentation
updates, and any incomplete items or risks.
