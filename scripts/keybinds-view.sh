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
    -theme-str "
* { background: transparent; }
window {
    width: 900px;
    transparency: \"real\";
    background-color: transparent;
    text-color: @foreground;
}
mainbox {
    background-color: @background;
    border: 0px;
    padding: 0px;
    children: [inputbar, listview];
}
inputbar {
    spacing: 0px;
    padding: 8px;
    background-color: @background;
    text-color: @foreground;
    children: [prompt, entry];
}
prompt {
    padding: 0 8px;
    background-color: transparent;
    text-color: @selected;
}
entry {
    background-color: transparent;
    text-color: @foreground;
    placeholder-color: @background-alt;
}
listview {
    padding: 0px;
    spacing: 2px;
    background-color: transparent;
    layout: vertical;
}
element {
    padding: 6px 12px;
    background-color: transparent;
    text-color: @foreground;
    orientation: horizontal;
}
element selected {
    background-color: @selected;
    text-color: @background;
}
" \
    -lines "$total")

# Exit silently if nothing selected
[ -z "$chosen" ] && exit 0

# Show description in notification
desc=$(echo "$chosen" | awk -F' │ ' '{print $3}')
notify-send -t 3000 "Keybind" "$desc"
