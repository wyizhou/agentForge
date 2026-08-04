# 进阶使用

首次使用建议按照根目录 [`README.md`](../README.md) 的交互流程运行。本页面面向自动化脚本、本地调试和需要精确控制生成选项的使用者。

## 非交互模式

只要一次性提供所有选项，agentForge 就不会提问，适合测试、模板仓库和自动化环境。

macOS 或 Linux：

```sh
sh agentforge.sh \
  --target ./my-project \
  --primary agents \
  --harness yes \
  --skill yes \
  --git yes
```

Windows PowerShell：

```powershell
.\agentforge.ps1 `
  -Target .\my-project `
  -Primary agents `
  -Harness yes `
  -Skill yes `
  -Git yes
```

参数说明：

| POSIX | PowerShell | 可选值 | 作用 |
| --- | --- | --- | --- |
| `--target` | `-Target` | 目录路径 | 目标项目，默认是当前目录；父目录必须已经存在 |
| `--primary` | `-Primary` | `agents`、`claude` | 选择主要指令文件；另一个文件作为兼容入口 |
| `--harness` | `-Harness` | `yes`、`no`（也接受 `y`、`n`） | 是否生成渐进式 Harness 文档 |
| `--skill` | `-Skill` | `yes`、`no`（也接受 `y`、`n`） | 是否安装 `orchestrate-parallel-work` |
| `--git` | `-Git` | `yes`、`no`（也接受 `y`、`n`） | 目标不在 Git 工作区时是否执行 `git init` |
| `--source-dir` | `-SourceDir` | agentForge 源码目录 | 从本地 `payload/` 读取模板，主要用于开发和离线生成 |

POSIX 入口可用 `sh agentforge.sh --help` 查看帮助。省略任意选择项时，只会针对缺失项继续提问；配置内容最多分为四类。输入无效答案可能触发重复提示，而一次性提供全部参数时不会提问。

## 从本地仓库生成

克隆 agentForge 后，可以完全从本地共享 Payload 生成，不必下载 agentForge 模板：

```sh
sh ./agentforge.sh \
  --source-dir . \
  --target ../my-project \
  --primary agents \
  --harness yes \
  --skill no \
  --git no
```

```powershell
.\agentforge.ps1 `
  -SourceDir . `
  -Target ..\my-project `
  -Primary agents `
  -Harness yes `
  -Skill no `
  -Git no
```

本地源码模式只替代 agentForge 自身 Payload 的下载。如果选择安装 Skill，仍需要访问 GitHub；Skill 的测试夹具环境变量属于维护者接口，不是稳定的公开命令行 API。

## 生成选项的结果

- 无论谁是主入口，都会生成 `AGENTS.md` 和 `CLAUDE.md`。主入口包含完整规则，兼容入口引导对应 AI 读取主入口。
- 选择 Harness 后会生成 `ARCHITECTURE.md`、`docs/` 下的知识目录和渐进式交付规范；不会生成统一验证脚本。
- 不选择 Harness 时只生成基础 AI 指令，不会建立 `docs/harness/`。
- 无论是否安装 Skill，都会生成 `SKILLS.md`；未安装时，它会明确记录当前没有项目级 Skill。
- 安装 Skill 时会向 `.agents/skills/` 和 `.claude/skills/` 写入内容一致的两份副本。

## Git 行为

`--git yes` 或 `-Git yes` 只代表“在需要时初始化”：

- 如果目标目录或其父级已经位于 Git 工作区，agentForge 会跳过初始化，避免嵌套仓库。
- 如果系统没有 Git，agentForge 会给出提示并跳过初始化。
- agentForge 不会创建提交、远程仓库、分支或推送内容。

## 已有文件和重复执行

agentForge 不会合并或覆盖既有文件。写入前只要发现任一目标文件、非目录父路径、符号链接父路径或 Windows 重解析点冲突，就会停止并列出冲突；预检通过前不会向项目写入本次生成的文件。

因此，agentForge 不是原地升级器。需要再次生成时，请使用新的空目录，或先人工审阅并迁移既有脚手架。不要为了重跑命令直接删除包含项目自定义规则的文件。

## 常见失败

| 现象 | 原因与处理 |
| --- | --- |
| `Target parent directory does not exist` | 先创建目标的父目录；agentForge 可以创建最后一级目标目录 |
| `Remote mode requires curl or wget` | macOS/Linux 远程模式需要其中一个下载工具；也可克隆仓库并使用 `--source-dir` |
| `will not overwrite existing paths` | 冲突文件属于现有项目；审阅列表后改用新目录或手动整合 |
| Skill Commit 必须是 40 位 SHA | Skill 只接受不可变的完整 Commit SHA，不接受 `main` 等可变引用 |
| Skill 下载失败 | 检查 GitHub 网络访问后重试；失败时命令返回非零状态 |

更详细的写入顺序和安全边界见 [`implementation.md`](implementation.md)。
