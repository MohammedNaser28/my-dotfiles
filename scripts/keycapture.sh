#!/usr/bin/env bash
# Capture a key combination 
set -uo pipefail

ROFI_THEME="${HOME}/.config/rofi/colors/wallust.rasi"
FONT="JetBrainsMono Nerd Font Propo 14"

notify-send -t 5000 "⌨ Key Capture" "Press your key combination now" -u critical

# 1) keycap (direct evdev)
BIN="${HOME}/.local/bin/keycap"
if [ -x "$BIN" ]; then
    tmp=$(mktemp /tmp/keycap-XXXX)
    "$BIN" > "$tmp" 2>/dev/null &
    KPID=$!
    (sleep 5 && kill "$KPID" 2>/dev/null) &
    TPID=$!
    wait "$KPID" 2>/dev/null
    kill "$TPID" 2>/dev/null
    wait 2>/dev/null
    combo=$(tr -d '\n' < "$tmp" | xargs)
    rm -f "$tmp"
    [ -n "$combo" ] && { echo "$combo"; exit 0; }
fi

# 2) wev (Wayland event viewer)
if command -v wev &>/dev/null; then
    tmp=$(mktemp /tmp/wevcap-XXXX)
    wev > "$tmp" 2>/dev/null &
    WPID=$!
    (sleep 5 && kill "$WPID" 2>/dev/null) &
    TPID=$!
    wait "$WPID" 2>/dev/null
    kill "$TPID" 2>/dev/null
    wait 2>/dev/null

    mods=""; key_code=""; key_name=""; state="idle"
    while IFS= read -r line; do
        # Track modifier state
        if [[ "$line" =~ depressed:\ ([0-9a-fA-F]+) ]]; then
            d=$((16#${BASH_REMATCH[1]}))
            mods=""
            ((d & (1<<4))) && mods+="MOD + "
            ((d & (1<<3))) && mods+="Alt + "
            ((d & (1<<2))) && mods+="Ctrl + "
            ((d & (1<<0))) && mods+="Shift + "
        fi

        if [[ "$line" =~ key:\ ([0-9]+) ]]; then
            c="${BASH_REMATCH[1]}"
            s=1; [[ "$line" =~ state:\ ([0-9]) ]] && s="${BASH_REMATCH[1]}"
            # Skip modifiers
            case "$c" in 29|97|56|100|42|54|125|126) continue ;; esac

            if [ "$s" = "1" ] && [ "$state" = "idle" ]; then
                key_code="$c"; state="held"
                read -r nx && [[ "$nx" =~ xkb:\ \'(.+)\' ]] && key_name="${BASH_REMATCH[1]}"
            elif [ "$s" = "0" ] && [ "$c" = "$key_code" ]; then
                [ -z "$key_name" ] && { read -r nx; [[ "$nx" =~ xkb:\ \'(.+)\' ]] && key_name="${BASH_REMATCH[1]}"; }
                echo "${mods}${key_name}"
                rm -f "$tmp"
                exit 0
            fi
        fi
    done < "$tmp"
    rm -f "$tmp"
fi

# 3) Fallback
rofi -dmenu -p "Keybind" -theme "$ROFI_THEME" -font "$FONT" \
    -theme-str 'window {width: 380px;}' \
    -theme-str 'entry {placeholder: "e.g. MOD + A";}' 2>/dev/null
