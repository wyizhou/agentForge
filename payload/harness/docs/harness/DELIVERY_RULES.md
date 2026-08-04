# Progressive Harness delivery rules

These rules apply from the first task. The Harness grows with the repository;
there is no separate bootstrap phase and no requirement to invent tools before
a technology stack exists.

## Mandatory rules

1. Every new or changed behavior must include corresponding automated tests.
2. Every bug fix must include a regression test that fails without the fix.
3. When executable code is first introduced, configure the smallest suitable
   test runner and linter in the same task.
   If code already exists when agentForge is installed, treat the first task
   under this Harness as the adoption point and establish those checks before
   delivering further code changes.
4. Once a check is applicable and configured, it remains a required delivery
   gate unless the project deliberately replaces it with documented evidence.
5. Add formatting, type checking, builds, integration tests, security checks,
   and CI when the project's technology and risks make them applicable.
6. Before delivery, run every currently applicable check and fix failures.
7. Do not delete tests, weaken rules, suppress meaningful diagnostics, or skip
   checks merely to obtain a passing result.
8. Record authoritative commands in `COMMANDS.md` and their enforcement in
   `CHECKS.md` whenever tooling changes.
9. Update architecture, product, quality, reliability, and security documents
   as relevant decisions become known; do not guess facts for an empty project.
10. The completion report must list commands run, results, intentionally
    inapplicable checks with reasons, and remaining risks.

## Proportional adoption

| Project stage | Minimum expected Harness evolution |
| --- | --- |
| Empty repository | Repository guidance and delivery contract only |
| First executable code | Test runner, focused tests, and linter |
| Typed code | Type checking |
| Build or package output | Reproducible build check |
| External integration | Integration tests and failure handling |
| Shared remote development | CI running the applicable checks |
| Sensitive data or trust boundaries | Security controls and checks |

The table is a floor, not a reason to defer checks that are already applicable.
