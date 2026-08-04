# agentForge

agentForge 是一个面向 AI 编程项目的零依赖命令行脚手架。它通过最多四个问题，引导你为 Codex、Claude Code 等 AI 编程工具建立清晰、可执行、可持续维护的项目基础设施。

agentForge 可以生成：

- 以 `AGENTS.md` 或 `CLAUDE.md` 为主入口的项目级 AI 指令；
- 面向不同 AI 工具的兼容入口；
- 参考 OpenAI Harness Engineering 思路设计的渐进式 Harness；
- 要求测试、linter 与项目同步演进的强制交付规范；
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
  curl -fsSL https://raw.githubusercontent.com/wyizhou/agentForge/v0.2.0/agentforge.sh -o "$agentforge_tmp" && \
  sh "$agentforge_tmp"; agentforge_status=$?; rm -f "$agentforge_tmp"; (exit "$agentforge_status")
```

如果系统没有 `curl`，但安装了 `wget`：

```sh
agentforge_tmp=$(mktemp) && \
  wget -q https://raw.githubusercontent.com/wyizhou/agentForge/v0.2.0/agentforge.sh -O "$agentforge_tmp" && \
  sh "$agentforge_tmp"; agentforge_status=$?; rm -f "$agentforge_tmp"; (exit "$agentforge_status")
```

### Windows PowerShell

```powershell
$AgentForge = Join-Path ([IO.Path]::GetTempPath()) "agentforge.ps1"
Invoke-WebRequest https://raw.githubusercontent.com/wyizhou/agentForge/v0.2.0/agentforge.ps1 -OutFile $AgentForge
& $AgentForge
$AgentForgeStatus = $LASTEXITCODE
Remove-Item $AgentForge -Force
if ($AgentForgeStatus) { exit $AgentForgeStatus }
```

## 交互流程

agentForge 最多提出四个问题：

1. 选择以 `AGENTS.md` 还是 `CLAUDE.md` 作为项目的主要 AI 指令文件；
2. 是否生成渐进式 Harness；
3. 是否安装 `orchestrate-parallel-work`；
4. 当项目尚未处于 Git 工作区时，是否初始化本地 Git 仓库。

未被选为主入口的指令文件仍会生成，但只作为轻量兼容入口，引导对应的 AI 工具读取主指令文件。

## 渐进式 Harness

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
├── verify.sh
└── verify.ps1
```

生成完成后即可直接开始开发，不需要复制额外提示词，也不需要执行二次 Bootstrap。主要 AI 指令会要求编程代理完整读取：

```text
docs/harness/DELIVERY_RULES.md
```

Harness 会与项目逐步演进：空目录只包含稳定的交付规范；首次引入可执行代码时，AI 必须在同一任务中加入适合当前规模的测试运行器、测试和 linter；类型检查、构建、集成测试、安全检查与 CI 则在变得适用时加入。任何已经适用并配置的检查，都必须在后续交付前通过。

这种设计不会为空项目猜测技术栈，也不会要求一次性搭建与当前阶段无关的工具。同时，新增功能必须带有对应测试，修复缺陷必须带有回归测试，AI 不能通过删除测试、降低规则或跳过失败来宣布任务完成。

初始验证脚本会检查 Harness 文档结构，并明确提示尚未注册项目级检查。空项目可以正常通过；一旦检测到源码或技术栈清单，而 AI 尚未接入项目级检查，验证就会失败。AI 必须在引入实际代码和工具时同步扩展验证脚本、`COMMANDS.md` 与 `CHECKS.md`。如果 agentForge 被用于已有源码的项目，则应在下一次代码交付前完成这项接入。

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

agentForge 0.2 不会覆盖任何已经存在的目标路径。

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
- 空项目的渐进式 Harness 行为与强制交付规范；
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
