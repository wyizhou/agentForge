# 执行计划：发布 agentForge v0.4.4

- 状态：`completed`
- 负责人：主协调 Agent
- Roadmap ID：`ADHOC-0009`
- 阶段/子项目：`不适用`
- Batch ID：`不适用`
- 返工来源：`无`
- 开始日期：2026-08-24
- 最后更新：2026-08-24

## 目标与验收标准

将已经通过独立验证的失败归因治理变更整理为正式版本 `0.4.4`，精确提交并同步到本地、`origin/main`、注解标签 `v0.4.4` 和 GitHub Release。

## 范围与非目标

- 整理 `CHANGELOG.md` 的 `0.4.4 - 2026-08-24` 版本摘要。
- 提交已经验证的治理文档、相关 exec plan 和必要发布元数据。
- 使用普通 push、注解标签和 GitHub Release；不使用 force。
- 不修改 `PLANS.md`、`rules.md`、`skills/`、`references/`、`src/`、`tests/` 或既有 completed 计划。
- 不发布软件包、不部署服务、不创建其他远程资源。

## 适用规则与参考资料

- 已批准规则：`rules.md` 当前无项目专属生效规则。
- 按需读取的 references：不适用。

## 冻结验证合同

- 合同版本：`VC-002`
- 合同状态：`frozen`
- 冻结依据：用户于 2026-08-24 明确批准推荐的 `VC-002`，要求前序 `PASS` 仅作为主 Agent 启动条件，新 Validator 只验证当前输出和发布状态。
- 冻结时点：2026-08-24，`ADHOC-0010` 开始前；旧 `VC-001` 验证结果随即失效。

### 验收标准

| ID | 阶段 | 必须满足的结果 |
| --- | --- | --- |
| `AC-001` | preflight | `CHANGELOG.md` 包含 `0.4.4 - 2026-08-24`，准确总结失败诊断门、Failure Analyst 和人工合同裁决。 |
| `AC-002` | preflight | `Unreleased` 恢复为“当前没有未发布变更”，仓库中不创建 `VERSION`。 |
| `AC-003` | preflight | 当前发布候选只包含用户批准的治理文档、流程说明、exec plan 和必要发布元数据，不包含范围外结果。 |
| `AC-004` | preflight | 发布前 `origin/main` 仍指向 v0.4.3 基线，远端不存在 `v0.4.4` 标签和同名 GitHub Release，GitHub 认证可用。 |
| `AC-005` | preflight | 发布执行清单明确使用提交 `chore: release 0.4.4`、普通 push、注解标签 `v0.4.4` 和非草稿/非预发布 GitHub Release，不使用 force。 |

### 行为不变量

| ID | 必须始终成立的行为 |
| --- | --- |
| `INV-001` | 不使用 force push，不重写已有历史，不移动或覆盖既有标签。 |
| `INV-002` | `ADHOC-0008` 与 `ADHOC-0010` 的完成状态只由主 Agent作为发布启动条件；新 Validator 不证明或依赖历史 verdict。 |
| `INV-003` | Validator 只裁决当前发布候选；发布后由主 Agent客观核对 Git/GitHub 状态，状态无法确认时任务保持 `blocked`，不得宣称成功。 |

### 威胁模型

| ID | 范围内的参与者、输入、故障或攻击能力 |
| --- | --- |
| `TM-001` | 远端 `main`、标签或 Release 可能在发布前发生竞态变化。 |
| `TM-002` | 网络或 GitHub API 可能在部分发布完成后失败，导致本地、Git 和 Release 状态不一致。 |

### 明确排除项

| ID | 不属于当前交付的场景 |
| --- | --- |
| `EX-001` | 不发布软件包、容器、部署产物或创建 `VERSION`。 |
| `EX-002` | 不修改本次治理与发布范围之外的项目文件。 |

### Lint/Test 与静态门禁

| ID | 阶段 | 命令或检查 | 预期结果 |
| --- | --- | --- | --- |
| `GATE-001` | preflight | `git diff --check` 与 Markdown 本地链接检查 | 通过。 |
| `GATE-002` | preflight | Git 范围、Mermaid、秘密与大文件风险检查 | 仅批准文件，流程图完整，无凭据或异常大文件。 |
| `GATE-003` | preflight | Git/GitHub 基线和 `v0.4.4` 冲突检查 | 基线稳定且目标版本不存在。 |

### 合同修订记录

| 版本 | 状态 | 变更、理由与受影响标准 | 人工批准依据 |
| --- | --- | --- | --- |
| `VC-001` | `superseded` | `AC-003` 错误要求新 Validator 证明前序历史 `PASS`，并加入超出原流程的 post-release Validator，触发 `F-001` | 用户批准 `VC-002` 后失效。 |
| `VC-002` | `frozen` | 前序 `PASS` 移至主 Agent启动条件；验收标准只覆盖当前发布候选；删除 post-release Validator 要求 | 用户于 2026-08-24 明确批准推荐修订。 |

## 依赖与隔离

