# Sync Policy

## What Is Synced

This repo may sync:

- `AGENTS.md` (with `CLAUDE.md` and `GEMINI.md` symlinks)
- `MEMORY.md`
- `PROJECTS.md`
- `PERSONA.md`
- `SESSION_SUMMARY.md`
- `commands/` (cross-agent slash commands)
- curated `memory/` notes
- `config/` (human-readable policy)
- `settings.json` (shared base — no provider or auth settings)
- `bootstrap.sh`, `setup-new-machine.sh`, `sync-on-start.sh`, `audit-secrets.sh`, `statusline-command.sh`
- `.gitignore`
- `README.md`, `LICENSE`

Only curated summaries belong here. Raw transcripts and generated state do not.

## What Is Local-Only

Keep these out of Git:

- `~/.claude.json`
- `~/.claude/projects/*.jsonl`
- `~/.claude/sessions/raw/`
- `~/.claude/backups/`
- `~/.claude/shell-snapshots/`
- `~/.claude/session-env/`
- `~/.claude/ide/`
- `~/.claude/local/`
- logs, caches, temp files
- credentials, tokens, keys, `.env` files, OAuth state
- machine-specific absolute paths unless intentionally documented

## Machine Profiles

`settings.json` in this repo is the shared base — permissions and behaviors common to all machines, with **no provider or auth config**.

Provider-specific configuration (for example, pointing an agent at a cloud provider like Vertex AI or Bedrock instead of a personal subscription) belongs in a machine-local file that is never committed:

- `settings.local.json` in `~/.claude/` — written by `setup-new-machine.sh`, holds per-machine provider/auth settings, and stays out of Git.

If you also use editor settings sync (e.g. VS Code Settings Sync), exclude any provider/auth environment variables from it so work-specific config does not leak onto personal machines. Store extension auth in the OS keychain and sign in per machine rather than syncing tokens.
