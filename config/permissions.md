# Claude Code Permissions Policy

## Purpose

Reduce routine development prompts while keeping destructive, networked, secret-touching, and system-level actions gated.

This policy is implemented in `settings.json` using Claude Code's user-level `permissions` settings. It is intentionally conservative and auditable.

## Allowed Without Prompt

Routine low-risk development actions inside the active workspace:

- navigation: `pwd`, `cd`, `ls`, `tree`
- reading/searching: `cat`, `less`, `head`, `tail`, `wc`, `grep`, `rg`, read-only `sed`, `awk`, `jq`
- safe Git inspection: `git status`, `git diff`, `git log`, `git show`, `git branch`, `git remote -v`
- common local validation commands: tests, lints, type checks, and builds that do not install packages or require network access
- edits accepted by Claude Code in ordinary workspaces through `permissions.defaultMode: "acceptEdits"`

Claude Code also has a built-in read-only Bash allowlist for commands such as `ls`, `cat`, `pwd`, `head`, `tail`, `grep`, `find`, `wc`, `which`, `diff`, `stat`, `du`, `cd`, and read-only Git forms.

## Require Approval

Actions that can destroy data, mutate important local state, cross trust boundaries, or expose private information:

- deleting or moving files outside normal reviewed edits
- permission/ownership changes: `chmod`, `chown`
- privileged or persistent system changes: `sudo`, `launchctl`, `defaults write`, system `plutil` writes
- network and remote access: `curl`, `wget`, `nc`, `ssh`, `scp`, remote `rsync`
- package installs: `brew install`, `npm install`, `pip install`, `cargo install`, and similar
- publish/history changes: `git push`, `git reset`, `git clean`
- reads from `~/.ssh`, `~/.aws`, broad `~/.config`, `~/.claude.json`, raw Claude projects/sessions/backups, and shell snapshots
- edits to `~/.claude` configuration itself

## Never Allow Automatically

- exfiltrating secrets
- printing secrets to the transcript
- uploading local files externally without explicit approval
- destructive recursive deletes outside the active repo
- modifying system security settings
- changing firewall, VPN, or endpoint security tooling
- installing persistent daemons or launch agents without review

## Workspace Boundary

Normal development should happen inside the active repo or explicitly selected workspace. Writes outside that boundary should require a deliberate user decision.

Use project-level `.claude/settings.json` only for team-safe, repo-specific rules. Use `.claude/settings.local.json` for personal local overrides that must not be committed.

## Secrets Handling

Secret-like files are denied or require approval by default:

- `.env` and `.env.*`
- `secrets/`
- `credentials/`
- `tokens/`
- private key and certificate files
- raw Claude sessions, projects, backups, and shell snapshots

Do not add secrets, tokens, OAuth state, or machine-specific credential paths to this repo.

## Network Handling

`WebFetch` and shell network commands such as `curl`, `wget`, `ssh`, `scp`, and `rsync` require approval.

If a project needs routine access to a specific domain, add a narrowly scoped project-level rule after review.

## Git Handling

Read-only Git commands are allowed. Publishing and history-mutating commands require approval:

- `git push`
- `git reset`
- `git clean`

Prefer reviewing `git status` and `git diff` before commits or pushes.
