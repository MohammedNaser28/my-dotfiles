#!/bin/bash
set -euo pipefail

# usb-notify — USB (un)plug notification + sound
# Triggered by udev on USB block device add/remove.
#
# Runs as root, sends notification + plays sound as the active user
# via direct DBUS/PulseAudio access (no sudo needed).
#
# Setup:
#   sudo setup-usb-notify.sh
#
# Tests (as your user):
#   NOTIFY_USER=$UID notify-send -a USB -i media-removable "Test" "body"

# --- Find the active user session ---
for dir in /run/user/*; do
    uid="${dir#/run/user/}"
    [[ "$uid" =~ ^[0-9]+$ ]] || continue
    [[ -d "/run/user/$uid/bus" ]] || continue
    ACTIVE_UID="$uid"
    break
done

ACTIVE_USER=$(getent passwd "${ACTIVE_UID:-}" | cut -d: -f1)
[[ -z "${ACTIVE_USER:-}" ]] && exit 1

# --- User session environment ---
export XDG_RUNTIME_DIR="/run/user/$ACTIVE_UID"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$ACTIVE_UID/bus"
export WAYLAND_DISPLAY="wayland-1"
export DISPLAY=":0"

# PulseAudio / PipeWire — connect to user's audio server
export PULSE_SERVER="unix:/run/user/$ACTIVE_UID/pulse/native"
export PIPEWIRE_REMOTE="/run/user/$ACTIVE_UID/pipewire-0"

# --- Determine action and device info ---
ACTION="${1:-${ACTION:-}}"
LABEL="${ID_FS_LABEL:-${2:-USB Drive}}"

notify() {
    local summary="$1" body="$2" sound_id="$3"
    notify-send -a "USB" -i media-removable -u low "$summary" "$body"

    if command -v canberra-gtk-play &>/dev/null; then
        canberra-gtk-play --id="$sound_id" 2>/dev/null || true
    fi
}

case "$ACTION" in
    add)  notify "USB Drive Added" "$LABEL" "device-added" ;;
    remove) notify "USB Drive Removed" "$LABEL" "device-removed" ;;
esac
