# Harness

The Harness turns project intent into repository-local instructions and durable
documentation that coding agents can inspect and improve.

It is progressive: an empty repository begins with durable delivery rules and
no assumed technology stack. It then records the project's real tests, linting,
type checks, builds, security checks, and CI as those controls become
applicable.

- `DELIVERY_RULES.md` defines the mandatory delivery contract.
- `COMMANDS.md` records commands that are actually supported by the project.
- `CHECKS.md` maps important invariants to current enforcement.

There is no separate bootstrap phase. Coding agents must evolve the Harness in
the same task that introduces the behavior or technology requiring a new check.
They run the documented project-native commands directly; agentForge does not
generate a verification wrapper.
