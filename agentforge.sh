#!/bin/sh
set -eu

AGENTFORGE_VERSION="0.1.0"
DEFAULT_BASE_URL="https://raw.githubusercontent.com/wyizhou/agentForge/v$AGENTFORGE_VERSION"
ORCHESTRATE_REPO="wyizhou/orchestrateParallelWork-skill"

target="."
primary=""
with_harness=""
with_skill=""
git_choice=""
source_dir=${AGENTFORGE_SOURCE_DIR:-}

usage() {
  cat <<'EOF'
agentForge - build an AI coding Harness in the target project

Usage:
  sh agentforge.sh [options]

Options:
  --target PATH                 Target project directory (default: current)
  --primary agents|claude      Canonical instruction file
  --harness yes|no             Generate the strict Harness scaffold
  --skill yes|no               Install orchestrate-parallel-work
  --git yes|no                 Initialize Git when no repository exists
  --source-dir PATH             Read agentForge payload from a local checkout
  --help                        Show this help

When an option is omitted, agentForge asks for it interactively. It asks at
most four questions.
EOF
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

normalize_yes_no() {
  case "$1" in
    y|Y|yes|YES|Yes) echo "yes" ;;
    n|N|no|NO|No) echo "no" ;;
    *) return 1 ;;
  esac
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --target) [ "$#" -ge 2 ] || die "--target needs a value"; target=$2; shift 2 ;;
    --primary) [ "$#" -ge 2 ] || die "--primary needs a value"; primary=$2; shift 2 ;;
    --harness) [ "$#" -ge 2 ] || die "--harness needs a value"; with_harness=$2; shift 2 ;;
    --skill) [ "$#" -ge 2 ] || die "--skill needs a value"; with_skill=$2; shift 2 ;;
    --git) [ "$#" -ge 2 ] || die "--git needs a value"; git_choice=$2; shift 2 ;;
    --source-dir) [ "$#" -ge 2 ] || die "--source-dir needs a value"; source_dir=$2; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) die "Unknown option: $1" ;;
  esac
done

case "$primary" in
  ""|agents|claude) ;;
  *) die "--primary must be agents or claude" ;;
esac

if [ -n "$with_harness" ]; then
  with_harness=$(normalize_yes_no "$with_harness") || die "--harness must be yes or no"
fi
if [ -n "$with_skill" ]; then
  with_skill=$(normalize_yes_no "$with_skill") || die "--skill must be yes or no"
fi
if [ -n "$git_choice" ]; then
  git_choice=$(normalize_yes_no "$git_choice") || die "--git must be yes or no"
fi

prompt_line() {
  prompt_text=$1
  if [ -r /dev/tty ]; then
    printf "%s" "$prompt_text" >/dev/tty
    IFS= read -r prompt_answer </dev/tty || die "Unable to read interactive input"
  else
    printf "%s" "$prompt_text"
    IFS= read -r prompt_answer || die "Unable to read interactive input"
  fi
  printf "%s" "$prompt_answer"
}

if [ -z "$primary" ]; then
  while :; do
    answer=$(prompt_line "Primary AI guide [1=AGENTS.md, 2=CLAUDE.md]: ")
    case "$answer" in
      1|agents|AGENTS) primary="agents"; break ;;
      2|claude|CLAUDE) primary="claude"; break ;;
      *) echo "Please enter 1 or 2." >&2 ;;
    esac
  done
fi

if [ -z "$with_harness" ]; then
  answer=$(prompt_line "Generate the strict Harness scaffold? [Y/n]: ")
  [ -n "$answer" ] || answer="yes"
  with_harness=$(normalize_yes_no "$answer") || die "Please answer yes or no"
fi

if [ -z "$with_skill" ]; then
  answer=$(prompt_line "Install orchestrate-parallel-work for Codex and Claude Code? [Y/n]: ")
  [ -n "$answer" ] || answer="yes"
  with_skill=$(normalize_yes_no "$answer") || die "Please answer yes or no"
fi

target_parent=$(dirname -- "$target")
[ -d "$target_parent" ] || die "Target parent directory does not exist: $target_parent"
if [ -e "$target" ] && [ ! -d "$target" ]; then
  die "Target exists but is not a directory: $target"
fi
if [ -d "$target" ]; then
  target=$(CDPATH= cd -- "$target" && pwd)
else
  target=$(CDPATH= cd -- "$target_parent" && pwd)/$(basename -- "$target")
fi

has_git="no"
inside_git="no"
if command -v git >/dev/null 2>&1; then
  has_git="yes"
  git_probe=$target
  [ -d "$git_probe" ] || git_probe=$(dirname -- "$git_probe")
  if git -C "$git_probe" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    inside_git="yes"
  fi
fi

if [ "$inside_git" = "yes" ]; then
  git_choice="no"
  echo "Git repository detected; initialization will be skipped."
elif [ "$has_git" = "no" ]; then
  git_choice="no"
  echo "Git is not installed; initialization will be skipped." >&2
