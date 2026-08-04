# agentForge

agentForge 是一个跨平台的 AI 编程项目脚手架生成器。运行一次并完成最多四类配置选择，即可在当前项目中落地 `AGENTS.md`、`CLAUDE.md`、可选的渐进式 Harness 文档和项目级 Skill。

生成完成后不需要执行二次 Bootstrap，也不需要让 AI 先猜测技术栈。你可以直接提交第一个真实开发任务，项目中的指令与文档会引导 Codex、Claude Code 等 AI 编程工具按统一的工程规则工作。

## agentForge 用来做什么

Vibe Coding 真正进入复杂项目后，难点通常不再是“生成第一段代码”，而是让 AI 长期记住并执行这些约定：

- 每次任务应该先读取哪些项目事实；
- 什么时候必须编写测试、增加 linter 或建立 CI；
- 复杂工作如何规划、拆分和留下验证证据；
- 哪些架构、产品、质量、安全与可靠性决策需要写回仓库；
- 哪些 Git、部署和远程操作未经允许不能执行。

agentForge 将这些要求写入版本化的项目文件，让 AI 获得稳定的上下文入口。它适合：

- 从空目录开始一个准备长期开发的项目；
- 为已有项目补充 AI 协作规范与工程治理文档；
- 同时兼容 Codex 与 Claude Code；
- 希望测试、linter、类型检查、构建和 CI 随项目逐步建立，而不是在项目后期集中补齐；
- 需要保存执行计划、架构决策、产品规格和交付证据的复杂项目。

agentForge 不替你选择框架，也不生成业务代码。它负责建立“AI 应该如何开发这个项目”的规则和知识骨架。

## 使用步骤

### 第一步：进入目标项目目录

agentForge 默认写入当前目录。这个目录可以是空目录，也可以是尚未存在目标脚手架文件的已有项目。

```sh
cd /path/to/your-project
```

Windows PowerShell：

```powershell
Set-Location C:\path\to\your-project
```

如果已经存在 `AGENTS.md`、`CLAUDE.md` 或其他将要生成的路径，agentForge 会停止并列出冲突，不会静默覆盖。

### 第二步：运行对应平台命令

运行启动器不需要 Node.js、Python、`jq` 或包管理器。macOS/Linux 使用系统 POSIX Shell，远程运行需要 `curl` 或 `wget`；Windows 使用 Windows PowerShell 5.1 或更高版本。

#### macOS 和 Linux

使用 `curl`：

```sh
agentforge_tmp=$(mktemp) && \
  curl -fsSL https://raw.githubusercontent.com/wyizhou/agentForge/v0.3.0/agentforge.sh -o "$agentforge_tmp" && \
  sh "$agentforge_tmp"; agentforge_status=$?; rm -f "$agentforge_tmp"; (exit "$agentforge_status")
```

如果没有 `curl`，但安装了 `wget`：

```sh
agentforge_tmp=$(mktemp) && \
  wget -q https://raw.githubusercontent.com/wyizhou/agentForge/v0.3.0/agentforge.sh -O "$agentforge_tmp" && \
  sh "$agentforge_tmp"; agentforge_status=$?; rm -f "$agentforge_tmp"; (exit "$agentforge_status")
```

#### Windows PowerShell

```powershell
$AgentForge = Join-Path ([IO.Path]::GetTempPath()) ("agentforge-{0}.ps1" -f [Guid]::NewGuid().ToString("N"))
$AgentForgeStatus = 1
try {
    Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/wyizhou/agentForge/v0.3.0/agentforge.ps1" -OutFile $AgentForge -ErrorAction Stop
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $AgentForge
    $AgentForgeStatus = $LASTEXITCODE
} finally {
    Remove-Item $AgentForge -Force -ErrorAction SilentlyContinue
}
if ($AgentForgeStatus -ne 0) { exit $AgentForgeStatus }
```

在高安全要求环境中，建议先下载并审阅启动器，再从本地执行。网络与安全边界见 [`docs/implementation.md`](docs/implementation.md)。

### 第三步：完成命令行选择

agentForge 最多涉及四类配置问题。主要指令选择无效时会重新提示，其他无效回答会报错退出；如果使用非交互参数，可以完全不提问；如果已经处于 Git 工作区，Git 初始化问题会自动跳过。

| 终端问题 | 输入 | 结果 | 默认值 |
| --- | --- | --- | --- |
| `Primary AI guide [1=AGENTS.md, 2=CLAUDE.md]` | Codex 或通用工具输入 `1`；Claude Code 输入 `2` | 被选文件保存完整规则，另一个作为兼容入口 | 必须输入 |
| `Generate the progressive Harness documentation scaffold? [Y/n]` | 回车或 `y` 开启；输入 `n` 关闭 | 生成架构、计划、质量和交付规范文档 | `yes` |
| `Install orchestrate-parallel-work for Codex and Claude Code? [Y/n]` | 回车或 `y` 安装；输入 `n` 跳过 | 同时安装 Codex 与 Claude Code 的项目级 Skill，并登记到 `SKILLS.md` | `yes` |
| `Initialize a local Git repository? [Y/n]` | 回车或 `y` 初始化；输入 `n` 跳过 | 仅在 Git 可用且当前不在 Git 工作区时执行本地 `git init` | `yes` |

