# dotfiles-sevens

Niri compositor dotfiles for Arch Linux, forked from
[saatvik333/niri-dotfiles](https://github.com/saatvik333/niri-dotfiles).

## Architecture

Dotfiles are managed with **GNU Stow**. Each application lives in its own
directory with the full `$HOME`-relative path:

```
~/.dotfiles-sevens/waybar/.config/waybar/config.jsonc
  └── stows to ──> ~/.config/waybar/config.jsonc (symlink)
```

Side projects integrate by **hardlinking** their config files into the stow
tree so git tracks them alongside the main dotfiles.

## Directory map

```
~/.dotfiles-sevens/
├── install.sh              Full automated installer (Arch only)
├── stow.sh                 GNU Stow symlink setup
│
├── alacritty/              Terminal emulator
├── btop/                   System monitor
├── fastfetch/              System fetch tool
├── fish/                   Fish shell (default)
├── git/                    Global .gitconfig
├── gtk/                    GTK3 settings + Colloid theme
├── gtklock/                Lock screen (11 themes)
├── hypr/                   Hyprland stub (compat)
├── kitty/                  Kitty terminal (fallback)
├── mako/                   Notification daemon
├── niri/                   Main compositor config (431 lines)
├── nvim/                   LazyVim-based editor
├── opencode/               OpenCode AI assistant config
├── pavucontrol/            Audio panel presets
├── rofi/                   Application launcher + powermenu
├── scripts/                ~40 helpers (see below)
├── starship/               Shell prompt
├── systemd/                User service units
├── vicinae/                App launcher
├── wallpapers/             Git-LFS submodule (~170 images)
├── wallust/                Theme engine + 13 templates
├── waybar/                 Vertical status bar
├── yazi/                   File manager
├── zathura/                PDF viewer
└── zsh/                    Zsh config (fallback shell)
```

## Key components

### Waybar (vertical, 72px wide)

Three sections in a left sidebar:

| Section | Modules |
|---------|---------|
| **Left** (top) | Cachy, clock, CPU, memory, disk, temperature, GPU, keyboard layout |
| **Center** (middle) | Prayer times, MPRIS (media), Niri workspaces, privacy indicator |
| **Right** (bottom) | Extras tray, network, bluetooth, microphone, audio slider, brightness, battery, powermenu |

Modules are defined in `modules.json` (279 lines) using Nerd Font icons.
Style uses `@import "./colors.css"` — 16 `@define-color` variables generated
by wallust from the current wallpaper.

### Wallust theme engine

Wallpaper → color extraction pipeline:

```
bgselector.sh  ──>  picks wallpaper  ──>  theme-sync.sh
                                                │
                          ┌─────────────────────┤
                          ▼                     ▼
                     wallust               GTK theme
                     (13 templates)         + icon theme
                          │                     │
                          ▼                     ▼
                   alacritty, kitty,        Colloid-Dark-Nord
                   waybar, mako, rofi,      (mapped from wallpaper path)
                   nvim, zathura, gtklock,
                   vscode, vicinae, dunst
```

`wallust.toml` uses `fastresize` backend with `lab` color space and
`harddark` palette. Templates live in `wallust/templates/` and use
`{{mustache}}` interpolation for the 16 extracted colors.

### C daemons (compiled locally)

| Daemon | Source | Purpose |
|--------|--------|---------|
| `hot-corner` | `scripts/hot-corner.c` | GTK3 layer-shell — configurable hotspot zones |
| `kbind-daemon` | `scripts/kbind-daemon.c` | Evdev key rebinding for ASUS Fn keys niri can't capture |
| `cursor-speeder` | `scripts/cursor-speeder.c` | Enlarges cursor on fast mouse movement |
| `keycap` | `scripts/keycap.c` | Captures evdev combos → "MOD + Shift + A" format |

Compiled by `scripts/build-daemons.sh`, run as systemd user services.

### Scripts directory

| Script | Purpose |
|--------|---------|
| `bgselector.sh` | Wallpaper picker (rofi + thumbnails + multi-monitor) |
| `theme-sync.sh` | Full theme sync (755 lines) — wallpaper → GTK/icons/wallust/VSCode/niri/mako/vicinae |
| `gtklock-theme.sh` | Lock screen theme selector (rofi grid, 12 themes) |
| `palette.sh` | Palette manager via vicinae dmenu |
| `keybinds-manager.sh` | Add/edit/remove/check keybinds |
| `keybinds-view.sh` | Search keybinds with exec-on-select |
| `media-control.sh` | Volume/brightness/media keys |
| `gpu-stats.sh` | NVIDIA GPU stats JSON for Waybar |
| `kb-layout.sh` | Keyboard layout indicator JSON |
| `curator.py` | Flask web UI for wallpaper collection management |

### Side-project integration

External projects hook into the dotfiles by **hardlinking** their config files
into the stow tree. Example with `muslim-dotfiles`:

```
# Waybar configs are hardlinked so changes in either place are shared:
~/.dotfiles-sevens/waybar/.config/waybar/
├── config.jsonc       <── hardlinked with muslim-dotfiles/waybar/...
├── modules.json       <── modified in-place to add custom/prayer module
└── style.css          <── modified in-place to add prayer CSS rules
```

This means:
- Git tracks the changes from the side project in the main dotfiles repo
- The side project can stay in its own repo with its own history
- Changes made while tweaking the side project appear in `git status` here

### Systemd user services

```
~/.config/systemd/user/
├── hot-corner.service          # Enabled by default
├── kbind-daemon.service        # Enabled by default
├── low-battery-notify.service  # Enabled by default
├── gtklock.service             # Manual trigger only
└── default.target.wants/       # Symlinks to enabled services
```

Third-party daemons (e.g. zekr-daemon from muslim-dotfiles) install their
own service unit to the same directory.

## Quick start

### Fresh install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MohammedNaser28/my-dotfiles/main/install.sh)
```

### Manual setup

```bash
git clone --recursive git@github.com:MohammedNaser28/my-dotfiles.git ~/.dotfiles-sevens
cd ~/.dotfiles-sevens
./stow.sh
```

`stow.sh` handles: submodule init, LFS pull, symlink creation, and daemon
compilation.

### Adding a new app config

```bash
cd ~/.dotfiles-sevens
mkdir -p myapp/.config/myapp
cp ~/.config/myapp/config.toml myapp/.config/myapp/config.toml
stow -d "$PWD" -t "$HOME" myapp
git add myapp && git commit -m "Add myapp config"
```

## Keybinds

See [KEYBINDS.md](KEYBINDS.md) for the full 463-entry keybind database
covering: window management, workspace switching, media, screenshots,
clipboard, display, color picker, and more.

## License

MIT
