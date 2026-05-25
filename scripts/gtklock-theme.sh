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
THEME_DESC["nord"]="Nord - frost blue/gray, arctic theme"
THEME_DESC["catppuccin"]="Catppuccin Mocha - warm mauve/blue"
THEME_DESC["dracula"]="Dracula - purple/pink dark theme"
THEME_DESC["everforest"]="Everforest - soft green, nature tones"
THEME_DESC["gruvbox"]="Gruvbox - warm yellow/retro orange"
THEME_DESC["tokyo-night"]="Tokyo Night - deep blue, neon accents"
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

    local bg_win="#0d0d0d" bg_panel accent text_clock text_date text_input input_bg input_border button_bg

    case "$name" in
        wallpaper)
            bg_panel="#1a1a1a" accent="#6c9eff" text_clock="#ffffff" text_date="#888888"
            text_input="#cccccc" input_bg="#222222" input_border="#444444" button_bg="#6c9eff"
            ;;
        minimal)
            bg_panel="rgba(25,25,35,0.92)" accent="rgba(200,200,220,0.9)" text_clock="#ffffff" text_date="rgba(200,200,220,0.6)"
            text_input="rgba(220,220,240,0.8)" input_bg="rgba(40,40,50,0.5)" input_border="rgba(220,220,240,0.2)" button_bg="rgba(200,200,220,0.15)"
            ;;
        dark-overlay)
            bg_panel="#0d0d0d" accent="#7c7cff" text_clock="#ffffff" text_date="#aaaaaa"
            text_input="#dddddd" input_bg="#000000" input_border="#555555" button_bg="#7c7cff"
            ;;
        gnome)
            bg_panel="#2a2a2a" accent="#6c9eff" text_clock="#ffffff" text_date="#999999"
            text_input="#cccccc" input_bg="#333333" input_border="#555555" button_bg="#6c9eff"
            ;;
        glass)
            bg_panel="rgba(25,25,35,0.7)" accent="rgba(255,255,255,0.15)" text_clock="#ffffff" text_date="#aaaaaa"
            text_input="rgba(220,220,240,0.7)" input_bg="rgba(30,30,40,0.4)" input_border="rgba(220,220,240,0.12)" button_bg="rgba(220,220,240,0.1)"
            ;;
        nord)
            bg_panel="#1e222a" accent="#88c0d0" text_clock="#eceff4" text_date="#81a1c1"
            text_input="#d8dee9" input_bg="#2e3440" input_border="#4c566a" button_bg="#88c0d0"
            ;;
        catppuccin)
            bg_panel="#1e1e2e" accent="#89b4fa" text_clock="#cdd6f4" text_date="#a6adc8"
            text_input="#bac2de" input_bg="#313244" input_border="#585b70" button_bg="#89b4fa"
            ;;
        dracula)
            bg_panel="#1e1f29" accent="#bd93f9" text_clock="#f8f8f2" text_date="#6272a4"
            text_input="#f8f8f2" input_bg="#282a36" input_border="#44475a" button_bg="#bd93f9"
            ;;
        everforest)
            bg_panel="#232a2e" accent="#a7c080" text_clock="#d3c6aa" text_date="#859289"
            text_input="#d3c6aa" input_bg="#2d353b" input_border="#475258" button_bg="#a7c080"
            ;;
        gruvbox)
            bg_panel="#282828" accent="#fabd2f" text_clock="#ebdbb2" text_date="#928374"
            text_input="#ebdbb2" input_bg="#3c3836" input_border="#504945" button_bg="#fabd2f"
            ;;
        tokyo-night)
            bg_panel="#1a1b26" accent="#7aa2f7" text_clock="#a9b1d6" text_date="#565f89"
            text_input="#c0caf5" input_bg="#24283b" input_border="#3b4261" button_bg="#7aa2f7"
            ;;
        wallust)
            local wf="$WALLUST_CSS"
            local c1="#222222" c2="#6c9eff" c3="#ffffff" c4="#888888"
            if [ -f "$wf" ]; then
                c1=$(grep -oP '#[0-9a-fA-F]{6}' "$wf" | sed -n '1p'); c1="${c1:-#222222}"
                c2=$(grep -oP '#[0-9a-fA-F]{6}' "$wf" | sed -n '4p'); c2="${c2:-#6c9eff}"
                c3=$(grep -oP '(?<=color: )#[0-9a-fA-F]{6}' "$wf" | sed -n '1p'); c3="${c3:-#ffffff}"
            fi
            bg_panel="$c1" accent="$c2" text_clock="$c3" text_date="#888888"
            text_input="$c3" input_bg="$c1" input_border="$c2" button_bg="$c2"
            ;;
    esac

    # Build a proper mockup with distinct elements
    magick -define png:color-type=6 -size 260x170 "xc:$bg_win" \
        -fill "$bg_panel" -draw "roundrectangle 6,6 254,164 12,12" \
        -fill "$text_clock" -pointsize 28 -gravity north -annotate +0+20 "12:34" \
        -fill "$text_date" -pointsize 10 -gravity north -annotate +0+56 "Mon 25 May 2026" \
        -fill "$input_bg" -draw "roundrectangle 48,80 212,104 6,6" \
        -fill "$text_input" -pointsize 10 -gravity center -annotate +0+0 "Password" \
        -draw "roundrectangle 48,80 212,104 6,6" -stroke "$input_border" -strokewidth 1 -fill none \
        -fill "$button_bg" -draw "roundrectangle 85,112 175,132 6,6" \
        -fill "$text_clock" -pointsize 9 -gravity center -annotate +0+22 "Unlock" \
        "$thumb_file" 2>/dev/null || true
}

generate_all_thumbs() {
    set +e
    mkdir -p "$THUMB_DIR"
    local count=0

    local names=("wallpaper" "minimal" "dark-overlay" "gnome" "glass" "nord" "catppuccin" "dracula" "everforest" "gruvbox" "tokyo-night" "wallust")
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
