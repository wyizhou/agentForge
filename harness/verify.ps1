$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $PSScriptRoot
Set-Location $RepoDir

& powershell -NoProfile -ExecutionPolicy Bypass -File tests/test_powershell.ps1
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host "agentForge Windows verification passed."
