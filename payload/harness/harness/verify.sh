#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

for required_file in \
  "$repo_dir/docs/harness/DELIVERY_RULES.md" \
  "$repo_dir/docs/harness/COMMANDS.md" \
  "$repo_dir/docs/harness/CHECKS.md"; do
  if [ ! -f "$required_file" ]; then
    echo "ERROR: Missing Harness document: ${required_file#"$repo_dir/"}" >&2
    exit 1
  fi
done

# AGENTFORGE:PROJECT_CHECKS:START
project_code=$(
  find "$repo_dir" \
    -path "$repo_dir/.git" -prune -o \
    -path "$repo_dir/.agents" -prune -o \
    -path "$repo_dir/.claude" -prune -o \
    -path "$repo_dir/harness" -prune -o \
    -type f -print |
  while IFS= read -r file; do
    relative=${file#"$repo_dir/"}
    name=$(printf '%s' "${relative##*/}" | tr '[:upper:]' '[:lower:]')
    case "$name" in
      package.json|deno.json|deno.jsonc|pyproject.toml|requirements.txt|pipfile|poetry.lock|uv.lock|cargo.toml|go.mod|pom.xml|build.gradle|build.gradle.kts|gemfile|composer.json|package.swift|cmakelists.txt|makefile|dockerfile|docker-compose.yml|compose.yml|rakefile|procfile|*.csproj|*.sln)
        printf '%s\n' "$relative"
        break
        ;;
      readme|license|notice|authors|contributors|changelog|version|copying|.gitignore|.gitattributes|.gitmodules|.gitkeep|.dockerignore|.editorconfig|.env.example|*.md|*.mdx|*.txt|*.rst|*.adoc|*.pdf|*.png|*.jpg|*.jpeg|*.gif|*.svg|*.ico|*.webp|*.avif|*.bmp|*.tif|*.tiff|*.mp3|*.mp4|*.wav|*.ogg|*.webm|*.mov|*.woff|*.woff2|*.ttf|*.otf|*.eot|*.csv|*.tsv|*.json|*.jsonl|*.yaml|*.yml|*.toml|*.xml|*.lock|*.log|*.map)
        ;;
      *)
        printf '%s\n' "$relative"
        break
        ;;
    esac
  done
)

if [ -n "$project_code" ]; then
  echo "ERROR: Project code or a technology manifest exists, but project-specific checks are not registered: $project_code" >&2
  echo "Add the applicable tests and linter to this verifier as required by docs/harness/DELIVERY_RULES.md." >&2
  exit 1
fi

echo "NOTICE: No project-specific checks are registered yet."
echo "No project code or technology manifest was detected; the progressive Harness is ready for development."
# AGENTFORGE:PROJECT_CHECKS:END

echo "Harness verification passed for all currently configured checks."
