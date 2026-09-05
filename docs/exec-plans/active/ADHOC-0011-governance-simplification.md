# 执行计划：治理精简与一致性修复

- 任务 ID：`ADHOC-0011`
- 状态：`validated`
- 负责人：主协调 Agent
- 执行方式：串行修改治理文档；独立只读验证，不涉及开发 worktree 集成
- 开始日期：2026-09-05
- 最后更新：2026-09-05
- 批准依据：用户明确要求实施《agentForge 治理精简与一致性修复计划》，包含两次本地提交和普通远程推送，不包含版本发布。
- 基准提交：`00e03cfb6e25e35967e414bea9233dc7b33929d5`

## 目标与范围

精简重复治理指令，按影响区分任务流程，修复串行完成、角色输入、阻塞恢复和选档矛盾；保留授权、测试完整性、冻结验收、独立验证和失败诊断边界。

允许修改：根目录 AGENTS、README、PLANS 维护说明、memory、CHANGELOG 的 Unreleased，exec-plans 的 README、template、active/completed 说明及本计划。禁止修改：已有 completed 计划、rules、skills、references、src、tests、许可证、CLAUDE 引用入口及已发布版本历史。只追加本计划的归档文件，不创建工具或产品规划。

## 冻结验证合同

- 合同版本：`VC-001`
- 合同状态：`frozen`
- 冻结依据：用户于 2026-09-05 明确要求实施上述完整计划。以下标准均来自该计划，没有新增业务假设。
- 冻结时点：实现修改前。
- 验证范围：当前治理文档及其实施元数据；提交、推送是主 Agent 在独立验证之后执行并客观核对的交付动作，不要求 Validator 证明未来动作或历史 verdict。

### 验收标准

| ID | 必须满足的结果 | 来源 |
| --- | --- | --- |
| AC-001 | AGENTS 保留核心纪律、权限边界和角色入口，完整执行协议集中在 exec-plans README；模板采用必填核心与按需章节，普通用户说明保留流程图和决策表。 | 批准计划二.1 |
| AC-002 | 单次只读/纯拼写排版可轻量处理；命令、链接目标、配置、功能或治理语义变更必须正式执行，不确定按正式流程；跨会话只读有检查点，本次必须独立验证。 | 批准计划二.2 |
| AC-003 | 串行任务适用验证 PASS 后可完成；实际并行仍两层验证；有证据的环境恢复和获批合同修订可按原边界恢复，PLANS 与相关状态说明一致且不编造 Roadmap。 | 批准计划二.3 |
| AC-004 | 各角色按需读取；Validator 不加载 memory、计划历史、主 Agent 或旧 Validator 推理；Failure Analyst 可以读取相关失败历史但不得实施或裁决 PASS。 | 批准计划二.3、二.4 |
| AC-005 | 冻结标准可追溯至用户请求、批准计划或生效规则；AI 方法不自动变成要求，影响验收的未知事项先澄清；合同修订保留人工批准和版本机制。 | 批准计划二.4 |
| AC-006 | 验证绑定合同版本、基准提交及受审文件清单和内容摘要，包含未跟踪文件与删除项；语义变更使相关证据失效，仅真实记录、状态和归档回写免递归验证但须查差异和链接。 | 批准计划二.4 |
| AC-007 | 保留抽象档位、最低充分和角色能力底线，删除固定六步升级路线，允许直接升级且不降已选维度；不支持时记录 platform-default，合同/环境问题不借选档解决。 | 批准计划二.5 |
| AC-008 | 保留授权边界、测试与 lint 完整性、三个 Validator 结论、原有诊断触发条件和停止规则；不改变目录职责或引入脚本、工具、版本。 | 批准计划一、二.4、二.5 |
| AC-009 | 相关文档、维护说明与 Unreleased 同步；当前任务记录可恢复且不声称未发生的验证或推送，不重写既有归档和正式版本历史。 | 批准计划三、四 |

### 不变量与排除项

- INV-001：不能因精简而取消语义变更的独立验证、擅自增加验收要求或弱化正确测试。
- EX-001：无可执行代码，不新增功能测试目录、linter、测试框架、脚本或 CI；保留现有空目录。
- EX-002：不创建版本、标签、Release 或新产品 Roadmap，不评价模型厂商优劣。
- EX-003：Validator 不执行提交、推送或归档，不以旧 verdict 证明本次通过；这些后续操作由主 Agent 核对。

