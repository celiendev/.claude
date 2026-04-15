#!/usr/bin/env bash
set -euo pipefail
trap 'echo "HOOK CRASH: $0 line $LINENO" >&2; exit 2' ERR

# Stop hook: BLOCK if a sprint/PRD finalized this session but /compound never ran.
#
# Gating: the `progress-signal.sh` PostToolUse hook writes a signal marker
# (`~/.claude/state/.sprint-finalized-${SESSION_ID}`) containing the absolute
# path of a `progress.json` whose sprints are ALL in the `complete` state.
# This hook exits 0 immediately unless that marker exists — so ordinary
# Q&A turns (AskUserQuestion, short answers) pay O(1) cost, not a filesystem
# walk.
#
# Exit codes:
#   0 — no finalized sprint this session, or compound already ran, or re-fire
#   2 — sprint finalized but /compound never captured the learnings

if ! command -v jq &>/dev/null; then
  exit 0
fi

source ~/.claude/hooks/lib/stop-guard.sh 2>/dev/null || true

INPUT=$(cat)
check_stop_hook_active "$INPUT"

# Only fire when the agent answered with a task-completion summary — not when
# the last turn ended with AskUserQuestion or when Claude hasn't planted the
# stop-hooks-ok-<session> authorization marker. This keeps ordinary Q&A and
# intermediate pauses silent/fast.
check_completion_authorized "$INPUT"

SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null || echo "")
# Never write markers with a `-unknown` suffix — they leak across sessions
# and trip harness-health.sh's stale-marker check.
if [ -z "$SESSION_ID" ] || [ "$SESSION_ID" = "unknown" ]; then
  exit 0
fi

STATE_DIR="${HOME}/.claude/state"
SIGNAL_FILE="${STATE_DIR}/.sprint-finalized-${SESSION_ID}"

# Fast path: if no sprint was finalized this turn, we have nothing to do.
# This is the whole point of the gating refactor — the hook used to scan
# docs/tasks on every Stop even when the user was just answering a question.
if [ ! -f "$SIGNAL_FILE" ]; then
  exit 0
fi

# Session-scoped throttle: once we have warned (or been dismissed) for this
# finalization, stay quiet until a new finalization resets the marker.
WARNED_MARKER="${STATE_DIR}/.claude-compound-warned-${SESSION_ID}"
if [ -f "$WARNED_MARKER" ]; then
  exit 0
fi

# Re-verify the finalized file still describes a completed PRD. The signal
# could be stale if the user manually edited progress.json after the write.
PJSON=$(cat "$SIGNAL_FILE" 2>/dev/null || echo "")
if [ -z "$PJSON" ] || [ ! -f "$PJSON" ]; then
  exit 0
fi

INCOMPLETE=$(jq '[.sprints[]? | select(.status != "complete")] | length' "$PJSON" 2>/dev/null || echo "1")
TOTAL=$(jq '.sprints | length' "$PJSON" 2>/dev/null || echo "0")
if [ "$TOTAL" -le 0 ] || [ "$INCOMPLETE" -ne 0 ]; then
  exit 0
fi

# Has /compound already run for this session?
DONE_MARKER="${STATE_DIR}/.claude-compound-done-${SESSION_ID}"
if [ -f "$DONE_MARKER" ]; then
  exit 0
fi

mkdir -p "$STATE_DIR" 2>/dev/null || true
: > "$WARNED_MARKER"
{
  echo "BLOCKED: Completed task detected but /compound hasn't run."
  echo "The learning loop captures errors, model performance, and patterns that prevent future failures."
  echo "Run /compound to capture learnings, or dismiss this to skip (learnings will be lost)."
} >&2
exit 2
