# 执行计划：补充开发、验证与失败归因流程说明

- 状态：`completed`
- 负责人：主协调 Agent
- Roadmap ID：`ADHOC-0010`
- 阶段/子项目：`不适用`
- Batch ID：`不适用`
- 返工来源：`无`
- 开始日期：2026-08-24
- 最后更新：2026-08-24

## 目标与验收标准

在现有失败归因规则上增加稳定的 Mermaid 流程图和纯文本决策表，使后续用户与 Agent都能准确理解开发、独立验证、普通修复、失败诊断和人工合同裁决之间的关系。

## 范围与非目标

- 更新 `AGENTS.md`、`README.md`、exec-plan 说明与模板、`CHANGELOG.md` 和 `memory.md`。
- 不增加独立 HTML、SVG、可执行脚本、linter 或测试框架。
- 不修改 `PLANS.md`、`rules.md`、`skills/`、`references/`、`src/` 或 `tests/`。
- 本任务不提交、推送、创建标签或 GitHub Release；发布继续由 `ADHOC-0009` 跟踪。

## 适用规则与参考资料

- 已批准规则：`rules.md` 当前无项目专属生效规则。
- 按需读取的 references：不适用。

## 冻结验证合同

- 合同版本：`VC-001`
- 合同状态：`frozen`
- 冻结依据：用户于 2026-08-24 批准《v0.4.4：完整开发、验证与失败归因流程说明》并要求实施。
- 冻结时点：2026-08-24，早于本任务文档修改。

### 验收标准

| ID | 必须满足的结果 |
| --- | --- |
| `AC-001` | `README.md` 使用 Mermaid 展示“主 Agent → 开发 Subagents → 独立 Validator → 主 Agent”的主流程以及 `PASS`、`FAIL`、`INCONCLUSIVE` 分支。 |
| `AC-002` | exec-plan 说明使用详细 Mermaid 和决策表展示普通实施修复、两修三轮/直接冲突诊断门、Failure Analyst 五类归因及后续行动。 |
| `AC-003` | `AGENTS.md` 权威定义：`FAIL` 表示标准明确且证据充分的不满足；`INCONCLUSIVE` 表示无法可靠判断，不能自动触发代码修改。 |
| `AC-004` | exec-plan 模板能记录 Validator 结论、依据、主 Agent处理方式、是否触发诊断和下一 Validator 身份。 |
| `AC-005` | 明确 Validator 只依据当前冻结合同、适用规则和当前输出独立裁决；Failure Analyst 才可读取失败历史。仓库中持久化的历史 verdict 只能作为被检查内容，不能作为当前 Validator 的通过证据。 |
| `AC-006` | `CHANGELOG.md` 的 0.4.4 摘要和 `memory.md` 的稳定事实同步反映完整流程说明。 |

### 行为不变量

| ID | 必须始终成立的行为 |
| --- | --- |
| `INV-001` | Validator 不负责解释反复失败根因，不接收实施辩解、倾向结论或历史 verdict 作为裁决依据。 |
| `INV-002` | Failure Analyst 不修改文件、不替代 Validator、不裁决 `PASS`；规划或合同冲突仍须人工批准。 |
| `INV-003` | “两种实质不同修法、三轮无收敛或直接冲突”三个触发条件保持不变，普通一次性实施错误不被过早升级。 |
| `INV-004` | 不新增任务生命周期状态、独立 HTML 或可执行工具，不修改排除路径。 |

### 威胁模型

| ID | 范围内的参与者、输入、故障或攻击能力 |
| --- | --- |
| `TM-001` | 用户或 Agent 可能把 `INCONCLUSIVE` 误解为功能已经失败并错误修改代码。 |
| `TM-002` | 主 Agent可能把任意一次 `FAIL` 都升级为规划缺陷，或在反复失败时仍无限修补实现。 |
| `TM-003` | 新 Validator 可能依赖仓库内的历史 `PASS` 记录而不是独立验证当前输出。 |

### 明确排除项

| ID | 不属于当前交付的场景 |
| --- | --- |
| `EX-001` | 不新增独立 HTML、图片资产、可执行诊断器、CLI 或平台适配器。 |
| `EX-002` | 不修改 Roadmap、项目规则、知识库、项目 Skill、实现或测试目录。 |
| `EX-003` | 本任务不执行 Git 提交、推送、标签或 GitHub Release。 |

### Lint/Test 与静态门禁

| ID | 命令或检查 | 预期结果 |
| --- | --- | --- |
| `GATE-001` | `git diff --check` | 无空白错误。 |
| `GATE-002` | Markdown 链接和 Mermaid 围栏检查 | 本地链接目标存在，Mermaid 块完整且使用 GitHub 支持的基础 flowchart 语法。 |
| `GATE-003` | 术语和场景一致性检查 | 三类 Validator 结论、三项诊断条件、五类 Failure Analyst 归因在相关文档中一致。 |
| `GATE-004` | Git 范围检查 | 未修改排除路径，未创建独立 HTML、`VERSION` 或可执行文件。 |

### 合同修订记录

| 版本 | 状态 | 变更、理由与受影响标准 | 人工批准依据 |
| --- | --- | --- | --- |
| `VC-001` | `frozen` | 初始冻结合同 | 用户于 2026-08-24 明确批准并要求实施。 |

## 依赖与隔离