elif [ -z "$git_choice" ]; then
  answer=$(prompt_line "Initialize a local Git repository? [Y/n]: ")
  [ -n "$answer" ] || answer="yes"
  git_choice=$(normalize_yes_no "$answer") || die "Please answer yes or no"
fi

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" 2>/dev/null && pwd || true)
if [ -z "$source_dir" ] && [ -n "$script_dir" ] && [ -f "$script_dir/payload/harness/manifest.tsv" ]; then
  source_dir=$script_dir
fi

download_tool=""
if [ -z "$source_dir" ]; then
  if command -v curl >/dev/null 2>&1; then
    download_tool="curl"
  elif command -v wget >/dev/null 2>&1; then
    download_tool="wget"
  else
    die "Remote mode requires curl or wget. Download the repository and rerun with --source-dir."
  fi
fi

tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t agentforge) || die "Unable to create a temporary directory"
cleanup() { rm -rf -- "$tmp_dir"; }
trap cleanup EXIT HUP INT TERM
stage_dir="$tmp_dir/stage"
mkdir -p "$stage_dir"
destinations="$tmp_dir/destinations.txt"
: > "$destinations"

download_url() {
  url=$1
  output=$2
  mkdir -p "$(dirname -- "$output")"
  case "$download_tool" in
    curl) curl -fsSL --retry 2 "$url" -o "$output" ;;
    wget) wget -q "$url" -O "$output" ;;
    *) die "No download tool available" ;;
  esac
}

fetch_payload() {
  relative=$1
  output=$2
  if [ -n "$source_dir" ]; then
    [ -f "$source_dir/payload/$relative" ] || die "Missing payload file: payload/$relative"
    mkdir -p "$(dirname -- "$output")"
    cp "$source_dir/payload/$relative" "$output"
  else
    download_url "$DEFAULT_BASE_URL/payload/$relative" "$output"
  fi
}

record_destination() {
  relative=$1
  case "$relative" in
    /*|../*|*/../*|*/..|..) die "Unsafe destination path: $relative" ;;
  esac
  printf "%s\n" "$relative" >> "$destinations"
}

stage_payload() {
  payload_path=$1
  destination=$2
  fetch_payload "$payload_path" "$stage_dir/$destination"
  record_destination "$destination"
}

render_project_guide() {
  input=$1
  output=$2
  replacement=$3
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      *'{{PROJECT_NAME}}'*)
        prefix=${line%%'{{PROJECT_NAME}}'*}
        suffix=${line#*'{{PROJECT_NAME}}'}
        printf '%s%s%s\n' "$prefix" "$replacement" "$suffix"
        ;;
      *) printf '%s\n' "$line" ;;
    esac
  done < "$input" > "$output"
}

project_name=$(basename -- "$target")
[ -n "$project_name" ] || project_name="project"
project_name=$(printf '%s' "$project_name" | tr '\r\n\t' '   ')

if [ "$primary" = "agents" ]; then
  guide_variant="AGENTS"
  bridge_variant="CLAUDE"
else
  guide_variant="CLAUDE"
  bridge_variant="AGENTS"
fi

if [ "$with_harness" = "yes" ]; then
  stage_payload "guides/$guide_variant.harness.md" "$guide_variant.md"
else
  stage_payload "guides/$guide_variant.basic.md" "$guide_variant.md"
fi
stage_payload "guides/$bridge_variant.bridge.md" "$bridge_variant.md"

render_project_guide "$stage_dir/$guide_variant.md" "$tmp_dir/rendered-guide" "$project_name"
mv "$tmp_dir/rendered-guide" "$stage_dir/$guide_variant.md"

if [ "$with_harness" = "yes" ]; then
  manifest_file="$tmp_dir/harness-manifest.tsv"
  fetch_payload "harness/manifest.tsv" "$manifest_file"
  tab=$(printf '\t')
  while IFS="$tab" read -r payload_path destination || [ -n "$payload_path" ]; do
    [ -n "$payload_path" ] || continue
    stage_payload "harness/$payload_path" "$destination"
  done < "$manifest_file"
fi

