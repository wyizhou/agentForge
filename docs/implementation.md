# 实现与安全边界

agentForge 由两个原生入口和一份共享 Payload 组成：macOS/Linux 使用 `agentforge.sh`，Windows 使用 `agentforge.ps1`，所有生成模板位于 `payload/`。运行时不依赖 Node.js、Python、`jq` 或包管理器。

## 生成流程

一次运行按以下顺序进行：

1. 解析目标目录和已提供的非交互参数。
2. 询问尚未提供的选项，并检查目标是否已经位于 Git 工作区。
3. 从当前版本的 GitHub Raw 地址或本地 `--source-dir` 读取共享 Payload。
4. 在系统临时目录中暂存本次选择需要的全部文件，并替换主指令中的项目名称占位符。
5. 如果选择 Skill，解析上游 Commit、下载文件并生成来源记录。
6. 对完整目标清单执行写入预检；发现任何冲突即停止。
7. 创建目标目录并复制暂存内容。
8. 仅在用户选择且目标不在现有工作区时执行 `git init`。

共享 Harness 清单 `payload/harness/manifest.tsv` 是两种入口的共同生成契约，避免在启动器中复制大段模板。POSIX 和 PowerShell 的等价性由测试验证，详见 [`development.md`](development.md)。

## 写入预检

预检覆盖本次将生成的完整文件集合：

- 目标文件已经存在时拒绝写入，包括悬空符号链接；
- 父路径是普通文件时拒绝写入；
- POSIX 下父路径是符号链接时拒绝写入；
- Windows 下父路径是重解析点时拒绝写入；
- 所有目标写入路径和 Skill 清单路径中的绝对路径及 `..` 路径被拒绝。

文件会先下载到临时目录，预检通过后才写入目标项目。这保证常见冲突不会产生半套脚手架，也保证既有目标路径不会被静默覆盖。

这不是文件系统事务：预检和复制之间仍可能发生并发修改，复制阶段遇到磁盘、权限或硬件故障时也没有自动回滚。请避免多个 agentForge 进程同时写入同一目标，并在异常退出后检查目标目录。

## Skill 来源与固定 SHA

Skill 安装只允许来源仓库 `wyizhou/orchestrateParallelWork-skill`，流程如下：

1. 通过 GitHub API 解析上游 `main` 在安装时指向的 Commit；
2. 要求解析结果是完整的 40 位十六进制 Commit SHA；
3. 从该精确 SHA 的 GitHub Raw 地址下载清单内文件；
4. 分别写入 Codex 与 Claude Code 的项目级 Skill 目录；
5. 在两份 `ORIGIN.md` 中记录仓库、Skill 路径、Commit SHA 和 agentForge 版本。

这会把一次安装固定到可审计的上游快照，避免同一运行过程中跟随可变分支漂移。agentForge 只下载 Skill 文件，不会在安装阶段执行其中的指令或代码。

需要注意：SHA 是“安装时解析”而不是写死在某个 agentForge 版本中，所以不同日期的两次安装可能解析到不同 Commit。`ORIGIN.md` 提供追溯信息，但当前实现不验证独立签名或额外内容校验和。

## 网络和权限边界

- 远程 Payload、GitHub API 和 Skill 文件均通过 HTTPS 获取。
- POSIX 远程模式使用系统已有的 `curl` 或 `wget`；PowerShell 使用 `Invoke-WebRequest` 和 `Invoke-RestMethod`。
- agentForge 只写入用户指定的目标目录和系统临时目录，不会执行生成到目标项目中的内容。
- Git 操作仅限用户选择后的本地 `git init`；不会提交、推送、创建远程资源或部署。
- 下载并运行远程启动器本身仍属于执行远程代码。应使用 README 中带版本标签的地址，并在高安全要求环境中先下载、审阅，再从本地运行。
- 文档式 Harness 能向 AI 明确提出质量门禁，但不能从操作系统层面强制代理遵守。最终证据来自项目原生命令的执行结果和交付报告。

## 从 v0.2 迁移

v0.2 会向目标项目生成 `harness/verify.sh` 和 `harness/verify.ps1`；从 v0.3 开始，Harness 只提供项目知识与交付规范，不再生成统一验证包装器。agentForge 不会覆盖已有文件，因此迁移必须人工完成。

建议顺序：

1. 审阅两个旧验证脚本，识别其中已经接入的真实测试、lint、类型检查、构建、安全和集成命令。
2. 把权威命令整理到 `docs/harness/COMMANDS.md`，把每项约束与执行机制的对应关系整理到 `docs/harness/CHECKS.md`。
3. 更新 `AGENTS.md`、`CLAUDE.md` 和 `docs/harness/DELIVERY_RULES.md`，要求 AI 在交付前直接运行所有适用的项目原生命令。
4. 搜索仓库、CI 和开发文档中对 `harness/verify.sh`、`harness/verify.ps1` 的引用，并改为对应的原生命令。
5. 在当前平台和 CI 中执行迁移后的全部命令，确认结果与旧入口一致。
6. 只有确认旧脚本不再包含独有逻辑且没有调用方后，才删除它们。

如果旧验证脚本已经承载自定义编排，不要机械删除；应先保留行为、拆分或迁移调用关系。v0.3 变更的实现记录见 [`exec-plans/completed/remove-generated-verifiers.md`](exec-plans/completed/remove-generated-verifiers.md)。
