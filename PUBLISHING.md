# Publishing This as a Public Repo

This directory is a sanitized, public-safe copy of a private agent-config repo. It was staged inside the private repo for review. **Do not publish it by pushing the private repo's history** — that history still contains personal data. Publish it as a fresh repo with no prior history:

```bash
# From the private repo root, copy this tree out to a clean location
cp -R public /path/to/agent-sync
cd /path/to/agent-sync

# Start fresh history — nothing from the private repo comes with it
git init
git add -A
git commit -m "Initial public release"

# Create the public remote and push
gh repo create <owner>/agent-sync --public --source=. --push
```

## Before you push — final checklist

- [ ] Fill in `LICENSE` copyright holder (currently `<YOUR NAME>`).
- [ ] Replace or empty the example content in `PROJECTS.md`, `SESSION_SUMMARY.md`, and `memory/*.md` if you don't want the samples public.
- [ ] `/new-repo` uses the bundled `tool-template/` by default; customize it or override with `TOOL_TEMPLATE_URL` if you prefer a different one.
- [ ] Run `./audit-secrets.sh` and review every hit.
- [ ] Confirm `CLAUDE.md` and `GEMINI.md` are symlinks to `AGENTS.md` (`ls -l`).
- [ ] Grep for personal identifiers one last time: names, emails, private repo/org names, absolute home paths.

## Keeping it in sync with your private repo (optional)

If you maintain both, treat the private repo as upstream and periodically re-run the sanitization when shared files change. The safest pattern is to keep this `public/` staging directory in the private repo, update it, then `cp -R` + commit into the public repo — never merge histories between the two.
