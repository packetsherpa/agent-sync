---
name: agent-config-is-versioned-infra
description: This repo is the source-controlled source of truth for ~/.claude; raw session state stays local-only
metadata:
  type: reference
---

This repo is the source-controlled source of truth for global agent config. `bootstrap.sh` symlinks its managed paths into `~/.claude` (`CLAUDE.md`, `MEMORY.md`, `PROJECTS.md`, `PERSONA.md`, `SESSION_SUMMARY.md`, `config/`, `memory/`, `settings.json`, `statusline-command.sh`) and the shared `AGENTS.md` into `~/.codex` and `~/.gemini`. Because these are symlinks, editing the repo files updates the live config in place — no re-bootstrap needed unless a new top-level managed path is added.

Design rules:
- Keep `~/.claude` lean. Config + curated memory are versioned infrastructure.
- Raw sessions, caches, OAuth state, and credentials stay **local-only** — never committed (enforced by `.gitignore` and `audit-secrets.sh`).
- Machine-specific provider/auth config lives in `settings.local.json`, written by `setup-new-machine.sh`, never synced.

See [[durable-memory-standard]] for where memory lives within this system.
