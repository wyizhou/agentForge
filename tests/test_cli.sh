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
assert_file "$case_one/docs/harness/DELIVERY_RULES.md"
assert_file "$case_one/harness/verify.sh"
assert_contains "$case_one/AGENTS.md" "My Strict Project project instructions"
assert_contains "$case_one/CLAUDE.md" "@AGENTS.md"
assert_absent "$case_one/docs/harness/BOOTSTRAP_PROMPT.md"
assert_absent "$case_one/harness/STATUS"
[ -d "$case_one/.git" ] || fail "Git repository was not initialized"
sh "$case_one/harness/verify.sh" > "$tmp_dir/generated-verify.log" 2>&1 || fail "Empty-project Harness verification failed"
assert_contains "$tmp_dir/generated-verify.log" "No project-specific checks are registered yet"
assert_contains "$tmp_dir/generated-verify.log" "Harness verification passed"
assert_contains "$tmp_dir/case-one.log" "You can start development now"

printf '# Project notes\n' > "$case_one/PROJECT_NOTES.md"
sh "$case_one/harness/verify.sh" > "$tmp_dir/docs-only.log" 2>&1 || fail "Documentation-only project incorrectly required code checks"
rm -f "$case_one/PROJECT_NOTES.md"

printf 'print("project code")\n' > "$case_one/app.py"
set +e
sh "$case_one/harness/verify.sh" > "$tmp_dir/unregistered-code.log" 2>&1
unregistered_code_status=$?
set -e
[ "$unregistered_code_status" -ne 0 ] || fail "Harness passed after code was added without project checks"
assert_contains "$tmp_dir/unregistered-code.log" "Project code or a technology manifest exists"
assert_contains "$tmp_dir/unregistered-code.log" "app.py"
rm -f "$case_one/app.py"

printf 'print("uppercase extension")\n' > "$case_one/APP.PY"
set +e
sh "$case_one/harness/verify.sh" > "$tmp_dir/uppercase-code.log" 2>&1
uppercase_code_status=$?
set -e
[ "$uppercase_code_status" -ne 0 ] || fail "Harness missed an uppercase source extension"
assert_contains "$tmp_dir/uppercase-code.log" "APP.PY"
rm -f "$case_one/APP.PY"

mkdir -p "$case_one/docs/site"
printf '<!doctype html>\n' > "$case_one/docs/site/index.html"
set +e
sh "$case_one/harness/verify.sh" > "$tmp_dir/docs-code.log" 2>&1
docs_code_status=$?
set -e
[ "$docs_code_status" -ne 0 ] || fail "Harness missed project code under docs"
assert_contains "$tmp_dir/docs-code.log" "docs/site/index.html"
rm -f "$case_one/docs/site/index.html"

printf 'print "project code";\n' > "$case_one/main.pl"
set +e
sh "$case_one/harness/verify.sh" > "$tmp_dir/unlisted-language.log" 2>&1
unlisted_language_status=$?
set -e
[ "$unlisted_language_status" -ne 0 ] || fail "Harness missed an unlisted programming language"
assert_contains "$tmp_dir/unlisted-language.log" "main.pl"
rm -f "$case_one/main.pl"

printf '#!/bin/sh\n' > "$case_one/tool"
set +e
sh "$case_one/harness/verify.sh" > "$tmp_dir/extensionless-code.log" 2>&1
extensionless_code_status=$?
set -e
[ "$extensionless_code_status" -ne 0 ] || fail "Harness missed an extensionless source file"
assert_contains "$tmp_dir/extensionless-code.log" "tool"
rm -f "$case_one/tool"

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
