#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_dir"

sh -n agentforge.sh
python3 tests/test_payload.py
sh tests/test_cli.sh

if command -v pwsh >/dev/null 2>&1; then
  pwsh -NoProfile -File tests/test_powershell.ps1
else
  echo "SKIP: PowerShell runtime is not installed; static parity checks ran in test_payload.py."
fi

echo "agentForge verification passed."
