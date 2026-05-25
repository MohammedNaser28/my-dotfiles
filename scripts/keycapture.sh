#!/usr/bin/env bash
# Capture a key combination silently via evdev (no window)
# Outputs: "MOD + A" or "MOD + Ctrl + Shift + A"

set -euo pipefail

notify-send -t 3000 "Key Capture" "Press your key combination..."

modname() {
    case "$1" in
        KEY_LEFTMETA|KEY_RIGHTMETA)  echo "MOD" ;;
        KEY_LEFTCTRL|KEY_RIGHTCTRL)  echo "Ctrl" ;;
        KEY_LEFTALT|KEY_RIGHTALT)    echo "Alt" ;;
        KEY_LEFTSHIFT|KEY_RIGHTSHIFT) echo "Shift" ;;
    esac
}

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
        KP_ENTER)        echo "KP_Enter" ;;
        F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|F12|F13|F14|F15|F16|F17|F18|F19|F20|F21|F22|F23|F24) echo "$k" ;;
        [A-Z0-9])   echo "$k" ;;
        *)          echo "$k" ;;
    esac
}

declare -A held_mods
captured=""

# Process substitution avoids subshell — exit works
while IFS= read -r line; do
    # Parse: "event11  KEYBOARD_KEY  +0.123s  KEY_LEFTALT (56) pressed"
    key="${line##*$'\t'}"
    key="${key%% (*}"
    state="${line##* }"

    mn=$(modname "$key" || true)

    if [ "$state" = "pressed" ]; then
        if [ -n "$mn" ]; then
            held_mods["$mn"]=1
        elif [ -z "$captured" ]; then
            captured=$(keyname "$key")
        fi
    else
        [ -n "$mn" ] && unset "held_mods[$mn]"
        # On release of captured key, output and exit
        if [ -z "$mn" ] && [ -n "$captured" ]; then
            result=""
            for m in MOD Ctrl Alt Shift; do
                [ "${held_mods[$m]:-}" = "1" ] && [ -n "$result" ] && result="$result + $m" || [ "${held_mods[$m]:-}" = "1" ] && result="$m"
            done
            [ -n "$result" ] && result="$result + $captured" || result="$captured"
            echo "$result"
            exit 0
        fi
    fi
done < <(stdbuf -oL libinput debug-events 2>/dev/null | grep --line-buffered "KEYBOARD_KEY")
