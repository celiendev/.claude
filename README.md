# Claude Workflow System

A portable AI engineering system for Claude Code that applies automatically to every project. Built on the Compound Engineering philosophy: each unit of work makes subsequent units easier — not harder.

Based on The AI-Human Engineering Stack and The Complete Guide to Specifying Work for AI (Mill & Sanchez, 2026).

## Quick Start

```bash
# 1. Clone to ~/.claude/
git clone <repository-url> ~/.claude

# 2. Open any project with Claude Code
cd /path/to/your/project
claude

# 3. That's it — the system loads automatically
```

Hooks enforce rules deterministically, agents handle complex work, and skills auto-invoke based on what you're doing. Project-specific context goes in each project's own `CLAUDE.md` (see [Getting Started](workflow/02-getting-started.md)).

## How It Works

```
PLAN → WORK → REVIEW → COMPOUND → (next task is now easier)
```

The core loop. Plan + Review = 80% of effort. Work + Compound = 20%. The bottleneck is knowing **what** to build and **verifying** it was built correctly — not typing speed.

## Repository Structure

```
~/.claude/
├── CLAUDE.md          # The brain — all rules, workflows, and judgment protocols
├── settings.json      # Deterministic enforcement via hooks
├── agents/            # Specialized workers with isolated context windows
│   ├── orchestrator.md    # Delegates and coordinates — never implements
│   ├── sprint-executor.md # Implements sprints in isolated worktrees
│   └── code-reviewer.md   # Read-only auditor — reports, never fixes
├── skills/            # Auto-invocable step-by-step workflows
│   ├── plan/              # PRD generation (/plan)
│   ├── plan-build-test/   # Local pipeline: discover → plan → execute → verify
│   ├── ship-test-ensure/  # Deploy: branch → PR → staging → E2E → production
│   ├── compound/          # Post-task learning capture
│   └── workflow-audit/    # Periodic system self-review
├── hooks/             # Safety enforcement scripts
│   ├── block-dangerous.sh     # Blocks rm -rf, force push, npm
│   ├── post-edit-quality.sh   # Auto-formats TS/JS after every edit
│   ├── end-of-turn-typecheck.sh # Type-checks before session end
│   └── compound-reminder.sh   # Blocks session end without learning capture
├── docs/              # Reference material (loaded on demand, not every session)
│   ├── evaluation-reference.md
│   ├── anti-patterns-full.md
│   ├── verification-gates.md
│   └── project-claude-md-template.md
├── workflow/          # Full documentation (you are here)
└── evolution/         # Cross-project learning data
    ├── error-registry.json     # Error patterns across all projects
    ├── model-performance.json  # Model success rate tracking
    └── workflow-changelog.md   # System evolution history
```

## The Five Skills

| Skill | What It Does | When to Use |
|---|---|---|
| `/plan` | Generates PRD only | "Just plan, don't build yet" |
| `/plan-build-test` | Plans, executes with agent teams, verifies locally | "Build this feature / fix this bug" |
| `/ship-test-ensure` | Branch, PR, staging E2E, production deploy, Lighthouse | "Ship what I've built" |
| `/compound` | Captures learnings, updates error registry, evolves system | Auto-invoked after task completion |
| `/workflow-audit` | Reviews model performance, error patterns, rule staleness | Monthly or after 10+ sessions |

**Autonomous pipeline:** `/plan` → review PRD → `/plan-build-test` (autonomous) → manual test → `/ship-test-ensure` (autonomous through staging, confirms before production).

## The Three Agents

| Agent | Role | Model | Key Constraint |
|---|---|---|---|
| **Orchestrator** | Delegates, coordinates, merges | sonnet | Never implements code directly |
| **Sprint Executor** | Implements sprints in isolation | sonnet | Cannot delegate to other agents |
| **Code Reviewer** | Read-only post-merge audit | sonnet | Cannot modify any files |

## Safety Enforcement (Hooks)

The system uses deterministic hooks — real code that runs before/after every action. Unlike CLAUDE.md instructions (which the model might ignore), hooks **cannot be bypassed**.

| Hook | Trigger | What It Does |
|---|---|---|
| `block-dangerous.sh` | Every Bash command | Blocks `rm -rf /`, force push, npm |
| `post-edit-quality.sh` | Every file edit | Auto-formats TS/JS (Biome or ESLint) |
| `end-of-turn-typecheck.sh` | Session end | Type-checks TypeScript |
| `compound-reminder.sh` | Session end | Blocks exit without learning capture |

## Full Documentation

Detailed documentation lives in [`workflow/`](workflow/):

### Getting Started
- [Introduction](workflow/01-introduction.md) — What this system is, why it exists, and the Compound Engineering philosophy
- [Getting Started](workflow/02-getting-started.md) — Installation, setup, first run, and project configuration

### Understanding the System
- [Architecture](workflow/03-architecture.md) — Repository structure, layers, and how everything connects
- [The Constitution](workflow/04-constitution.md) — Value hierarchy, decision boundaries, and autonomous authority
- [Workflow & Modes](workflow/05-workflow-and-modes.md) — Execution modes, Contract-First pattern, and the autonomous pipeline
- [Sprint System](workflow/06-sprint-system.md) — PRDs, sprint decomposition, templates, and file boundaries

### Components
- [Agents](workflow/07-agents.md) — Orchestrator, Sprint Executor, and Code Reviewer in depth
- [Skills Reference](workflow/08-skills-reference.md) — All five skills with full phase breakdowns
- [Hooks & Enforcement](workflow/09-hooks-and-enforcement.md) — `settings.json`, hook lifecycle, and adding custom hooks
- [Evolution & Learning](workflow/10-evolution-and-learning.md) — Cross-project learning, error registry, model performance

### Quality & Verification
- [Verification & Quality](workflow/11-verification-and-quality.md) — 6 verification gates, Anti-Goodhart, Anti-Premature Completion

### Specialized Topics
- [proot-distro Guide](workflow/12-proot-distro-guide.md) — ARM64 environment setup, known issues, and workarounds
- [End-to-End Example](workflow/13-end-to-end-example.md) — Complete walkthrough from feature request to production

### Reference
- [Design Principles](workflow/14-design-principles.md) — 10 recurring principles that guide the entire system
- [Glossary](workflow/15-glossary.md) — Terms and definitions
