# agentForge

agentForge 是一个面向 AI 编程项目的零依赖命令行脚手架。它通过最多四个问题，引导你为 Codex、Claude Code 等 AI 编程工具建立清晰、可执行、可持续维护的项目基础设施。

agentForge 可以生成：

- 以 `AGENTS.md` 或 `CLAUDE.md` 为主入口的项目级 AI 指令；
- 面向不同 AI 工具的兼容入口；
- 参考 OpenAI Harness Engineering 思路设计的严格 Harness；
- 供 AI 分析真实技术栈并补全工程约束的启动提示词；
- 项目级 `SKILLS.md` 与可选的 `orchestrate-parallel-work` Skill；
- 必要的架构、产品、执行计划、质量、安全和可靠性文档目录。

支持以下环境：

- Windows：Windows PowerShell 5.1 或更高版本；
- macOS：系统自带的 POSIX Shell；
- Linux：POSIX Shell，远程安装时需要 `curl` 或 `wget`。

运行 agentForge 不需要 Node.js、Python、`jq` 或任何包管理器。

## 快速开始

请在准备搭建脚手架的项目目录中运行以下命令。

### macOS 和 Linux

使用 `curl`：

```sh
agentforge_tmp=$(mktemp) && \
  curl -fsSL https://raw.githubusercontent.com/wyizhou/agentForge/v0.1.0/agentforge.sh -o "$agentforge_tmp" && \
  sh "$agentforge_tmp"; agentforge_status=$?; rm -f "$agentforge_tmp"; (exit "$agentforge_status")
```

如果系统没有 `curl`，但安装了 `wget`：

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

## 交互流程

agentForge 最多提出四个问题：

1. 选择以 `AGENTS.md` 还是 `CLAUDE.md` 作为项目的主要 AI 指令文件；
2. 是否生成严格 Harness；
3. 是否安装 `orchestrate-parallel-work`；
4. 当项目尚未处于 Git 工作区时，是否初始化本地 Git 仓库。

未被选为主入口的指令文件仍会生成，但只作为轻量兼容入口，引导对应的 AI 工具读取主指令文件。

## 严格 Harness

启用 Harness 后，项目将获得以下基础结构：

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

新生成的 Harness 会有意保持为 `INCOMPLETE`，验证脚本也会采用失败关闭策略。这样可以避免尚未配置的空壳检查被误认为有效的工程保障。

生成完成后，请让项目的主要 AI 编程工具执行：

```text
docs/harness/BOOTSTRAP_PROMPT.md
```

AI 必须先检查项目的真实技术栈，再补充格式化、代码检查、类型检查、测试、构建、安全检查和 CI 命令。只有完整验证通过后，才能把 `harness/STATUS` 改为 `READY`。

这种两阶段设计既不会预先猜测项目技术栈，又能确保复杂项目从开发初期就具有可执行的工程约束。

## 项目级 Skill

选择安装 Skill 后，agentForge 会解析
[`wyizhou/orchestrateParallelWork-skill`](https://github.com/wyizhou/orchestrateParallelWork-skill)
当前主分支的精确 Commit SHA，然后下载对应版本的文件。下载内容不会在安装过程中执行。

Skill 会同时安装到：

```text
.agents/skills/orchestrate-parallel-work/
.claude/skills/orchestrate-parallel-work/
```

两份内容保持一致，分别供 Codex 和 Claude Code 使用。每份 Skill 都包含 `ORIGIN.md`，记录来源仓库、精确 Commit SHA 和 agentForge 版本。生成的 `SKILLS.md` 会说明 Skill 的触发条件和按需加载方式。

## 非交互式使用

自动化脚本或测试环境可以直接通过参数完成配置。

POSIX：

```sh
sh agentforge.sh \
  --target ./my-project \
  --primary agents \
  --harness yes \
  --skill yes \
  --git yes
```

PowerShell：

```powershell
.\agentforge.ps1 `
  -Target .\my-project `
  -Primary agents `
  -Harness yes `
  -Skill yes `
  -Git yes
```

## 现有文件与重复执行

agentForge 0.1 不会覆盖任何已经存在的目标路径。

生成器会先下载并暂存本次选择所需的全部文件，然后统一检查目标路径、父目录、符号链接和 Windows 重解析点。发现冲突时会在写入项目前停止，并列出冲突路径。

如果目标目录已经位于 Git 工作区内，agentForge 会保留现有仓库并跳过 `git init`，避免创建嵌套仓库。

## 开发与验证

克隆仓库后，可以运行：

```sh
./harness/verify.sh
```

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\harness\verify.ps1
```

验证套件覆盖：

- Payload 完整性；
- POSIX 与 PowerShell 生成流程；
- Harness 失败关闭行为；
- 空格及特殊目录名；
- 文件、父目录和符号链接冲突；
- Git 初始化与现有工作区识别；
- 固定 Commit SHA 的 Skill 安装；
- 公开版本的远程启动流程。

GitHub Actions 会在 Ubuntu 和 Windows 环境中执行验证。版本标签还会额外验证公开 GitHub Raw 地址上的 POSIX 与 PowerShell 启动器。

## 设计依据

Harness 结构参考 OpenAI 的
[Harness Engineering](https://openai.com/zh-Hans-CN/index/harness-engineering/)
实践：保持主要 AI 指令简洁，把版本化项目文档作为事实来源，按需加载上下文，显式编码架构约束，并提供可执行的反馈循环。

## 许可证

[MIT](LICENSE)