- 显式依赖：`ADHOC-0008` 已建立失败归因规则；`ADHOC-0009` 保持 blocked，等待本任务完成和 `VC-002` 重新 preflight。
- 共享接口和冻结依据：保持现有 `PASS`、`FAIL`、`INCONCLUSIVE`、Failure Analyst 五类归因和两修三轮诊断门。
- 任务分支：`不适用——当前串行治理变更`
- Worktree：当前仓库根目录。
- 集成分支：`不适用`
- 允许写入范围：`AGENTS.md`、`README.md`、`CHANGELOG.md`、`memory.md`、`docs/exec-plans/README.md`、`docs/exec-plans/template.md`、本计划和 `ADHOC-0009` 的协调链接。
- 禁止写入范围：`PLANS.md`、`rules.md`、`skills/`、`references/`、`src/`、`tests/` 和其他既有 completed 计划。

## 功能与测试映射

`不适用——纯治理文档任务。`

## 工具采用情况

- 可执行技术栈：无。
- Linter 配置和命令：无；静态模板不预装 linter。
- 测试框架、定向命令和完整命令：无；使用静态门禁。

## Subagent 派发

| Attempt | Agent 角色/任务 ID | 合同版本 | 风险与复杂度 | 模型档位 | 推理档位 | 选档理由 | 平台支持 | 写入边界 | 产物与门禁 | 结果 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Validator / ADHOC-0010 | `VC-001` | 跨文档流程、权限和术语一致性 | `high` | `high` | 错误流程会导致后续 Agent 越权或误修 | 支持 | 只读 | 固定 Validator 输出与静态证据 | `PASS` |

## 工作分解

| 步骤 | 状态（`pending`、`in_progress`、`blocked`、`done`） | 证据 |
| --- | --- | --- |
| 冻结合同并恢复现有工作 | `done` | Git 门禁通过，既有变更范围与 active 计划已核对。 |
| 更新权威判定规则和 Validator 输入边界 | `done` | `AGENTS.md` 已增加权威结论表和历史 verdict 输入边界。 |
| 增加 README 与 exec-plan Mermaid/决策表 | `done` | 两份文档已包含总流程、详细流程和纯文本决策表。 |
| 更新模板、Changelog 和 memory | `done` | 模板已增加结论处理表，版本摘要与稳定事实已同步。 |
| 运行静态检查 | `done` | `git diff --check`、Markdown 本地链接、2 个 Mermaid 块、术语、文件模式和变更范围检查通过。 |
| 进行独立 Validator 复核 | `done` | 全新只读 `high/high` Validator 对 `VC-001` 返回 `PASS`。 |
| 归档并恢复 `ADHOC-0009` | `done` | 本计划归档，发布计划依赖解除并进入 `VC-002` preflight。 |

## 当前检查点

- 当前 Loop：1
- 最近完成：全新独立 Validator 对全部 `AC-*`、`INV-*`、`TM-*`、`EX-*` 和 `GATE-*` 返回 `PASS`。
- 当前焦点：任务完成并归档。
- 下一动作：恢复 `ADHOC-0009 VC-002` 发布预检。
- 阻塞项：无。
- blocker_type：`none`
- 诊断状态：`not_triggered`
- 已变更文件：`AGENTS.md`、`README.md`、`CHANGELOG.md`、`memory.md`、exec-plan 说明、模板、本计划和 `ADHOC-0009` 协调计划。
- 待验证项：无。

## 失败尝试与诊断

当前没有本任务失败特征或诊断触发。

## 决策与发现

- Mermaid 只使用 GitHub 支持的基础 `flowchart TD`、节点和条件分支；纯文本决策表作为不支持 Mermaid 环境的降级说明。
- 不将先前 HTML 可视化复制进仓库。
- `ADHOC-0009 VC-002` 由用户单独批准，完成本任务后使用全新 Validator 重新 preflight。

## Validator 固定输出

Validator 必须原样声明 `contract_version`、`overall_verdict`、`criterion_results`、`blocking_findings`、`advisories`、`scope_change_candidates`、`unknowns` 和 `commands_and_evidence`。

## 任务级独立验证

- 逐字冻结合同版本：`VC-001`
- 中性交接：`仅冻结合同、适用规则和当前仓库结果`
- Validator 身份/上下文：全新、只读、未参与实施的独立上下文。
- 模型/推理档位：`high/high`
- `overall_verdict`：`PASS`
- `criterion_results`：`AC-001` 至 `AC-006`、`INV-001` 至 `INV-004`、`TM-001` 至 `TM-003`、`EX-001` 至 `EX-003`、`GATE-001` 至 `GATE-004` 全部 `PASS`。
- `blocking_findings`：无。
- `advisories`：未安装 Mermaid CLI，合同只要求的基础 `flowchart TD` 语法已通过逐块静态检查；其他未跟踪 exec plan 未作为本任务裁决证据。
- `scope_change_candidates`：无。
- `unknowns`：无。
- `commands_and_evidence`：`git status --short`、`git diff --name-status`、`git diff --check`、本地链接目标、Markdown 围栏、关键词一致性、排除路径、HTML、`VERSION` 和可执行文件检查均通过。

## 集成级独立验证

- `overall_verdict`：`不适用——无并行集成`

## PLANS 回写清单

`不适用——ADHOC 治理任务。`

## 迭代日志

| 日期/上下文 | 已完成事项与证据 | 发现 | 下一动作 |
| --- | --- | --- | --- |
| 2026-08-24 / 当前上下文 | 完成 Mermaid、决策表、模板和权威规则；静态门禁与独立 Validator `PASS` | Mermaid CLI 未安装，但基础语法和围栏已完成静态核对 | 归档任务并恢复 v0.4.4 发布预检 |
