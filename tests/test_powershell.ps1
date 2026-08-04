$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $PSScriptRoot
$TempDir = Join-Path ([IO.Path]::GetTempPath()) ("agentforge-pwsh-test-" + [Guid]::NewGuid().ToString("N"))
$Fixture = Join-Path $TempDir "skill-fixture"
$Target = Join-Path $TempDir "generated project"

try {
    New-Item -ItemType Directory -Path $Fixture -Force | Out-Null
    foreach ($Path in [IO.File]::ReadAllLines((Join-Path $RepoDir "payload/orchestrate-files.txt"))) {
        if ([string]::IsNullOrWhiteSpace($Path)) { continue }
        $Output = Join-Path $Fixture $Path
        New-Item -ItemType Directory -Path (Split-Path -Parent $Output) -Force | Out-Null
        [IO.File]::WriteAllText($Output, "fixture:$Path`n")
    }

    $env:AGENTFORGE_SKILL_SOURCE_DIR = $Fixture
    $env:AGENTFORGE_SKILL_COMMIT = "powershell-fixture"
    & (Join-Path $RepoDir "agentforge.ps1") -SourceDir $RepoDir -Target $Target -Primary claude -Harness yes -Skill yes -Git no

    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw "agentforge.ps1 failed with $LASTEXITCODE" }
    foreach ($Path in @(
        "CLAUDE.md",
        "AGENTS.md",
        "ARCHITECTURE.md",
        "docs/README.md",
        "docs/harness/README.md",
        "docs/harness/DELIVERY_RULES.md",
        "docs/harness/COMMANDS.md",
        "docs/harness/CHECKS.md",
        ".agents/skills/orchestrate-parallel-work/SKILL.md",
        ".claude/skills/orchestrate-parallel-work/SKILL.md"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $Target $Path) -PathType Leaf)) { throw "Missing generated file: $Path" }
    }

    if (Test-Path -LiteralPath (Join-Path $Target "harness")) { throw "Harness runtime scripts were generated" }
    if (Test-Path -LiteralPath (Join-Path $Target "docs/harness/BOOTSTRAP_PROMPT.md")) { throw "Legacy bootstrap prompt was generated" }
    $ClaudeGuide = Get-Content -LiteralPath (Join-Path $Target "CLAUDE.md") -Raw
    foreach ($Phrase in @(
        "docs/harness/DELIVERY_RULES.md",
        "docs/harness/COMMANDS.md",
        "docs/harness/CHECKS.md",
        "test runner and linter",
        "project-native"
    )) {
        if ($ClaudeGuide -notmatch [regex]::Escape($Phrase)) { throw "CLAUDE.md lacks Harness instruction: $Phrase" }
    }
    $AgentsBridge = Get-Content -LiteralPath (Join-Path $Target "AGENTS.md") -Raw
    foreach ($Path in @(
        "docs/harness/DELIVERY_RULES.md",
        "docs/harness/COMMANDS.md",
        "docs/harness/CHECKS.md"
    )) {
        if ($AgentsBridge -notmatch [regex]::Escape($Path)) { throw "AGENTS.md compatibility guide lacks Harness path: $Path" }
    }
    $DeliveryRules = Get-Content -LiteralPath (Join-Path $Target "docs/harness/DELIVERY_RULES.md") -Raw
    foreach ($Phrase in @("Every new or changed behavior", "regression test", "test runner and linter", "Before delivery", "does not generate or require a unified")) {
        if ($DeliveryRules -notmatch [regex]::Escape($Phrase)) { throw "Delivery rules lack required contract: $Phrase" }
    }

    $CodexSkill = Get-Content -LiteralPath (Join-Path $Target ".agents/skills/orchestrate-parallel-work/SKILL.md") -Raw
    $ClaudeSkill = Get-Content -LiteralPath (Join-Path $Target ".claude/skills/orchestrate-parallel-work/SKILL.md") -Raw
    if ($CodexSkill -ne $ClaudeSkill) { throw "Generated Skill copies differ" }

    $IsWindowsHost = [Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT
    $ShCommand = Get-Command sh -ErrorAction SilentlyContinue
    if (-not $IsWindowsHost -and $ShCommand) {
        $PowerShellParityRoot = Join-Path $TempDir "powershell-parity"
        $PosixParityRoot = Join-Path $TempDir "posix-parity"
        $PowerShellParityTarget = Join-Path $PowerShellParityRoot "same-project"
        $PosixParityTarget = Join-Path $PosixParityRoot "same-project"
        New-Item -ItemType Directory -Path $PowerShellParityRoot, $PosixParityRoot -Force | Out-Null

        & (Join-Path $RepoDir "agentforge.ps1") -SourceDir $RepoDir -Target $PowerShellParityTarget -Primary agents -Harness yes -Skill yes -Git no
        if ($LASTEXITCODE -ne 0) { throw "PowerShell parity generation failed" }
        & $ShCommand.Source (Join-Path $RepoDir "agentforge.sh") --source-dir $RepoDir --target $PosixParityTarget --primary agents --harness yes --skill yes --git no
        if ($LASTEXITCODE -ne 0) { throw "POSIX parity generation failed" }

        $PowerShellFiles = @(Get-ChildItem -LiteralPath $PowerShellParityTarget -File -Recurse | ForEach-Object {
            $_.FullName.Substring($PowerShellParityTarget.Length + 1).Replace([IO.Path]::DirectorySeparatorChar, "/")
        } | Sort-Object)
        $PosixFiles = @(Get-ChildItem -LiteralPath $PosixParityTarget -File -Recurse | ForEach-Object {
            $_.FullName.Substring($PosixParityTarget.Length + 1).Replace([IO.Path]::DirectorySeparatorChar, "/")
        } | Sort-Object)
        if (($PowerShellFiles -join "`n") -ne ($PosixFiles -join "`n")) { throw "POSIX and PowerShell generated different file sets" }

        foreach ($RelativePath in $PowerShellFiles) {
            $PowerShellHash = (Get-FileHash -LiteralPath (Join-Path $PowerShellParityTarget $RelativePath) -Algorithm SHA256).Hash
            $PosixHash = (Get-FileHash -LiteralPath (Join-Path $PosixParityTarget $RelativePath) -Algorithm SHA256).Hash
            if ($PowerShellHash -ne $PosixHash) { throw "POSIX and PowerShell content differs: $RelativePath" }
        }
    } else {
        Write-Host "SKIP: byte-for-byte launcher parity requires POSIX sh on a non-Windows host."
    }

    $ConflictTarget = Join-Path $TempDir "parent-conflict"
    New-Item -ItemType Directory -Path $ConflictTarget -Force | Out-Null
    [IO.File]::WriteAllText((Join-Path $ConflictTarget "docs"), "user-owned parent`n")
    & (Join-Path $RepoDir "agentforge.ps1") -SourceDir $RepoDir -Target $ConflictTarget -Primary agents -Harness yes -Skill no -Git no
    if ($LASTEXITCODE -eq 0) { throw "Parent-path conflict unexpectedly succeeded" }
    if (Test-Path -LiteralPath (Join-Path $ConflictTarget "AGENTS.md")) { throw "Parent-path conflict caused a partial write" }
    if ((Get-Content -LiteralPath (Join-Path $ConflictTarget "docs") -Raw) -ne "user-owned parent`n") { throw "Parent conflict file was modified" }

    $DanglingTarget = Join-Path $TempDir "dangling-conflict"
    New-Item -ItemType Directory -Path $DanglingTarget -Force | Out-Null
    $DanglingGuide = Join-Path $DanglingTarget "AGENTS.md"
    $MissingGuide = Join-Path $TempDir "missing-guide"
    try {
        [IO.File]::WriteAllText($MissingGuide, "temporary target`n")
        New-Item -ItemType SymbolicLink -Path $DanglingGuide -Target $MissingGuide -ErrorAction Stop | Out-Null
        Remove-Item -LiteralPath $MissingGuide -Force
        & (Join-Path $RepoDir "agentforge.ps1") -SourceDir $RepoDir -Target $DanglingTarget -Primary agents -Harness no -Skill no -Git no
        if ($LASTEXITCODE -eq 0) { throw "Dangling-link conflict unexpectedly succeeded" }
        if (-not (Get-Item -LiteralPath $DanglingGuide -Force -ErrorAction SilentlyContinue)) { throw "Dangling link was modified" }
        if (Test-Path -LiteralPath (Join-Path $DanglingTarget "CLAUDE.md")) { throw "Dangling-link conflict caused a partial write" }
    } catch [System.UnauthorizedAccessException] {
        Write-Host "SKIP: this host does not permit symbolic-link test setup."
    }

    Remove-Item Env:AGENTFORGE_SKILL_SOURCE_DIR
    $env:AGENTFORGE_SKILL_COMMIT = "main"
    $MutableRefTarget = Join-Path $TempDir "mutable-skill-ref"
    & (Join-Path $RepoDir "agentforge.ps1") -SourceDir $RepoDir -Target $MutableRefTarget -Primary agents -Harness no -Skill yes -Git no
    if ($LASTEXITCODE -eq 0) { throw "Mutable Skill ref unexpectedly succeeded" }
    if (Test-Path -LiteralPath $MutableRefTarget) { throw "Mutable Skill ref caused a partial write" }

    $ParentRepo = Join-Path $TempDir "existing-parent-repo"
    New-Item -ItemType Directory -Path $ParentRepo -Force | Out-Null
    & git -c init.defaultBranch=main -C $ParentRepo init | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Unable to initialize parent Git fixture" }
    $NestedTarget = Join-Path $ParentRepo "new-project"
    & (Join-Path $RepoDir "agentforge.ps1") -SourceDir $RepoDir -Target $NestedTarget -Primary agents -Harness no -Skill no -Git yes
    if ($LASTEXITCODE -ne 0) { throw "Generation inside parent Git repository failed" }
    if (Test-Path -LiteralPath (Join-Path $NestedTarget ".git")) { throw "Nested Git repository was incorrectly initialized" }

    Write-Host "PowerShell CLI integration tests passed."
} finally {
    Remove-Item Env:AGENTFORGE_SKILL_SOURCE_DIR -ErrorAction SilentlyContinue
    Remove-Item Env:AGENTFORGE_SKILL_COMMIT -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $TempDir) { Remove-Item -LiteralPath $TempDir -Recurse -Force }
}
