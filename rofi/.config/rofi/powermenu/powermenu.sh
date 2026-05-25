#!/bin/bash

WALLUST_COLORS="${HOME}/.config/rofi/colors/wallust.rasi"

entries="󰍃 Logout\n󰜉 Reboot\n󰐥 Shutdown\n󰤄 Suspend\n Lock"

chosen=$(echo -e "$entries" | rofi -dmenu -theme-str "window {width: 200px;}
listview {lines: 5; columns: 1;}
element {padding: 12px; orientation: vertical;}"
-p "Power Menu" \
-theme "$WALLUST_COLORS" \
-font "JetBrainsMono Nerd Font Propo 14" \
-lines 5)

case "$chosen" in
    *Logout)
        niri msg action quit
        ;;
    *Reboot)
        systemctl reboot
        ;;
    *Shutdown)
        systemctl poweroff
        ;;
    *Suspend)
        systemctl suspend
        ;;
    *Lock)
        gtklock
        ;;
esac