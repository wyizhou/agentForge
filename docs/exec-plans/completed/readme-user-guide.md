# Reframe README as the user guide

## Scope

Make the root README a Chinese, outcome-first introduction for people using
agentForge. Explain why to use it, how to run it, what the questions mean, what
files and working behavior it creates, and how AI agents will evolve the
project. Move implementation and maintainer details into linked documents.

## Decisions

- Adapt the provided AI inspection into stable product behavior; do not copy
  transient facts such as a particular repository having no commits or exactly
  one installed Skill.
- Keep the three copyable platform commands and explain the four questions in
  the root README.
- Describe Harness requirements as conditional, progressive rules rather than
  claiming an empty project already has a technology stack or quality tools.
- Keep user-visible safety boundaries in the README; place detailed CLI flags,
  implementation, migration, and maintainer verification elsewhere.
- State and link the existing MIT license.

## Progress

- [x] Audit the current README and generated behavioral contract.
- [x] Rewrite the root README.
- [x] Add and link supporting technical documents.
- [x] Verify commands, links, formatting, and repository tests.
- [x] Publish the documentation update.

## Acceptance evidence

- A new user can identify the use case, run the correct command, understand all
  questions, and know what changes after generation from the root README alone.
- Behavioral claims match the generated guides and Harness delivery rules.
- Technical details remain discoverable through working relative links.
- The README states that the project uses the MIT license and links `LICENSE`.
- Documentation contract tests check the user-facing sections, exact terminal
  prompts, release URLs, local links, Windows safety flags, and MIT boundary.
- POSIX and PowerShell README command blocks pass syntax parsing.
- The full repository verification suite passes with the portable PowerShell
  runtime, including POSIX/PowerShell generator parity.
- GitHub Actions run `30887495037` passed on Ubuntu and native Windows for the
  published default-branch documentation update.

## Risks

- Project instructions guide AI behavior but do not provide an operating-system
  sandbox. The README distinguishes documentation rules from future mechanical
  CI and branch-protection gates.
- This is a post-v0.3.0 documentation update on the default branch; the existing
  v0.3.0 source archive retains the README that was present at release time.
