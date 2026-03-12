# Evaluation Reference

Reference material for quality evaluation. Loaded by skills that need it, not every conversation.

## Stack Evaluation Checklist

| Layer     | Question                                                                          | Pass? |
| --------- | --------------------------------------------------------------------------------- | ----- |
| Prompt    | Did output match what was asked? Format, scope, constraints followed?             | [ ]   |
| Context   | Were all relevant docs read?                                                      | [ ]   |
| Intent    | Were tradeoffs resolved per Value Hierarchy?                                      | [ ]   |
| Judgment  | Were uncertainties documented? Assumptions flagged correctly?                     | [ ]   |
| Coherence | Does implementation follow existing patterns/ADRs? Consistent with previous work? | [ ]   |

## Diagnostic Loop

When output is unsatisfactory, diagnose WHICH layer failed:

1. Wrong format/scope/constraints? → **Prompt** issue
2. Missing/wrong information? → **Context** issue
3. Wrong tradeoffs? → **Intent** issue
4. Charged ahead on uncertain ground? → **Judgment** issue
5. Inconsistent with previous work? → **Coherence** issue

Re-enter at the failing layer. Often the fix is adding context or clarifying intent, not changing the prompt.

## Spec Self-Evaluator (run before executing any PRD)

- [ ] Problem stated before solution?
- [ ] Audience explicitly named?
- [ ] Success metrics quantitative and binary-testable?
- [ ] Failure modes enumerated?
- [ ] Danger modes enumerated?
- [ ] Non-goals at least as detailed as goals?
- [ ] All constraints explicit?
- [ ] Uncertainty policy stated?
- [ ] Tradeoff preferences stated?
- [ ] Verification steps described?
- [ ] All vague terms have measurable translations?
- [ ] No references to tacit knowledge without providing it?
- [ ] Abstraction level appropriate for task size?
- [ ] Could a different agent execute this unambiguously?

**Scoring:** 11-14 pass = ready. 7-10 = revise weak areas. Below 7 = fundamental rethink.
