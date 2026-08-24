# 执行计划：建立实施失败归因机制

- 状态：`completed`
- 负责人：主协调 Agent
- Roadmap ID：`ADHOC-0008`
- 阶段/子项目：`不适用`
- Batch ID：`不适用`
- 返工来源：`无`
- 开始日期：2026-08-24
- 最后更新：2026-08-24

## 目标与验收标准

在冻结验证合同和独立 Validator 之间增加失败诊断门，允许 AI 在安全边界内修复实施缺陷，并在目标或合同冲突时停止修改、提交人工裁决，避免无限修复和验收漂移。

## 范围与非目标

- 更新仓库治理文档、执行计划说明、模板、README、记忆和变更日志。
- 不增加可执行代码、linter、测试框架或新的任务生命周期状态。
- 不修改 `PLANS.md`、`rules.md`、`skills/`、`references/`、`src/` 或 `tests/`。
- 本计划不执行版本提交、推送、标签或 GitHub Release；发布由后续 `ADHOC-0009` 跟踪。

## 适用规则与参考资料

- 已批准规则：`rules.md` 当前无项目专属生效规则。
- 按需读取的 references：不适用。

## 冻结验证合同

- 合同版本：`VC-001`
- 合同状态：`frozen`
- 冻结依据：用户于 2026-08-24 明确批准《agentForge v0.4.4：实施失败归因机制》并要求实施。
- 冻结时点：2026-08-24，早于治理文档修改。

### 验收标准

| ID | 必须满足的结果 |
| --- | --- |
| `AC-001` | 全局治理明确区分 `IMPLEMENTATION_DEFECT`、`PLAN_CONTRACT_CONFLICT`、`VALIDATION_DEFECT`、`ENVIRONMENT_FAILURE` 和 `UNDETERMINED`。 |
| `AC-002` | 同一标准两种实质不同修法仍失败、同一失败连续三轮无收敛或发现明确冲突时，必须暂停修改并触发诊断。 |
| `AC-003` | Failure Analyst 为全新、只读、未参与实施的 `high/high` 角色，可以读取失败历史，但不得修改文件、替代 Validator 或裁决 `PASS`。 |
| `AC-004` | 实施缺陷只有在不改变冻结合同、正确测试预期和批准范围时才允许一次诊断后修复；相同失败继续出现时停止自动修复。 |
| `AC-005` | 规划或合同冲突必须输出最小冲突集合和选项，人工批准后才能升级合同；验证、环境和无法确定的失败按批准方案分别处理。 |
| `AC-006` | exec-plan 模板记录失败特征、尝试、触发条件、归因结果、阻塞类型和 Failure Analyst 固定输出。 |
| `AC-007` | README 使用简明语言解释实施问题由 AI 修复、目标冲突由人工决定。 |
| `AC-008` | `memory.md` 记录经验证的稳定机制，`CHANGELOG.md` 在 `Unreleased` 记录本次治理变化。 |

### 行为不变量

| ID | 必须始终成立的行为 |
| --- | --- |
| `INV-001` | Validator 继续只接收冻结合同、适用规则和当前结果，不接收历史推理；Failure Analyst 与 Validator 的职责和输入不得混淆。 |
| `INV-002` | 失败诊断不得静默改变目标、合同、正确测试预期、批准范围或 Validator 裁决。 |
| `INV-003` | 不新增任务生命周期状态；诊断期间使用现有 `blocked` 状态并记录 `blocker_type` 与诊断状态。 |
| `INV-004` | 失败计数按任务、合同版本和失败特征累计，只在该特征解决或合同升级后重置。 |
| `INV-005` | 静态脚手架继续不包含可执行命令、预装 linter 或测试框架，不创建 `VERSION`。 |

### 威胁模型

| ID | 范围内的参与者、输入、故障或攻击能力 |
| --- | --- |
| `TM-001` | Worker 可能把合同冲突误判为代码缺陷并持续堆补丁、弱化测试或扩大范围。 |
| `TM-002` | Validator 报告或外部环境故障可能被误当成实现缺陷并触发错误修改。 |
| `TM-003` | Failure Analyst 可能越权修改仓库、替代 Validator 或把不确定结论当成自动修复授权。 |

### 明确排除项

| ID | 不属于当前交付的场景 |
| --- | --- |
| `EX-001` | 不实现可执行诊断器、CLI、自动重试程序或特定平台适配器。 |
| `EX-002` | 不修改 Roadmap、项目规则、参考资料、项目 Skill、实现目录或测试目录。 |
| `EX-003` | 本计划不执行 v0.4.4 的 Git 与 GitHub 发布操作。 |

### Lint/Test 与静态门禁

| ID | 命令或检查 | 预期结果 |
| --- | --- | --- |
| `GATE-001` | `git diff --check` | 无空白错误。 |
| `GATE-002` | Markdown 本地链接检查 | 所有仓库内 Markdown 链接目标存在。 |
| `GATE-003` | 枚举、阈值和角色职责一致性检查 | 五类结果、两修三轮、Failure Analyst/Validator 边界在相关文档中一致。 |
| `GATE-004` | 范围检查 | 未修改合同明确排除的路径，未创建 `VERSION` 或可执行代码。 |

### 合同修订记录

