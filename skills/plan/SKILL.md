---
name: plan
description: >
  Task planning and PRD generation. Auto-invoke when the user describes a new
  task, feature request, bug to fix (multi-file), refactoring need, or says
  "plan", "let's build", "I need", "implement", "create a PRD". Do NOT invoke
  for simple questions, conversations, or single-line fixes.
---

# Plan: Task Classification and PRD Generation

## Steps

1. **Classify mode** based on scope:
   - **Quick Fix:** Single-file, < 30 lines, no architectural impact → skip this skill, fix directly (no PRD needed)
   - **Standard:** Multi-file, clear scope, moderate complexity → Minimal PRD
   - **PRD + Sprint:** Large feature, multi-component, >1h of work → Full PRD

2. **If Quick Fix:** Tell the user this doesn't need a PRD — they can fix directly or use `/plan-build-test`. Done.

3. **If Standard or PRD+Sprint:**
   a. Run **Contract-First Pattern**: mirror your understanding back to user, get confirmation before proceeding
   b. Run **Correctness Discovery** (scaled by mode — see CLAUDE.md):
   - **Standard:** Audience + Verification (2 questions)
   - **PRD+Sprint:** All 6 questions (full framework in `~/.claude/skills/plan/correctness-discovery.md`)
     c. If project has a **Context Routing Table** in its CLAUDE.md → follow it. Otherwise → search for relevant docs manually
     d. Create PRD at `docs/tasks/<area>/<category>/YYYY-MM-DD_HHmm-name.md` (create directories if they don't exist)
     e. Fill "Context Loaded" section with what you learned from docs
     f. Write PRD using appropriate template (read from `~/.claude/skills/plan/prd-template-minimal.md` for Standard, `~/.claude/skills/plan/prd-template-full.md` for PRD+Sprint)
     g. For PRD+Sprint: decompose into Sprints with dependencies and acceptance criteria
     h. Run **Spec Self-Evaluator** from `~/.claude/docs/evaluation-reference.md` (must score 11+ out of 14 to proceed)
     i. Tell the user: "PRD saved at [path]. Run `/plan-build-test` to execute, or review and adjust first."
     j. **Do NOT execute.** This skill produces the plan only.
