#!/usr/bin/env bash
set -euo pipefail

repo_dir="${CLAUDE_CONFIG_REPO:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
claude_dir="${CLAUDE_HOME:-$HOME/.claude}"
stamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="$HOME/.claude.backup.$stamp"
local_stash="$claude_dir/local/pre-bootstrap-$stamp"

managed_paths=(
  "AGENTS.md"
  "CLAUDE.md"
  "MEMORY.md"
  "PROJECTS.md"
  "PERSONA.md"
  "SESSION_SUMMARY.md"
  "config"
  "memory"
  "settings.json"
  "statusline-command.sh"
  "tool-template"
)

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

[ -d "$repo_dir" ] || fail "Repo not found: $repo_dir"

for path in "${managed_paths[@]}"; do
  [ -e "$repo_dir/$path" ] || fail "Missing managed path in repo: $path"
done

if [ -e "$claude_dir" ]; then
  cp -a "$claude_dir" "$backup_dir"
  log "Backed up $claude_dir -> $backup_dir"
else
  mkdir -p "$claude_dir"
  log "Created $claude_dir"
fi

mkdir -p "$claude_dir/local"
mkdir -p "$local_stash"

for path in "${managed_paths[@]}"; do
  src="$repo_dir/$path"
  dest="$claude_dir/$path"

  if [ -L "$dest" ]; then
    current_target="$(readlink "$dest")"
    if [ "$current_target" = "$src" ]; then
      log "Already linked: $dest -> $src"
      continue
    fi
    mv "$dest" "$local_stash/$path.symlink"
    log "Moved existing symlink aside: $dest -> $local_stash/$path.symlink"
  elif [ -e "$dest" ]; then
    mkdir -p "$(dirname "$local_stash/$path")"
    mv "$dest" "$local_stash/$path"
    log "Moved existing path aside: $dest -> $local_stash/$path"
  fi

  ln -s "$src" "$dest"
  log "Linked: $dest -> $src"
done

# Cross-agent global instructions: Codex and Gemini read their own filenames.
# Point them at the same shared AGENTS.md so all three agents get one source of
# truth. Skip gracefully if the agent's home dir is not present on this machine.
link_cross_agent() {
  local dest="$1"
  local src="$repo_dir/AGENTS.md"
  local dir
  dir="$(dirname "$dest")"

  if [ ! -d "$dir" ]; then
    log "Skipping $dest (dir $dir not present)"
    return
  fi

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    log "Already linked: $dest -> $src"
    return
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.pre-bootstrap-$stamp"
    log "Moved existing path aside: $dest -> $dest.pre-bootstrap-$stamp"
  fi

  ln -s "$src" "$dest"
  log "Linked: $dest -> $src"
}

link_cross_agent "$HOME/.codex/AGENTS.md"
link_cross_agent "$HOME/.gemini/GEMINI.md"

# Per-agent custom commands (e.g. /new-repo). One source per agent format,
# installed to each agent's command dir. Skip gracefully if the agent is absent.
link_command() {
  local src="$repo_dir/$1"
  local dest="$2"
  local agent_root
  agent_root="$(dirname "$(dirname "$dest")")"

  if [ ! -d "$agent_root" ]; then
    log "Skipping $dest (agent dir $agent_root not present)"
    return
  fi
  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    log "Already linked: $dest -> $src"
    return
  fi
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mv "$dest" "$dest.pre-bootstrap-$stamp"
    log "Moved existing path aside: $dest -> $dest.pre-bootstrap-$stamp"
  fi
  ln -s "$src" "$dest"
  log "Linked: $dest -> $src"
}

link_command "commands/claude/new-repo.md"   "$claude_dir/commands/new-repo.md"
link_command "commands/codex/new-repo.md"    "$HOME/.codex/prompts/new-repo.md"
link_command "commands/gemini/new-repo.toml" "$HOME/.gemini/commands/new-repo.toml"

link_command "commands/claude/repo-triage.md"   "$claude_dir/commands/repo-triage.md"
link_command "commands/codex/repo-triage.md"    "$HOME/.codex/prompts/repo-triage.md"
link_command "commands/gemini/repo-triage.toml" "$HOME/.gemini/commands/repo-triage.toml"

link_command "commands/claude/session-handoff.md"   "$claude_dir/commands/session-handoff.md"
link_command "commands/codex/session-handoff.md"    "$HOME/.codex/prompts/session-handoff.md"
link_command "commands/gemini/session-handoff.toml" "$HOME/.gemini/commands/session-handoff.toml"

log "Done."
