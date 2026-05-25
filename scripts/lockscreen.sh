#!/usr/bin/env bash
set -euo pipefail

TMP_BG="/tmp/lockscreen-bg.png"
STYLE="$HOME/.config/gtklock/style.css"
CONFIG="$HOME/.config/gtklock/config.ini"

# Get current wallpaper from awww
WALL=$(awww query 2>/dev/null | grep "image:" | head -1 | sed 's/.*image: //;s/ *$//')
WALL="${WALL:-$HOME/Pictures/Wallpapers/Catppuccin/Dark/hollow-knight.png}"

# Blur it
magick "$WALL" -filter Gaussian -blur 0x8 -define png:color-type=6 "$TMP_BG" 2>/dev/null

exec gtklock -c "$CONFIG" -s "$STYLE" -b "$TMP_BG"
