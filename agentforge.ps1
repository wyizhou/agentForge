[CmdletBinding()]
param(
    [string]$Target = ".",
    [ValidateSet("agents", "claude")][string]$Primary,
    [ValidateSet("yes", "no", "y", "n")][string]$Harness,
    [ValidateSet("yes", "no", "y", "n")][string]$Skill,
    [ValidateSet("yes", "no", "y", "n")][string]$Git,
    [string]$SourceDir
)

$ErrorActionPreference = "Stop"
$AgentForgeVersion = "0.3.0"
$DefaultBaseUrl = "https://raw.githubusercontent.com/wyizhou/agentForge/v$AgentForgeVersion"
$OrchestrateRepo = "wyizhou/orchestrateParallelWork-skill"

function Normalize-YesNo([string]$Value) {
    switch -Regex ($Value) {
        "^(?i:y|yes)$" { return "yes" }
        "^(?i:n|no)$" { return "no" }
        default { throw "Expected yes or no, received: $Value" }
    }
}

function Ask-YesNo([string]$Prompt, [string]$Default = "yes") {
    $Answer = Read-Host $Prompt
    if ([string]::IsNullOrWhiteSpace($Answer)) { $Answer = $Default }
    return Normalize-YesNo $Answer
}

if (-not $Primary) {
    while (-not $Primary) {
        $Answer = Read-Host "Primary AI guide [1=AGENTS.md, 2=CLAUDE.md]"
        switch ($Answer) {
            "1" { $Primary = "agents" }
            "agents" { $Primary = "agents" }
            "2" { $Primary = "claude" }
            "claude" { $Primary = "claude" }
            default { Write-Warning "Please enter 1 or 2." }
        }
    }
}
if ($Harness) { $Harness = Normalize-YesNo $Harness } else { $Harness = Ask-YesNo "Generate the progressive Harness documentation scaffold? [Y/n]" }
if ($Skill) { $Skill = Normalize-YesNo $Skill } else { $Skill = Ask-YesNo "Install orchestrate-parallel-work for Codex and Claude Code? [Y/n]" }

$TargetPath = [IO.Path]::GetFullPath($Target)
$TargetParent = Split-Path -Parent $TargetPath
if (-not (Test-Path -LiteralPath $TargetParent -PathType Container)) {
    throw "Target parent directory does not exist: $TargetParent"
}

$GitCommand = Get-Command git -ErrorAction SilentlyContinue
$InsideGit = $false
if ($GitCommand) {
    $GitProbePath = if (Test-Path -LiteralPath $TargetPath -PathType Container) { $TargetPath } else { $TargetParent }
    $PreviousErrorActionPreference = $ErrorActionPreference
    try {
        # Windows PowerShell 5.1 can promote native stderr to a terminating
        # NativeCommandError when the probe is expected to report "not a repo".
        $ErrorActionPreference = "Continue"
        & git -C $GitProbePath rev-parse --is-inside-work-tree *> $null
        $InsideGit = ($LASTEXITCODE -eq 0)
    } finally {
        $ErrorActionPreference = $PreviousErrorActionPreference
    }
}

if ($InsideGit) {
    $Git = "no"
    Write-Host "Git repository detected; initialization will be skipped."
} elseif (-not $GitCommand) {
    $Git = "no"
    Write-Warning "Git is not installed; initialization will be skipped."
} elseif ($Git) {
    $Git = Normalize-YesNo $Git
} else {
    $Git = Ask-YesNo "Initialize a local Git repository? [Y/n]"
}

if (-not $SourceDir -and $env:AGENTFORGE_SOURCE_DIR) { $SourceDir = $env:AGENTFORGE_SOURCE_DIR }
if (-not $SourceDir -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot "payload/harness/manifest.tsv"))) {
    $SourceDir = $PSScriptRoot
}
if ($SourceDir) { $SourceDir = [IO.Path]::GetFullPath($SourceDir) }

$TempDir = Join-Path ([IO.Path]::GetTempPath()) ("agentforge-" + [Guid]::NewGuid().ToString("N"))
$StageDir = Join-Path $TempDir "stage"
New-Item -ItemType Directory -Path $StageDir -Force | Out-Null
$Destinations = [Collections.Generic.List[string]]::new()
$ExitCode = 0

function Fetch-Url([string]$Url, [string]$Output) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $Output) -Force | Out-Null
    Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $Output
}