对于准备开发复杂项目的使用者，推荐开启 Harness 和 Skill，并允许在需要时初始化 Git。主要指令文件则按你最常用的 AI 工具选择。

选择安装 Skill 时，agentForge 会访问 GitHub，从 [`wyizhou/orchestrateParallelWork-skill`](https://github.com/wyizhou/orchestrateParallelWork-skill) 下载 Codex 与 Claude Code 使用的项目文件，固定到安装时解析出的精确 Commit SHA，并记录来源；下载内容不会在安装阶段执行。不希望安装 Skill，或无法访问该 Skill 上游仓库时可以选择 `n`；远程运行 agentForge 本身仍需访问 GitHub Raw。详细机制见 [`docs/implementation.md`](docs/implementation.md)。

### 第四步：直接开始开发

生成完成后，打开 Codex 或 Claude Code，直接描述第一个实际任务即可。例如：

> 实现一个带参数校验的用户注册接口；重复邮箱应返回明确错误，并补充对应测试。

这不是第二阶段初始化提示词。AI 会被项目级指令要求先检查仓库、读取当前适用的项目指令与文档；启用 Harness 时还会读取 Harness 交付规则，再决定当前任务需要哪些实现、测试与工具。

### 第五步：检查交付报告

启用 Harness 后，一次符合完整交付约定的 AI 交付应说明：

- 完成了什么以及修改了哪些关键文件；
- 实际运行了哪些项目命令及其结果；
- 哪些检查当前不适用，以及原因；
- 更新了哪些架构、产品、质量或计划文档；
- 是否仍有未完成项或剩余风险。

## 生成后你会得到什么

`AGENTS.md`、`CLAUDE.md` 和 `SKILLS.md` 始终生成。其余内容取决于你的选择：

```text
AGENTS.md                              # 主指令或兼容入口
CLAUDE.md                              # 主指令或兼容入口
SKILLS.md                              # 项目 Skill 清单与加载说明
ARCHITECTURE.md                        # 选择 Harness 时生成
docs/                                  # 选择 Harness 时生成
├── design-docs/                       # 设计原则与决策
├── product-specs/                     # 产品行为与验收标准
├── exec-plans/                        # 活动计划、已完成计划和技术债
├── quality/                           # 质量、可靠性与安全约束
└── harness/
    ├── README.md                      # Harness 文档地图
    ├── DELIVERY_RULES.md              # 渐进式交付规则
    ├── COMMANDS.md                    # 项目真实可运行的命令
    └── CHECKS.md                      # 约束与执行机制的对应关系
.agents/skills/orchestrate-parallel-work/  # 选择 Skill 时生成
.claude/skills/orchestrate-parallel-work/  # 选择 Skill 时生成
.git/                                  # 选择初始化且当前没有 Git 工作区时生成
```

主指令文件保存完整项目规则；兼容入口会引导另一种 AI 工具读取主指令。Harness 是项目内的文档与工作约定，不是需要再次运行的程序，也不会生成统一的 `harness/verify.sh` 或 `harness/verify.ps1`。

安装 Skill 后，`SKILLS.md` 会记录它的触发条件。主指令只要求 AI 在任务确实包含多个可独立验证的工作流时按需加载，而不是每个任务都强制并行。

## 如果从空目录开始

如果从空目录开始并选择 Harness，刚生成后的正常状态是“治理骨架已经就位，技术事实仍等待项目产生”：

- 没有业务代码、模块、构建系统或外部集成；
- `ARCHITECTURE.md` 不会凭空编造系统架构；
- `COMMANDS.md` 与 `CHECKS.md` 初始不预填虚假的工具和命令；
- 没有复杂任务时，不会为了填满目录而创建虚假的活动执行计划；
- 是否存在项目级 Skill 和本地 Git 仓库，取决于你的选择与当前环境；
- agentForge 不会自动创建提交、远程仓库或推送内容。

这不是初始化不完整。第一个功能引入真实技术栈时，项目指令会要求 AI 在同一个任务中建立适合当前规模的测试、linter 和命令记录。

如果目标原本已有源码，AI 则应从仓库中的真实代码、配置和工具链出发工作，并在下一次代码交付前补齐已经适用的测试与 linter，而不是重新猜测或替换技术栈。

## AI 会朝什么方向工作

以下是生成的项目指令对 AI 的行为要求，不是固定回复模板，也不是操作系统级的强制沙箱。

### 每次任务开始

无论是否启用 Harness，基础指令都会要求 AI 检查仓库和既有改动、理解当前行为、读取 `SKILLS.md`、保护不相关工作，并在修改前确认真实边界。

启用 Harness 后，AI 还会被要求：

1. 检查当前目录和 Git 状态；
2. 完整阅读 `docs/harness/DELIVERY_RULES.md`；
3. 阅读 `docs/README.md` 和与任务相关的文档；
4. 检查 `docs/exec-plans/active/` 中是否已有计划；
5. 阅读 `SKILLS.md`，仅在触发条件匹配时加载 Skill。

下面的完整实施与交付流程描述 Harness 模式。未启用 Harness 时，基础指令仍会要求 AI 保护既有改动、为行为变化维护测试、运行相关项目检查并报告证据，但不会引用不存在的 Harness 文档。

### 实施过程中

- 小而单一的任务直接处理；复杂、跨模块、高风险或长期任务建立并持续更新执行计划；
- 修改前理解已有行为、接口与依赖方向，不覆盖用户的无关改动；
- 新增行为同步更新测试，明确的产品和架构决策同步写入对应文档；
- 有价值但不属于当前范围的问题记录为技术债，不擅自扩大任务；
- 优先扩展已有抽象，避免建立用途重叠的平行实现；
- 只有已经安装 Skill，且任务适合拆成多个独立、可验证的工作流时，才加载并行任务 Skill。

### 交付之前

- 阅读 `COMMANDS.md`，直接运行所有当前适用且已经配置的项目原生命令；
- 修复测试、lint、类型、构建、集成或安全检查中的真实失败；
- 同步更新 `COMMANDS.md` 和 `CHECKS.md` 中已经变化的工具与门禁；
- 报告执行过的命令、结果、跳过项及原因和剩余风险。

## 写入项目指令的渐进式质量门禁

Harness 不会为空项目一次性安装整套工具。项目条件出现时，主指令要求 AI 在引入该条件的同一次任务中同步建立相应工程能力：

| 项目变化 | 项目指令要求同步建立 |
| --- | --- |
| 空项目 | 只保留规则与文档入口，不猜测技术栈 |
| 首次出现可执行代码 | 最小适用的测试运行器、针对新增行为的测试和 linter |
| 出现类型系统 | 类型检查 |
| 产生构建、包或发布制品 | 可复现构建检查 |
| 接入外部系统 | 集成测试与失败处理 |
| 进入共享远程开发 | 运行现有门禁的 CI |
| 出现敏感数据或信任边界 | 安全控制、负面测试或评审证据 |
| 出现状态、并发、后台任务或部署 | 超时、重试、恢复、隔离、可观测性等可靠性约束 |

同时，Harness 明确要求：

- 新增或改变行为必须新增或更新自动化测试；
- Bug 修复必须加入回归测试，而且该测试在没有修复时应当失败；
- 已经适用并配置的检查会持续作为后续交付门禁，除非项目使用有记录的证据明确替换该门禁；
- 不得为了获得通过而删除测试、弱化规则、屏蔽有意义的诊断或跳过真实失败；
- 工具和检查变化时必须同步维护 `COMMANDS.md` 与 `CHECKS.md`；
- AI 应直接运行项目原生命令，不应虚构统一 Harness 验证包装器。

这些规则为 AI 提供明确、可审查的项目约束；当项目建立 CI、分支保护等机制后，才会进一步形成机械化门禁。

## Git、外部操作与安全边界

生成的指令不会授权 AI 擅自执行以下操作：

- commit、push 或 merge；
- deploy 或发布制品；
- 创建 GitHub 仓库等远程资源；
- 执行破坏性 Git 操作；
- 在启用 Harness 的并行工作中，让多个执行者同时修改相同写入范围。

这些操作只有在用户明确要求时才应执行。agentForge 自身也只会在你同意且环境需要时执行本地 `git init`。

## agentForge 不会做什么

- 不生成业务代码，也不替用户选择技术栈；
- 不要求二次 Bootstrap 或额外的技术栈分析阶段；
- 不向目标项目生成统一验证脚本；
- 不为空项目预装或虚构测试、lint、构建和部署命令；
- 不静默覆盖已有目标路径；
- 不自动迁移旧版本已经生成的脚手架；
- 不保证每个任务都加载 Skill、创建执行计划或启用并行工作；
- 不自动创建提交、推送、部署或远程仓库。

## 更多文档

README 只保留使用者需要首先了解的内容。进一步资料见：

- [`docs/usage.md`](docs/usage.md)：非交互参数、本地源码模式、重复执行与常见失败；
- [`docs/implementation.md`](docs/implementation.md)：生成流程、写入预检、网络边界、Skill 固定 SHA 与 v0.2 迁移；
- [`docs/development.md`](docs/development.md)：开发 agentForge、运行测试与 GitHub Actions；
- [`ARCHITECTURE.md`](ARCHITECTURE.md)：启动器、共享 Payload 和整体架构；
- [`docs/README.md`](docs/README.md)：完整文档索引；
- [GitHub Releases](https://github.com/wyizhou/agentForge/releases)：已发布版本与变更说明。

Harness 设计参考 OpenAI 的 [Harness Engineering](https://openai.com/zh-Hans-CN/index/harness-engineering/) 实践。

## 许可证

agentForge 采用 [MIT License](LICENSE) 发布。在保留许可证声明的前提下，可以使用、复制、修改和分发本项目。

agentForge 不会为生成的目标项目自动选择或添加许可证。可选安装的第三方 Skill 保留其上游许可证与来源记录。
