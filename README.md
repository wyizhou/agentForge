# agentForge

agentForge 是一个可直接下载使用的静态 Loop Engineering 项目脚手架。它不包含生成器、安装器、初始化脚本、CI、预装 linter 或测试框架，也不要求执行 Bootstrap 命令。

下载仓库归档并解压到项目目录后，AI 编程工具即可通过仓库内的持久化文件恢复规则、偏好和任务状态。首次进行仓库工作时，AI 会依据 [`AGENTS.md`](AGENTS.md) 检查 Git；缺少 Git 或尚未初始化仓库时，必须分别取得用户批准后才能安装或执行 `git init`。

## 文件结构

```text
AGENTS.md                  # AI 的权威启动与交付协议
CLAUDE.md                  # Claude Code 对 AGENTS.md 的引用入口
rules.md                   # 仅由人工批准加入的项目硬约束
memory.md                  # AI 维护的跨会话稳定事实与偏好
CHANGELOG.md               # 正式发布版本及变更摘要
docs/exec-plans/           # 每项仓库工作的计划、检查点和验证证据
tests/                     # 按功能划分的测试目录
skills/                    # 只在当前仓库内按需读取的项目 Skill
```

## Loop 状态恢复

每个新的上下文窗口从 `AGENTS.md` 开始，并依次恢复 `rules.md`、`memory.md` 和匹配的活动执行计划。任务步骤只记录在执行计划中；`memory.md` 仅保存稳定信息和活动计划链接，避免两份状态互相漂移。

项目 Skill 使用 `skills/<name>/SKILL.md`，不得安装、复制或链接到用户级或全局 Skill 目录。

## 工程门禁

空模板不猜测技术栈。首次引入可执行代码时，开发任务必须同时建立适合该项目类型的 linter 和测试框架。每项功能使用独立的 `tests/<feature-slug>/` 目录，先固定测试预期再实现功能。后续交付必须运行所有适用检查，且不得为获得绿灯而弱化测试或 lint 规则。

产生结果变更的任务只有通过全新、只读且独立的 Validator 后才能完成。Validator 独立运行适用的 linter 和测试，并核对测试是否真实表达验收标准。

## 版本发布

普通任务不创建版本。只有用户明确要求发布时，才使用人工批准的版本号把 `CHANGELOG.md` 中的 `Unreleased` 内容整理为正式版本，并留下对应更新摘要。

## 许可证

本模板使用 [MIT License](LICENSE)。使用者应根据自己的项目需要审阅并调整许可证。
