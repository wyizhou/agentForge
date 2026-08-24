# 执行计划

执行计划回答“当前任务如何完成”，并外置需求、步骤、检查点、Agent 派发和验证证据。产品与工程方向保存在根目录 `PLANS.md`。

## 创建时机与命名

- Git 门禁通过后，除纯概念问答和简单状态查询外，每个仓库任务都要创建或恢复计划。
- Roadmap 任务只有进入 ready batch、即将开始修改仓库时才创建详细计划；阶段获批时不得提前批量创建未来计划。
- Roadmap 计划使用 `<stage>-<initiative-slug>-<sequence>-<feature-slug>.md`。
- 返工使用原文件名加 `-r01`、`-r02` 等后缀，并链接原 completed 计划。
- 非 Roadmap 工作使用 `ADHOC-<sequence>-<slug>.md`。
- 历史计划可以保留旧名称，不需要机械改名。

## 生命周期

- 非终态计划保存在 `active/`，终态计划移至 `completed/`。
- 状态使用 `planned`、`ready`、`active`、`blocked`、`validating`、`validated`、`integrating`、`completed`、`rework` 和 `cancelled`。
- 主协调 Agent 是计划、Roadmap 和协调状态的唯一写入者；Worker 和 Validator 返回结构化事实。
- `memory.md` 只链接活动计划；步骤和检查点只保存在计划中，完成后删除 memory 指针。

```text
planned → ready → active → validating → validated → integrating → completed
                    ↕           │                         │
                  blocked       └── FAIL → 记录与诊断门   └── FAIL → 记录与诊断门

completed → rework → active
active|blocked|validating|validated|integrating → cancelled
```

任务级 Validator `PASS` 只进入 `validated`。并行结果集成后，集成级 Validator `PASS` 才能完成、归档并勾选 `PLANS.md`。

## 冻结验证合同

全局验证纪律由 `AGENTS.md` 定义；每个任务具体的验收范围保存在自身 exec plan 的“冻结验证合同”中，不建立独立合同文件。

- 用户明确提出任务或批准计划时，同时冻结初始版本 `VC-001`，Worker 开始修改前合同必须为 `frozen`。
- 合同使用 `AC-*` 验收标准、`INV-*` 行为不变量、`TM-*` 威胁模型、`EX-*` 明确排除项和 `GATE-*` lint/test 门禁，并记录冻结依据和修订历史。
- Validator 可以用新方法验证已有标准，但不得增加验收要求。阻塞发现必须绑定 `AC-*`、`INV-*`、`TM-*`、`RULE-*` 或 `GATE-*`。
- `EX-*` 或超范围发现只进入 `ADVISORY`/`SCOPE_CHANGE_CANDIDATE`；合同含糊或阻塞发现未绑定标准时保持 `INCONCLUSIVE`/`validating`。
- 冻结后只有人工明确批准才能升级合同版本。新版本必须记录变更和批准依据，旧版本验证随即失效。
- 重验证逐字沿用同一合同版本，且不接收历史 Validator 输出。合同争议不触发模型升级或自动实现修改。

## 失败诊断门

有效失败不能无条件进入下一轮修复。计划按“任务 + 合同版本 + 失败特征”记录每次修法和验证结果；失败特征由关联标准和可观察的不符合结果组成。

| Validator 结论 | 判断条件 | 主协调 Agent处理 |
| --- | --- | --- |
| `PASS` | 全部适用标准和门禁通过，且没有有效阻塞发现 | 进入集成、归档、发布或下一任务。 |
| `FAIL` | 当前输出明确违反至少一项已有标准，且阻塞发现已经绑定标准并提供可复核证据 | 记录失败特征；未达到诊断条件时修复明确的实施错误，达到条件时先启动 Failure Analyst。 |
| `INCONCLUSIVE` | 证据不足、检查无法运行、合同含糊或冲突，或报告协议无效，当前无法可靠判断 | 禁止直接修改实现；补足证据、等待环境变化或请求人工澄清。直接发现合同冲突时立即启动 Failure Analyst。 |

```mermaid
flowchart TD
    A["主 Agent<br/>冻结合同并派发开发"] --> B["开发 Subagents<br/>实现与测试"]
    B --> C["全新独立 Validator<br/>合同 + 规则 + 当前输出"]
    C -->|PASS| D["主 Agent<br/>进入下一步"]
    C -->|INCONCLUSIVE| E{"无法判断的原因"}
    E -->|证据不足| F["补足可验证证据"]
    E -->|环境不可用| G["等待外部状态变化"]
    E -->|标准直接冲突| H["blocked<br/>启动 Failure Analyst"]
    F --> C
    G --> C
    C -->|FAIL| I{"达到诊断条件？"}
    I -->|否| J["明确实施错误<br/>原合同与范围内修复"]
    J --> C
    I -->|两种修法仍失败| H
    I -->|三轮无收敛| H
    I -->|直接冲突| H
    H --> K{"Failure Analyst 归因"}
    K -->|IMPLEMENTATION_DEFECT| L["允许一次针对性修复"]
    L --> C
    K -->|PLAN_CONTRACT_CONFLICT| M["保持 blocked<br/>用户批准后升级合同"]
    K -->|VALIDATION_DEFECT| N["不改实现<br/>更换全新 Validator"]
    N --> C
    K -->|ENVIRONMENT_FAILURE| O["外部状态变化后重试"]
    K -->|UNDETERMINED| P["保持 blocked<br/>请求人工决定"]
```

