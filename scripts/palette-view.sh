#!/usr/bin/env bash
# Browse and apply cached wallust palettes.
# Shows a rofi grid of 16-color swatches — pick one to apply its palette.

set -euo pipefail

CACHE_DIR="$HOME/.cache/wallpaper-palettes"
THUMB_DIR="$HOME/.cache/thumbnails/palettes"
WALL_DIR="$HOME/Pictures/Wallpapers"

mkdir -p "$CACHE_DIR" "$THUMB_DIR"

if ! ls "$CACHE_DIR"/*.json &>/dev/null; then
    notify-send "Palette Viewer" "No cached palettes found. Run cache-palettes.sh first."
    exit 1
fi

# Build rofi input: relpath + swatch as icon
rofi_input=$(mktemp)
for json in "$CACHE_DIR"/*.json; do
    name_hash=$(basename "$json" .json)
    swatch="$THUMB_DIR/$name_hash.png"
    wallpaper_path=$(jq -r '.wallpaper // "unknown"' "$json")

    # Normalize: resolve symlinks so it works with both ~/.dotfiles-sevens/wallpapers/ and ~/Pictures/Wallpapers/
    rel=$(realpath --relative-to="$WALL_DIR" "$wallpaper_path" 2>/dev/null || echo "$wallpaper_path")

    if [[ -f "$swatch" ]]; then
        printf '%s\000icon\037%s\n' "$rel" "$swatch"
    else
        echo "$rel"
    fi
done > "$rofi_input"

chosen=$(rofi -dmenu -show-icons -p "Select Palette" \
    -config "$HOME/.config/rofi/bgselector/style.rasi" \
    < "$rofi_input")
rm -f "$rofi_input"

[[ -z "$chosen" ]] && exit 0

# Find matching cached palette — resolve symlinks
selected_path=$(realpath "$WALL_DIR/$chosen" 2>/dev/null || echo "$WALL_DIR/$chosen")
name_hash=$(echo -n "${chosen}" | sha256sum | cut -c1-16)
cache_json="$CACHE_DIR/$name_hash.json"

if [[ ! -f "$cache_json" ]]; then
    notify-send "Palette Viewer" "No cached palette for: $chosen"
    exit 1
fi

# Apply the cached palette: copy to wallust cache
cp "$cache_json" "$HOME/.cache/wallust/colors.json"

# Re-run wallust on the wallpaper to regenerate all templates
if wallust run "$selected_path" --quiet 2>/dev/null; then
    # Re-save (in case wallust slightly adjusted colors)
    cp "$HOME/.cache/wallust/colors.json" "$cache_json"
    notify-send "Palette Viewer" "Applied palette for: $chosen"
else
    notify-send -u critical "Palette Viewer" "Failed to apply palette"
    exit 1
fi

# Reload affected daemons
if command -v vicinae >/dev/null 2>&1; then
    vicinae theme set wallust 2>/dev/null || true
fi
if command -v makoctl >/dev/null 2>&1; then
    makoctl reload 2>/dev/null || true
fi