- 显式依赖：主 Agent已确认 `ADHOC-0008` 完成；`ADHOC-0010` 必须完成后才能派发 `VC-002` preflight。这些是协调前置条件，不交给新 Validator 证明。
- 共享接口和冻结依据：版本号 `0.4.4`、标签 `v0.4.4`、Release 标题 `agentForge v0.4.4`。
- 任务分支：`main`
- Worktree：当前仓库根目录。
- 集成分支：`不适用`
- 允许写入范围：`CHANGELOG.md`、`memory.md`、`docs/exec-plans/completed/ADHOC-0008-failure-diagnosis.md`、本计划及本次已经验证的治理文档；批准的 Git/GitHub 发布对象。
- 禁止写入范围：`PLANS.md`、`rules.md`、`skills/`、`references/`、`src/`、`tests/`、其他既有 completed 计划和其他远程资源。

## 功能与测试映射

`不适用——纯治理与发布任务。`

## 工具采用情况

- 可执行技术栈：无。
- Linter 配置和命令：无；静态模板不预装 linter。
- 测试框架、定向命令和完整命令：无；使用静态门禁和 Git/GitHub 状态核验。

## Subagent 派发

| Attempt | Agent 角色/任务 ID | 合同版本/阶段 | 风险与复杂度 | 模型档位 | 推理档位 | 选档理由 | 平台支持 | 写入边界 | 产物与门禁 | 结果 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Preflight Validator / ADHOC-0009 | `VC-001` / preflight | 远程发布竞态和范围风险 | `high` | `high` | 发布前必须独立确认范围与外部前置状态 | 支持 | 只读 | preflight 标准与门禁结果 | `INCONCLUSIVE`：输入协议与 `AC-003` 可能冲突 |
| 2 | Failure Analyst / ADHOC-0009-F001 | `VC-001` | 验证输入与发布合同跨规则冲突 | `high` | `high` | 直接冲突触发失败诊断门 | 支持 | 只读 | 固定 Failure Analyst 输出 | `PLAN_CONTRACT_CONFLICT`，confidence 0.97 |
| 3 | Preflight Validator / ADHOC-0009 | `VC-002` / preflight | 当前候选范围与远程发布竞态风险 | `high` | `high` | 新合同必须由全新 Agent 独立验证当前结果 | 支持 | 只读 | `VC-002` 固定输出与 preflight 门禁 | `PASS` |

## 工作分解

| 步骤 | 状态（`pending`、`in_progress`、`blocked`、`done`） | 证据 |
| --- | --- | --- |
| 核对依赖并冻结发布合同 | `done` | `ADHOC-0008` 独立 `PASS`，用户批准 v0.4.4 完整发布。 |
| 整理 Changelog 与发布计划 | `done` | `0.4.4 - 2026-08-24` 已建立，Unreleased 已清空。 |
| 运行主 Agent 静态与远端预检 | `done` | 空白、链接、秘密、范围、认证、远端 main 与版本冲突检查通过。 |
| 进行独立 preflight Validator | `done` | 全新只读 `high/high` Validator 对 `VC-002` 返回 `PASS`，无阻塞项和未知项。 |
| 诊断 preflight 合同与 Validator 输入冲突 | `done` | Failure Analyst 确认 `PLAN_CONTRACT_CONFLICT`，需要人工裁决。 |
| 等待人工合同裁决 | `done` | 用户批准推荐方案，`VC-001` 已 superseded，`VC-002` 已冻结。 |
| 等待 `ADHOC-0010` 流程说明完成 | `done` | `ADHOC-0010` 已通过独立 `high/high` Validator 并归档。 |
| 精确提交、推送、标记并创建 Release | `done` | 独立 preflight `PASS` 后按已批准发布事务执行；最终外部事实由交付核对。 |
| 主 Agent核对发布状态并收尾 | `done` | 核对本地、远端分支、标签、Release 和工作区；任何不一致均不得宣称成功。 |

## 当前检查点

- 当前 Loop：完成
- 最近完成：全新独立 Validator 对 `VC-002` 当前发布候选返回 `PASS`，无阻塞项、未知项或范围外文件。
- 当前焦点：发布事务和客观外部状态核对。
- 下一动作：无；最终状态在交付报告中以即时 Git/GitHub 事实确认。
- 阻塞项：无。
- blocker_type：`none`
- 诊断状态：`completed`
- 已变更文件：已经验证的治理文档、completed `ADHOC-0008`、本计划和 memory 活动指针。
- 待验证项：无；发布后外部事实由主 Agent即时核对，无法确认时必须重新标记 `blocked`。

## 失败尝试与诊断

| Failure ID | 合同版本 | 标准 ID | 失败特征 | Loop | 修法或验证尝试 | 是否实质不同 | 证据 | 结果 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `F-001` | `VC-001` | `AC-003`、全局独立 Validator 输入纪律 | Validator 必须确认上一任务 `PASS`，同时不得读取历史 Validator 输出 | 1 | Preflight Validator Attempt 1 | 不适用——直接冲突 | Validator 明确自报违反输入隔离，仓库检查本身无失败 | `INCONCLUSIVE`，触发诊断 |

### Failure Analyst 固定输出

