#!/usr/bin/env bash
# Re-link all dotfiles on a new machine
# Requires: GNU stow (sudo pacman -S stow)

set -euo pipefail
DOT="$(cd "$(dirname "$0")" && pwd)"

echo "==> Stowing .config/ packages..."
for pkg in alacritty fastfetch fish gtklock kitty mako niri nvim rofi systemd vicinae wallust waybar yazi zathura hypr btop opencode; do
    stow -d "$DOT" -t "$HOME" "$pkg" 2>/dev/null && echo "  $pkg" || echo "  $pkg (skipped)"
done

echo "==> Stowing flat config files..."
stow -d "$DOT" -t "$HOME" starship 2>/dev/null && echo "  starship"
stow -d "$DOT" -t "$HOME" pavucontrol 2>/dev/null && echo "  pavucontrol"
stow -d "$DOT" -t "$HOME" gtk 2>/dev/null && echo "  gtk"

echo "==> Stowing home dotfiles..."
stow -d "$DOT" -t "$HOME" zsh 2>/dev/null && echo "  zsh"
stow -d "$DOT" -t "$HOME" git 2>/dev/null && echo "  git"

echo "==> Symlinking scripts..."
mkdir -p "$HOME/.local/bin"
for script in bgselector.sh git-cleanup.sh gpu-stats.sh kb-layout.sh low-battery-notify.sh media-control.sh theme-sync.sh keybinds-view.sh keybinds-manager.sh keycapture.sh; do
    ln -sf "$DOT/scripts/$script" "$HOME/.local/bin/$script"
done
ln -sf "$DOT/scripts/lib" "$HOME/.local/bin/lib"
ln -sf "$DOT/scripts/keybinds.json" "$HOME/.local/bin/keybinds.json"
ln -sf "$DOT/scripts/keybinds-view.sh" "$HOME/.local/bin/keybinds-view"
ln -sf "$DOT/scripts/keybinds-manager.sh" "$HOME/.local/bin/keybinds-manager"
ln -sf "$DOT/scripts/keycapture.sh" "$HOME/.local/bin/keycapture"
echo "==> Building keycap (evdev key capture)..."
gcc -O2 -o "$HOME/.local/bin/keycap" "$DOT/scripts/keycap.c" 2>/dev/null && echo "  keycap" || echo "  keycap (build failed)"
  echo "  scripts"

echo "==> Done! All dotfiles linked."
echo "    Upstream (original): git remote add upstream https://github.com/saatvik333/niri-dotfiles.git"
