#!/usr/bin/env bash
# Capture a key combination via evdev, with a styled rofi overlay
# Uses the compiled keycap binary for reliable capture

BIN="${HOME}/.local/bin/keycap"
SRC="$(dirname "$0")/keycap.c"
ROFI_THEME="${HOME}/.config/rofi/colors/wallust.rasi"

# Build if missing
if [ ! -x "$BIN" ]; then
    if command -v gcc &>/dev/null && [ -f "$SRC" ]; then
        gcc -O2 -o "$BIN" "$SRC" 2>/dev/null || {
            notify-send -t 3000 "Key Capture" "Build failed: gcc error"
            exit 1
        }
    else
        notify-send -t 3000 "Key Capture" "keycap binary not found"
        exit 1
    fi
fi

KEYCAP_OUT=$(mktemp /tmp/keycap-XXXXXX)

# Run keycap in background, save combo to temp file
"$BIN" > "$KEYCAP_OUT" 2>/dev/null &
KEYCAP_PID=$!

# Show styled rofi overlay until key is captured
rofi -e "Press your key combination..." \
    -theme "$ROFI_THEME" \
    -font "JetBrainsMono Nerd Font Propo 14" \
    -theme-str "window {width: 480px;}" &
ROFI_PID=$!

# Wait for keycap to capture
wait "$KEYCAP_PID" 2>/dev/null

# Dismiss rofi
kill "$ROFI_PID" 2>/dev/null
wait "$ROFI_PID" 2>/dev/null

COMBIN=$(tr -d '\n' < "$KEYCAP_OUT")
rm -f "$KEYCAP_OUT"

[ -z "$COMBIN" ] && exit 1

echo "$COMBIN"
