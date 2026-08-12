# 执行计划：Roadmap、并行执行与动态 Agent 选档

- 状态：`completed`
- 负责人：主协调 Agent
- Roadmap ID：`ADHOC-0001`
- 阶段/子项目：不适用
- Batch ID：不适用
- 返工来源：无
- 开始日期：2026-08-12
- 最后更新：2026-08-12

## 目标与验收标准

在保留已完成 references 改动和验证历史的基础上，新增长期 `PLANS.md`，并建立 Roadmap 到即时 exec plan、隔离并行开发、两层验证、动态 Agent 选档和技术债人工提升的完整契约。

## 范围与非目标

- 范围：Roadmap、exec-plan 模板、主 Agent 派发、并行 worktree、验证和技术债治理文档。
- 非目标：创建真实产品 Roadmap、启动并行开发、创建 worktree、安装工具、提交或推送。

## 适用的已批准规则

当前没有项目专属规则。

## 功能与测试映射

不适用——本次为纯治理文档变更。

## 工具采用情况

- 可执行技术栈：无。
- Linter：不适用。
- 测试框架：不适用。
- 静态检查：文档契约、状态枚举、命名一致性、Markdown 链接和 `git diff --check`。

## 依赖与隔离

- 显式依赖：已完成的 references 改动及其验证记录。
- 分支/worktree：不适用——单一治理工作流直接在当前授权工作区实施。
- 允许写入范围：根级治理文档与 `docs/exec-plans/`。
- 禁止写入范围：`LICENSE`、references 专题内容、项目外路径和远程仓库。

## Subagent 派发

| Attempt | Agent 角色/任务 ID | 风险与复杂度 | 模型档位 | 推理档位 | 选档理由 | 平台支持 | 写入边界 | 产物与门禁 | 结果 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 独立 Validator / `ADHOC-0001-validator` | 跨文档契约一致性，风险中高 | `high` | `high` | 需复核并行、状态机和跨平台选档边界 | 模型映射由平台决定 | 只读 | 事实型验收报告 | `FAIL`：CHANGELOG 权限语义冲突 |
| 2 | 独立 Validator / `ADHOC-0001-validator-r02` | 修正后的完整契约复验，风险中高 | `high` | `high` | 首次验证失败后必须使用全新 Agent 复验全部合同 | 模型映射由平台决定 | 只读 | 事实型验收报告 | `PASS` |

## 工作分解

| 步骤 | 状态 | 证据 |
| --- | --- | --- |
| 新增空 Roadmap 模板 `PLANS.md` | `done` | 初始无虚构阶段或任务 |
| 建立即时 exec plan、并行 worktree 和双层验证契约 | `done` | 权威规则、Roadmap 与模板一致 |
| 建立动态 Agent 选档和升级契约 | `done` | 抽象档位、阶梯和平台降级已记录 |
| 完善技术债治理和相关说明 | `done` | 候选记录和人工提升边界已建立 |
| 执行静态检查并取得独立 Validator 的 `PASS` | `done` | 全新只读 Validator 15 项验收全部通过 |

## 当前检查点

- 当前 Loop：完成
- 最近完成：完整契约独立复验返回 `PASS`
- 当前焦点：无
- 下一动作：无
- 阻塞项：无
- 已变更文件：`PLANS.md`、`AGENTS.md`、README、memory、CHANGELOG 和 exec-plan 文档
- 待验证项：无

## 决策与发现

- 保留未提交的 references 改动和 `docs/exec-plans/completed/2026-08-12-project-references.md`。
- 本次为单一治理工作流，不需要并行 Worker 或 worktree。
- 最终 Validator 的抽象选档为模型 `high`、推理 `high`；当前平台模型映射由运行时决定，不写入仓库文档。
- 首次独立验证发现 `AGENTS.md` 对 `CHANGELOG.md` 的更新权限与 `Unreleased` 实践冲突，已统一为“普通重要变更更新 Unreleased，正式版本必须人工批准”。

## 独立验证

- 中性交接：仅提供中性目标、验收标准和当前仓库位置
- Validator 身份/上下文：两次均为全新零历史只读 Agent，均未参与实施
- 模型/推理档位：`high/high`
- 命令与观察：主协调 Agent静态检查已通过，不作为 Validator 结论输入
- 结果：首次 `FAIL`；修正后完整复验 `PASS`
- 未满足项与剩余风险：无未满足项；治理契约没有操作系统级强制机制

## 迭代日志

| 日期/上下文 | 已完成事项与证据 | 发现 | 下一动作 |
| --- | --- | --- | --- |
| 2026-08-12 / Loop 1 | Git 门禁通过；references 改动和已完成计划均存在 | Roadmap、并行和动态选档尚未实现 | 更新模板契约 |
| 2026-08-12 / Loop 2 | Roadmap、并行、选档和技术债契约完成并通过复验 | 修正 CHANGELOG 的 Unreleased 权限语义后 15 项全部通过 | 归档计划 |
