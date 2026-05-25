#!/usr/bin/env bash
set -euo pipefail

THEMES_DIR="$HOME/.config/gtklock/themes"
WALLUST_CSS="$HOME/.config/gtklock/wallust.css"
ACTIVE_CSS="$HOME/.config/gtklock/style.css"

declare -A THEME_DESC
THEME_DESC["wallpaper"]="Default - wallpaper background only"
THEME_DESC["minimal"]="Clean semi-transparent panel with wallpaper"
THEME_DESC["dark-overlay"]="Dark overlay, large clock, purple accents"
THEME_DESC["gnome"]="GNOME-inspired - blue accent, thin clock"
THEME_DESC["glass"]="Glassmorphism - frosted panel, uppercase date"
THEME_DESC["wallust"]="Dynamic colors matched to current wallpaper"

get_current() {
    if [ ! -f "$ACTIVE_CSS" ] && [ ! -L "$ACTIVE_CSS" ]; then
        echo "none"; return
    fi

    if [ -L "$ACTIVE_CSS" ]; then
        local target; target=$(readlink "$ACTIVE_CSS")
        local name; name=$(basename "$target" .css)
        if [ "$target" = "themes/wallust.css" ]; then
            echo "wallust"
        else
            echo "$name"
        fi
        return
    fi

    if cmp -s "$ACTIVE_CSS" "$WALLUST_CSS" 2>/dev/null; then
        echo "wallust"
        return
    fi

    if grep -q "background-size" "$ACTIVE_CSS" 2>/dev/null; then
        echo "wallpaper"
    else
        echo "custom"
    fi
}

apply_theme() {
    local name="$1"

    rm -f "$ACTIVE_CSS"

    if [ "$name" = "wallust" ]; then
        if [ ! -f "$WALLUST_CSS" ]; then
            notify-send -u critical "gtklock-theme" \
                "wallust CSS not found. Run wallust first:\n  wallust run <image>"
            exit 1
        fi
        cp "$WALLUST_CSS" "$ACTIVE_CSS"
    else
        local src="$THEMES_DIR/$name.css"
        if [ ! -f "$src" ]; then
            notify-send -u critical "gtklock-theme" "Theme file not found: $name.css"
            exit 1
        fi
        ln -s "$src" "$ACTIVE_CSS"
    fi

    notify-send -i dialog-information "gtklock-theme" "Theme: $name"
}

preview_theme() {
    local src="$ACTIVE_CSS"
    if [ ! -f "$src" ]; then
        notify-send -u critical "gtklock-theme" "No active style.css to preview"
        return
    fi

    local bg_path
    bg_path=$(find "${WALL_DIR:-$HOME/Pictures/wall}" -maxdepth 1 -type f,l 2>/dev/null | head -1)

    if [ -n "$bg_path" ]; then
        gtklock -il -s "$src" -b "$bg_path" &
        local pid=$!
        sleep 3
        kill "$pid" 2>/dev/null || true
    else
        notify-send -u normal "gtklock-theme" "No wallpaper for preview"
    fi
}

open_url() {
    local url="$1"
    if command -v xdg-open &>/dev/null; then
        xdg-open "$url" 2>/dev/null &
    elif command -v firefox &>/dev/null; then
        firefox "$url" 2>/dev/null &
    else
        notify-send -u critical "gtklock-theme" "No browser found"
    fi
}

list_choices() {
    local current; current=$(get_current)
    local choices=()

    for f in "$THEMES_DIR"/*.css; do
        local name; name=$(basename "$f" .css)
        local desc="${THEME_DESC[$name]:-}"
        if [ "$name" = "$current" ]; then
            choices+=("$name  [ACTIVE]  $desc")
        else
            choices+=("$name  $desc")
        fi
    done

    if [ "$current" = "wallust" ]; then
        choices+=("wallust  [ACTIVE]  Dynamic colors matched to current wallpaper")
    else
        choices+=("wallust  Dynamic colors matched to current wallpaper")
    fi

    choices+=("---")
    choices+=("Browse online  Open gtklock theme repos in browser")
    choices+=("Preview  Preview current theme via gtklock -il")

    local pick
    pick=$(vicinae dmenu -p "Select gtklock theme" \
        -s "Lock screen style" -n " Lock Screen " \
        < <(printf '%s\n' "${choices[@]}"))

    case "$pick" in
        ""|"---") exit 0 ;;
        "Browse online")
            open_url "https://github.com/tomdewildt/gnome-gtklock-theme"
            open_url "https://github.com/jovanlanik/gtklock/wiki"
            ;;
        "Preview") preview_theme ;;
        *)
            local name
            name=$(echo "$pick" | sed 's/  \[ACTIVE\].*//;s/  .*//')
            apply_theme "$name"
            ;;
    esac
}

mkdir -p "$THEMES_DIR"

case "${1:-}" in
    list)
        for f in "$THEMES_DIR"/*.css; do
            basename "$f" .css
        done
        echo "wallust"
        ;;
    apply) apply_theme "${2:-}" ;;
    current) get_current ;;
    preview) preview_theme ;;
    browse)
        open_url "https://github.com/tomdewildt/gnome-gtklock-theme"
        open_url "https://github.com/jovanlanik/gtklock/wiki"
        ;;
    "") list_choices ;;
    *) echo "Usage: gtklock-theme.sh [list|apply <name>|current|preview|browse]" >&2; exit 1 ;;
esac
