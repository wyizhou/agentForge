# agentForge

agentForge is a dependency-free command-line scaffold for AI-first software
projects. It creates durable project guidance for Codex and Claude Code, an
optional strict Harness inspired by OpenAI's Harness Engineering practices, and
an optional project-local `orchestrate-parallel-work` Skill.

The generator asks at most four questions and supports:

- Windows through Windows PowerShell 5.1 or newer;
- macOS through the system POSIX shell;
- Linux through a POSIX shell plus `curl` or `wget` for remote installation.

Runtime use does not require Node.js, Python, `jq`, or a package manager.

## Quick start

### macOS and Linux

```sh
agentforge_tmp=$(mktemp) && \
  curl -fsSL https://raw.githubusercontent.com/wyizhou/agentForge/v0.1.0/agentforge.sh -o "$agentforge_tmp" && \
  sh "$agentforge_tmp"; agentforge_status=$?; rm -f "$agentforge_tmp"; (exit "$agentforge_status")
```

If `curl` is unavailable but `wget` exists:

```sh
agentforge_tmp=$(mktemp) && \
  wget -q https://raw.githubusercontent.com/wyizhou/agentForge/v0.1.0/agentforge.sh -O "$agentforge_tmp" && \
  sh "$agentforge_tmp"; agentforge_status=$?; rm -f "$agentforge_tmp"; (exit "$agentforge_status")
```

### Windows PowerShell

```powershell
$AgentForge = Join-Path ([IO.Path]::GetTempPath()) "agentforge.ps1"
Invoke-WebRequest https://raw.githubusercontent.com/wyizhou/agentForge/v0.1.0/agentforge.ps1 -OutFile $AgentForge
& $AgentForge
$AgentForgeStatus = $LASTEXITCODE
Remove-Item $AgentForge -Force
if ($AgentForgeStatus) { exit $AgentForgeStatus }
```

Run the command from the project directory you want to scaffold. agentForge
asks:

1. whether `AGENTS.md` or `CLAUDE.md` is canonical;
2. whether to generate the strict Harness;
3. whether to install `orchestrate-parallel-work`;
4. whether to initialize Git, only when the directory is not already in a Git
   work tree.

The non-canonical guide is also created as a small compatibility entry point.

## Generated strict Harness

When enabled, the generated project starts with this shape:

```text
AGENTS.md / CLAUDE.md
ARCHITECTURE.md
SKILLS.md
docs/
├── design-docs/
├── product-specs/
├── exec-plans/
├── quality/
└── harness/
harness/
├── STATUS
├── verify.sh
└── verify.ps1
```

The Harness intentionally starts as `INCOMPLETE`. Its verification scripts fail
closed and point to `docs/harness/BOOTSTRAP_PROMPT.md`. Give that prompt to the
project's primary AI agent. The agent must inspect the real technology stack,
configure formatting, linting, types, tests, builds, security checks and CI,
then run the complete verification before changing the status to `READY`.

This two-stage design avoids guessing a stack while still preventing empty
placeholders from being mistaken for enforceable project infrastructure.

## Project-local Skill

When selected, agentForge resolves the current upstream commit of
[`wyizhou/orchestrateParallelWork-skill`](https://github.com/wyizhou/orchestrateParallelWork-skill),
downloads the exact payload without executing it, and installs identical copies
to:

```text
.agents/skills/orchestrate-parallel-work/
.claude/skills/orchestrate-parallel-work/
```

Each copy includes `ORIGIN.md` with the source repository, exact commit, and
agentForge version. The generated `SKILLS.md` documents trigger conditions and
native discovery paths.

## Non-interactive use

POSIX:

```sh
sh agentforge.sh \
  --target ./my-project \
  --primary agents \
  --harness yes \
  --skill yes \
  --git yes
```

PowerShell:

```powershell
.\agentforge.ps1 `
  -Target .\my-project `
  -Primary agents `
  -Harness yes `
  -Skill yes `
  -Git yes
```

## Existing files and reruns

Version 0.1 never overwrites an existing target path. agentForge downloads and
stages the complete selected payload first, checks every destination, and stops
before writing when it finds a conflict. Existing Git repositories are detected
and left intact.

## Development and verification

From a clone of this repository:

```sh
./harness/verify.sh
```

The verification suite checks the payload contract, POSIX generation,
fail-closed Harness behavior, paths containing spaces, conflict atomicity, Git
initialization, and offline Skill installation. GitHub Actions runs POSIX and
PowerShell jobs.

## Design source

The Harness structure follows the principles described in OpenAI's
[Harness Engineering](https://openai.com/zh-Hans-CN/index/harness-engineering/):
keep the main agent guide short, treat versioned repository documents as the
system of record, use progressive disclosure, encode architectural constraints,
and create executable feedback loops.

## License

[MIT](LICENSE)
