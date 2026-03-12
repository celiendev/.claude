---
name: check-and-fix
description: >
  Bug fixing with judgment protocols. Auto-invoke when the user reports a bug,
  describes unexpected behavior, asks to "fix", "debug", "investigate", or
  references error messages. Also invoke when a task file with bugs/issues
  is provided.
---

# Check and Fix: Bug Fixing with Judgment

1. **Classify scope:** Quick Fix (single-file, obvious) or Standard (multi-file, investigation needed)
   - If Standard → create a Minimal PRD before proceeding
2. **Before each fix:** classify confidence level:
   - HIGH: Clear root cause, existing tests confirm → proceed
   - MEDIUM: Probable cause, no tests → proceed but document assumption
   - LOW: Multiple possible causes, unfamiliar area → STOP and ask user
3. **Preserve verification loops:** Run test suite after each fix
4. **Preserve human confirmation gate:** If the fix touches auth, data, or API contracts → confirm with user before applying
5. **Anti-Goodhart check** before marking complete:
   - Does the fix address the ROOT cause or just the symptom?
   - Will the test catch a regression or just this specific case?
6. **Scope Boundary:** If you discover unrelated issues during investigation → log them in PRD/session-learnings, do NOT fix them
