#!/bin/bash

chosen=$(printf "Logout\nReboot\nShutdown\nSuspend\nLock" \
    | vicinae dmenu -n " Power Menu" -s "Choose action" -W 200)

case "$chosen" in
    Logout)
        niri msg action quit
        ;;
    Reboot)
        systemctl reboot
        ;;
    Shutdown)
        systemctl poweroff
        ;;
    Suspend)
        systemctl suspend
        ;;
    Lock)
        gtklock
        ;;
esac
