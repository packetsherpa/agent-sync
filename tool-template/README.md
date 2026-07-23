# tool-template

Copier template bundled with **agent-sync**. Bakes in the agent-config + durable-memory standard so every new repo is conformant at creation — and stays conformant as the standard evolves (via `copier update`).

This template ships inside the agent-sync repo and is installed to `~/.claude/tool-template` by `bootstrap.sh`, so `/new-repo` uses it with no external dependency. You can also copy directly from the local path.

## What it generates

```
AGENTS.md              # single source of truth for agent instructions
CLAUDE.md              # symlink -> AGENTS.md  (Claude Code)
GEMINI.md              # symlink -> AGENTS.md  (Gemini CLI)
project-context.md     # optional: live-state / handoff doc
.claude/
  memory/
    MEMORY.md          # durable-memory index (@-imported from AGENTS.md)
.gitignore             # commits .claude/memory + settings.json; ignores local
.copier-answers.yml    # enables `copier update`
```

Global conventions and global memory live in `~/.claude` (managed by the `agent-sync` repo) and are intentionally NOT duplicated here.

> `--trust` is required: the `CLAUDE.md`/`GEMINI.md -> AGENTS.md` symlinks are only materialized when copier is trusted. Without it the symlinks are silently skipped.

## Create a new repo

```bash
uvx copier copy --trust ~/.claude/tool-template <dest-dir>
cd <dest-dir> && git init && git add -A && git commit -m "Scaffold from tool-template"
```

Copying from the local path needs no network or GitHub auth. To use a remote template instead, set `TOOL_TEMPLATE_URL` and point `copier copy` at it.

## Update an existing repo to the latest standard

Only works once a repo has `.copier-answers.yml` (all generated repos do).

```bash
cd <repo>
uvx copier update --trust --defaults      # review the diff, then commit
```

### Retrofitting a repo that predates the template

```bash
cd <repo>
uvx copier copy --trust --data-file /tmp/answers.yml ~/.claude/tool-template .   # writes .copier-answers.yml, prompts on conflicts
```

Do this on ONE repo first and confirm `copier update` behaves before rolling out.

## Scope

Agent config + durable memory only. Python/uv scaffolding (`pyproject.toml`, `.python-version`, ruff/pytest) is available behind the `is_python` question.
