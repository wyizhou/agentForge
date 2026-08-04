# Development commands

Record only commands verified against the actual repository. Do not invent
commands for an empty project. Add and maintain rows incrementally as the stack
and delivery workflow evolve.

| Purpose | Command | Supported environment | Evidence / adoption point |
| --- | --- | --- | --- |
| Full verification | `sh ./harness/verify.sh` or `.\harness\verify.ps1` | POSIX / Windows | Generated Harness structure; extend as checks become applicable |

When executable code is introduced, add the project's actual setup, lint, and
test commands in the same task. Add format, type, build, integration, security,
and deployment checks when applicable.
