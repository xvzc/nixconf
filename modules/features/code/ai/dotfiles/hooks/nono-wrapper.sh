#!/usr/bin/env bash
# PreToolUse hook for read-only subagents: rewrites a Bash command so it runs
# inside a read-only nono sandbox.
#
# Usage: nono-wrapper --profile <path>
#
# Exit code 2 blocks the call, any other nonzero code does not. So errors are
# handled explicitly and every failure goes through block(). Do not use
# `set -e` here, because it would exit with the failing command's own code.
set -o pipefail

block() {
  echo "nono-wrapper: $1" >&2
  exit 2
}

profile=
while (($# > 0)); do
  case $1 in
  --profile)
    (($# >= 2)) || block "--profile needs a value"
    profile=$2
    shift 2
    ;;
  *) block "unknown argument: $1" ;;
  esac
done

[[ -n $profile ]] || block "missing --profile <path>"
[[ -f $profile ]] || block "profile not found: $profile"

for tool in nono jq git; do
  command -v "$tool" >/dev/null 2>&1 || block "$tool not found in PATH"
done
nono=$(command -v nono)

input=$(cat) || block "cannot read hook input"
cwd=$(jq -er '.cwd | strings | select(length > 0)' <<<"$input" 2>/dev/null) ||
  block "hook input has no cwd, or it is not a non-empty string"
jq -e '.tool_input.command | strings | select(length > 0)' <<<"$input" >/dev/null 2>&1 ||
  block "hook input has no tool_input.command, or it is not a non-empty string"

roots=()
if root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null); then
  roots+=("$root")
  # Linked worktree: git also needs the main repo, which holds the common dir.
  common=$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) ||
    block "cannot resolve the git common dir in $cwd"
  if [[ $common != "$root/.git" ]]; then
    roots+=("$(dirname "$common")")
  fi
else
  roots+=("$cwd")
fi

# @sh single-quotes each string exactly, whatever characters it contains.
out=$(jq -ce --arg nono "$nono" --arg profile "$profile" '
  ($ARGS.positional | map("--read " + @sh) | join(" ")) as $reads
  | .tool_input
  | .command = ($nono | @sh) + " run --silent --profile " + ($profile | @sh)
      + " " + $reads + " -- bash -c " + (.command | @sh)
  | {hookSpecificOutput: {hookEventName: "PreToolUse", updatedInput: .}}
' --args "${roots[@]}" <<<"$input" 2>/dev/null) || block "cannot build the rewritten command"

[[ -n $out ]] || block "empty rewrite"
printf '%s\n' "$out"
