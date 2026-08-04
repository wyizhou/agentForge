# Remove generated verifier wrappers

## Scope

Change agentForge so the Harness option generates repository guidance and
documentation only. Target projects must not receive agentForge-owned
`harness/verify.sh` or `harness/verify.ps1` wrappers.

## Decisions

- Keep this repository's own `harness/` directory as an internal development
  test entry point; it is not part of the generated payload.
- Generated `AGENTS.md` or `CLAUDE.md` must point agents to the Harness
  documents and require direct execution of the project's native test, lint,
  type, build, security, and CI commands when applicable.
- Empty projects record no invented commands. The first task that introduces
  executable code must establish the smallest appropriate test and lint setup
  and document the real commands.
- Remove all generated-verifier payloads, manifest entries, launcher behavior,
  documentation promises, and product tests.

## Progress

- [x] Audit current verifier payload and references.
- [x] Update payload, launchers, repository architecture, and documentation.
- [x] Update POSIX, PowerShell, and payload contract tests.
- [x] Run local and cross-platform verification.
- [ ] Publish the completed version.

## Acceptance evidence

- A Harness-enabled generation contains `docs/harness/` but no generated
  `harness/` directory.
- Both launchers generate equivalent file sets.
- Generated canonical guides require reading the Harness contract and running
  project-native checks directly.
- Empty, existing-file, Git, Skill, POSIX, and PowerShell scenarios pass the
  repository's internal test suite.
- The portable PowerShell suite proves byte-for-byte parity with the POSIX
  launcher across all primary-guide, Harness, and Skill option combinations.
- A real Codex run from an empty generated project added a POSIX command,
  focused tests, syntax linting, and project-native command documentation. All
  documented checks passed, and no verifier wrapper was created.

## Risks

- Documentation-only enforcement cannot itself guarantee that an agent follows
  the contract; the generated guide must make the delivery requirements
  explicit and require concrete command evidence in completion reports.
- Existing v0.2 projects are not mutated automatically. The README documents a
  safe manual migration that preserves custom checks before old wrappers are
  removed.
