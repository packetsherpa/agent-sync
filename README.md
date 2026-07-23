# agent-sync

A portable, versioned configuration template for AI coding agents — Claude Code, Codex, and Gemini — from a single source of truth.

`AGENTS.md` holds one set of agent-neutral guidance. `bootstrap.sh` symlinks it (and your curated memory, commands, and settings) into `~/.claude`, `~/.codex`, and `~/.gemini`, so every agent reads the same rules and edits to this repo update your live config in place. Raw transcripts, caches, credentials, and machine-specific state are intentionally excluded.

Fork it, delete the example content, and drop in your own.

## What Belongs Here

- `AGENTS.md` (source of truth) with `CLAUDE.md` and `GEMINI.md` as symlinks to it
- `MEMORY.md`, `PROJECTS.md`, `PERSONA.md`, `SESSION_SUMMARY.md`
- Cross-agent slash commands in `commands/` (`claude/`, `codex/`, `gemini/`), linked in by `bootstrap.sh`
- Curated durable-memory notes in `memory/`
- Human-readable policy in `config/`
- `settings.json` for portable user-level Claude Code settings
- `tool-template/` — bundled copier template for `/new-repo` (installed to `~/.claude/tool-template` by `bootstrap.sh`)
- Bootstrap and audit scripts

## What Stays Local (never commit)

- `~/.claude.json`
- `~/.claude/projects/*.jsonl` (raw session transcripts)
- `~/.claude/sessions/raw/`, `~/.claude/backups/`, `~/.claude/shell-snapshots/`, `~/.claude/session-env/`, `~/.claude/local/`
- Any credentials, tokens, keys, `.env` files, or host-specific paths
- Machine-specific provider/auth settings → `settings.local.json` (see `config/sync.md`)

## Setup

Clone this repo, then run:

```bash
./setup-new-machine.sh
```

The setup script validates `settings.json`, runs the local secret audit, and then calls `bootstrap.sh`. It works from any clone path.

Or bootstrap directly:

```bash
./bootstrap.sh
```

`bootstrap.sh` backs up `~/.claude`, moves existing managed paths aside into `~/.claude/local/pre-bootstrap-*`, and symlinks the selected files and directories from this repo into `~/.claude` (and the shared `AGENTS.md` into `~/.codex` and `~/.gemini` when those dirs exist). Override the repo location with `CLAUDE_CONFIG_REPO=/path/to/clone`.

## Audit Before Committing

```bash
./audit-secrets.sh
```

Uses [`betterleaks`](https://github.com/betterleaks/betterleaks) if installed, otherwise a conservative pattern grep. Review every hit before committing — this repo syncs into your live agent config.

## Customizing

1. Replace the placeholder content in `PROJECTS.md`, `SESSION_SUMMARY.md`, and `memory/*.md` with your own (or empty them).
2. Edit `AGENTS.md` to match how you want your agents to behave.
3. Adjust `settings.json` permissions and `config/permissions.md` policy to taste.
4. `/new-repo` scaffolds new repos from the bundled `tool-template/` — no setup needed. Customize that template, or point `/new-repo` at a different one via `TOOL_TEMPLATE_URL`.

## License

MIT — see [LICENSE](LICENSE).
