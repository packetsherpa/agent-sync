#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$script_dir"
claude_dir="${CLAUDE_HOME:-$HOME/.claude}"

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_file() {
  [ -e "$repo_dir/$1" ] || fail "Missing required repo path: $1"
}

validate_json() {
  if command -v jq >/dev/null 2>&1; then
    jq empty "$repo_dir/settings.json"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -m json.tool "$repo_dir/settings.json" >/dev/null
  else
    log "Skipping JSON validation: jq and python3 are not installed."
  fi
}

log "Claude sync new-machine setup"
log "Repo: $repo_dir"
log "Target Claude dir: $claude_dir"
log ""

require_file "bootstrap.sh"
require_file "audit-secrets.sh"
require_file "settings.json"
require_file "AGENTS.md"
require_file "CLAUDE.md"
require_file "MEMORY.md"
require_file "PROJECTS.md"
require_file "commands"
require_file "config"
require_file "memory"

if git -C "$repo_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if [ -n "$(git -C "$repo_dir" status --short)" ]; then
    log "Warning: repo has uncommitted changes. Continuing because bootstrap only reads repo files."
  fi
else
  log "Warning: $repo_dir is not a Git worktree. Continuing with local files."
fi

log "Validating settings.json..."
validate_json

log "Running secret audit..."
"$repo_dir/audit-secrets.sh"

log "Bootstrapping ~/.claude from this repo..."
CLAUDE_CONFIG_REPO="$repo_dir" "$repo_dir/bootstrap.sh"

# Machine profile: write settings.local.json if not already present
local_settings="$claude_dir/settings.local.json"
if [ -e "$local_settings" ]; then
  log ""
  log "settings.local.json already exists at $local_settings — skipping profile setup."
  log "Edit it manually if the machine profile needs to change."
else
  log ""
  log "Machine profile setup"
  log "  1) Personal (claude.ai subscription)"
  log "  2) Work — Vertex AI (corporate GCP subscription)"
  printf 'Choose profile [1/2]: '
  read -r profile_choice

  case "$profile_choice" in
    2)
      printf 'GCP project ID: '
      read -r gcp_project
      printf 'Vertex region [us-east5]: '
      read -r gcp_region
      gcp_region="${gcp_region:-us-east5}"
      printf '{\n  "$schema": "https://json.schemastore.org/claude-code-settings.json",\n  "apiProvider": "vertex",\n  "vertexProjectId": "%s",\n  "vertexRegion": "%s"\n}\n' \
        "$gcp_project" "$gcp_region" > "$local_settings"
      log "Wrote Vertex AI profile to $local_settings"
      log "Ensure 'gcloud auth application-default login' has been run, or GOOGLE_APPLICATION_CREDENTIALS is set."
      ;;
    *)
      log "Personal profile selected — no settings.local.json needed."
      ;;
  esac
fi

log ""
log "Setup complete."
log "Synced config is linked into $claude_dir."
log "Shared global guidance (AGENTS.md) is also linked into ~/.codex/AGENTS.md and ~/.gemini/GEMINI.md when those agent dirs exist."
log "Machine-local Claude state remains local: ~/.claude.json, settings.local.json, projects, sessions, backups, shell snapshots, session env, and credentials."
log "Run 'git pull' in this repo later to receive updates, then rerun this script or ./bootstrap.sh."

