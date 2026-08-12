# 执行计划：明确 src 与 tests 目录职责

- 状态：`completed`
- 负责人：主协调 Agent
- Roadmap ID：`ADHOC-0003`
- 阶段/子项目：`不适用`
- Batch ID：`不适用`
- 返工来源：`无`
- 开始日期：2026-08-12
- 最后更新：2026-08-12

## 目标与验收标准

- 新增 `src/.gitkeep`，使静态模板直接保留实现目录。
- 保持根目录 `tests/.gitkeep`，并明确 `src/` 与 `tests/<feature-slug>/` 的对应职责。
- 模板不包含 `product/` 或 `dist/`；不建立永久禁止 `dist/` 的规则。
- 不修改正式版本号、Roadmap、项目规则、Skills、References 或既有 completed 计划。

## 范围与非目标

- 允许修改：`src/.gitkeep`、`README.md`、`AGENTS.md`、`CHANGELOG.md`、本计划和活动期间的 `memory.md` 指针。
- 非目标：引入可执行代码、技术栈、linter、测试框架、部署工具、版本发布或 Git 提交与推送。

## 适用规则与参考资料

- 已批准规则：无。
- 按需读取的 references：无。

## 依赖与隔离

- 显式依赖：无。
- 共享接口和冻结依据：用户批准的目录职责调整计划。
- 任务分支：`不适用——单项 ADHOC 文档任务`
- Worktree：`不适用——无并行 Worker`
- 集成分支：`不适用——无并行集成`
- 允许写入范围：见“范围与非目标”。
- 禁止写入范围：其他全部仓库文件。

## 功能与测试映射

`不适用——静态脚手架治理变更，不引入功能行为。`

## 工具采用情况

- 可执行技术栈：无。
- Linter 配置和命令：无；静态模板未配置 linter。
- 测试框架、定向命令和完整命令：无；使用文件树、内容检索、Markdown 链接和 `git diff --check` 验证。

## Subagent 派发

| Attempt | Agent 角色/任务 ID | 风险与复杂度 | 模型档位 | 推理档位 | 选档理由 | 平台支持 | 写入边界 | 产物与门禁 | 结果 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 独立 Validator / ADHOC-0003 | 低风险静态文档复核 | `medium` | `medium` | Validator 不低于实施任务，且推理至少为 medium | 支持抽象选档 | 只读，禁止修改任何文件 | 独立检查目录、范围、内容和静态验证 | `PASS` |

## 工作分解

| 步骤 | 状态（`pending`、`in_progress`、`blocked`、`done`） | 证据 |
| --- | --- | --- |
| 核对 Git、仓库状态和权威文档 | `done` | Git worktree 有效，`main` 工作区干净，当前无活动计划 |
| 新增 `src/` 并调整职责文档 | `done` | 已新增 `src/.gitkeep`，并更新 `README.md`、`AGENTS.md`、`CHANGELOG.md` |
| 运行静态检查 | `done` | 目录断言、内容检索和 `git diff --check` 均通过 |
| 交给全新只读 Validator | `done` | Validator 独立返回 `PASS`，无未满足项 |
| 归档计划并清除活动指针 | `done` | 计划移入 `completed/`，`memory.md` 恢复为无活动计划 |

## 当前检查点

- 当前 Loop：1
- 最近完成：全新只读 Validator 返回 `PASS`。
- 当前焦点：任务完成并归档。
- 下一动作：无。
- 阻塞项：无。
- 已变更文件：`src/.gitkeep`、`README.md`、`AGENTS.md`、`CHANGELOG.md`、本计划、`memory.md`。
- 待验证项：无。

## 决策与发现

- 当前仓库原本已无 `product/` 和 `dist/`，且 `tests/` 已位于根目录，因此无需迁移或删除。
- `dist/` 仅不由初始模板提供；未来项目可按技术栈需要决定是否生成构建产物。

## 任务级独立验证

- 中性交接：核对空 `src/`、根目录 `tests/`、文档职责、目录缺失、Unreleased 范围和禁止修改范围。
- Validator 身份/上下文：全新只读 Validator `src_layout_validator`，未读取主 Agent 计划、memory 或推理。
- 模型/推理档位：`medium/medium`
- 命令与观察：确认 `src/.gitkeep` 与 `tests/.gitkeep` 均存在且为空；`product/`、`dist/` 不存在；README、AGENTS、CHANGELOG 内容一致；`PLANS.md`、`rules.md`、`skills/`、`references/` 和既有 completed 计划无差异；Markdown 相对链接目标存在；`git diff --check` 通过。
- 结果：`PASS`
- 未满足项与剩余风险：无。

## 集成级独立验证

- 集成范围：`不适用——无并行集成`
- 中性交接：`不适用`
- Validator 身份/上下文：`不适用`
- 模型/推理档位：`不适用`
- 完整 lint/test 与回归观察：`不适用——无可执行代码及并行结果`
- 结果：`不适用——无并行集成`
- 未满足项与剩余风险：无。

## PLANS 回写清单

- [x] Exec plan 已归档到 `completed/`
- [x] Roadmap 叶子任务已更新为 `[x] completed`（不适用——ADHOC）
- [x] 子项目和阶段状态已重新计算（不适用——ADHOC）
- [x] `memory.md` 中的活动计划指针已删除

## 迭代日志

| 日期/上下文 | 已完成事项与证据 | 发现 | 下一动作 |
| --- | --- | --- | --- |
| 2026-08-12 / 当前上下文 | 完成 Git 门禁、权威文档和实际目录核对，建立 ADHOC-0003 | 只需新增 src 占位和修正文档，无真实迁移 | 实施后运行静态检查和独立验证 |
