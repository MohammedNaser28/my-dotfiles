#!/usr/bin/env bash
# Re-link all dotfiles on a new machine
# Requires: GNU stow (sudo pacman -S stow), git-lfs (sudo pacman -S git-lfs)

set -euo pipefail
DOT="$(cd "$(dirname "$0")" && pwd)"

echo "==> Checking git-lfs..."
if ! command -v git-lfs &>/dev/null; then
  echo "  WARNING: git-lfs not found. Wallpaper images will not be checked out."
  echo "  Install: sudo pacman -S git-lfs"
else
  git lfs install --skip-repo 2>/dev/null || true
fi

echo "==> Initializing git submodules..."
git -C "$DOT" submodule update --init --recursive 2>/dev/null && echo "  wallpapers" || echo "  (no submodules)"

echo "==> Pulling LFS objects..."
if command -v git-lfs &>/dev/null && [[ -d "$DOT/wallpapers/.git" ]]; then
  git -C "$DOT/wallpapers" lfs pull 2>/dev/null && echo "  wallpapers LFS data" || echo "  (no LFS data)"
fi

echo "==> Stowing .config/ packages..."
for pkg in alacritty fastfetch fish gtklock kitty mako niri nvim rofi systemd vicinae wallust waybar yazi zathura hypr btop opencode kbind-daemon; do
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
# ~/.config/scripts -> dotfiles/scripts (so $HOME/.config/scripts/* paths work)
ln -sfT "$DOT/scripts" "$HOME/.config/scripts"
for script in bgselector.sh git-cleanup.sh gpu-stats.sh kb-layout.sh low-battery-notify.sh media-control.sh theme-sync.sh keybinds-view.sh keybinds-manager.sh keycapture.sh cache-palettes.sh palette-view.sh; do
    ln -sf "$DOT/scripts/$script" "$HOME/.local/bin/$script"
done
ln -sf "$DOT/scripts/lib" "$HOME/.local/bin/lib"
ln -sf "$DOT/scripts/keybinds.json" "$HOME/.local/bin/keybinds.json"
ln -sf "$DOT/scripts/keybinds-view.sh" "$HOME/.local/bin/keybinds-view"
ln -sf "$DOT/scripts/keybinds-manager.sh" "$HOME/.local/bin/keybinds-manager"
ln -sf "$DOT/scripts/keycapture.sh" "$HOME/.local/bin/keycapture"
ln -sf "$DOT/scripts/mediactl" "$HOME/.local/bin/mediactl"
echo "==> Building evdev tools..."
gcc -O2 -o "$HOME/.local/bin/keycap" "$DOT/scripts/keycap.c" 2>/dev/null && echo "  keycap" || echo "  keycap (build failed)"
gcc -O2 -o "$HOME/.local/bin/kbind-daemon" "$DOT/scripts/kbind-daemon.c" 2>/dev/null && echo "  kbind-daemon" || echo "  kbind-daemon (build failed)"
  echo "  scripts"

echo "==> Done! All dotfiles linked."
echo "    Forked from: https://github.com/saatvik333/niri-dotfiles.git"