function Fetch-Payload([string]$Relative, [string]$Output) {
    if ($SourceDir) {
        $Source = Join-Path $SourceDir ("payload/" + $Relative)
        if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) { throw "Missing payload file: payload/$Relative" }
        New-Item -ItemType Directory -Path (Split-Path -Parent $Output) -Force | Out-Null
        Copy-Item -LiteralPath $Source -Destination $Output
    } else {
        Fetch-Url "$DefaultBaseUrl/payload/$Relative" $Output
    }
}

function Add-Destination([string]$Relative) {
    if ([IO.Path]::IsPathRooted($Relative) -or $Relative -match "(^|[\\/])\.\.([\\/]|$)") {
        throw "Unsafe destination path: $Relative"
    }
    $Destinations.Add($Relative)
}

function Stage-Payload([string]$PayloadPath, [string]$Destination) {
    $Output = Join-Path $StageDir $Destination
    Fetch-Payload $PayloadPath $Output
    Add-Destination $Destination
}

try {
    $TrimmedTargetPath = $TargetPath.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
    $ProjectName = Split-Path -Leaf $TrimmedTargetPath
    if (-not $ProjectName) { $ProjectName = "project" }
    $ProjectName = $ProjectName -replace "[\r\n\t]", " "

    if ($Primary -eq "agents") {
        $GuideVariant = "AGENTS"
        $BridgeVariant = "CLAUDE"
    } else {
        $GuideVariant = "CLAUDE"
        $BridgeVariant = "AGENTS"
    }

    if ($Harness -eq "yes") {
        Stage-Payload "guides/$GuideVariant.harness.md" "$GuideVariant.md"
    } else {
        Stage-Payload "guides/$GuideVariant.basic.md" "$GuideVariant.md"
    }
    Stage-Payload "guides/$BridgeVariant.bridge.md" "$BridgeVariant.md"

    $GuidePath = Join-Path $StageDir "$GuideVariant.md"
    $GuideText = [IO.File]::ReadAllText($GuidePath).Replace("{{PROJECT_NAME}}", $ProjectName)
    [IO.File]::WriteAllText($GuidePath, $GuideText, [Text.UTF8Encoding]::new($false))

    if ($Harness -eq "yes") {
        $ManifestPath = Join-Path $TempDir "harness-manifest.tsv"
        Fetch-Payload "harness/manifest.tsv" $ManifestPath
        foreach ($Line in [IO.File]::ReadAllLines($ManifestPath)) {
            if ([string]::IsNullOrWhiteSpace($Line)) { continue }
            $Parts = $Line -split "`t", 2
            if ($Parts.Count -ne 2) { throw "Invalid Harness manifest line: $Line" }
            Stage-Payload ("harness/" + $Parts[0]) $Parts[1]
        }
    }

    $SkillCommit = ""
    if ($Skill -eq "yes") {
        Stage-Payload "skills/SKILLS.orchestrate.md" "SKILLS.md"
        $SkillFilesPath = Join-Path $TempDir "orchestrate-files.txt"
        Fetch-Payload "orchestrate-files.txt" $SkillFilesPath

        if ($env:AGENTFORGE_SKILL_SOURCE_DIR) {
            $SkillCommit = if ($env:AGENTFORGE_SKILL_COMMIT) { $env:AGENTFORGE_SKILL_COMMIT } else { "local-test-fixture" }
        } elseif ($env:AGENTFORGE_SKILL_COMMIT) {
            $SkillCommit = $env:AGENTFORGE_SKILL_COMMIT
        } else {
            $CommitInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/$OrchestrateRepo/commits/main"
            $SkillCommit = $CommitInfo.sha
        }
        if (-not $SkillCommit) { throw "Unable to resolve orchestrate-parallel-work main commit" }
        if (-not $env:AGENTFORGE_SKILL_SOURCE_DIR -and $SkillCommit -notmatch "^[0-9a-fA-F]{40}$") {
            throw "AGENTFORGE_SKILL_COMMIT must be a full 40-character Git commit SHA"
        }

        foreach ($SkillPath in [IO.File]::ReadAllLines($SkillFilesPath)) {
            if ([string]::IsNullOrWhiteSpace($SkillPath)) { continue }
            if ([IO.Path]::IsPathRooted($SkillPath) -or $SkillPath -match "(^|[\\/])\.\.([\\/]|$)") { throw "Unsafe Skill path: $SkillPath" }
            foreach ($SkillRoot in @(".agents/skills/orchestrate-parallel-work", ".claude/skills/orchestrate-parallel-work")) {
                $Destination = "$SkillRoot/$SkillPath"
                $Output = Join-Path $StageDir $Destination
                if ($env:AGENTFORGE_SKILL_SOURCE_DIR) {
                    $Source = Join-Path $env:AGENTFORGE_SKILL_SOURCE_DIR $SkillPath
                    if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) { throw "Missing Skill fixture file: $SkillPath" }
                    New-Item -ItemType Directory -Path (Split-Path -Parent $Output) -Force | Out-Null
                    Copy-Item -LiteralPath $Source -Destination $Output
                } else {
                    Fetch-Url "https://raw.githubusercontent.com/$OrchestrateRepo/$SkillCommit/skills/orchestrate-parallel-work/$SkillPath" $Output
                }
                Add-Destination $Destination
            }
        }

        $OriginText = @(
            "# Upstream origin",
            "",
            "- Repository: https://github.com/$OrchestrateRepo",
            "- Skill path: skills/orchestrate-parallel-work",
            "- Commit: $SkillCommit",
            "- Installed by: agentForge $AgentForgeVersion",
            ""
        ) -join "`n"
        foreach ($SkillRoot in @(".agents/skills/orchestrate-parallel-work", ".claude/skills/orchestrate-parallel-work")) {
            $OriginPath = Join-Path $StageDir "$SkillRoot/ORIGIN.md"
            [IO.File]::WriteAllText($OriginPath, $OriginText, [Text.UTF8Encoding]::new($false))
            Add-Destination "$SkillRoot/ORIGIN.md"
        }
    } else {
        Stage-Payload "skills/SKILLS.none.md" "SKILLS.md"
    }

    $Conflicts = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($Destination in $Destinations) {
        $DestinationPath = Join-Path $TargetPath $Destination
        $DestinationItem = Get-Item -LiteralPath $DestinationPath -Force -ErrorAction SilentlyContinue
        if ($null -ne $DestinationItem) { [void]$Conflicts.Add($Destination) }

        $Ancestor = Split-Path -Parent $Destination
        while ($Ancestor -and $Ancestor -ne ".") {
            $AncestorPath = Join-Path $TargetPath $Ancestor
            $AncestorItem = Get-Item -LiteralPath $AncestorPath -Force -ErrorAction SilentlyContinue
            if ($null -ne $AncestorItem) {
                $IsReparsePoint = ($AncestorItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
                if ($IsReparsePoint) {
                    [void]$Conflicts.Add("$Ancestor (reparse-point parent)")
                    break
                }
                if (-not $AncestorItem.PSIsContainer) {
                    [void]$Conflicts.Add("$Ancestor (non-directory parent)")
                    break
                }
            }
            $Ancestor = Split-Path -Parent $Ancestor
        }
    }
    if ($Conflicts.Count -gt 0) {
        throw "agentForge will not overwrite existing paths:`n  $($Conflicts -join "`n  ")`nNo project files were written."
    }

    New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
    foreach ($Destination in $Destinations) {
        $Source = Join-Path $StageDir $Destination
        $Output = Join-Path $TargetPath $Destination
        New-Item -ItemType Directory -Path (Split-Path -Parent $Output) -Force | Out-Null
        Copy-Item -LiteralPath $Source -Destination $Output
    }

    if ($Git -eq "yes") {
        & git -c init.defaultBranch=main -C $TargetPath init | Out-Null
        if ($LASTEXITCODE -ne 0) { throw "git init failed" }
        Write-Host "Initialized Git repository in $TargetPath."
    }

    Write-Host ""
    Write-Host "agentForge $AgentForgeVersion completed for $ProjectName."
    Write-Host "Canonical guide: $GuideVariant.md"
    Write-Host "Compatibility guide: $BridgeVariant.md"
    Write-Host "Progressive Harness documentation: $Harness"
    $SkillSuffix = if ($SkillCommit) { " ($SkillCommit)" } else { "" }
    Write-Host "orchestrate-parallel-work: $Skill$SkillSuffix"
    if ($Harness -eq "yes") {
        Write-Host ""
        Write-Host "The progressive Harness documentation is active. You can start development now."
        Write-Host "AI coding agents must follow docs/harness/DELIVERY_RULES.md and run the project's native checks before delivery."
    }
} catch {
    [Console]::Error.WriteLine("ERROR: " + $_.Exception.Message)
    $ExitCode = 1
} finally {
    if (Test-Path -LiteralPath $TempDir) { Remove-Item -LiteralPath $TempDir -Recurse -Force }
}

exit $ExitCode
