#!/usr/bin/env bash
set -euo pipefail

DATA=$(cliphist list 2>/dev/null) || true
if [[ -z "$DATA" ]]; then
  notify-send "Clipboard" "No clipboard history yet"
  exit 1
fi

ITEM=$(echo "$DATA" | vicinae dmenu --placeholder "Search clipboard..." --no-section 2>/dev/null) || true
if [[ -z "$ITEM" ]]; then
  exit 1
fi

ID=$(echo "$ITEM" | cut -f1)
if [[ -z "$ID" ]]; then
  exit 1
fi

echo "$ID" | cliphist decode | wl-copy