### 检查门禁

| ID | 检查 | 预期 |
| --- | --- | --- |
| GATE-001 | Git 差异及受保护文件与基准比较，包含未跟踪路径 | 仅获批文档和本计划发生变化 |
| GATE-002 | Markdown 本地链接与锚点、代码围栏、Mermaid 语法 | 引用可解析、格式和图语法正确 |
| GATE-003 | 逐项走查 AC-002 至 AC-008 的流程场景和跨文档术语 | 无矛盾、无越权豁免、无失效 PASS 复用 |
| GATE-004 | `git diff --check` | 成功，无空白错误 |

### 合同修订记录

| 版本 | 状态 | 内容 | 批准依据 |
| --- | --- | --- | --- |
| VC-001 | frozen | 初始合同 | 用户明确要求实施完整计划 |

## 工作分解

| 步骤 | 状态 | 证据 |
| --- | --- | --- |
| Git 门禁、读取规则和建立计划 | done | Git 可用，仓库根目录匹配；main 与 live origin/main 均为基准 SHA，工作区初始干净 |
| 精简协议、入口和模板，同步相关说明 | done | 入口 76 行、模板 80 行，详细协议集中，相关说明同步 |
| 静态自检和全新独立 Validator | done | V1 独立 PASS，全部适用 AC/GATE 满足 |
| 提交实现、普通推送并核对远端 | in_progress | 已批准，待执行和核对 |
| 记录实际结果、归档、提交归档并再次推送核对 | pending | 尚未执行 |

## 当前检查点

- 当前 Loop：1
- 最近完成：V1 对受审快照 R1 返回独立 PASS。
- 当前焦点：首次提交与普通推送。
- 下一动作：核对受审快照和远端后执行首次提交。
- 阻塞项：无；blocker_type：`none`；诊断状态：`not_triggered`。
- 待验证项：提交、远端接收与最终归档同步事实；独立文档验收已通过。

## Agent 派发与验证记录

### 受审快照 R1

基准：`00e03cfb6e25e35967e414bea9233dc7b33929d5`；合同段摘要边界为“## 冻结验证合同”至“## 工作分解”之前；计划其他段仅作协调差异检查。所有受审当前文件模式为 644，没有删除或符号链接变化。

| 受审路径 | SHA-256（计划仅冻结段） |
| --- | --- |
| `AGENTS.md` | `5720cfb3e1997f398ebc979c52a1a646b171d04bfc2fdc18c2191bb67bb38bbc` |
| `CHANGELOG.md` | `a33fa34bf46c066a0b5a054e9fd12f6a31bc89a87ceb0c3c66bdcf158e8cfd8e` |
| `PLANS.md` | `61a4affef0378b14be440d39311eb1033b3c2a469e86ebae411079dedea12a6a` |
| `README.md` | `d9943ac89f4287aaabff57b2eb498e90df3d8dd664c7b71a4db578ea7356b3c2` |
| `docs/exec-plans/README.md` | `27f59d8861718c7306901a88f280dc5731b53fedad974199e2fa6fe2630e619e` |
| `docs/exec-plans/active/ADHOC-0011-governance-simplification.md` | `47233d3a9faca1af43dcd601ea64f61f4f4393170768940cf7ff19f81c32acb4` |
| `docs/exec-plans/active/README.md` | `86af2af79aae4dae34a950816f97424f0eff6c9a46c52779081e7423b8c63151` |
| `docs/exec-plans/completed/README.md` | `5d48ebe621f5dac3741aa18121ce9767384933565fad805a27e923f2cf059d08` |
| `docs/exec-plans/template.md` | `7a348f03180a18ce239985775b905aa8cc6bc282dd066915628a3b523f4725cd` |
| `memory.md` | `8c31a2483d61084881ec8e304d63b6fff7f0860d656621a53fa114e5f92fa7c8` |

### 主 Agent 静态检查

