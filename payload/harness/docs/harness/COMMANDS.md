# Development commands

Record only commands verified against the actual repository. Do not invent
commands for an empty project. Add and maintain rows incrementally as the stack
and delivery workflow evolve.

| Purpose | Command | Supported environment | Evidence / adoption point |
| --- | --- | --- | --- |

An empty repository intentionally begins with no command rows. When executable
code is introduced, add the project's actual setup, lint, and test commands in
the same task. Add format, type, build, integration, security, and deployment
commands when applicable. Agents run these commands directly; agentForge does
not provide or require a unified verification wrapper.
