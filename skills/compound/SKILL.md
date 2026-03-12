---
name: compound
description: >
  Post-task learning capture and knowledge promotion. Auto-invoke when a task
  or sprint is completed, when the user says "done", "finished", "wrap up",
  or when all acceptance criteria are checked off. Do NOT invoke when user
  says "ship it" — that triggers /ship-test-ensure instead.
---

# Compound: Learning Capture & Knowledge Promotion

1. **Review what was done** — read PRD, recent changes, or conversation context
2. **Identify learnings:**
   - What worked well?
   - What didn't work or was surprising?
   - Were there any assumptions that turned out wrong?
   - Did any tool/pattern perform better or worse than expected?
3. **Update session-learnings** with key findings
4. **Knowledge Promotion Chain** — check if promotion is warranted:
   - Does this pattern repeat from previous session-learnings? → promote to `docs/solutions/`
   - Does this affect architecture? → propose an ADR in `docs/architecture/decisions/`
   - Does this suggest a workflow change? → propose CLAUDE.md update (ask user first)
5. **The Three Compound Questions:**
   - "What was the hardest decision made here?"
   - "What alternatives were rejected, and why?"
   - "What are we least confident about?"
6. **If using git backup for `~/.claude/`:** suggest committing workflow changes
