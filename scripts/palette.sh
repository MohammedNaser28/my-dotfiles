#!/usr/bin/env bash
# Palette Manager — browse, edit, generate, and save color palettes.
# Uses vicinae dmenu for selection, wallust for color generation.

set -euo pipefail

PALETTE_DIR="$HOME/.local/share/wallust-palettes"
WALLUST_CACHE="$HOME/.cache/wallust/colors.json"
mkdir -p "$PALETTE_DIR"

# ─── Predefined wallust theme categories ───────────────────────────────────

declare -A THEME_CATEGORIES
THEME_CATEGORIES["Nord"]="Nord Nord-Light base16-nord"
THEME_CATEGORIES["Catppuccin"]=""
THEME_CATEGORIES["Dracula"]="Dracula base16-dracula"
THEME_CATEGORIES["Gruvbox"]="Gruvbox Gruvbox-Dark Gruvbox-Material-Dark Gruvbox-Material-Light base16-gruvbox-{hard,medium,soft}-{dark,light} gruvbox"
THEME_CATEGORIES["Everforest"]="Everforest-Dark-{Hard,Medium,Soft} Everforest-Light-{Hard,Medium,Soft}"
THEME_CATEGORIES["Tokyo-Night"]="Tokyo-Night Tokyo-Night-Light Tokyo-Night-Storm"
THEME_CATEGORIES["Rose-Pine"]="rose-pine rose-pine-dawn rose-pine-moon"
THEME_CATEGORIES["Solarized"]="Solarized-{Dark,Light} Solarized-Darcula Solarized-Dark-Higher-Contrast base16-solarized-{dark,light} base16-solarflare solarized-{dark,light}"
THEME_CATEGORIES["Material"]="Material base16-material base16-material-palenight base16-materialer-{dark,light} hybrid-material sexy-material"
THEME_CATEGORIES["Other"]=""

# ─── Helpers ────────────────────────────────────────────────────────────────

list_saved_palettes() {
    local category="$1"
    local dir="$PALETTE_DIR/$category"
    if [[ -d "$dir" ]]; then
        find "$dir" -name '*.json' -printf '%f\n' | sed 's/\.json$//' | sort
    fi
}

