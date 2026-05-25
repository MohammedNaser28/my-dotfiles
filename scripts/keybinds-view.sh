#!/usr/bin/env bash
# Keybind reference viewer — vicinae dmenu, styled like vicinae
# Reads ~/.config/scripts/keybinds.json

set -euo pipefail

BINDS_FILE="${HOME}/.config/scripts/keybinds.json"

if [ ! -f "$BINDS_FILE" ]; then
    notify-send "Keybinds" "keybinds.json not found at $BINDS_FILE"
    exit 1
fi

# Build vicinae dmenu entries: "keybind │ action │ description"
entries=$(jq -r '.categories[]
    | .name as $cat
    | .entries[]
    | "\(.bind) │ \(.action) │ \(.desc)"
' "$BINDS_FILE")

total=$(echo "$entries" | wc -l)

chosen=$(echo "$entries" | vicinae dmenu \
    -n " Keybinds " \
    -s "{count} keybinds" \
    -p "Search keybinds..." \
    -W 900)

# Exit silently if nothing selected
[ -z "$chosen" ] && exit 0

# Show description in notification
desc=$(echo "$chosen" | awk -F' │ ' '{print $3}')
notify-send -t 3000 "Keybind" "$desc"
