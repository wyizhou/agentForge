#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
status_file="$repo_dir/harness/STATUS"

if [ ! -f "$status_file" ]; then
  echo "ERROR: harness/STATUS is missing." >&2
  exit 1
fi

status=$(tr -d '\r\n' < "$status_file")
if [ "$status" != "READY" ]; then
  echo "ERROR: Harness is $status." >&2
  echo "Run the prompt in docs/harness/BOOTSTRAP_PROMPT.md with your AI coding agent." >&2
  exit 1
fi

# AGENTFORGE:PROJECT_CHECKS:START
echo "ERROR: Project checks have not been configured." >&2
echo "Complete docs/harness/BOOTSTRAP_PROMPT.md before marking the Harness READY." >&2
exit 1
# AGENTFORGE:PROJECT_CHECKS:END
