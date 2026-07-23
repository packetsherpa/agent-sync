#!/usr/bin/env bash
# SessionStart hook: keep the agent-sync repo current with origin.
#
# Behavior (fail-safe):
#   - fetch origin quietly; if offline/fetch fails, stay silent.
#   - if behind AND working tree clean AND history not diverged -> git merge --ff-only.
#   - if dirty OR diverged -> warn and change NOTHING.
#   - if already current (or only ahead) -> silent.
#
# A fast-forward only advances the branch pointer to commits already on origin,
# so it can never conflict or lose local work. Anything riskier is left to the user.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

json_escape() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  s=${s//$'\n'/\\n}
  printf '"%s"' "$s"
}

# Print a user-visible message as SessionStart hook JSON, then exit clean.
msg() {
  printf '{"systemMessage": %s, "suppressOutput": true}\n' "$(json_escape "$1")"
  exit 0
}

# Only act on a real git repo that has an origin remote.
git -C "$REPO" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
git -C "$REPO" remote get-url origin >/dev/null 2>&1 || exit 0

# Fetch quietly; if it fails (offline, auth), stay silent — startup must not break.
git -C "$REPO" fetch --quiet origin 2>/dev/null || exit 0

# Need an upstream for the current branch.
upstream="$(git -C "$REPO" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)" || exit 0
[ -n "$upstream" ] || exit 0

behind="$(git -C "$REPO" rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)"
ahead="$(git -C "$REPO" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)"

# Up to date, or only ahead: nothing to pull.
[ "${behind:-0}" -gt 0 ] || exit 0

branch="$(git -C "$REPO" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"

# Diverged: we have local commits origin doesn't. Never auto-merge.
if [ "${ahead:-0}" -gt 0 ]; then
  msg "agent-sync: local '$branch' has diverged from $upstream ($ahead ahead, $behind behind). Resolve manually (e.g. git pull --rebase); nothing changed."
fi

# Dirty working tree: don't touch it (avoids the stash/rebase conflict trap).
if [ -n "$(git -C "$REPO" status --porcelain 2>/dev/null)" ]; then
  msg "agent-sync: $behind commit(s) behind $upstream, but the working tree is dirty. Commit or stash, then pull; nothing changed."
fi

# Safe case: behind, clean, not diverged -> fast-forward only.
if git -C "$REPO" merge --ff-only --quiet '@{u}' 2>/dev/null; then
  msg "agent-sync: fast-forwarded '$branch' $behind commit(s) to match $upstream."
else
  msg "agent-sync: fast-forward of '$branch' failed unexpectedly; resolve manually. No partial state applied."
fi
