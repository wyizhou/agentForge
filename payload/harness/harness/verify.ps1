$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $PSScriptRoot
$StatusFile = Join-Path $PSScriptRoot "STATUS"

if (-not (Test-Path -LiteralPath $StatusFile -PathType Leaf)) {
    Write-Error "harness/STATUS is missing."
    exit 1
}

$Status = (Get-Content -LiteralPath $StatusFile -Raw).Trim()
if ($Status -ne "READY") {
    Write-Error "Harness is $Status. Run the prompt in docs/harness/BOOTSTRAP_PROMPT.md with your AI coding agent."
    exit 1
}

# AGENTFORGE:PROJECT_CHECKS:START
Write-Error "Project checks have not been configured. Complete docs/harness/BOOTSTRAP_PROMPT.md before marking the Harness READY."
exit 1
# AGENTFORGE:PROJECT_CHECKS:END
