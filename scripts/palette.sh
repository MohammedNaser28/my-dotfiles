#!/usr/bin/env bash
# Palette Manager — browse, generate, save, and apply color palettes.
# vicinae for lists, small rofi dialogs only for text input.

set -euo pipefail

PALETTE_DIR="$HOME/.local/share/wallust-palettes"
WALLUST_CACHE="$HOME/.cache/wallust/colors.json"
ROFI_INPUT="-width 400 -lines 1 -theme-str 'window {fullscreen:false;} listview {lines:1;} inputbar {children: [prompt,entry];}'"

mkdir -p "$PALETTE_DIR"

# ─── Categories ─────────────────────────────────────────────────────────────

declare -A THEME_CATS
THEME_CATS["Nord"]="Nord Nord-Light base16-nord"
THEME_CATS["Catppuccin"]=""
THEME_CATS["Dracula"]="Dracula base16-dracula"
THEME_CATS["Gruvbox"]="Gruvbox Gruvbox-Dark base16-gruvbox"
THEME_CATS["Everforest"]="Everforest"
THEME_CATS["Tokyo-Night"]="Tokyo-Night"
THEME_CATS["Rose-Pine"]="rose-pine"
THEME_CATS["Solarized"]="Solarized"
THEME_CATS["Material"]="Material base16-material"
THEME_CATS["Other"]=""

# ─── Helpers ────────────────────────────────────────────────────────────────

vic_input() { vicinae dmenu -n " Palette " "$@"; }
vic_msg()   { vicinae dmenu -n " Palette " -s "$1" <<< "ok"; }
rofi_input(){ rofi -dmenu -p "$1" -width 400 -lines 1 -theme-str 'window {fullscreen:false;}' "$@"; }

apply_wallust() {
    wallust run --no-export 2>/dev/null && vicinae theme set wallust 2>/dev/null || true
    makoctl reload 2>/dev/null || true
}

# ─── Actions ────────────────────────────────────────────────────────────────

from_wallpaper() {
    local path
    path=$(awww query 2>/dev/null | grep -oP '(?<=image: ).*' | head -1)
    if [[ -z "$path" || ! -f "$path" ]]; then
        vic_msg "No wallpaper active in awww"
        return
    fi
    wallust run "$path" --dynamic-threshold 2>/dev/null || \
        wallust run "$path" --backend fastresize 2>/dev/null || {
        vic_msg "Failed to extract colors"
        return
    }
    apply_wallust
    vic_msg "Colors from current wallpaper"
}

from_image() {
    local path
    path=$(rofi_input "Image path" < /dev/null 2>/dev/null || true)
    [[ -z "$path" ]] && return
    path=$(eval echo "$path")
    [[ ! -f "$path" ]] && { vic_msg "File not found"; return; }

    wallust run "$path" --dynamic-threshold 2>/dev/null || \
        wallust run "$path" --backend fastresize 2>/dev/null || {
        vic_msg "Failed"; return
    }
    apply_wallust
    vic_msg "Colors from $(basename "$path")"
}

browse_themes() {
    local choice
    choice=$(printf '%s\n' "${!THEME_CATS[@]}" | vic_input -s "Theme category" -W 300)
    [[ -z "$choice" ]] && return

    local themes
    themes=$(wallust theme list 2>/dev/null | sed 's/^..//;s/..$//' | sed 's/^[[:space:]]*//' | sort -u)
    if [[ "$choice" != "Other" ]]; then
        local pats="${THEME_CATS[$choice]}"
        themes=$(echo "$themes" | grep -iE "${pats// /|}" 2>/dev/null || true)
    fi
    [[ -z "$themes" ]] && { vic_msg "No themes in $choice"; return; }

    local theme
    theme=$(echo "$themes" | vic_input -s "Select $choice theme" -W 500 -H 400)
    [[ -z "$theme" ]] && return

    wallust theme "$theme" 2>/dev/null || { vic_msg "Failed: $theme"; return; }
    apply_wallust
    vic_msg "Applied: $theme"
}

show_colors() {
    [[ ! -f "$WALLUST_CACHE" ]] && { vic_msg "No palette loaded"; return; }
    local input
    input=$(python3 -c "
import json
with open('$WALLUST_CACHE') as f:
    c = json.load(f)
cs = c.get('colors', {})
sp = c.get('special', {})
lines = ['bg: ' + sp.get('background','?'), 'fg: ' + sp.get('foreground','?'), 'cr: ' + sp.get('cursor','?')]
for i in range(16):
    lines.append(f'color{i}: {cs.get(\"color\"+str(i),\"?\")}')
print('\n'.join(lines))
" 2>/dev/null)
    vic_input -s "Current palette colors" -W 400 -H 500 <<< "$input"
}

save_palette() {
    [[ ! -f "$WALLUST_CACHE" ]] && { vic_msg "No palette to save"; return; }
    local name
    name=$(rofi_input "Palette name" < /dev/null 2>/dev/null || true)
    [[ -z "$name" ]] && return

    local cat
    cat=$(printf '%s\n' "${!THEME_CATS[@]}" "Uncategorized" | vic_input -s "Category" -W 300)
    [[ -z "$cat" ]] && cat="Uncategorized"

    mkdir -p "$PALETTE_DIR/$cat"
    cp "$WALLUST_CACHE" "$PALETTE_DIR/$cat/$name.json"
    vic_msg "Saved: $cat/$name"
}

browse_saved() {
    local cat
    cat=$(printf '%s\n' "${!THEME_CATS[@]}" "Uncategorized" | vic_input -s "Category" -W 300)
    [[ -z "$cat" ]] && return

    local palettes
    palettes=$(find "$PALETTE_DIR/$cat" -name '*.json' -printf '%f\n' 2>/dev/null | sed 's/\.json$//' | sort || true)
    [[ -z "$palettes" ]] && { vic_msg "No saved palettes in $cat"; return; }

    local pick
    pick=$(echo "$palettes" | vic_input -s "Select palette" -W 400 -H 400)
    [[ -z "$pick" ]] && return

    cp "$PALETTE_DIR/$cat/$pick.json" "$WALLUST_CACHE"
    apply_wallust
    vic_msg "Applied: $cat/$pick"
}

# ─── Main ───────────────────────────────────────────────────────────────────

main() {
    while true; do
        local choice
        choice=$(printf '%s\n' \
            "Browse themes" \
            "From current wallpaper" \
            "From image file" \
            "Show current colors" \
            "Save current palette" \
            "Browse saved palettes" \
            "exit" \
        | vic_input -s "Palette Manager" -W 380 -H 280)

        case "$choice" in
            "Browse themes")        browse_themes ;;
            "From current wallpaper") from_wallpaper ;;
            "From image file")      from_image ;;
            "Show current colors")  show_colors ;;
            "Save current palette") save_palette ;;
            "Browse saved palettes") browse_saved ;;
            "exit"|"")              exit 0 ;;
        esac
    done
}

main "$@"
