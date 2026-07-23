Scaffold a new repository using a copier template that follows the AGENTS.md standard.

The copier template ships with this repo and is installed to `~/.claude/tool-template` by `bootstrap.sh`, so this works out of the box with no external dependency. To use a different template, set `TOOL_TEMPLATE_URL` in your environment (see `AGENTS.md`).

Requested: $ARGUMENTS (First token = repo name; the rest = one-line description. If the name is missing, ask for it. If the description is missing, ask for a short one.)

Steps:
1. Pick a destination directory — default `./<repo-name>` unless told otherwise.
2. Run (--trust is REQUIRED or the CLAUDE.md/GEMINI.md symlinks are skipped):
   ```
   uvx copier copy --trust "${TOOL_TEMPLATE_URL:-$HOME/.claude/tool-template}" <dest> \
     --data project_name=<repo-name> --data project_description="<description>" --defaults
   ```
   The bundled template is a local path — no network or GitHub auth needed. If `TOOL_TEMPLATE_URL` points at a private remote, ensure GitHub auth is available first.
3. `cd <dest> && git init && git add -A && git commit -m "Scaffold from template"`.
4. Ask whether to create a remote. If yes: `gh repo create <owner>/<repo-name> --source=. --push` (add `--private` if desired).
5. Confirm: `AGENTS.md` exists, `CLAUDE.md` and `GEMINI.md` are symlinks to it, and `.claude/memory/MEMORY.md` is present.

Report the destination path and the commands you ran.
