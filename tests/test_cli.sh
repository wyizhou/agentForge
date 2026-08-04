#!/bin/sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_dir=$(mktemp -d 2>/dev/null || mktemp -d -t agentforge-test)
cleanup() { rm -rf -- "$tmp_dir"; }
trap cleanup EXIT HUP INT TERM

fail() {
  echo "TEST FAILURE: $*" >&2
  exit 1
}

assert_file() { [ -f "$1" ] || fail "missing file: $1"; }
assert_absent() { [ ! -e "$1" ] || fail "unexpected path: $1"; }
assert_contains() { grep -F "$2" "$1" >/dev/null || fail "$1 does not contain: $2"; }
assert_not_contains() { ! grep -F "$2" "$1" >/dev/null || fail "$1 unexpectedly contains: $2"; }

case_one="$tmp_dir/My Strict Project"
sh "$repo_dir/agentforge.sh" \
  --source-dir "$repo_dir" \
  --target "$case_one" \
  --primary agents \
  --harness yes \
  --skill no \
  --git yes > "$tmp_dir/case-one.log"

assert_file "$case_one/AGENTS.md"
assert_file "$case_one/CLAUDE.md"
assert_file "$case_one/ARCHITECTURE.md"
assert_file "$case_one/docs/README.md"
assert_file "$case_one/docs/harness/README.md"
assert_file "$case_one/docs/harness/DELIVERY_RULES.md"
assert_file "$case_one/docs/harness/COMMANDS.md"
assert_file "$case_one/docs/harness/CHECKS.md"
assert_contains "$case_one/AGENTS.md" "My Strict Project project instructions"
assert_contains "$case_one/CLAUDE.md" "@AGENTS.md"
assert_contains "$case_one/AGENTS.md" 'docs/harness/DELIVERY_RULES.md'
assert_contains "$case_one/AGENTS.md" 'docs/harness/COMMANDS.md'
assert_contains "$case_one/AGENTS.md" 'docs/harness/CHECKS.md'
assert_contains "$case_one/CLAUDE.md" 'docs/harness/DELIVERY_RULES.md'
assert_contains "$case_one/CLAUDE.md" 'docs/harness/COMMANDS.md'
assert_contains "$case_one/CLAUDE.md" 'docs/harness/CHECKS.md'
assert_contains "$case_one/AGENTS.md" "test runner and linter"
assert_contains "$case_one/AGENTS.md" "project-native"
assert_contains "$case_one/docs/harness/DELIVERY_RULES.md" "Every new or changed behavior"
assert_contains "$case_one/docs/harness/DELIVERY_RULES.md" "regression test"
assert_contains "$case_one/docs/harness/DELIVERY_RULES.md" "test runner and linter"
assert_contains "$case_one/docs/harness/DELIVERY_RULES.md" "Before delivery"
assert_contains "$case_one/docs/harness/DELIVERY_RULES.md" "does not generate or require a unified"
assert_not_contains "$case_one/AGENTS.md" "harness/verify"
assert_not_contains "$case_one/docs/harness/DELIVERY_RULES.md" "harness/verify"
assert_absent "$case_one/harness"
assert_absent "$case_one/docs/harness/BOOTSTRAP_PROMPT.md"
[ -d "$case_one/.git" ] || fail "Git repository was not initialized"
assert_contains "$tmp_dir/case-one.log" "You can start development now"

case_two="$tmp_dir/basic-claude"
sh "$repo_dir/agentforge.sh" \
  --source-dir "$repo_dir" \
  --target "$case_two" \
  --primary claude \
  --harness no \
  --skill no \
  --git no > "$tmp_dir/case-two.log"

assert_file "$case_two/CLAUDE.md"
assert_file "$case_two/AGENTS.md"
assert_file "$case_two/SKILLS.md"
assert_contains "$case_two/CLAUDE.md" "basic-claude project instructions"
assert_contains "$case_two/AGENTS.md" 'read `CLAUDE.md` completely'
assert_absent "$case_two/harness"
assert_absent "$case_two/docs/harness"
assert_absent "$case_two/.git"

case_conflict="$tmp_dir/conflict"
mkdir -p "$case_conflict"
printf "user-owned\n" > "$case_conflict/AGENTS.md"
set +e
sh "$repo_dir/agentforge.sh" \
  --source-dir "$repo_dir" \
  --target "$case_conflict" \
  --primary agents \
  --harness yes \
  --skill no \
  --git no > "$tmp_dir/conflict.log" 2>&1
conflict_status=$?
set -e
[ "$conflict_status" -eq 2 ] || fail "conflict exit code was $conflict_status, expected 2"
[ "$(cat "$case_conflict/AGENTS.md")" = "user-owned" ] || fail "existing file was overwritten"
assert_absent "$case_conflict/CLAUDE.md"
assert_absent "$case_conflict/SKILLS.md"
assert_contains "$tmp_dir/conflict.log" "No project files were written"