出现以下任一情况时，将任务设为 `blocked`、`blocker_type` 设为 `DIAGNOSIS_PENDING`：

- 同一失败特征采用两种实质不同修法仍失败；
- 连续三轮修改和验证没有消除该特征、没有持续减少有效阻塞项，或在同一组标准间往返；
- 直接发现冻结目标、标准、依赖或范围无法同时满足。

全新、只读、未参与实施的 `high/high` Failure Analyst 可以读取相关失败历史，固定归因为 `IMPLEMENTATION_DEFECT`、`PLAN_CONTRACT_CONFLICT`、`VALIDATION_DEFECT`、`ENVIRONMENT_FAILURE` 或 `UNDETERMINED`。它只负责找原因，不得修改文件、改变合同、替代 Validator 或裁决 `PASS`。

- 可安全修复的实施缺陷只允许一次诊断后修复；相同特征继续失败则停止并请求人工决定。
- 规划或合同冲突必须给出最小冲突集合和处理选项，只有人工批准才能升级合同。
- 验证缺陷使用同一合同交给全新 Validator，不修改实现。
- 环境故障只有确认外部状态变化后才允许一次重试。
- 无法确定时保持 `blocked`，不得猜测或降低标准。

Failure Analyst 与 Validator 严格隔离：前者为了归因可以接收尝试历史；后者为了独立裁决仍只能接收冻结合同、适用规则和当前结果。

主协调 Agent根据 exec plan 中的失败记录判断是否达到诊断条件，Validator 不负责决定是否升级为 Failure Analyst。仓库中已经持久化的历史 Validator 记录可以作为当前变更内容接受格式和风险检查，但其历史 verdict 不得成为新 Validator 的裁决证据。

## 并行与写入隔离

- 计划记录 Roadmap ID、Batch ID、显式依赖、分支、worktree、集成分支、写入范围和禁止范围。
- 同一 batch 的活动任务不得拥有重叠写入范围。
- Worker 只修改任务合同批准的代码和测试；协调文档由主协调 Agent统一维护。
- 依赖、接口或写入冲突出现时停止相关并行工作，并将任务改为 `blocked` 或串行执行。

## Agent 派发与升级

- 每个 subagent 派发记录抽象模型档位和推理档位：`low`、`medium`、`high`；不得写入具体模型名称。
- 记录选档依据、平台支持情况、输入、权限、预期产物和 lint/test 门。
- 平台无法控制某个维度时记录 `platform-default`。
- 只有能力不足时才使用全新 Agent 按规定阶梯升级；合同缺失、含糊、范围争议或超范围发现交由合同裁决和人工决定，不得借升级扩大要求。
- `high/high` 仍无法满足合同后停止自动重试并标记 `blocked`。
- Failure Analyst 固定使用 `high/high`，因为其结果可能停止实施或触发人工合同裁决；它不参与能力升级链。

## 检查点与回写

- 同一计划最多一个步骤为 `in_progress`。
- 检查点记录 `blocker_type` 和诊断状态；诊断状态使用 `not_triggered`、`pending`、`in_progress` 或 `completed`。
- 完成关键步骤、出现阻塞、准备交接以及上下文结束前更新当前检查点。
- 每个上下文追加一条简短迭代日志，不保存完整对话。
- 恢复时以 Git 和文件系统证据核对检查点；仓库事实优先，并记录偏差。
- 集成验证通过后，主协调 Agent按顺序归档计划、勾选 Roadmap 任务、重新计算父级状态并删除 memory 指针。

## 验证证据

- Validator 必须是全新、只读且未参与实施的 Agent，只接收逐字冻结合同、适用规则和当前结果。
- Validator 固定返回 `contract_version`、`overall_verdict`、`criterion_results`、`blocking_findings`、`advisories`、`scope_change_candidates`、`unknowns` 和 `commands_and_evidence`。
- 计划分别保存任务级和集成级 Validator 的档位、合同版本、逐项结果、命令、证据、`PASS`/`FAIL`/`INCONCLUSIVE` 和剩余风险。
- 未绑定冻结标准的阻塞发现使报告无效并按 `INCONCLUSIVE` 处理，不得触发代码、测试、规则或合同修改。
- Validator 不可用或结果为 `INCONCLUSIVE` 时不得完成计划。