show_current_colors() {
    if [[ ! -f "$WALLUST_CACHE" ]]; then
        vicinae dmenu -n " Palette " -s "No palette loaded" <<< "ok"
        return
    fi

    local input
    input=$(python3 -c "
import json
with open('$WALLUST_CACHE') as f:
    c = json.load(f)
colors = c.get('colors', {})
special = c.get('special', {})
lines = ['Current Palette',
    f'Background: {special.get(\"background\", \"?\")}',
    f'Foreground: {special.get(\"foreground\", \"?\")}',
    f'Cursor:     {special.get(\"cursor\", \"?\")}',
]
for i in range(16):
    name = f'color{i}'
    if name in colors:
        lines.append(f'{name}: {colors[name]}')
lines.append('')
lines.append('back')
printf '%s\n' '${lines[@]}'
" 2>/dev/null)
    local choice
    choice=$(vicinae dmenu -n " Palette " -s "Current palette" -W 400 -H 500 <<< "$input")
    [[ "$choice" == "back" ]] && return 0
}

generate_from_image() {
    local img_path
    img_path=$(vicinae dmenu -n " Palette " -s "Enter image path" -W 500 -p "/path/to/image.jpg" <<< "" 2>/dev/null || true)
    [[ -z "$img_path" ]] && return
    img_path=$(eval echo "$img_path")

    if [[ ! -f "$img_path" ]]; then
        vicinae dmenu -n " Palette " -s "File not found: $img_path" <<< "ok"
        return
    fi

    if ! wallust run "$img_path" --dynamic-threshold 2>/dev/null; then
        wallust run "$img_path" --backend fastresize 2>/dev/null || {
            vicinae dmenu -n " Palette " -s "Failed to generate palette" <<< "ok"
            return
        }
    fi

    vicinae dmenu -n " Palette " -s "Palette generated from $img_path" <<< "ok"
    apply_palette
}

apply_palette() {
    local theme="$1"
    if [[ -n "$theme" ]]; then
        wallust theme "$theme" 2>/dev/null && vicinae theme set wallust 2>/dev/null || true
    fi

    # Reload everything that uses wallust colors
    if command -v makoctl &>/dev/null; then
        makoctl reload 2>/dev/null || true
    fi
}

save_current_palette() {
    if [[ ! -f "$WALLUST_CACHE" ]]; then
        vicinae dmenu -n " Palette " -s "No palette to save" <<< "ok"
        return
    fi

    local name
    name=$(vicinae dmenu -n " Palette " -s "Name this palette" -W 400 -p "my-palette" <<< "" 2>/dev/null || true)
    [[ -z "$name" ]] && return

    local categories=()
    for cat in "${!THEME_CATEGORIES[@]}"; do
        categories+=("$cat")
    done
    categories+=("Uncategorized")

    local category
    category=$(printf '%s\n' "${categories[@]}" | vicinae dmenu -n " Palette " -s "Category" -W 300)
    [[ -z "$category" ]] && category="Uncategorized"

    mkdir -p "$PALETTE_DIR/$category"
    cp "$WALLUST_CACHE" "$PALETTE_DIR/$category/$name.json"
    vicinae dmenu -n " Palette " -s "Saved: $category/$name" <<< "ok"
}

browse_saved() {
    local categories=()
    for cat in "${!THEME_CATEGORIES[@]}"; do
        categories+=("$cat")
    done
    categories+=("Uncategorized")

    local category
    category=$(printf '%s\n' "${categories[@]}" | vicinae dmenu -n " Palette " -s "Select category" -W 300)
    [[ -z "$category" ]] && return

    local palettes
    palettes=$(list_saved_palettes "$category")
    if [[ -z "$palettes" ]]; then
        vicinae dmenu -n " Palette " -s "No saved palettes in $category" <<< "ok"
        return
    fi

    local palette
    palette=$(printf '%s\n' "$palettes" | vicinae dmenu -n " Palette " -s "Select palette" -W 400 -H 400)
    [[ -z "$palette" ]] && return

    # Load the palette
    cp "$PALETTE_DIR/$category/$palette.json" "$WALLUST_CACHE"

    # Apply colors via wallust template rendering
    wallust run --no-export 2>/dev/null && vicinae theme set wallust 2>/dev/null || true

    if command -v makoctl &>/dev/null; then
        makoctl reload 2>/dev/null || true
    fi

    vicinae dmenu -n " Palette " -s "Applied: $category/$palette" <<< "ok"
}

browse_wallust_themes() {
    local categories=()
    for cat in "${!THEME_CATEGORIES[@]}"; do
        categories+=("$cat")
    done

    local category
    category=$(printf '%s\n' "${categories[@]}" | vicinae dmenu -n " Palette " -s "Select category" -W 300)
    [[ -z "$category" ]] && return

    local themes
    themes=$(wallust theme list 2>/dev/null | sed 's/^..//;s/..$//' | sed 's/^[[:space:]]*//' | grep -iv "base16\|base2\|base4\|3024\|sexy" | sort -u || true)

    # Filter by category if not "Other"
    if [[ "$category" != "Other" ]]; then
        local patterns="${THEME_CATEGORIES[$category]}"
        if [[ -n "$patterns" ]]; then
            local filtered=""
            while IFS= read -r theme; do
                for pat in $patterns; do
                    local globbed
                    globbed=$(echo "$theme" | grep -i "$pat" || true)
                    if [[ -n "$globbed" ]]; then
                        filtered+="$theme"$'\n'
                        break
                    fi
                done
            done <<< "$themes"
            themes="$filtered"
        fi
    else
        # Other = everything not in a named category
        local all_patterns=""
        for cat in "${!THEME_CATEGORIES[@]}"; do
            [[ "$cat" == "Other" ]] && continue
            all_patterns+="${THEME_CATEGORIES[$cat]} "
        done
        local filtered=""
        while IFS= read -r theme; do
            local matched=false
            for pat in $all_patterns; do
                if echo "$theme" | grep -qi "$pat"; then
                    matched=true
                    break
                fi
            done
            [[ "$matched" == false ]] && filtered+="$theme"$'\n'
        done <<< "$themes"
        themes="$filtered"
    fi

    if [[ -z "$themes" ]]; then
        vicinae dmenu -n " Palette " -s "No themes in $category" <<< "ok"
        return
    fi

    local theme
    theme=$(printf '%s\n' "$themes" | vicinae dmenu -n " Palette " -s "Select $category theme" -W 500 -H 500)
    [[ -z "$theme" ]] && return

    apply_palette "$theme"

    vicinae dmenu -n " Palette " -s "Applied: $theme" <<< "ok"
}

# ─── Main Menu ─────────────────────────────────────────────────────────────

main() {
    while true; do
        local choice
        choice=$(printf '%s\n' \
            "Browse predefined wallust themes" \
            "Generate from image" \
            "Show current palette" \
            "Save current palette" \
            "Browse saved palettes" \
            "exit" | vicinae dmenu -n " Palette " -s "Palette Manager" -W 400 -H 300)

        case "$choice" in
            "Browse predefined wallust themes")
                browse_wallust_themes
                ;;
            "Generate from image")
                generate_from_image
                ;;
            "Show current palette")
                show_current_colors
                ;;
            "Save current palette")
                save_current_palette
                ;;
            "Browse saved palettes")
                browse_saved
                ;;
            "exit"|"")
                exit 0
                ;;
        esac
    done
}

main "$@"
