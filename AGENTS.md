# Global Agent Guidance

This is the shared, agent-neutral global guidance for Claude Code, Codex, and Gemini. `AGENTS.md` is the source of truth; the copies at `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, and `~/.gemini/GEMINI.md` are symlinks to it (installed by `bootstrap.sh`).

## Primary Objective

Maximize useful work per token.

Be concise, direct, and execution-oriented. Assume the user is technically experienced and does not need introductory explanations unless asked.

## Context Discipline

- Treat context as a finite resource.
- Do not load files unless required.
- Do not scan entire repositories unless explicitly asked.
- Prefer targeted reads and searches.
- Prefer summaries over raw content.
- Keep startup context minimal.
- Use project-specific `AGENTS.md` files for project-specific rules.

## Work Style

- For small reversible tasks, act directly.
- For complex or risky tasks, make a concise plan first; stop before irreversible or high-risk actions.
- "Create a plan" means present the plan and do not execute.
- Make the smallest viable change.
- Avoid unrelated refactoring.
- Preserve existing project patterns.

## Tool Selection

- Use bash for file assembly, concatenation, search, and any task that requires no reasoning — never spawn a subagent for work a shell one-liner can do.
- Subagents are for tasks that require reasoning across content (analysis, review, synthesis). Not for mechanical assembly.

## Testing

- Prefer targeted validation first.
- Run full test suites only when necessary.
- Explain expensive validation before running it.

## Git

- Treat git history as memory.
- Use diffs to verify changes.
- Suggest concise commit messages after logical units of work.

## Working in This Repo

This repo is the source of truth synced to `~/.claude`, `~/.codex`, and `~/.gemini` — treat it as unusually secrets-sensitive.

- Run `./audit-secrets.sh` before committing (uses `betterleaks`, falls back to a pattern grep if not installed).
- `sync-on-start.sh` runs on every session start (a `SessionStart` hook in `settings.json`) to keep the local clone current: it fetches origin and fast-forwards **only** when the branch is behind, the tree is clean, and history has not diverged. If the tree is dirty or diverged it warns and changes nothing — so commit or stash before relying on it.
- See `README.md` for repo structure, `bootstrap.sh`, and `setup-new-machine.sh`.

## Bootstrapping a New Repo

The `/new-repo [name] [description]` command scaffolds a new standard-conformant repo (AGENTS.md source of truth, CLAUDE.md/GEMINI.md symlinks, durable-memory scaffold). The copier template ships with this repo under `tool-template/` and is installed to `~/.claude/tool-template` by `bootstrap.sh`, so it works with no external dependency:

```
uvx copier copy --trust ~/.claude/tool-template <dest>
cd <dest> && git init && git add -A && git commit -m "Scaffold from template"
```

- `--trust` is required, or the `CLAUDE.md`/`GEMINI.md → AGENTS.md` symlinks are silently skipped.
- To use a different template, set `TOOL_TEMPLATE_URL` and point `copier copy` at it instead.
- Then create the remote and push. Pull future standard changes with `uvx copier update --trust --defaults`.

## Memory

Durable memory is one fact per file (frontmatter: `name`, `description`, `metadata.type`), indexed in a `MEMORY.md`. Facts only — do not restate this file's policy as memory.

- **Project facts** → `<repo>/.claude/memory/`, committed, imported from the repo's `AGENTS.md` via `@.claude/memory/MEMORY.md`. Per repo, `AGENTS.md` is the source of truth and `CLAUDE.md` is a symlink to it.
- **Global / cross-repo facts** → `~/.claude/memory/` (source: `memory/` in this repo), indexed in `~/.claude/MEMORY.md`.
- Do **not** use the per-session `~/.claude/projects/**/memory/` default location.

## Session Management

When context gets large:

- summarize current state
- update SESSION_SUMMARY.md if useful
- recommend a fresh session

## Security

Assume security matters. Favor least privilege, explicit permissions, secure defaults, auditability, and maintainability.

Call out material security risks briefly.

## Multi-Model Workflow

Assume research, architecture, or strategy may be handled by other models.

Focus the coding agent on:

- implementation
- debugging
- refactoring
- testing
- automation
- documentation

Treat models as interchangeable components where practical.

## Output Format

For advisory answers, prefer:

1. Recommendation
2. Brief reasoning
3. Next step

Keep responses compact unless more detail is requested.

## Markdown

Never hard-wrap paragraphs. Write each paragraph as a single line and let the rendering engine (editor, browser, terminal, GitHub) handle wrapping. Line breaks carry semantic meaning only for list items, headings, code blocks, and tables — not for fitting prose to a column width.
