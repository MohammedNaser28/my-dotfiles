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

# Look up the exec command from keybinds.json
selected_bind=$(echo "$chosen" | awk -F' │ ' '{print $1}')
selected_action=$(echo "$chosen" | awk -F' │ ' '{print $2}')
selected_desc=$(echo "$chosen" | awk -F' │ ' '{print $3}')

exec_cmd=$(jq -r --arg bind "$selected_bind" --arg action "$selected_action" '
    .categories[].entries[]
    | select(.bind == $bind and .action == $action)
    | .exec // empty
' "$BINDS_FILE" | head -1)

if [ -n "$exec_cmd" ]; then
    # Execute in background, detached from rofi's stdin
    ( eval "$exec_cmd" & ) &>/dev/null
else
    # No exec available, just show description
    notify-send -t 3000 "Keybind" "$selected_desc"
fi
