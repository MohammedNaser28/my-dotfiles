#!/usr/bin/env bash
# Keybind reference viewer — rofi-based, searchable, styled
# Reads ~/.config/scripts/keybinds.json

set -euo pipefail

BINDS_FILE="${HOME}/.config/scripts/keybinds.json"
WALLUST_COLORS="${HOME}/.config/rofi/colors/wallust.rasi"
FONT="JetBrainsMono Nerd Font Propo 14"

if [ ! -f "$BINDS_FILE" ]; then
    notify-send "Keybinds" "keybinds.json not found at $BINDS_FILE"
    exit 1
fi

# Build rofi entries: "keybind | action | description"
entries=$(jq -r '.categories[]
    | .name as $cat
    | .entries[]
    | "\(.bind) │ \(.action) │ \(.desc)"
' "$BINDS_FILE")

total=$(echo "$entries" | wc -l)

chosen=$(echo "$entries" | rofi -dmenu -i -p " Keybinds " \
    -theme "$WALLUST_COLORS" \
    -font "$FONT" \
    -theme-str "window {width: 900px;}
listview {lines: $total; columns: 1; dynamic: true; spacing: 4px; padding: 8px;}
element {padding: 6px 12px; orientation: horizontal;}
element-text {margin: 0px;}
inputbar {padding: 8px; children: [prompt,entry];}
prompt {padding: 0 8px;}" \
    -lines "$total")

# Exit silently if nothing selected
[ -z "$chosen" ] && exit 0

# Show description in notification
desc=$(echo "$chosen" | awk -F' │ ' '{print $3}')
notify-send -t 3000 "Keybind" "$desc"
