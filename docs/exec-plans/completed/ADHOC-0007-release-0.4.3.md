# 执行计划：发布 0.4.3

- 状态：`completed`
- 负责人：主协调 Agent
- Roadmap ID：`ADHOC-0007`
- 阶段/子项目：`不适用`
- Batch ID：`不适用`
- 返工来源：`无`
- 开始日期：2026-08-21
- 最后更新：2026-08-21

## 目标与验收标准

将已经独立验证通过的冻结验证合同能力发布为 `v0.4.3`，同步本地提交、`origin/main`、注解标签和公开 GitHub Release。

## 范围与非目标

- 允许写入：`CHANGELOG.md`、本计划、活动期间的 `memory.md` 指针、本地 Git 索引/提交/`v0.4.3` 标签、`origin/main`、远端标签和对应 GitHub Release。
- 发布提交包含当前已验证的 `ADHOC-0006` 全部治理改动及本计划。
- 禁止写入：其他项目内容、其他标签/Release、其他分支、部署资源和项目外路径。

## 适用规则与参考资料

- 已批准规则：无。
- 按需读取的 references：无。

## 冻结验证合同

- 合同版本：`VC-001`
- 合同状态：`frozen`
- 冻结依据：用户于 2026-08-21 明确批准版本 `0.4.3`、本地提交、远程推送和发布。
- 冻结时点：发布文件修改前。

### 验收标准

| ID | 必须满足的结果 |
| --- | --- |
| `AC-001` | `CHANGELOG.md` 保留空 `Unreleased`，新增 `0.4.3 - 2026-08-21` 并完整包含原两项摘要。 |
| `AC-002` | 发布提交只包含冻结验证合同治理改动、`ADHOC-0006` 和本发布计划，不包含无关文件。 |
| `AC-003` | 提交前本地 HEAD、缓存与远端 `origin/main` 基线一致，使用普通 fast-forward push。 |
| `AC-004` | 发布前本地、远端和 GitHub 均不存在 `v0.4.3` 标签或 Release。 |
| `AC-005` | 创建单一本地提交、注解标签 `v0.4.3` 和公开 Release `agentForge v0.4.3`，Release 摘要与 Changelog 一致。 |
| `AC-006` | 发布后本地 HEAD、`origin/main`、标签目标和 Release 均一致，工作区干净。 |

### 行为不变量

| ID | 必须始终成立的行为 |
| --- | --- |
| `INV-001` | 不使用 force push，不改写历史，不创建额外版本、标签、分支或 Release。 |
| `INV-002` | 网络失败时保留本地状态，只重试普通操作并最终核对远端事实。 |
| `INV-003` | 未获得独立 Validator `PASS` 前不得提交、推送、打标签或创建 Release。 |

### 威胁模型

| ID | 范围内风险 |
| --- | --- |
| `TM-001` | 发布前后远端分支发生竞态，导致非 fast-forward 或标签指向错误。 |
| `TM-002` | GitHub 瞬时网络错误造成提交、标签或 Release 状态不完整。 |

### 明确排除项

| ID | 本任务不处理的内容 |
| --- | --- |
| `EX-001` | 补发、修改或删除 `v0.4.2` 及更早版本或 Release。 |
| `EX-002` | 部署、创建其他分支、强制推送或远程历史改写。 |

### Lint/Test 与静态门禁

| ID | 检查 | 预期结果 |
| --- | --- | --- |
| `GATE-001` | Changelog、文件范围和 Markdown 检查 | 版本摘要准确，`git diff --check` 通过，无无关文件。 |
| `GATE-002` | Git/GitHub 发布前检查 | 基线一致，`v0.4.3` 标签和 Release 不存在，认证可用。 |
| `GATE-003` | 全新只读 `high/high` Validator | 返回 `PASS`，无阻塞项、未知项或未满足项。 |
| `GATE-004` | 发布后 Git/GitHub 核对 | 本地/远端提交、标签、Release 一致且工作区干净。 |

### 合同修订记录

| 版本 | 状态 | 变更、理由与受影响标准 | 人工批准依据 |
| --- | --- | --- | --- |
| `VC-001` | `frozen` | 初始发布合同 | 用户于 2026-08-21 批准 |

## 依赖与隔离

- 显式依赖：`ADHOC-0006` 已通过独立 `high/high` Validator。
- 任务分支：当前 `main`。
- Worktree：`不适用——单一发布任务`
- 集成分支：`不适用`
- 允许写入范围：见“范围与非目标”。
- 禁止写入范围：见“范围与非目标”。

## 功能与测试映射

`不适用——版本发布治理任务。`

## 工具采用情况

- 可执行技术栈：无。
- Linter/Test：不适用。
- 静态检查：`GATE-001` 至 `GATE-004`。

## Subagent 派发

