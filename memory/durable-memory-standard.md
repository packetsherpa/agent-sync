---
name: durable-memory-standard
description: The standard for agent config and durable memory across all repos
metadata:
  type: reference
---

Standard for agent config + durable memory across every repo:

- **Agent instructions:** `AGENTS.md` is the single source of truth per repo; `CLAUDE.md` **and** `GEMINI.md` are symlinks to it (Claude and Codex read AGENTS.md natively, Gemini reads GEMINI.md). No hand-maintained duplicate files. A copier template (set `TOOL_TEMPLATE_URL` to your own) can generate this layout for new repos.
- **Global guidance:** the same one-source-many-symlinks pattern applies globally — this repo's `AGENTS.md` is canonical, installed by `bootstrap.sh` to `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and `~/.gemini/GEMINI.md`.
- **Durable memory format:** one fact per file with frontmatter (`name`, `description`, `metadata.type`), linked with `[[slug]]`, indexed in a `MEMORY.md`. Same shape everywhere.
- **Project memory:** `<repo>/.claude/memory/` — committed, `@`-imported from the repo's `AGENTS.md` via `@.claude/memory/MEMORY.md`. `.gitignore` carves it out: `.claude/*` ignored except `!memory/` and `!settings.json`; `settings.local.json` stays local.
- **Global memory:** `~/.claude/memory/` (source: this repo's `memory/`), indexed in `~/.claude/MEMORY.md` (the index the harness loads each session).
- **Not used:** the native per-session `~/.claude/projects/**/memory/` location.
- **Split of concerns:** durable facts/decisions/landmines → memory; live/churning state (active branches, next work, blockers) → a `project-context.md`-style doc; changelog → git history.

Do not restate `CLAUDE.md` policy as memory — memory is for facts, not operating guidance. See [[agent-config-is-versioned-infra]].
