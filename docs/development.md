# 开发与验证 agentForge

本页只描述 agentForge 源码仓库自身的开发流程。仓库根目录的 `harness/verify.sh` 和 `harness/verify.ps1` 是维护者测试入口，不会生成到使用者的目标项目。

## 本地验证

macOS 或 Linux：

```sh
./harness/verify.sh
```

该入口依次执行：

1. `sh -n agentforge.sh`，检查 POSIX Shell 语法；
2. `python3 tests/test_payload.py`，验证共享 Payload 和静态契约；
3. `sh tests/test_cli.sh`，执行 POSIX 集成测试；
4. 如果系统安装了 `pwsh`，执行 `tests/test_powershell.ps1`；否则明确报告跳过动态 PowerShell 测试。

Windows PowerShell：

```powershell
powershell -ExecutionPolicy Bypass -File .\harness\verify.ps1
```

Windows 入口执行原生 PowerShell 集成测试。运行 POSIX 完整验证需要 `sh` 和 Python 3；这些只是源码仓库的测试依赖，不是使用 agentForge 生成脚手架的运行时依赖。

## 测试覆盖

当前测试重点覆盖：

- Harness Manifest、模板文件和必需规则的完整性；
- 最多四个交互问题和非交互参数契约；
- `AGENTS.md` 与 `CLAUDE.md` 主入口、兼容入口及项目名渲染；
- Harness 启用和禁用后的生成树；
- 不向目标项目生成 `harness/verify.*` 或旧 Bootstrap 文件；
- 目标路径包含空格、换行等情况；
- 已有文件、非目录父路径和悬空符号链接冲突；
- 冲突发生时保护已有内容并避免常见的部分写入；
- 新建 Git 仓库和已有父级 Git 工作区识别；
- Skill 双份安装、来源记录和可变引用拒绝；
- 在可同时运行 `sh` 与 PowerShell 的环境中，使用包含 Harness 和 Skill 的代表性配置比较两种入口的文件集合及 SHA-256，验证字节级一致性。

测试中的 `AGENTFORGE_SKILL_SOURCE_DIR` 和 `AGENTFORGE_SKILL_COMMIT` 用于提供可控 Skill 夹具、隔离外部网络变化。它们是维护者测试接口，不应作为普通用户的长期配置方式。

## GitHub Actions

`.github/workflows/ci.yml` 在每次 Push 和 Pull Request 上运行：

- Ubuntu：执行 `./harness/verify.sh`；
- Windows：执行 `harness/verify.ps1`。

版本标签还会增加两项发布面验证：直接从该标签对应的 GitHub Raw 地址下载 POSIX 和 PowerShell 启动器，生成测试项目，并确认主要指令、Harness 核心文档存在且没有生成统一验证目录。标签构建同时检查 `VERSION` 与标签名一致。

## 修改要求

- `agentforge.sh` 和 `agentforge.ps1` 必须保持行为等价。
- 生成内容应维护在 `payload/`，不要把大段模板复制进启动器。
- 新增生成文件时，应更新共享 Manifest 或对应清单，并补充 Payload 与两端集成测试。
- 运行时代码继续保持无第三方语言运行时依赖；不能为了实现启动器功能引入 Node.js、Python、`jq` 或包管理器。
- 不得弱化“不静默覆盖已有路径”和“Skill 使用精确 SHA”的安全契约。
- 发布前应在可用平台运行完整验证，并报告实际执行、通过、跳过及剩余风险。

架构概览见 [`../ARCHITECTURE.md`](../ARCHITECTURE.md)，更细的生成与安全设计见 [`implementation.md`](implementation.md)。
