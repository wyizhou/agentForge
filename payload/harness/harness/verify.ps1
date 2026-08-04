$ErrorActionPreference = "Stop"
$RepoDir = Split-Path -Parent $PSScriptRoot

foreach ($RequiredFile in @(
    "docs/harness/DELIVERY_RULES.md",
    "docs/harness/COMMANDS.md",
    "docs/harness/CHECKS.md"
)) {
    if (-not (Test-Path -LiteralPath (Join-Path $RepoDir $RequiredFile) -PathType Leaf)) {
        [Console]::Error.WriteLine("ERROR: Missing Harness document: $RequiredFile")
        exit 1
    }
}

# AGENTFORGE:PROJECT_CHECKS:START
$ManifestNames = @(
    "package.json", "deno.json", "deno.jsonc", "pyproject.toml", "requirements.txt",
    "Pipfile", "poetry.lock", "uv.lock", "Cargo.toml", "go.mod", "pom.xml",
    "build.gradle", "build.gradle.kts", "Gemfile", "composer.json", "Package.swift",
    "CMakeLists.txt", "Makefile", "Dockerfile", "docker-compose.yml", "compose.yml",
    "Rakefile", "Procfile"
)
$MetadataNames = @(
    "README", "LICENSE", "NOTICE", "AUTHORS", "CONTRIBUTORS", "CHANGELOG", "VERSION",
    "COPYING", ".gitignore", ".gitattributes", ".gitmodules", ".gitkeep",
    ".dockerignore", ".editorconfig", ".env.example"
)
$NonCodeExtensions = @(
    ".md", ".mdx", ".txt", ".rst", ".adoc", ".pdf", ".png", ".jpg", ".jpeg",
    ".gif", ".svg", ".ico", ".webp", ".avif", ".bmp", ".tif", ".tiff", ".mp3",
    ".mp4", ".wav", ".ogg", ".webm", ".mov", ".woff", ".woff2", ".ttf", ".otf",
    ".eot", ".csv", ".tsv", ".json", ".jsonl", ".yaml", ".yml", ".toml", ".xml",
    ".lock", ".log", ".map"
)
$ExcludedRoots = @(".git", ".agents", ".claude", "harness")
$ProjectCode = Get-ChildItem -LiteralPath $RepoDir -Recurse -Force -File | Where-Object {
    $RelativePath = $_.FullName.Substring($RepoDir.Length).TrimStart(
        [IO.Path]::DirectorySeparatorChar,
        [IO.Path]::AltDirectorySeparatorChar
    )
    $FirstSegment = ($RelativePath -split "[\\/]", 2)[0]
    if ($ExcludedRoots -contains $FirstSegment) { return $false }
    if ($ManifestNames -contains $_.Name -or $_.Extension -like ".csproj" -or $_.Extension -like ".sln") {
        return $true
    }
    if ($MetadataNames -contains $_.Name -or $NonCodeExtensions -contains $_.Extension.ToLowerInvariant()) {
        return $false
    }
    return $true
} | Select-Object -First 1

if ($ProjectCode) {
    $RelativeProjectCode = $ProjectCode.FullName.Substring($RepoDir.Length).TrimStart(
        [IO.Path]::DirectorySeparatorChar,
        [IO.Path]::AltDirectorySeparatorChar
    )
    [Console]::Error.WriteLine("ERROR: Project code or a technology manifest exists, but project-specific checks are not registered: $RelativeProjectCode")
    [Console]::Error.WriteLine("Add the applicable tests and linter to this verifier as required by docs/harness/DELIVERY_RULES.md.")
    exit 1
}

Write-Host "NOTICE: No project-specific checks are registered yet."
Write-Host "No project code or technology manifest was detected; the progressive Harness is ready for development."
# AGENTFORGE:PROJECT_CHECKS:END

Write-Host "Harness verification passed for all currently configured checks."
exit 0
