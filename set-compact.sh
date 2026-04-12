#!/usr/bin/env bash
# set-compact.sh — Switch CLAUDE_AUTOCOMPACT_PCT_OVERRIDE for a given context window size.
#
# Per-window compact targets (all windows target 80K tokens):
#   128K window -> compact at 80K tokens  (62%)
#   200K window -> compact at 80K tokens  (40%)
#   1M   window -> compact at 80K tokens   (8%)
#
# Usage:
#   ~/.claude/set-compact.sh 128k     # 128K window  -> 62%
#   ~/.claude/set-compact.sh 200k     # 200K window  -> 40%
#   ~/.claude/set-compact.sh 1m       # 1M window    ->  8%
#   ~/.claude/set-compact.sh custom 150000 500000  # 150K target on 500K window -> 30%
#   ~/.claude/set-compact.sh status   # Show current config without changing
#
# Run as: ! ~/.claude/set-compact.sh 1m

set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"

# Per-window target table — edit here if policy changes.
# Keep in sync with: ~/.claude/hooks/session-start.sh, CLAUDE.md, rules/context-engineering.md
target_for_window() {
  case "$1" in
    128000)  echo 80000 ;;
    200000)  echo 80000 ;;
    1000000) echo 80000 ;;
    *)       echo 80000 ;;  # default for unknown windows
  esac
}

usage() {
  echo "Usage: $0 <window-size>"
  echo "  Presets: 200k | 1m | 128k"
  echo "  Custom:  custom <target_tokens> <window_tokens>"
  echo "  Query:   status"
  exit 1
}

if [ $# -lt 1 ]; then usage; fi

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required but not installed." >&2
  exit 1
fi

ARG="${1,,}"  # lowercase

# status mode: print current config and exit
if [ "$ARG" = "status" ]; then
  CURRENT=$(jq -r '.env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE // "unset"' "$SETTINGS")
  echo "Current CLAUDE_AUTOCOMPACT_PCT_OVERRIDE: ${CURRENT}"
  echo "Per-window targets: 128K->80K(62%)  200K->80K(40%)  1M->80K(8%)"
  case "$CURRENT" in
    8|9)   echo "Matches: 1M window (80K trigger at ~8%)" ;;
    40|41) echo "Matches: 200K window (80K trigger at ~40%)" ;;
    62|63) echo "Matches: 128K window (80K trigger at ~62%)" ;;
    unset) echo "No override set - using Claude Code default (~95%)" ;;
    *)     echo "Custom value - verify against your window size" ;;
  esac
  exit 0
fi

case "$ARG" in
  200k) WINDOW=200000  ; TARGET_TOKENS=$(target_for_window 200000)  ;;
  1m)   WINDOW=1000000 ; TARGET_TOKENS=$(target_for_window 1000000) ;;
  128k) WINDOW=128000  ; TARGET_TOKENS=$(target_for_window 128000)  ;;
  custom)
    if [ $# -lt 3 ]; then
      echo "custom requires: $0 custom <target_tokens> <window_tokens>" >&2
      exit 1
    fi
    TARGET_TOKENS="$2"
    WINDOW="$3"
    ;;
  *)
    echo "Unknown window size: $1" >&2
    usage
    ;;
esac

# Compute percentage: floor(target/window * 100)
PCT=$(( TARGET_TOKENS * 100 / WINDOW ))

# Clamp between 5 and 95
if [ "$PCT" -lt 5 ]; then PCT=5; fi
if [ "$PCT" -gt 95 ]; then PCT=95; fi

echo "Window: ${WINDOW} tokens | Target: ${TARGET_TOKENS} tokens | Setting: ${PCT}%"

# Update settings.json in-place
TMP=$(mktemp)
jq --argjson pct "$PCT" '.env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE = ($pct | tostring)' "$SETTINGS" > "$TMP"
mv "$TMP" "$SETTINGS"

echo "Updated $SETTINGS: CLAUDE_AUTOCOMPACT_PCT_OVERRIDE = \"${PCT}\""
echo "Compact will trigger at ~${TARGET_TOKENS} tokens on a ${WINDOW}-token window."
echo "(Takes effect on next session start)"