- `git diff --check`：exit 0。
- 临时检查 `node /tmp/agentforge-check-YtbIva/check.mjs`：26 个 Markdown、18 个本地链接及锚点，错误 0；已验证允许路径、空目录、历史计划和正式 CHANGELOG 未改。
- 临时检查 `node /tmp/agentforge-check-YtbIva/mermaid-check.mjs`：2 个 Mermaid 图均被解析并渲染为 SVG；exit 0。检查依赖仅放在仓库外临时目录，没有加入模板或安装为项目工具。
- 静态场景走查：一字命令/链接修改仍正式；串行 PASS 与并行两层状态不同；环境恢复可按受阻步骤重试；未批准假设阻塞冻结；语义改动使 PASS 失效，真实回写免递归；选档不降已选维度。独立结果尚待验证。
- 当前没有代码技术栈，功能 lint/test 不适用，不新增工具或测试目录。

### 独立验证派发 V1

- 角色/任务：Validator / ADHOC-0011；目标、验收、范围和门禁均引用 VC-001。
- 风险与选档：治理语义变更可能影响后续所有项目，选择 high/high；平台支持明确选择模型能力及推理强度，具体运行时映射不写入仓库。
- 上下文：全新、不继承实施历史；只读，未参与实施；允许检查当前交付及必要临时验证，不允许修改仓库文件或执行 Git 写操作。
- 输入：逐字 VC-001、适用规则、仓库基准和受审结果，不输入本节的自检结果、日志或历史推理。
- 返回产物：已收到协议八字段报告与可复核证据，见下文。

### Validator V1 报告

- 身份：`/root/governance_validator_v1`；全新独立上下文，不继承实施历史，high/high；只读，未参与实施。
- 主 Agent 处理：收到有效 PASS，未触发诊断；受审快照 R1 不变。以下按协议八字段保存报告及证据。

#### contract_version

`VC-001`；Validator 核对冻结段与派发合同逐字一致。

#### overall_verdict

`PASS`。当前快照满足全部适用标准和门禁，没有有效阻塞发现；此结论不代表提交、推送、归档或发布已经完成。

#### criterion_results

| 标准 | 结果 | 独立证据 |
| --- | --- | --- |
| AC-001 | PASS | AGENTS 保留 Git 门禁、授权、角色入口、工程边界与目录职责；详细流程集中于执行协议。模板采用核心与按需章节，README 保留决策表及图。 |
| AC-002 | PASS | 单次只读/纯排版可轻量，命令、链接目标、配置及治理语义不可豁免；跨会话只读有检查点；本任务 validating 并独立验证。 |
| AC-003 | PASS | 协议区分串行和实际并行；PLANS、active/completed 说明同步；合同批准修订和有证据环境恢复后有明确恢复条件。PLANS 未新增 Roadmap。 |
| AC-004 | PASS | 角色最小输入、关闭实施历史继承；memory/协调段仅当前差异审计；Failure Analyst 可读取失败历史但不能实施或 PASS。 |
| AC-005 | PASS | 标准需授权来源；未知验收先澄清，AI 方法不自动成为要求；修订须批准、保留原文并升级。当前标准均有来源。 |
| AC-006 | PASS | 合同摘要、基准、完整文件清单、删除/重命名/模式信息齐备；语义变更使相关 PASS 失效，真实回写仍检查差异和链接；独立核对 10 项摘要与 R1 一致。 |
| AC-007 | PASS | 保留最低充分、角色底线、high/high 停止及 platform-default；删除固定路线，直接升级且不降维度；合同和环境问题不借升级解决。 |
| AC-008 | PASS | 对照基准，授权、测试完整性、三个裁决、三个诊断触发条件、一次针对性修复及重复失败停止均保留；目录、工具、正式版本历史不变。 |
| AC-009 | PASS | 文档及 Unreleased 同步；检查时计划 validating、提交推送 pending，可恢复且无未来成功声明；历史未改。 |
| INV-001 | PASS | 无取消独立验证、增加验收或弱化正确测试条款。 |
| EX-001 | PASS | 无新增代码、框架、脚本、CI 或功能测试目录；占位与基准一致。 |
| EX-002 | PASS | 未改正式版本、未新增 Roadmap 或模型厂商评价。 |
| EX-003 | PASS | Validator 未修改文件、执行 Git 写入或用旧 verdict 认证当前结果。 |
| GATE-001 | PASS | 9 个 tracked 修改及 1 个 untracked 计划均在允许范围；其余 tracked 与基准逐字一致，无删除、重命名、模式或符号链接变化。 |
| GATE-002 | PASS | 26 个 Markdown 的 18 个本地链接及锚点错误 0；当前交付 5 个围栏均闭合；2 个图解析并生成 SVG。 |
| GATE-003 | PASS | 下列场景无跨文档矛盾、越权豁免或失效 PASS 复用。 |
| GATE-004 | PASS | git diff --check 两次 exit 0，无输出。 |

