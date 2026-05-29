#!/usr/bin/env bash
# Keybind manager — vicinae dmenu based
# Add, edit, remove, and check conflicts in keybinds.json

set -uo pipefail

BINDS_FILE="${HOME}/.config/scripts/keybinds.json"
ROFI_THEME="${HOME}/.config/rofi/colors/wallust.rasi"
FONT="JetBrainsMono Nerd Font Propo 14"

input() {
    local prompt="$1"
    rofi -dmenu -p "$prompt" -theme "$ROFI_THEME" \
        -font "$FONT" \
        -theme-str "window {width: 380px;} inputbar {padding: 12px 16px;} entry {placeholder: \"TYPE VALUE\";}" 2>/dev/null
}

notify() {
    notify-send -t 3500 "Keybinds" "$1" 2>/dev/null || true
}

# ── Conflict check ──────────────────────────────────────
check_conflicts() {
    local conflicts
    conflicts=$(jq -r '
        [.categories[].entries[] | .bind]
        | group_by(.)
        | .[] | select(length > 1)
        | .[0] + " (" + (length | tostring) + "x)"
    ' "$BINDS_FILE" 2>/dev/null)

    if [ -z "$conflicts" ]; then
        notify "No conflicts"
    fi
}

# ── View keybinds ───────────────────────────────────────
view_keybinds() {
    local output
    output=$(jq -r '.categories[]
        | .name as $cat
        | .entries[]
        | "\(.bind) │ \(.action) │ \(.desc)"
    ' "$BINDS_FILE" 2>/dev/null) || { notify "Failed to read keybinds"; return; }
    [ -z "$output" ] && { notify "No keybinds found"; return; }
    echo "$output" | rofi -dmenu -p "Search" -theme "$ROFI_THEME" \
        -theme-str 'window {width: 700px;}' 2>/dev/null
}

# ── Add keybind ─────────────────────────────────────────
add_keybind() {
    local bind action desc exec_cmd

    notify "Press key combination..."
    bind=$("${HOME}/.local/bin/keycapture" 2>/dev/null)
    if [ -z "$bind" ]; then
        notify "Cancelled"
        return
    fi

    notify-send -t 3000 "Captured" "$bind" -u critical

    action=$(input "Add: enter action name")
    [ -z "$action" ] && { notify "Cancelled"; return; }

    desc=$(input "Add: enter description")
    [ -z "$desc" ] && { notify "Cancelled"; return; }

    exec_cmd=$(input "Add: enter exec command (or leave empty)")

    local tmp
    tmp=$(mktemp)
    if ! jq --arg bind "$bind" --arg action "$action" --arg desc "$desc" \
       --argjson exec_cmd "$([ -n "$exec_cmd" ] && echo "$exec_cmd" | jq -R '.' || echo null)" \
       '.categories[0].entries += [{"bind": $bind, "action": $action, "desc": $desc, "exec": $exec_cmd}]' \
       "$BINDS_FILE" > "$tmp" 2>/dev/null; then
        rm -f "$tmp"
        notify "Failed: jq error"
        return
    fi
    mv "$tmp" "$BINDS_FILE"

    notify "Added: $bind"
    check_conflicts
}

# ── Edit keybind ────────────────────────────────────────
edit_keybind() {
    local chosen bind action

    chosen=$(jq -r '.categories[]
        | .name as $cat
        | .entries[]
        | "\(.bind) │ \(.action) │ \(.desc)"
    ' "$BINDS_FILE" 2>/dev/null | rofi -dmenu -p "Edit" -theme "$ROFI_THEME" \
        -theme-str 'window {width: 700px;}' 2>/dev/null)

    [ -z "$chosen" ] && return

    bind=$(echo "$chosen" | awk -F' │ ' '{print $1}')
    action=$(echo "$chosen" | awk -F' │ ' '{print $2}')

    local old_desc old_exec
    old_desc=$(jq -r --arg b "$bind" --arg a "$action" '
        .categories[].entries[] | select(.bind == $b and .action == $a) | .desc
    ' "$BINDS_FILE" | head -1)
    old_exec=$(jq -r --arg b "$bind" --arg a "$action" '
        .categories[].entries[] | select(.bind == $b and .action == $a) | .exec // ""
    ' "$BINDS_FILE" | head -1)

    local new_bind new_action new_desc new_exec

    new_bind=$("${HOME}/.local/bin/keycapture" 2>/dev/null)
    [ -z "$new_bind" ] && new_bind="$bind"

    new_action=$(input "Edit: action [$action]" )
    [ -z "$new_action" ] && new_action="$action"

    new_desc=$(input "Edit: description [$old_desc]" )
    [ -z "$new_desc" ] && new_desc="$old_desc"

    new_exec=$(input "Edit: exec [$old_exec]" )
    [ -z "$new_exec" ] && new_exec="$old_exec"

    local tmp
    tmp=$(mktemp)
    jq --arg ob "$bind" --arg oa "$action" \
       --arg nb "$new_bind" --arg na "$new_action" \
       --arg nd "$new_desc" --arg ne "$new_exec" '
        (.categories[].entries[] | select(.bind == $ob and .action == $oa)) += {
            bind: $nb, action: $na, desc: $nd, exec: $ne
        }
    ' "$BINDS_FILE" > "$tmp" 2>/dev/null && mv "$tmp" "$BINDS_FILE"

    notify "Edited: $bind"
    check_conflicts
}

# ── Remove keybind ──────────────────────────────────────
remove_keybind() {
    local chosen bind action

    chosen=$(jq -r '.categories[]
        | .name as $cat
        | .entries[]
        | "\(.bind) │ \(.action) │ \(.desc)"
    ' "$BINDS_FILE" 2>/dev/null | rofi -dmenu -p "Remove" -theme "$ROFI_THEME" \
        -theme-str 'window {width: 700px;}' 2>/dev/null)

    [ -z "$chosen" ] && return

    bind=$(echo "$chosen" | awk -F' │ ' '{print $1}')
    action=$(echo "$chosen" | awk -F' │ ' '{print $2}')

    local tmp
    tmp=$(mktemp)
    jq --arg b "$bind" --arg a "$action" '
        del((.categories[].entries[] | select(.bind == $b and .action == $a)))
        | walk(if type == "object" then with_entries(select(.value != null and .value != [])) else . end)
    ' "$BINDS_FILE" > "$tmp" 2>/dev/null && mv "$tmp" "$BINDS_FILE"

    notify "Removed: $bind"
}

# ── Main menu ───────────────────────────────────────────
main_menu() {
    local choice
    choice=$(printf "🔍 View keybinds\n➕ Add keybind\n✏️  Edit keybind\n🗑️  Remove keybind\n⚠️  Check conflicts" \
        | rofi -dmenu -p "" -theme "$ROFI_THEME" \
            -theme-str 'window {width: 360px;}' \
            -no-custom 2>/dev/null)

    case "$choice" in
        *View*) view_keybinds ;;
        *Add*) add_keybind ;;
        *Edit*) edit_keybind ;;
        *Remove*) remove_keybind ;;
        *Conflicts*) check_conflicts ;;
    esac
}

main_menu
