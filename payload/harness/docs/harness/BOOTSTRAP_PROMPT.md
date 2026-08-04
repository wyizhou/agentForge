# Bootstrap the project Harness

Give the prompt below to the primary AI coding agent from the repository root.

```text
Complete this repository's agent Harness before normal feature development.

First read the complete canonical project instruction file, `harness/STATUS`,
`docs/README.md`, `ARCHITECTURE.md`, `SKILLS.md`, and every file under
`docs/harness/` and `docs/quality/`. Inspect the actual repository, Git state,
source code, dependency manifests, existing scripts, tests, CI configuration,
and deployment or infrastructure files. Do not infer a technology stack from
placeholders and do not overwrite unrelated user work.

Establish an evidence-backed system map in `ARCHITECTURE.md`. Complete the
project-specific quality, reliability, and security contracts. Update the
documentation indexes and record important design decisions. Remove every
`Pending AI analysis` placeholder only when repository evidence supports its
replacement.

Configure deterministic formatting, linting, type checking where applicable,
unit and integration tests, builds, dependency or security checks, and any
architecture-boundary checks the project needs. Reuse sound existing tooling
instead of replacing it without cause. Make failures actionable. Document the
authoritative commands in `docs/harness/COMMANDS.md` and the enforcement map in
`docs/harness/CHECKS.md`.

Replace the fail-closed placeholder sections in `harness/verify.sh` and
`harness/verify.ps1` with equivalent project checks. Both entry points must be
usable on their supported operating systems; if a project tool is intentionally
unsupported on one system, fail with an explicit explanation or document and
implement a safe equivalent. Configure the repository's actual CI provider to
run the unified verification entry point on relevant changes.

Run every configured check and fix failures without deleting tests, suppressing
meaningful diagnostics, weakening thresholds, or changing expected behavior
merely to obtain a pass. Keep `harness/STATUS` as `INCOMPLETE` until the unified
verification succeeds and no required placeholder remains. Then change it to
`READY`, rerun verification from a clean command invocation, and report:

- the detected technology stack and evidence;
- files added or changed;
- checks configured and their exact results;
- CI integration;
- any intentionally unsupported checks and why;
- remaining risks or decisions that require a human.
```