| 版本 | 状态 | 变更、理由与受影响标准 | 人工批准依据 |
| --- | --- | --- | --- |
| `VC-001` | `frozen` | 初始冻结合同 | 用户于 2026-08-24 明确批准并要求实施。 |

## 依赖与隔离

- 显式依赖：v0.4.3 已发布且工作区干净。
- 共享接口和冻结依据：现有冻结验证合同与 Validator 协议保持不变，只增加失败归因层。
- 任务分支：`不适用——用户批准在当前 main 完成正式发布`
- Worktree：`不适用——单任务串行治理变更`
- 集成分支：`不适用`
- 允许写入范围：`AGENTS.md`、`README.md`、`CHANGELOG.md`、`memory.md`、`docs/exec-plans/README.md`、`docs/exec-plans/template.md`、本计划。
- 禁止写入范围：`PLANS.md`、`rules.md`、`skills/`、`references/`、`src/`、`tests/` 及其他既有 completed 计划。

## 功能与测试映射

`不适用——纯治理文档任务。`

## 工具采用情况

- 可执行技术栈：无。
- Linter 配置和命令：无；静态模板不预装 linter。
- 测试框架、定向命令和完整命令：无；使用合同中的静态门禁。

## Subagent 派发

| Attempt | Agent 角色/任务 ID | 合同版本 | 风险与复杂度 | 模型档位 | 推理档位 | 选档理由 | 平台支持 | 写入边界 | 产物与门禁 | 结果 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Validator / ADHOC-0008 | `VC-001` | 高风险治理规则一致性 | `high` | `high` | 必须识别跨文档冲突和越权路径 | 支持 | 只读 | 固定 Validator 输出与静态门禁证据 | `PASS` |

## 工作分解

| 步骤 | 状态（`pending`、`in_progress`、`blocked`、`done`） | 证据 |
| --- | --- | --- |
| 冻结合同并建立活动计划 | `done` | 用户批准计划，Git 门禁通过。 |
| 更新全局治理和执行计划协议 | `done` | `AGENTS.md`、exec-plan 说明和模板已加入归因协议。 |
| 更新用户说明、记忆与 Unreleased | `done` | README、memory 和 Changelog 已同步。 |
| 运行静态检查 | `done` | `git diff --check`、Markdown 链接、术语和排除路径检查通过。 |
| 进行独立 Validator 复核 | `done` | 全新只读 `high/high` Validator 对 `VC-001` 返回 `PASS`。 |
| 归档计划并准备发布任务 | `done` | 计划移至 completed，发布由 `ADHOC-0009` 跟踪。 |

## 当前检查点

- 当前 Loop：完成
- 最近完成：同一 `VC-001` 的全新只读 Validator 返回 `PASS`。
- 当前焦点：无。
- 下一动作：由独立 `ADHOC-0009` 执行 v0.4.4 发布。
- 阻塞项：无。
- blocker_type：`none`
- 诊断状态：`not_triggered`
- 已变更文件：`AGENTS.md`、`README.md`、`CHANGELOG.md`、`memory.md`、`docs/exec-plans/README.md`、`docs/exec-plans/template.md` 和本计划。
- 待验证项：无。

## 失败诊断记录

当前没有失败特征或诊断触发。

## 决策与发现

- 采用用户确认的平衡阈值：“两种修法仍失败、三轮无收敛或直接冲突”。
- 不新增 `diagnosing` 生命周期状态，避免修改 Roadmap 状态协议。
- 发布与远程结果由独立 `ADHOC-0009` 跟踪。

## Validator 固定输出

Validator 必须原样声明 `contract_version`、`overall_verdict`、`criterion_results`、`blocking_findings`、`advisories`、`scope_change_candidates`、`unknowns` 和 `commands_and_evidence`。

## 任务级独立验证

- 逐字冻结合同版本：`VC-001`
- 中性交接：`仅冻结合同、适用规则和当前仓库结果`
- Validator 身份/上下文：全新、只读、未参与实施的独立 Agent；未接收实施推理、计划日志、memory 偏好或历史 Validator 输出。
- 模型/推理档位：`high/high`
- `criterion_results`：`AC-001` 至 `AC-008`、`INV-001` 至 `INV-005`、`TM-001` 至 `TM-003`、`EX-001` 至 `EX-003`、`GATE-001` 至 `GATE-004` 全部 `PASS`。
- `blocking_findings`：`[]`
- `advisories`：`[]`
- `scope_change_candidates`：`[]`
- `unknowns`：`[]`
- `commands_and_evidence`：核对 Git 实际范围、文档语义、全部本地 Markdown 链接、文件模式和排除目录；`git diff --check` 通过，未发现 `VERSION` 或可执行文件。
- `overall_verdict`：`PASS`
- 未满足项与剩余风险：无。

## 集成级独立验证

- `overall_verdict`：`不适用——无并行集成`

## PLANS 回写清单

`不适用——ADHOC 治理任务。`

## 迭代日志

| 日期/上下文 | 已完成事项与证据 | 发现 | 下一动作 |
| --- | --- | --- | --- |
| 2026-08-24 / 当前上下文 | 完成治理文档、静态门禁和独立 `high/high` Validator，`VC-001` 最终 `PASS` | 无阻塞项、建议项、范围候选或未知项 | 归档并转入独立发布任务 |
