# Claude Workflow System

Personal AI engineering system based on the AI-Human Engineering Stack.
Updated for Claude Code with hooks, custom agents, and worktree support.

## What This Is

Portable development workflow for Claude Code. Applies automatically
to any project. Contains: methodology (CLAUDE.md), enforcement (hooks),
specialized agents, skills (auto-invoked and manual), and reference docs.

## Setup on New Machine

1. Clone this repo to `~/.claude/`
2. Open any project with Claude Code — the workflow applies automatically
3. Hooks enforce rules deterministically (auto-format, block dangerous commands)
4. Agents are available for sprint execution and code review
5. Skills auto-invoke based on conversation context (no setup needed)
6. Project-specific context goes in the project's own CLAUDE.md

## Structure

- `CLAUDE.md` — Main engineering system (intent, workflow, context, judgment, evaluation)
- `settings.json` — Hooks & enforcement (auto-format, blockers, anti-Goodhart Stop hook)
- `agents/` — Custom subagents with own context windows
  - `orchestrator.md` — Sprint lifecycle manager (delegates, never implements)
  - `sprint-executor.md` — Sprint implementation (isolated worktree)
  - `code-reviewer.md` — Read-only review agent
- `skills/` — Auto-invocable skills with supporting files
  - `plan/` — Task classification and PRD generation (auto-invoked)
  - `check-and-fix/` — Bug fixing with judgment protocols (auto-invoked)
  - `compound/` — Post-task learning capture (auto-invoked)
- `docs/` — Standalone reference material
  - `vague-requirements-translator.md` — Vague to measurable requirement translations
  - `anti-patterns-full.md` — Expanded anti-patterns with examples and fixes

## Based On

- The AI-Human Engineering Stack (Mill & Sanchez, 2026)
- The Complete Guide to Specifying Work for AI (Mill & Sanchez, 2026)
