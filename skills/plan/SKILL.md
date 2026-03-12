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
   - **Quick Fix:** Single-file, < 30 lines, no architectural impact → write Intent Doc (4 lines: Task, Scope, Boundaries, If Uncertain), execute directly
   - **Standard:** Multi-file, clear scope, moderate complexity → Minimal PRD
   - **PRD + Sprint:** Large feature, multi-component, >1h of work → Full PRD

2. **If Quick Fix:** Execute directly, run tests, update session-learnings if surprising. Done.

3. **If Standard or PRD+Sprint:**
   a. Run **Contract-First Pattern**: mirror your understanding back to user, get confirmation before proceeding
   b. Run **Correctness Discovery** (answer all 6 questions):
      - Audience: Who uses this output?
      - Failure Definition: What makes it useless?
      - Danger Definition: What makes it harmful?
      - Uncertainty Policy: Guess / Flag / Stop?
      - Risk Tolerance: Wrong answer vs. refusal — which is worse?
      - Verification: How to check correctness?
   c. If project has a **Context Routing Table** in its CLAUDE.md → follow it. Otherwise → search for relevant docs manually
   d. Create PRD at `docs/tasks/<area>/<category>/YYYY-MM-DD_HHmm-name.md` (create directories if they don't exist)
   e. Fill "Context Loaded" section with what you learned from docs
   f. Write PRD using appropriate template (read from `~/.claude/skills/plan/prd-template-minimal.md` for Standard, `~/.claude/skills/plan/prd-template-full.md` for PRD+Sprint)
   g. For PRD+Sprint: decompose into Sprints with dependencies and acceptance criteria
   h. Run **Spec Self-Evaluator** (must score 11+ out of 14 to proceed)
   i. Ask user for execution mode: Autonomous / Step-by-step
   j. Execute (directly for Standard, Sprint-by-Sprint for PRD+Sprint)
   k. After each sprint: update PRD status, run Stack Evaluation, check context health
   l. After completion: run full verification, invoke the `compound` skill
