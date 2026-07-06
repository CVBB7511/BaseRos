#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <title> <command>"
  exit 2
fi

TITLE="$1"
COMMAND="$2"

if command -v gnome-terminal >/dev/null 2>&1; then
  gnome-terminal --title="$TITLE" -- bash -lc "$COMMAND; echo; echo '[terminal] command finished. Press Enter to close.'; read -r"
elif command -v x-terminal-emulator >/dev/null 2>&1; then
  x-terminal-emulator -T "$TITLE" -e bash -lc "$COMMAND; echo; echo '[terminal] command finished. Press Enter to close.'; read -r"
elif command -v xterm >/dev/null 2>&1; then
  xterm -T "$TITLE" -e bash -lc "$COMMAND; echo; echo '[terminal] command finished. Press Enter to close.'; read -r"
else
  echo "No supported terminal emulator found. Run manually:"
  echo "$COMMAND"
  exit 1
fi
