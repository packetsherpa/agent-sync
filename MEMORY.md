# Memory

Global durable memory index — loaded each session. One fact per file in `memory/`. Facts only, not policy (operating guidance lives in `CLAUDE.md`). Live project state belongs in the relevant project repo.

Replace the example fact below with your own durable facts.

- [Durable memory standard](memory/durable-memory-standard.md) — the agent-config + memory standard (AGENTS.md source, `.claude/memory/` one-fact files)
- [Agent config is versioned infra](memory/agent-config-is-versioned-infra.md) — this repo is the source of truth for `~/.claude`; raw session state stays local
- [Example preference](memory/example-preference.md) — template for a durable preference fact
