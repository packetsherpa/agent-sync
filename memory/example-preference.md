---
name: example-preference
description: Template for a durable preference fact — replace or delete
metadata:
  type: feedback
---

This is an example of a durable preference fact. Replace it with your own, or delete it.

Durable design preferences (example):

- **Local-first and portable.** Favor architectures that run locally and move between machines cleanly (git-backed, symlinked, no host lock-in).
- **Model-agnostic.** Treat models as interchangeable components; avoid designs that hard-bind to one provider.

**Why:** state the durable taste or reasoning behind the preference so an agent can generalize it.

**How to apply:** tell the agent what to do with it — e.g. "when proposing architecture, default to the lean/portable option and flag vendor lock-in."