case_parent_conflict="$tmp_dir/parent-conflict"
mkdir -p "$case_parent_conflict"
printf "user-owned parent\n" > "$case_parent_conflict/docs"
set +e
sh "$repo_dir/agentforge.sh" \
  --source-dir "$repo_dir" \
  --target "$case_parent_conflict" \
  --primary agents \
  --harness yes \
  --skill no \
  --git no > "$tmp_dir/parent-conflict.log" 2>&1
parent_conflict_status=$?
set -e
[ "$parent_conflict_status" -eq 2 ] || fail "parent conflict exit code was $parent_conflict_status, expected 2"
[ "$(cat "$case_parent_conflict/docs")" = "user-owned parent" ] || fail "parent conflict file was modified"
assert_absent "$case_parent_conflict/AGENTS.md"
assert_absent "$case_parent_conflict/CLAUDE.md"
assert_contains "$tmp_dir/parent-conflict.log" "non-directory parent"

fixture="$tmp_dir/skill-fixture"
while IFS= read -r path || [ -n "$path" ]; do
  [ -n "$path" ] || continue
  mkdir -p "$fixture/$(dirname -- "$path")"
  printf "fixture:%s\n" "$path" > "$fixture/$path"
done < "$repo_dir/payload/orchestrate-files.txt"

case_skill="$tmp_dir/with-skill"
AGENTFORGE_SKILL_SOURCE_DIR="$fixture" \
AGENTFORGE_SKILL_COMMIT="fixture-commit" \
sh "$repo_dir/agentforge.sh" \
  --source-dir "$repo_dir" \
  --target "$case_skill" \
  --primary agents \
  --harness no \
  --skill yes \
  --git no > "$tmp_dir/skill.log"

assert_file "$case_skill/.agents/skills/orchestrate-parallel-work/SKILL.md"
assert_file "$case_skill/.claude/skills/orchestrate-parallel-work/SKILL.md"
assert_file "$case_skill/.agents/skills/orchestrate-parallel-work/ORIGIN.md"
assert_contains "$case_skill/.agents/skills/orchestrate-parallel-work/ORIGIN.md" "fixture-commit"
diff -r "$case_skill/.agents/skills/orchestrate-parallel-work" "$case_skill/.claude/skills/orchestrate-parallel-work" >/dev/null || fail "Skill copies differ"

case_mutable_ref="$tmp_dir/mutable-skill-ref"
set +e
AGENTFORGE_SKILL_COMMIT="main" \
sh "$repo_dir/agentforge.sh" \
  --source-dir "$repo_dir" \
  --target "$case_mutable_ref" \
  --primary agents \
  --harness no \
  --skill yes \
  --git no > "$tmp_dir/mutable-ref.log" 2>&1
mutable_ref_status=$?
set -e
[ "$mutable_ref_status" -ne 0 ] || fail "mutable Skill ref unexpectedly succeeded"
assert_absent "$case_mutable_ref"
assert_contains "$tmp_dir/mutable-ref.log" "full 40-character Git commit SHA"

case_current="$tmp_dir/current-directory"
mkdir -p "$case_current"
(
  cd "$case_current"
  sh "$repo_dir/agentforge.sh" \
    --source-dir "$repo_dir" \
    --primary agents \
    --harness no \
    --skill no \
    --git no > "$tmp_dir/current.log"
)
assert_contains "$case_current/AGENTS.md" "current-directory project instructions"

case_parent_repo="$tmp_dir/existing-parent-repo"
mkdir -p "$case_parent_repo"
git -c init.defaultBranch=main -C "$case_parent_repo" init >/dev/null
case_nested_target="$case_parent_repo/new-project"
sh "$repo_dir/agentforge.sh" \
  --source-dir "$repo_dir" \
  --target "$case_nested_target" \
  --primary agents \
  --harness no \
  --skill no \
  --git yes > "$tmp_dir/parent-repo.log"
assert_file "$case_nested_target/AGENTS.md"
assert_absent "$case_nested_target/.git"
assert_contains "$tmp_dir/parent-repo.log" "Git repository detected"

case_newline="$tmp_dir/line
break"
sh "$repo_dir/agentforge.sh" \
  --source-dir "$repo_dir" \
  --target "$case_newline" \
  --primary agents \
  --harness no \
  --skill no \
  --git no > "$tmp_dir/newline.log"
assert_file "$case_newline/AGENTS.md"
assert_contains "$case_newline/AGENTS.md" "line break project instructions"

echo "POSIX CLI integration tests passed."