skill_commit=""
if [ "$with_skill" = "yes" ]; then
  stage_payload "skills/SKILLS.orchestrate.md" "SKILLS.md"
  skill_files="$tmp_dir/orchestrate-files.txt"
  fetch_payload "orchestrate-files.txt" "$skill_files"

  if [ -n "${AGENTFORGE_SKILL_SOURCE_DIR:-}" ]; then
    skill_commit=${AGENTFORGE_SKILL_COMMIT:-local-test-fixture}
  else
    if [ -n "${AGENTFORGE_SKILL_COMMIT:-}" ]; then
      skill_commit=$AGENTFORGE_SKILL_COMMIT
    else
      api_output="$tmp_dir/orchestrate-commit.json"
      if [ -n "$source_dir" ] && [ -z "$download_tool" ]; then
        if command -v curl >/dev/null 2>&1; then download_tool="curl";
        elif command -v wget >/dev/null 2>&1; then download_tool="wget";
        else die "Installing the Skill requires curl or wget"; fi
      fi
      download_url "https://api.github.com/repos/$ORCHESTRATE_REPO/commits/main" "$api_output"
      skill_commit=$(sed -n 's/^[[:space:]]*"sha":[[:space:]]*"\([0-9a-f][0-9a-f]*\)".*/\1/p' "$api_output" | head -n 1)
      [ -n "$skill_commit" ] || die "Unable to resolve orchestrate-parallel-work main commit"
    fi
    if ! printf "%s\n" "$skill_commit" | grep '^[0-9a-fA-F]\{40\}$' >/dev/null 2>&1; then
      die "AGENTFORGE_SKILL_COMMIT must be a full 40-character Git commit SHA"
    fi
  fi

  while IFS= read -r skill_path || [ -n "$skill_path" ]; do
    [ -n "$skill_path" ] || continue
    case "$skill_path" in /*|../*|*/../*) die "Unsafe Skill path: $skill_path" ;; esac
    for skill_root in ".agents/skills/orchestrate-parallel-work" ".claude/skills/orchestrate-parallel-work"; do
      skill_dest="$stage_dir/$skill_root/$skill_path"
      if [ -n "${AGENTFORGE_SKILL_SOURCE_DIR:-}" ]; then
        [ -f "$AGENTFORGE_SKILL_SOURCE_DIR/$skill_path" ] || die "Missing Skill fixture file: $skill_path"
        mkdir -p "$(dirname -- "$skill_dest")"
        cp "$AGENTFORGE_SKILL_SOURCE_DIR/$skill_path" "$skill_dest"
      else
        download_url "https://raw.githubusercontent.com/$ORCHESTRATE_REPO/$skill_commit/skills/orchestrate-parallel-work/$skill_path" "$skill_dest"
      fi
      record_destination "$skill_root/$skill_path"
    done
  done < "$skill_files"

  origin_text="# Upstream origin

- Repository: https://github.com/$ORCHESTRATE_REPO
- Skill path: skills/orchestrate-parallel-work
- Commit: $skill_commit
- Installed by: agentForge $AGENTFORGE_VERSION
"
  for skill_root in ".agents/skills/orchestrate-parallel-work" ".claude/skills/orchestrate-parallel-work"; do
    printf "%s" "$origin_text" > "$stage_dir/$skill_root/ORIGIN.md"
    record_destination "$skill_root/ORIGIN.md"
  done
else
  stage_payload "skills/SKILLS.none.md" "SKILLS.md"
fi

conflicts_file="$tmp_dir/conflicts.txt"
: > "$conflicts_file"
add_conflict() {
  conflict_text=$1
  grep -F -x "$conflict_text" "$conflicts_file" >/dev/null 2>&1 || printf "%s\n" "$conflict_text" >> "$conflicts_file"
}
while IFS= read -r destination || [ -n "$destination" ]; do
  [ -n "$destination" ] || continue
  if [ -e "$target/$destination" ] || [ -L "$target/$destination" ]; then
    add_conflict "$destination"
  fi
  ancestor=$(dirname -- "$destination")
  while [ "$ancestor" != "." ]; do
    if [ -L "$target/$ancestor" ]; then
      add_conflict "$ancestor (symlink parent)"
      break
    fi
    if [ -e "$target/$ancestor" ] && [ ! -d "$target/$ancestor" ]; then
      add_conflict "$ancestor (non-directory parent)"
      break
    fi
    ancestor=$(dirname -- "$ancestor")
  done
done < "$destinations"

if [ -s "$conflicts_file" ]; then
  echo "ERROR: agentForge will not overwrite existing paths:" >&2
  sed 's/^/  /' "$conflicts_file" >&2
  echo "No project files were written." >&2
  exit 2
fi

mkdir -p "$target"
while IFS= read -r destination || [ -n "$destination" ]; do
  [ -n "$destination" ] || continue
  mkdir -p "$target/$(dirname -- "$destination")"
  cp "$stage_dir/$destination" "$target/$destination"
done < "$destinations"

if [ "$with_harness" = "yes" ]; then
  chmod +x "$target/harness/verify.sh"
fi

if [ "$git_choice" = "yes" ]; then
  git -c init.defaultBranch=main -C "$target" init >/dev/null
  echo "Initialized Git repository in $target."
fi

echo ""
echo "agentForge $AGENTFORGE_VERSION completed for $project_name."
echo "Canonical guide: $guide_variant.md"
echo "Compatibility guide: $bridge_variant.md"
echo "Strict Harness: $with_harness"
echo "orchestrate-parallel-work: $with_skill${skill_commit:+ ($skill_commit)}"
if [ "$with_harness" = "yes" ]; then
  echo ""
  echo "Next: open your AI coding agent in the project root and give it the prompt in:"
  echo "  docs/harness/BOOTSTRAP_PROMPT.md"
  echo "The generated Harness intentionally remains INCOMPLETE until that prompt succeeds."
fi