独立场景走查：一字语义变化仍正式；跨会话只读保存检查点；串行 PASS 不虚构集成；并行任务 PASS 仅 validated；合同含糊或无标准阻塞为 INCONCLUSIVE；两种修法/三轮无收敛/直接冲突触发诊断；诊断后一次安全修复仍失败则停止；环境无变化不重试、恢复有证据后按原步骤一次重试；合同冲突人工批准升级再实施；语义改动重验、真实回写仍查差异；升级不降维度，合同/环境不升级。

#### blocking_findings

无。

#### advisories

无。

#### scope_change_candidates

无。

#### unknowns

- 检查时提交、推送和归档尚待主 Agent 执行，不在 Validator 对未来动作的证明范围内。
- 无可执行技术栈，功能 lint/test 不适用。
- 图检查验证解析及 SVG 生成，不声明进行了人工美观审查。
- 遵守只读操作边界；平台未提供操作系统级只读沙箱，不宣称存在该保障。

#### commands_and_evidence

日期：2026-09-05；根目录：`/Volumes/DiskOther/Code/agentForge`；分支 main；检查时 HEAD 与基准均为 `00e03cfb6e25e35967e414bea9233dc7b33929d5`。

| 实际命令/检查 | 退出结果与证据 |
| --- | --- |
| pwd、git --version、git rev-parse --show-toplevel、git branch --show-current | 均 exit 0，Git 2.50.1，项目根目录和 main 确认。 |
| git status --short、git ls-files、git diff --name-status 基准、git diff --summary 基准 | 均 exit 0；9 tracked 修改、1 untracked，无删除/重命名/模式变化。 |
| git diff 基准 -- AGENTS.md docs/exec-plans/README.md | exit 0，结合当前产物和基准条款核对规则迁移与保留。 |
| git diff 基准 -- PLANS.md memory.md CHANGELOG.md docs/exec-plans/active/README.md docs/exec-plans/completed/README.md | exit 0；仅允许的维护说明、事实/指针和 Unreleased；memory 只审计差异。 |
| 独立 Node 标准输入程序：用 Git 获取完整清单、crypto SHA-256、git show 基准:path 比较受保护文件 | exit 0，changed=10、tracked=9、untracked=1、模式均 644、protected differences=0；摘要与 R1 表完全相同，计划仅冻结段。 |
| 独立 Node Markdown 链接/标题锚点/围栏检查 | exit 0；markdownFiles=26、localLinks=18、errors=[]；当前交付围栏 5、未闭合 0；不使用历史叙述作为验收证据。 |
| 独立 Node + Playwright headless Chromium，分别调用 mermaid.parse 与 mermaid.render | exit 0；两图 flowchart-v2 且生成 SVG；README SVG 23340 字符，协议 SVG 48990 字符。 |
| git diff --check（两次） | 均 exit 0，无输出。 |
| 最终 git status --short | exit 0，文件范围不变，未产生仓库检查产物。 |

独立检查只使用临时 Mermaid 库和已提供的 Playwright 运行时，没有运行或读取主 Agent 的临时检查脚本。受审完整 SHA-256 清单见 R1；Validator 独立计算并核对一致。SVG 长度不同于主 Agent 检查不作为内容摘要，受审 Markdown 的 SHA-256 一致。

### 验证后协调回写

本节报告、状态与步骤是实际收到结果后的协调回写；未改变合同、治理正文或其他受审交付。提交前重新核对 R1 摘要、允许路径及 Markdown 链接，禁止混入未验证语义变化。

## 迭代日志

| 日期/上下文 | 已完成与证据 | 发现 | 下一动作 |
| --- | --- | --- | --- |
| 2026-09-05 / Loop 1 | Git 门禁、实施、自检及全新独立 V1 PASS | 验证无阻塞，受审内容未变 | 执行获批的两次提交与普通推送，逐次核对 |
