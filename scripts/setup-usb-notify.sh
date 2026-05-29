#!/bin/bash
set -euo pipefail

# Installs USB notification script + udev rule.
# Run this once (it needs sudo for the udev rule).

SCRIPT_SRC="$HOME/.config/scripts/usb-notify.sh"
UDEV_SRC="$HOME/.config/scripts/udev/99-usb-notify.rules"
UDEV_DEST="/etc/udev/rules.d/99-usb-notify.rules"

echo "==> Installing script to /usr/local/bin/..."
sudo cp "$SCRIPT_SRC" /usr/local/bin/usb-notify
sudo chmod +x /usr/local/bin/usb-notify

echo "==> Installing udev rule..."
sudo cp "$UDEV_SRC" "$UDEV_DEST"

# Update path in udev rule to point to system location
sudo sed -i 's|/home/[^/]*/.local/bin/usb-notify|/usr/local/bin/usb-notify|g' "$UDEV_DEST"

echo "==> Reloading udev rules..."
sudo udevadm control --reload-rules

echo "==> Done! USB notifications enabled."
echo "    Test: plug or unplug a USB drive."
echo ""
echo "    Manual test: sudo /usr/local/bin/usb-notify add 'TestDrive'"
