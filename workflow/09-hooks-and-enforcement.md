# Hooks & Enforcement

## Why Hooks Exist

```
┌────────────────────────────────────────┐
│            CLAUDE.md says:             │
│  "Never use npm; use pnpm"            │
│                                        │
│  This is a SUGGESTION.                 │
│  The model might ignore it.            │
│  (LLMs are probabilistic)             │
│                                        │
├────────────────────────────────────────┤
│          block-dangerous.sh:           │
│  if [[ $COMMAND =~ npm ]]; then        │
│    deny "Use pnpm instead"             │
│  fi                                    │
│                                        │
│  This is ENFORCEMENT.                  │
│  The model CANNOT bypass it.           │
│  (Code is deterministic)              │
└────────────────────────────────────────┘
```

While `CLAUDE.md` provides guidelines the model "should" follow, `settings.json` implements **deterministic enforcement** via hooks. Instructions in CLAUDE.md are suggestions the model can ignore (LLMs are probabilistic). Hooks are real code that runs before/after every action. The model cannot bypass a hook.

## Hook Lifecycle

```
┌─────────────────────────────────────────────────────────────────────┐
│                        HOOK LIFECYCLE                               │
│                                                                     │
│  ┌──────────────────┐                                               │
│  │  PreToolUse      │ ◄── Runs BEFORE every Bash command            │
│  │  (Bash)          │     block-dangerous.sh: hard/soft blocks      │
│  │                  │     proot-preflight.sh: environment warnings   │
│  └──────────────────┘                                               │
│                                                                     │
│  ┌──────────────────┐                                               │
│  │  PostToolUse     │ ◄── Runs AFTER every Write/Edit/MultiEdit     │
│  │  (Write|Edit|    │     post-edit-quality.sh: auto-format TS/JS   │
│  │   MultiEdit)     │     (Biome → ESLint+Prettier → skip)          │
│  └──────────────────┘                                               │
│                                                                     │
│  ┌──────────────────┐                                               │
│  │  Stop            │ ◄── Runs when the agent tries to end session  │
│  │  (always)        │     end-of-turn-typecheck.sh: check TS types  │
│  │                  │     compound-reminder.sh: BLOCK if compound   │
│  │                  │     hasn't run after task completion           │
│  └──────────────────┘                                               │
│                                                                     │
│  ┌──────────────────┐                                               │
│  │  Notification    │ ◄── Runs when agent needs user attention      │
│  │  (always)        │     Desktop notification (notify-send)        │
│  └──────────────────┘                                               │
│                                                                     │
│  Exit codes:                                                        │
│    0 = allow (continue normally)                                    │
│    1 = error (hook itself failed)                                   │
│    2 = BLOCK with message (agent receives the stderr message)       │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Hook Summary

| Hook | Type | Trigger | Purpose | Blocking? |
|---|---|---|---|---|
| `block-dangerous.sh` | PreToolUse(Bash) | Every shell command | Block destructive operations | Hard/soft block |
| `proot-preflight.sh` | PreToolUse(Bash) | First command/session | Warn about proot issues | No (informational) |
| `post-edit-quality.sh` | PostToolUse(Write/Edit) | Every file edit | Auto-format TS/JS | Yes (exit 2 on lint errors) |
| `end-of-turn-typecheck.sh` | Stop | End of turn | Type-check TypeScript | Yes (exit 2 on type errors) |
| `compound-reminder.sh` | Stop | End of turn | Ensure /compound ran | Yes (exit 2 if skipped) |
| `worktree-preflight.sh` | (orchestrator) | Sprint start | Git/env readiness | N/A (utility) |
| `retry-with-backoff.sh` | (utility) | API calls | Exponential backoff | N/A (utility) |

## PreToolUse: block-dangerous.sh

Runs **before** every Bash command and implements three protection levels:

### Hard Blocks (always denied, no override)

- `rm -rf /` and variants (`rm -rf /*`, `rm -rf ~`, `rm -rf $HOME`)
- `rm -rf .` in critical directories (/, home)
- `rm -rf` on system directories (`/etc`, `/usr`, `/var`, `/bin`, etc.)
- `chmod -R 777` on system paths
- `dd if=` (raw disk operations)
- Fork bombs

### Soft Blocks (asks for re-approval)

| Category | Blocked Commands | Why |
|---|---|---|
| Destructive git | `git push --force`, `git reset --hard`, `git checkout .`, `git restore .`, `git branch -D`, `git clean -f`, `git stash drop/clear` | Can destroy work irreversibly |
| Push to main | `git push ... main/master` | Enforces PR workflow |
| Wrong package manager | `npm install/run/exec/start/test/build/ci/init`, `npx` | Project uses pnpm exclusively |

The hook uses pure bash regex matching (no subprocesses) for performance.

## PostToolUse: post-edit-quality.sh

Runs **after** every Write, Edit, or MultiEdit operation:

```
File edited
    │
    ▼
Is it a TS/JS file? ─── No ──► skip
    │
   Yes
    │
    ▼
Is it in an excluded dir? ─── Yes ──► skip
(node_modules, dist, .next, etc.)
    │
   No
    │
    ▼
Biome config exists? ─── Yes ──► biome check --write
    │
   No
    │
    ▼
ESLint config exists? ─── Yes ──► eslint --fix + prettier --write
    │
   No
    │
    ▼
skip (no linter found)
```

**Why this matters:** The agent never needs to remember to format code. Every edit is auto-formatted with zero cognitive overhead.

## Stop Hook: end-of-turn-typecheck.sh

When the agent tries to end a turn after writing code:

```
Agent wants to stop
    │
    ▼
Was code written this turn? ─── No ──► allow stop
    │
   Yes
    │
    ▼
Has tsconfig.json? ─── No ──► allow stop
    │
   Yes
    │
    ▼
Find type checker (preference order):
1. Native tsgo binary (cached path for speed)
2. Global tsgo
3. pnpm tsc --noEmit --skipLibCheck (fallback)
    │
    ▼
Run type checker
    │
    ├─ Pass ──► allow stop
    ├─ Fail ──► BLOCK (agent must fix types)
    └─ Crash ──► fallback to tsc
```

## Stop Hook: compound-reminder.sh

**BLOCKING** hook that prevents session end without learning capture:

```
Agent wants to stop
    │
    ▼
Any progress.json with all sprints "complete"? ─── No ──► allow stop
    │
   Yes
    │
    ▼
Was /compound run?
    │
    ├─ Yes ──► allow stop
    └─ No ──► BLOCK
             "Completed task detected but /compound hasn't run.
              Run /compound to capture learnings, or dismiss to skip."
```

**Why this is the most important hook:** Without learning capture, the workflow never improves. The compound step is where the system transforms individual task experience into permanent system improvement. Making it blocking ensures it's never skipped.

## settings.json Configuration

```json
{
  "env": {
    "ENABLE_LSP_TOOL": "1",
    "NODE_OPTIONS": "--max-old-space-size=2048",
    "CHOKIDAR_USEPOLLING": "true",
    "WATCHPACK_POLLING": "true"
  },
  "permissions": {
    "defaultMode": "bypassPermissions",
    "deny": []
  },
  "effortLevel": "high",
  "skipDangerousModePermissionPrompt": true
}
```

| Setting | Purpose |
|---|---|
| `ENABLE_LSP_TOOL` | Enables Language Server Protocol (goToDefinition, findReferences, etc.) |
| `NODE_OPTIONS` | Increases Node.js memory limit (essential for proot-distro ARM64) |
| `CHOKIDAR_USEPOLLING` / `WATCHPACK_POLLING` | Enables polling-based file watching |
| `bypassPermissions` | Allows autonomous execution — compensated by hook safety |
| `effortLevel: "high"` | Claude invests more tokens/reasoning in responses |

## Adding Custom Hooks

To add a new hook, add an entry to the relevant section in `settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/your-new-hook.sh \"$TOOL_INPUT\""
          }
        ]
      }
    ]
  }
}
```

Exit codes: `0` = allow, `1` = error, `2` = block with message (stderr).

---

Next: [Evolution & Learning](10-evolution-and-learning.md)