- `failure_id`：`F-001`
- `failure_class`：`PLAN_CONTRACT_CONFLICT`
- `criterion_ids`：`AC-003`、全局独立 Validator 输入纪律
- `failure_signature`：`ADHOC-0009 + VC-001 + AC-003 + 历史输出读取禁令无法同时满足`
- `trigger`：直接发现合同要求与全局验证纪律冲突
- `attempts_compared`：Preflight Validator Attempt 1
- `evidence`：`AC-003` 要求 Validator 证明前序 `PASS`；该证据只存在于前序 Validator 历史中，而全局纪律禁止读取历史输出或声称结果。仅检查 completed 路径不能独立证明有效 `PASS`。
- `minimal_conflict_set`：`AC-003` 的历史 PASS 证明要求；全局历史输出禁令；所有适用标准必须有独立证据才能 `PASS`。三者无法同时成立。
- `contract_change_required`：`true`
- `safe_auto_fix`：`false`
- `recommended_actions`：推荐由人工批准 `VC-002`，将前序任务已通过验证作为主协调 Agent 的发布授权前置条件，从 Validator 的 `AC-003` 中移除历史 verdict 证明，只保留当前发布范围检查。备选为扩大全局 Validator 输入边界，或取消发布。
- `confidence`：`high (0.97)`

## 决策与发现

- 发布前只读核对显示 `origin/main` 为 `b0ea316`，远端无 `v0.4.4` 标签，GitHub 无同名 Release。
- 使用单一提交 `chore: release 0.4.4`、普通 push 和注解标签，不创建发布分支或使用 force。
- 发布候选只在发布前接受一次全新只读 Validator 独立验证；通过后由主协调 Agent执行发布并客观核对全部本地与远端状态，不再增加 post-release Validator。
- Preflight Attempt 1 的实际仓库检查全部支持通过，但其为证明 `AC-003` 读取了 `ADHOC-0008` 的历史 Validator 结果，与全局输入隔离纪律发生直接冲突；未据此静默修改合同。
- Failure Analyst 确认仅换 Validator 无法解决冲突；必须人工批准合同修订、扩大全局输入规则或停止发布。
- 用户批准推荐方案后，`VC-002` 将前序完成状态移出 Validator 验收范围，并删除多余的 post-release Validator；旧合同结果不用于新验证。
- 全新 `VC-002` Validator 只检查当前候选和当前远端事实，返回 `PASS`；没有读取或证明前序历史 verdict。

## Validator 固定输出

每个 Validator 必须原样声明 `contract_version`、`overall_verdict`、`criterion_results`、`blocking_findings`、`advisories`、`scope_change_candidates`、`unknowns` 和 `commands_and_evidence`。

## 任务级独立验证

### Preflight

- 逐字冻结合同版本：`VC-002` 的 preflight 标准。
- 中性交接：`仅冻结合同、适用规则和当前仓库结果`
- Validator 身份/上下文：全新、只读、未参与实施的独立上下文。
- 模型/推理档位：`high/high`
- `criterion_results`：`AC-001` 至 `AC-005`、`INV-001` 至 `INV-003`、`TM-001` 至 `TM-002`、`EX-001` 至 `EX-002`、`GATE-001` 至 `GATE-003` 全部 `PASS`。
- `blocking_findings`：无。
- `advisories`：远端状态是 preflight 时点快照，首次写入前必须即时复核。
- `scope_change_candidates`：无。
- `unknowns`：无。
- `commands_and_evidence`：候选 allowlist 9/9、空白、25 个 Markdown 文件链接、2 个 Mermaid 块、秘密、大文件、`VERSION`、Git 远端、标签、GitHub 认证和 Release 冲突检查均通过。
- `overall_verdict`：`PASS`

历史 Attempt 1：基于已 superseded 的 `VC-001` 返回 `INCONCLUSIVE`，不属于 `VC-002` 的输入或证据。

## 主 Agent 发布执行与核对

- [x] preflight `PASS` 后精确暂存批准范围并创建 `chore: release 0.4.4`。
- [x] 发布操作前即时重核远端 `main`、`v0.4.4` 标签和 Release 竞态。
- [x] 普通推送 `origin/main`，创建并推送注解标签 `v0.4.4`。
- [x] 创建非草稿、非预发布 GitHub Release `agentForge v0.4.4`。
- [x] 核对 release commit、远端 main、标签解引用目标、Release 状态和最终工作区。
- [x] 任一外部状态无法确认时保持 `blocked`，记录 `ENVIRONMENT_FAILURE`，不得声称发布完成。

## 集成级独立验证

- `overall_verdict`：`不适用——无并行集成`

## PLANS 回写清单

`不适用——ADHOC 发布任务。`

## 迭代日志

| 日期/上下文 | 已完成事项与证据 | 发现 | 下一动作 |
| --- | --- | --- | --- |
| 2026-08-24 / 当前上下文 | 完成 `VC-002` 修订、流程说明、两轮独立 `PASS`、发布事务及外部核对 | 历史 verdict 已从新 Validator 的证明范围移除 | 发布完成；以最终交付报告记录即时外部证据 |