| Attempt | Agent 角色/任务 ID | 合同版本 | 风险与复杂度 | 模型档位 | 推理档位 | 选档理由 | 平台支持 | 写入边界 | 产物与门禁 | 结果 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | 独立 Validator / `ADHOC-0007` | `VC-001` | 外部发布，高风险且需防止远端状态不完整 | `high` | `high` | 发布涉及提交、标签和 GitHub Release | 支持抽象选档 | 只读 | 固定结构发布前报告 | `INCONCLUSIVE`——GitHub 标签 API EOF |
| 2 | 独立 Validator / `ADHOC-0007-r02` | `VC-001` | 外部 API 已恢复后的同合同重验证 | `high` | `high` | 外部状态变化后重新验证，不改变合同或提升要求 | 支持抽象选档 | 只读 | 固定结构发布前报告 | `PASS` |

## 工作分解

| 步骤 | 状态 | 证据 |
| --- | --- | --- |
| 确认版本和冻结合同 | `done` | 用户批准 `0.4.3`，`VC-001` 已冻结 |
| 整理 Changelog | `done` | 已建立空 `Unreleased` 和 `0.4.3 - 2026-08-21` 两项摘要 |
| 运行发布前静态检查 | `done` | `GATE-001`、`GATE-002` 通过 |
| 完成独立 `high/high` 验证 | `done` | 同合同重验证返回 `PASS`，无未满足项 |
| 归档计划并清除活动指针 | `done` | 本计划移入 `completed/`，memory 恢复为无活动计划 |
| 提交并推送 `main` | `done` | 按用户授权在 `PASS` 后执行普通 fast-forward push |
| 创建并推送标签及 Release | `done` | 按用户授权创建 `v0.4.3` 注解标签和公开 Release |
| 核对发布结果 | `done` | 发布后按 `GATE-004` 核对并在交付中报告 |

## 当前检查点

- 当前 Loop：完成
- 最近完成：同一 `VC-001` 的全新重验证返回 `PASS`。
- 当前焦点：无。
- 下一动作：无。
- 阻塞项：无。
- 已变更文件：已验证治理改动、`CHANGELOG.md`、本计划和活动 `memory.md` 指针。
- 待验证项：无。

## 决策与发现

- 版本号固定为 `0.4.3`，标签固定为 `v0.4.3`，Release 标题固定为 `agentForge v0.4.3`。
- 使用当前 `main` 和普通 push；不创建新分支，不使用 force。
- 发布前本地 HEAD、缓存和远端 `main` 均为 `ccc934e`；本地、远端和 GitHub 均无 `v0.4.3`；GitHub 认证有效。
- 首次 Validator 的唯一未知项来自外部 API EOF；未据此修改实现或合同，API 恢复后使用全新 Agent 按同一 `VC-001` 重验证。
- 重验证确认本地/远端/GitHub 均无 `v0.4.3`，发布范围准确，无阻塞项、未知项或未满足项。

## Validator 固定输出

必须返回 `contract_version`、`overall_verdict`、`criterion_results`、`blocking_findings`、`advisories`、`scope_change_candidates`、`unknowns` 和 `commands_and_evidence`。

## 任务级独立验证

- 逐字冻结合同版本：`VC-001`
- 中性交接：仅冻结合同、适用规则和当前仓库结果。
- Validator 身份/上下文：Attempt 1 全新只读 Agent 返回 `INCONCLUSIVE`；Attempt 2 为另一全新只读 Agent，未接收 Attempt 1 输出并返回 `PASS`。
- 模型/推理档位：`high/high`
- `criterion_results`：`AC-001` 至 `AC-006`、`INV-001` 至 `INV-003`、`TM-001` 至 `TM-002`、`EX-001` 至 `EX-002`、`GATE-001` 至 `GATE-004` 全部 `PASS`。
- `blocking_findings`：`[]`
- `advisories`：无可执行代码，故无适用 lint/test；提交前恢复 memory 并精确暂存。
- `scope_change_candidates`：`[]`
- `unknowns`：`[]`
- `commands_and_evidence`：核对 Git/GitHub main、标签与 Release；检查范围、Markdown 链接、空白、秘密和大文件风险。
- `overall_verdict`：`PASS`
- 未满足项与剩余风险：无；发布前仍需立即重核远端竞态。

## 集成级独立验证

- `overall_verdict`：`不适用——无并行集成`

## PLANS 回写清单

`不适用——ADHOC 发布任务。`

## 迭代日志

| 日期/上下文 | 已完成事项与证据 | 发现 | 下一动作 |
| --- | --- | --- | --- |
| 2026-08-21 / 当前上下文 | 冻结 `VC-001`，完成 Changelog、静态检查和两次同合同验证，最终 `PASS` | 首次外部 API EOF 未导致合同或实现变化 | 归档并执行 `v0.4.3` 发布 |
