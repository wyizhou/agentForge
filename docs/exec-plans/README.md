# 执行计划

执行计划将任务状态外置，使全新上下文无需依赖对话历史即可继续工作。Git 门禁通过后，除简单状态查询外，每个仓库分析或修改任务都要创建计划。

## 生命周期

- 从 `template.md` 开始，文件命名为 `active/YYYY-MM-DD-short-slug.md`；重名时增加数字后缀。
- 状态为 `active`、`blocked` 或 `validating` 时，计划保留在 `active/`。
- 状态变为 `completed` 或 `cancelled` 后，将计划移至 `completed/`，并保留验证证据和迭代历史。
- 主协调 Agent 是计划的唯一写入者；工作 Agent 和 Validator 只返回结构化事实。
- 在 `memory.md` 中链接活动计划，但具体步骤和检查点只保存在计划内；任务完成后删除 memory 链接。

## 状态流转

```text
active <-> blocked
active -> validating
validating -> active       # 验证失败，需要修复
validating -> completed    # 独立 Validator 返回 PASS
active|blocked|validating -> cancelled
```

同一时间只能有一个步骤处于 `in_progress`。完成关键步骤、出现阻塞、准备交接以及上下文结束前都要更新检查点。每个上下文追加一条简短迭代记录，包含完成事项、证据、发现和下一动作。

恢复任务时，将检查点与 Git 和文件系统证据进行比较。仓库事实优先，继续前先记录所有偏差。

## 验证要求

产生结果变更的计划必须保持 `validating`，直到全新、只读且独立的 Validator 返回 `PASS`。计划中记录中性输入合同、实际命令、观察结果、结论和剩余风险。Validator 不可用或结果为 `INCONCLUSIVE` 均不视为通过。
