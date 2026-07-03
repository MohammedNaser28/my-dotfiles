# dotfiles (general edition)

Niri compositor dotfiles for Wayland, managed with **GNU Stow**.

Forked from [saatvik333/niri-dotfiles](https://github.com/saatvik333/niri-dotfiles).

## Quick start

```bash
git clone --recursive https://github.com/MohammedNaser28/my-dotfiles.git ~/.dotfiles-sevens
cd ~/.dotfiles-sevens
./install.sh --packages --yay   # Optional: install all dependencies (Arch)
./stow.sh                       # Link configs to $HOME
```

## Structure

Each app lives in its own directory with `$HOME`-relative paths:

```
~/.dotfiles-sevens/waybar/.config/waybar/config.jsonc
  └── stows to ──> ~/.config/waybar/config.jsonc (symlink)
```

### Packages

| Package | Purpose |
|---------|---------|
| `niri` | Scrollable-tiling Wayland compositor |
| `waybar` | Vertical status bar (left side, 72px) |
| `alacritty` | GPU-accelerated terminal |
| `kitty` | Feature-rich fallback terminal |
| `fish` | Interactive shell (primary) |
| `zsh` | Fallback shell config |
| `starship` | Cross-shell prompt |
| `rofi` | App launcher + powermenu + wallpaper picker UI |
| `vicinae` | Web-search-style app launcher |
| `mako` | Notification daemon |
| `gtklock` | Swaylock-compatible lockscreen |
| `wallust` | Wallpaper-driven color engine (13+ app templates) |
| `fastfetch` | System fetch tool |
| `btop` | System monitor |
| `nvim` | LazyVim-based Neovim config |
| `yazi` | Terminal file manager |
| `zathura` | PDF viewer |
| `gtk` | GTK3/GTK4 settings |
| `systemd` | User service units |

### Scripts

Key scripts in `~/.config/scripts/`:

| Script | Purpose |
|--------|---------|
| `bgselector.sh` | Wallpaper picker with rofi + thumbnails |
| `theme-sync.sh` | Triggers wallust to regenerate colors for all apps |
| `lockscreen.sh` | Lock screen wrapper |
| `kb-layout.sh` | Keyboard layout indicator for Waybar |
| `clipboard.sh` | Clipboard history viewer |
| `mediactl` | Volume/brightness/media key handler |
| `keybinds-view.sh` | Interactive keybind reference |
| `keybinds-manager.sh` | Add/edit/remove keybinds |

### Daemons (compiled from C)

| Daemon | Purpose |
|--------|---------|
| `kbind-daemon` | Evdev key rebinding for keys niri can't capture |
| `cursor-speeder` | Enlarges cursor on fast mouse movement |
| `keycap` | Captures evdev combos → readable format |

### Themes

Color scheme is driven by **wallust** — change wallpaper → colors update across all apps automatically.

GTK themes (installed separately): Colloid-Dark, Rose-Pine (moon), Osaka (solarized).

## Keybinds

See [KEYBINDS.md](KEYBINDS.md) for full reference. MOD = Super/Windows key.

| Binding | Action |
|---------|--------|
| `MOD + Return` | Terminal |
| `MOD + Space` | Rofi launcher |
| `MOD + A` | Vicinae toggle |
| `MOD + H/J/K/L` | Focus window |
| `MOD + Shift + H/J/K/L` | Move window |
| `MOD + T` | Toggle floating |
| `MOD + F` | Fullscreen |
| `MOD + 1-9` | Switch workspace |

## Website

The project has a landing page at **[niri-dots.pages.dev](https://niri-dots.pages.dev)** — built from `docs/index.html` and auto-deployed by GitHub Actions.

## License

MIT
