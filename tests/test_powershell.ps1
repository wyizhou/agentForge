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
        "docs/harness/DELIVERY_RULES.md",
        "harness/verify.ps1",
        ".agents/skills/orchestrate-parallel-work/SKILL.md",
        ".claude/skills/orchestrate-parallel-work/SKILL.md"
    )) {
        if (-not (Test-Path -LiteralPath (Join-Path $Target $Path) -PathType Leaf)) { throw "Missing generated file: $Path" }
    }

    if (Test-Path -LiteralPath (Join-Path $Target "harness/STATUS")) { throw "Legacy Harness status was generated" }
    if (Test-Path -LiteralPath (Join-Path $Target "docs/harness/BOOTSTRAP_PROMPT.md")) { throw "Legacy bootstrap prompt was generated" }
    & (Join-Path $Target "harness/verify.ps1")
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw "Empty-project Harness verification failed" }
    if ((Get-Content -LiteralPath (Join-Path $Target "harness/verify.ps1") -Raw) -notmatch "No project-specific checks are registered yet") {
        throw "Generated verifier lacks progressive empty-project notice"
    }

    $ProjectNotes = Join-Path $Target "PROJECT_NOTES.md"
    [IO.File]::WriteAllText($ProjectNotes, "# Project notes`n")
    & (Join-Path $Target "harness/verify.ps1")
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw "Documentation-only project incorrectly required code checks" }
    Remove-Item -LiteralPath $ProjectNotes -Force

    $UnregisteredCode = Join-Path $Target "app.py"
    [IO.File]::WriteAllText($UnregisteredCode, "print('project code')`n")
    & (Join-Path $Target "harness/verify.ps1")
    if ($LASTEXITCODE -eq 0) { throw "Harness passed after code was added without project checks" }
    Remove-Item -LiteralPath $UnregisteredCode -Force

    $UppercaseCode = Join-Path $Target "APP.PY"
    [IO.File]::WriteAllText($UppercaseCode, "print('uppercase extension')`n")
    & (Join-Path $Target "harness/verify.ps1")
    if ($LASTEXITCODE -eq 0) { throw "Harness missed an uppercase source extension" }
    Remove-Item -LiteralPath $UppercaseCode -Force

    $DocsCode = Join-Path $Target "docs/site/index.html"
    New-Item -ItemType Directory -Path (Split-Path -Parent $DocsCode) -Force | Out-Null
    [IO.File]::WriteAllText($DocsCode, "<!doctype html>`n")
    & (Join-Path $Target "harness/verify.ps1")
    if ($LASTEXITCODE -eq 0) { throw "Harness missed project code under docs" }
    Remove-Item -LiteralPath $DocsCode -Force

    $UnlistedLanguage = Join-Path $Target "main.pl"
    [IO.File]::WriteAllText($UnlistedLanguage, "print 'project code';`n")
    & (Join-Path $Target "harness/verify.ps1")
    if ($LASTEXITCODE -eq 0) { throw "Harness missed an unlisted programming language" }
    Remove-Item -LiteralPath $UnlistedLanguage -Force

    $ExtensionlessCode = Join-Path $Target "tool"
    [IO.File]::WriteAllText($ExtensionlessCode, "#!/bin/sh`n")
    & (Join-Path $Target "harness/verify.ps1")
    if ($LASTEXITCODE -eq 0) { throw "Harness missed an extensionless source file" }
    Remove-Item -LiteralPath $ExtensionlessCode -Force

    & (Join-Path $Target "harness/verify.ps1")
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw "Harness did not recover after unregistered code was removed" }

    $CodexSkill = Get-Content -LiteralPath (Join-Path $Target ".agents/skills/orchestrate-parallel-work/SKILL.md") -Raw
    $ClaudeSkill = Get-Content -LiteralPath (Join-Path $Target ".claude/skills/orchestrate-parallel-work/SKILL.md") -Raw
    if ($CodexSkill -ne $ClaudeSkill) { throw "Generated Skill copies differ" }

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
