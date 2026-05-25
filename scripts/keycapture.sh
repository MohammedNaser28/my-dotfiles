#!/usr/bin/env bash
# Capture a key combination using wev
# Outputs format like: "MOD + A" or "MOD + Ctrl + Shift + A"

set -euo pipefail

notify-send -t 5000 "Key Capture" "Focus this window and press your key combination..."

# Map wev modifier key names to display names
modname() {
    case "$1" in
        KEY_LEFTMETA|KEY_RIGHTMETA)  echo "MOD" ;;
        KEY_LEFTCTRL|KEY_RIGHTCTRL)  echo "Ctrl" ;;
        KEY_LEFTALT|KEY_RIGHTALT)    echo "Alt" ;;
        KEY_LEFTSHIFT|KEY_RIGHTSHIFT) echo "Shift" ;;
    esac
}

# Map wev key names to readable display names
keyname() {
    local k="${1#KEY_}"
    case "$k" in
        RETURN)     echo "Return" ;;
        TAB)        echo "Tab" ;;
        ESCAPE)     echo "Escape" ;;
        SPACE)      echo "Space" ;;
        BACKSPACE)  echo "BackSpace" ;;
        DELETE)     echo "Delete" ;;
        HOME)       echo "Home" ;;
        END)        echo "End" ;;
        PAGEUP)     echo "Page_Up" ;;
        PAGEDOWN)   echo "Page_Down" ;;
        UP)         echo "Up" ;;
        DOWN)       echo "Down" ;;
        LEFT)       echo "Left" ;;
        RIGHT)      echo "Right" ;;
        BRACKETLEFT)  echo "[" ;;
        BRACKETRIGHT) echo "]" ;;
        SLASH)      echo "/" ;;
        BACKSLASH)  echo "\\\\" ;;
        SEMICOLON)  echo ";" ;;
        APOSTROPHE) echo "'" ;;
        COMMA)      echo "," ;;
        DOT)        echo "." ;;
        MINUS)      echo "-" ;;
        EQUAL)      echo "=" ;;
        GRAVE)      echo "grave" ;;
        KP_ENTER)   echo "KP_Enter" ;;
        F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|F17|F18|F19|F20|F21|F22|F23|F24) echo "$k" ;;
        [A-Z0-9])   echo "$k" ;;
        *)          echo "$k" ;;
    esac
}

declare -A held_mods
captured=""

stdbuf -oL wev 2>/dev/null | while IFS= read -r line; do
    # Check for key name line: "  key: KEY_XXX (N)"
    if echo "$line" | grep -qP '^\s+key:\s+KEY_'; then
        current_key=$(echo "$line" | sed 's/.*key: //; s/ ([0-9].*)//')
        continue
    fi

    # Check for state line: "  state: PRESSED" or "  state: RELEASED"
    if echo "$line" | grep -qP '^\s+state:\s+(PRESSED|RELEASED)'; then
        state=$(echo "$line" | sed 's/.*state: //')

        mn=$(modname "$current_key" || true)

        if [ "$state" = "PRESSED" ]; then
            if [ -n "$mn" ]; then
                held_mods["$mn"]=1
            else
                captured=$(keyname "$current_key")
            fi
        else
            # RELEASED
            if [ -n "$mn" ]; then
                unset "held_mods[$mn]"
            fi
            # On release of the captured non-modifier key, output and exit
            if [ -z "$mn" ] && [ -n "$captured" ]; then
                # Build modifier prefix sorted: MOD > Ctrl > Alt > Shift
                result=""
                for m in MOD Ctrl Alt Shift; do
                    [ "${held_mods[$m]:-}" = "1" ] && [ -z "$result" ] && result="$m" && break
                done
                # Actually build the full chain
                result=""
                for m in MOD Ctrl Alt Shift; do
                    [ "${held_mods[$m]:-}" = "1" ] && [ -n "$result" ] && result="$result + $m" || [ "${held_mods[$m]:-}" = "1" ] && result="$m"
                done
                [ -n "$result" ] && result="$result + $captured" || result="$captured"
                echo "$result"
                exit 0
            fi
        fi
    fi
done
