#!/usr/bin/env bash
set -euo pipefail

THEMES_DIR="$HOME/.config/gtklock/themes"
WALLUST_CSS="$HOME/.config/gtklock/wallust.css"
ACTIVE_CSS="$HOME/.config/gtklock/style.css"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/gtklock-theme"
THUMB_DIR="$CACHE_DIR/thumbs"

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
        [ "$target" = "themes/wallust.css" ] && echo "wallust" || echo "$name"
        return
    fi

    if cmp -s "$ACTIVE_CSS" "$WALLUST_CSS" 2>/dev/null; then
        echo "wallust"; return
    fi

    grep -q "background-size" "$ACTIVE_CSS" 2>/dev/null && echo "wallpaper" || echo "custom"
}

apply_theme() {
    local name="$1"
    rm -f "$ACTIVE_CSS"

    if [ "$name" = "wallust" ]; then
        [ ! -f "$WALLUST_CSS" ] && {
            notify-send -u critical "gtklock-theme" "wallust CSS not found. Run:\n  wallust run ~/Pictures/Wallpapers/.../image.jpg"
            exit 1
        }
        cp "$WALLUST_CSS" "$ACTIVE_CSS"
    else
        local src="$THEMES_DIR/$name.css"
        [ ! -f "$src" ] && {
            notify-send -u critical "gtklock-theme" "Theme file not found: $name.css"
            exit 1
        }
        ln -sf "$src" "$ACTIVE_CSS"
    fi
    notify-send -i dialog-information "gtklock-theme" "Theme: $name"
}

gen_thumbnail() {
    local name="$1"
    local thumb_file="$2"

    # Theme color swatches: bg_panel bg_win accent text_primary text_secondary
    local bg_panel="#222222" bg_win="#111111" accent="#6c9eff" text_primary="#ffffff" text_secondary="#aaaaaa"

    case "$name" in
        wallpaper)
            bg_panel="#222222" bg_win="#000000"
            accent="#6c9eff" text_primary="#ffffff" text_secondary="#888888"
            ;;
        minimal)
            bg_panel="#222222" bg_win="#000000"
            accent="#cccccc" text_primary="#ffffff" text_secondary="#999999"
            ;;
        dark-overlay)
            bg_panel="#111111" bg_win="#000000"
            accent="#7c7cff" text_primary="#ffffff" text_secondary="#cccccc"
            ;;
        gnome)
            bg_panel="#1e1e1e" bg_win="#1e1e1e"
            accent="#6c9eff" text_primary="#ffffff" text_secondary="#cccccc"
            ;;
        glass)
            bg_panel="#333333" bg_win="#000000"
            accent="#dddddd" text_primary="#ffffff" text_secondary="#aaaaaa"
            ;;
        wallust)
            local wf="$WALLUST_CSS"
            if [ -f "$wf" ]; then
                local c; c=$(grep -oP '#[0-9a-fA-F]{6}' "$wf" | sed -n '1p')
                bg_panel="${c:-#222222}"
                c=$(grep -oP '#[0-9a-fA-F]{6}' "$wf" | sed -n '2p')
                accent="${c:-#6c9eff}"
                c=$(grep -oP '(?<=color: )#[0-9a-fA-F]{6}' "$wf" | sed -n '1p')
                text_primary="${c:-#ffffff}"
            fi
            bg_win="#000000" text_secondary="#888888"
            ;;
    esac

    magick -size 240x160 "xc:$bg_win" \
        -fill "$bg_panel" -draw "roundrectangle 4,4 236,156 14,14" \
        -fill "$text_primary" -font "Adwaita-Mono-Bold" -pointsize 24 \
        -gravity north -annotate +0+22 "12:34" \
        -fill "$text_secondary" -pointsize 10 -annotate +0+52 "Mon, May 25" \
        -fill "$accent" -pointsize 9 -gravity center -annotate +0+15 "---  o  ---" \
        -fill "$text_secondary" -pointsize 9 -gravity south -annotate +0-14 "Enter password..." \
        "$thumb_file" 2>/dev/null || true
}

generate_all_thumbs() {
    set +e
    mkdir -p "$THUMB_DIR"
    local count=0

    local names=("wallpaper" "minimal" "dark-overlay" "gnome" "glass" "wallust")
    for name in "${names[@]}"; do
        local thumb="$THUMB_DIR/$name.png"
        if [ ! -f "$thumb" ]; then
            gen_thumbnail "$name" "$thumb"
            ((count++))
        fi
    done

    [ "$count" -gt 0 ] && notify-send -t 1500 "gtklock-theme" "Generated $count theme thumbnails"
    set -e
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

grid_picker() {
    set +e; generate_all_thumbs; set -e
    local current; current=$(get_current)

    # Build rofi input with null-delimited icon metadata
    local rofi_input
    rofi_input=$(mktemp)

    {
        for f in "$THEMES_DIR"/*.css; do
            local name; name=$(basename "$f" .css)
            local thumb="$THUMB_DIR/$name.png"
            local desc="${THEME_DESC[$name]:-}"
            local mark=""
            [ "$name" = "$current" ] && mark=" [ACTIVE]"
            if [ -f "$thumb" ]; then
                printf '%s%s  %s\0icon\x1f%s\n' "$name" "$mark" "$desc" "$thumb"
            else
                echo "$name$mark  $desc"
            fi
        done

        local wmark=""
        [ "$current" = "wallust" ] && wmark=" [ACTIVE]"
        local wthumb="$THUMB_DIR/wallust.png"
        if [ -f "$wthumb" ]; then
            printf 'wallust%s  Dynamic colors matched to wallpaper\0icon\x1f%s\n' "$wmark" "$wthumb"
        else
            echo "wallust$wmark  Dynamic colors matched to wallpaper"
        fi

        echo "action-browse  Browse online - open theme repos in browser"
        echo "action-refresh  Regenerate preview thumbnails"
    } > "$rofi_input"

    local chosen
    chosen=$(rofi -dmenu -show-icons -p "Lock Screen Theme" \
        -theme-str 'listview { columns: 3; lines: 2; spacing: 8px; }' \
        -config "$HOME/.config/rofi/bgselector/style.rasi" \
        < "$rofi_input")
    rm -f "$rofi_input"

    case "$chosen" in
        "" ) exit 0 ;;
        "action-browse" )
            open_url "https://github.com/tomdewildt/gnome-gtklock-theme"
            open_url "https://github.com/jovanlanik/gtklock/wiki"
            ;;
        "action-refresh" )
            rm -rf "$THUMB_DIR"
            generate_all_thumbs
            notify-send "gtklock-theme" "Thumbnails regenerated"
            ;;
        * )
            local name
            name=$(echo "$chosen" | sed 's/  \[ACTIVE\].*//;s/  .*//')
            apply_theme "$name"
            ;;
    esac
}

mkdir -p "$THEMES_DIR"

case "${1:-}" in
    list)
        for f in "$THEMES_DIR"/*.css; do basename "$f" .css; done
        echo "wallust"
        ;;
    apply) apply_theme "${2:-}" ;;
    current) get_current ;;
    thumbs) generate_all_thumbs ;;
    browse)
        open_url "https://github.com/tomdewildt/gnome-gtklock-theme"
        open_url "https://github.com/jovanlanik/gtklock/wiki"
        ;;
    "") grid_picker ;;
    *) echo "Usage: gtklock-theme.sh [list|apply <name>|current|thumbs|browse]" >&2; exit 1 ;;
esac
