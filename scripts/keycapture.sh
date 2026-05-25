#!/usr/bin/env bash
# Capture a key combination silently via evdev (no window, no panel)
# Uses the compiled keycap binary for reliable capture

BIN="${HOME}/.local/bin/keycap"
SRC="$(dirname "$0")/keycap.c"

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

notify-send -t 2000 "Key Capture" "Press your key combination..."
"$BIN"
