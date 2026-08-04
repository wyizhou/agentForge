# Project skills

## orchestrate-parallel-work

Use this Skill for genuinely multi-part work involving independently verifiable
workstreams, dependency waves, isolated writes, staged integration, or an
independent final validation. Do not use it for small single-output tasks.

- Codex: `.agents/skills/orchestrate-parallel-work/SKILL.md`
- Claude Code: `.claude/skills/orchestrate-parallel-work/SKILL.md`
- Source: `wyizhou/orchestrateParallelWork-skill`
- Exact upstream commit: see `ORIGIN.md` in either installed copy.

The two installed directories must contain identical upstream payloads. Runtime
adapters inside the Skill select Codex, Claude Code, or safe generic behavior.
