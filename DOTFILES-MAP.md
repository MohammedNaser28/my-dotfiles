# Dotfiles Map

> Auto-generated reference. Update this file when repos change.
> Last updated: 2026-05-28
> 
> **AGENT NOTE**: This document is the authoritative map of Mohammed's dotfiles.
> For any edit task, consult this file FIRST. Do **NOT** re-read source files
> from disk unless the user says something changed. When you edit a file,
> note which repo it lives in and whether stow needs to be re-run.

## Repo overview

| Repo | Path | Manager | Purpose |
|------|------|---------|---------|
| **dotfiles-sevens** | `~/.dotfiles-sevens` | GNU Stow (`stow.sh`) | Primary Niri/Wayland desktop config |
| **muslim-dotfiles** | `~/projects/muslim-dotfiles` | Manual + `install.sh` | Islamic companion tools (prayer-bar, zekr-daemon) |

---

## Stow packages (dotfiles-sevens)

### Package: `alacritty`
- **Stow target**: `$HOME`
- **Files managed**: `.config/alacritty/alacritty.toml`, `.config/alacritty/colors.toml`
- **Symlinks**: `~/.config/alacritty/alacritty.toml`, `~/.config/alacritty/colors.toml`
- **Purpose**: Terminal emulator config (Catppuccin Mocha theme via wallust)
- **Key settings**: JetBrainsMono Nerd Font 12pt, 90% opacity, no window decorations, imports `colors.toml`

### Package: `btop`
- **Stow target**: `$HOME`
- **Files managed**: `.config/btop/btop.conf`
- **Symlinks**: `~/.config/btop/btop.conf`
- **Purpose**: System monitor presets and theme colors

### Package: `fastfetch`
- **Stow target**: `$HOME`
- **Files managed**: `.config/fastfetch/config.jsonc`, `.config/fastfetch/logo.txt`
- **Symlinks**: `~/.config/fastfetch/config.jsonc`, `~/.config/fastfetch/logo.txt`
- **Purpose**: Neofetch replacement with custom Arch ASCII logo

### Package: `fish`
- **Stow target**: `$HOME`
- **Files managed**: `.config/fish/config.fish`, `.config/fish/fish_variables`
- **Symlinks**: `~/.config/fish/config.fish`, `~/.config/fish/fish_variables`
- **Purpose**: Fish shell config — interactive shell (alternative to Zsh)
- **Key settings**: Starship prompt, vim key bindings, `eza` aliases, `$GOPATH` + `$CARGO_HOME` in PATH, `zoxide` cd

### Package: `git`
- **Stow target**: `$HOME`
- **Files managed**: `.gitconfig`
- **Symlinks**: `~/.gitconfig`
- **Purpose**: Git identity and LFS config
- **Key settings**: User: Mohammed Naser, email: MohammedNaser2826@gmail.com, LFS enabled

### Package: `gtk`
- **Stow target**: `$HOME`
- **Files managed**: `.config/gtk-3.0/settings.ini`, `.config/gtk-3.0/colors.css`, `.config/gtk-4.0/settings.ini`, `.config/gtk-4.0/colors.css`
- **Symlinks**: all in `~/.config/gtk-*`
- **Purpose**: GTK theme settings + wallust-generated colors

### Package: `gtklock`
- **Stow target**: `$HOME`
- **Files managed**: `.config/gtklock/config.ini`, `.config/gtklock/wallust.css`, 10 theme files in `.config/gtklock/themes/*.css`
- **Symlinks**: `~/.config/gtklock/...`
- **Purpose**: Swaylock-compatible lockscreen with wallust theme support

### Package: `hypr`
- **Stow target**: `$HOME`
- **Files managed**: `.config/hypr/hyprland.conf`
- **Symlinks**: `~/.config/hypr/hyprland.conf`
- **Purpose**: Hyprland config (fallback/alternative WM; Niri is primary)
- **Key settings**: Preserved for testing — not the daily-driver WM

### Package: `kbind-daemon`
- **Stow target**: `$HOME`
- **Files managed**: `.config/systemd/user/kbind-daemon.service`
- **Symlinks**: `~/.config/systemd/user/kbind-daemon.service`
- **Purpose**: systemd unit for the keyboard-binding daemon (built from C source)

### Package: `kitty`
- **Stow target**: `$HOME`
- **Files managed**: `.config/kitty/kitty.conf`, `.config/kitty/colors.conf`
- **Symlinks**: `~/.config/kitty/kitty.conf`, `~/.config/kitty/colors.conf`
- **Purpose**: Alternative terminal emulator
- **Key settings**: JetBrainsMono Nerd Font, wallust colors

### Package: `mako`
- **Stow target**: `$HOME`
- **Files managed**: `.config/mako/config`
- **Symlinks**: `~/.config/mako/config`
- **Purpose**: Lightweight notification daemon config
- **Key settings**: Catppuccin-coloured via wallust template

### Package: `niri`
- **Stow target**: `$HOME`
- **Files managed**: `.config/niri/config.kdl`
- **Symlinks**: `~/.config/niri/config.kdl`
- **Purpose**: Niri window manager — daily driver
- **Key settings**: 1920x1080@144 + 2560x1440@60 dual monitor, US/Arabic keyboard (`grp:alt_shift_toggle`), `caps:escape`, waybar/awww/vicinae auto-start, `cursor-speeder`, touchpad natural-scroll. App launcher: `MOD+A` → vicinae, `MOD+Space` → rofi (drun).

### Package: `nvim`
- **Stow target**: `$HOME`
- **Files managed**: Full Neovim config under `.config/nvim/` (init.lua, lua/ plugins/, lazy-lock.json, etc.)
- **Symlinks**: `~/.config/nvim/...`
- **Purpose**: LazyVim-based Neovim setup with C++ snippets + templates

### Package: `opencode`
- **Stow target**: `$HOME`
- **Files managed**: `.config/opencode/opencode.json`, `opencode.jsonc`, `AGENTS.md`, `agents/*`, `commands/*`, `knowledge/projects.md`
- **Symlinks**: `~/.config/opencode/...`
- **Purpose**: OpenCode AI assistant configuration — agent definitions, commands, project context

### Package: `pavucontrol`
- **Stow target**: `$HOME`
- **Files managed**: `.config/pavucontrol.ini`
- **Symlinks**: `~/.config/pavucontrol.ini`
- **Purpose**: PulseAudio volume control saved state

### Package: `rofi`
- **Stow target**: `$HOME`
- **Files managed**: `.config/rofi/config.rasi`, `.config/rofi/colors/wallust.rasi`, `.config/rofi/bgselector/style.rasi`, `.config/rofi/powermenu/powermenu.sh`
- **Symlinks**: `~/.config/rofi/...`
- **Purpose**: Application launcher + powermenu + BG selector UI

### Package: `scripts`
- **Managed by**: Custom bash loop in `stow.sh` (lines 38-70) — **NOT** by the `stow` binary. Running `stow scripts` alone does not work; you must run `stow.sh`.
- **Creates**: Directory symlink `~/.config/scripts/` → `$DOT/scripts/` so that paths like `$HOME/.config/scripts/gpu-stats.sh` resolve
- **Also creates individual symlinks in `~/.local/bin/`**: bgselector.sh, clipboard.sh, git-cleanup.sh, gpu-stats.sh, kb-layout.sh, low-battery-notify.sh, media-control.sh, theme-sync.sh, keybinds-view.sh, keybinds-manager.sh, keycapture.sh, cache-palettes.sh, palette-view.sh, mount_games_hardisks.sh, mediactl, keybinds.json, lib/
- **Also compiles C sources** to `~/.local/bin/`: keycap, kbind-daemon, cursor-speeder, hot-corner (needs GTK)
- **External builds**: niri-display-manager (Rust, from separate repo)
- **Purpose**: Custom scripts for wallpaper management, keyboard layout, GPU stats, media control, clipboard, backups, game drive mounting, etc.

### Package: `starship`
- **Stow target**: `$HOME`
- **Files managed**: `.config/starship/starship.toml`
- **Symlinks**: `~/.config/starship/starship.toml`
- **Purpose**: Cross-shell prompt
- **Key settings**: Username + hostname + directory + git + language modules, vim-mode indicator, Nerd Font icons, 12hr time

### Package: `systemd`
- **Stow target**: `$HOME`
- **Files managed**: `.config/systemd/user/gtklock.service`, `.config/systemd/user/low-battery-notify.service`
- **Symlinks**: `~/.config/systemd/user/gtklock.service`, `~/.config/systemd/user/low-battery-notify.service`
- **Purpose**: User systemd services for lockscreen + low battery notification

### Package: `vicinae`
- **Stow target**: `$HOME`
- **Files managed**: `.config/vicinae/settings.json`, `.config/vicinae/vicinae.json`
- **Symlinks**: `~/.config/vicinae/...`
- **Purpose**: Neighbourhood network monitor (Waybar-integrated)

### Package: `wallpapers` (git submodule + LFS)
- **Stow target**: N/A — copied via `install.sh` to `~/Pictures/Wallpapers`
- **Files managed**: Catalog of JPG/PNG wallpapers organized by theme (Catppuccin, Dracula, Everforest, Gruvbox, Material, Nord, Osaka, Rose-Pine, Uncategorized)
- **Purpose**: Wallpaper collection in ~34GB of images

### Package: `wallust`
- **Stow target**: `$HOME`
- **Files managed**: `.config/wallust/wallust.toml`, 14 templates in `.config/wallust/templates/`
- **Symlinks**: `~/.config/wallust/...`
- **Purpose**: Color scheme generator (pywal successor) — regenerates colors for all tools from wallpaper
- **Templates output to**: alacritty, kitty, waybar, mako, rofi, gtk, gtklock, zathura, vicinae, vscode, neopywal, dunstrc

---

## ⚠ Wallust-managed files — do not edit directly

These files are **auto-generated** by wallust from templates.
Editing them directly will be overwritten next time wallust runs (wallpaper change or `wallust run`).

| File | Template that generates it | Package |
|------|---------------------------|---------|
| `~/.config/alacritty/colors.toml` | `wallust/templates/alacritty.toml` | alacritty |
| `~/.config/kitty/colors.conf` | `wallust/templates/kitty.conf` | kitty |
| `~/.config/waybar/colors.css` | `wallust/templates/waybar.css` | waybar |
| `~/.config/rofi/colors/wallust.rasi` | `wallust/templates/rofi.rasi` | rofi |
| `~/.config/gtk-3.0/colors.css` | `wallust/templates/gtk.css` | gtk |
| `~/.config/gtk-4.0/colors.css` | `wallust/templates/gtk.css` | gtk |
| `~/.config/gtklock/wallust.css` | `wallust/templates/gtklock` | gtklock |
| `~/.config/mako/config` | `wallust/templates/mako` | mako |
| `~/.config/zathura/zathurarc` | `wallust/templates/zathurarc` | zathura |

**Rule**: To change colors for any of the above, edit the template in
`~/.dotfiles-sevens/wallust/.config/wallust/templates/`, then run:
```
wallust run "$(cat ~/.cache/wallust/current_wallpaper)"
```
Or change wallpaper via `bgselector.sh` which triggers wallust automatically.

### Package: `waybar`
- **Stow target**: `$HOME`
- **Files managed**: `.config/waybar/config.jsonc`, `.config/waybar/modules.json`, `.config/waybar/style.css`, `.config/waybar/colors.css`
- **Symlinks**: `~/.config/waybar/...`
- **Purpose**: Vertical Waybar on left side
- **Key settings**: Vertical layout 72px wide, modules-left (clock/cpu/memory/disk/temp/gpu/kb), modules-center (prayer/mpris/workspaces/privacy), modules-right (network/bluetooth/audio/brightness/battery/powermenu)

### Package: `yazi`
- **Stow target**: `$HOME`
- **Files managed**: `.config/yazi/yazi.toml`
- **Symlinks**: `~/.config/yazi/yazi.toml`
- **Purpose**: Terminal file manager config

### Package: `zathura`
- **Stow target**: `$HOME`
- **Files managed**: `.config/zathura/zathurarc`
- **Symlinks**: `~/.config/zathura/zathurarc`
- **Purpose**: PDF reader config with wallust colors

### Package: `zsh`
- **Stow target**: `$HOME`
- **Files managed**: `.zshrc`, `.zshenv`, `.config/zsh/config.zsh`
- **Symlinks**: `~/.zshrc`, `~/.zshenv`, `~/.config/zsh/config.zsh`
- **Purpose**: Zsh shell config — alternative to Fish
- **Key settings**: Sources `config.zsh`, starship prompt, vim key bindings, atuin history, zoxide cd, fzf fuzzy finder, eza aliases, git shortcuts, extract function

---

## Muslim-dotfiles files

### `prayer-bar/prayer-bar.py`
- **Type**: standalone dotfile (copied to `~/.local/bin/prayer-bar`)
- **Integrates with**: Waybar (`custom/prayer` module in dotfiles-sevens waybar package)
- **Purpose**: Polled every 60s by Waybar, shows next prayer with countdown & tooltip of full daily schedule
- **States**: idle (>30 min, teal), soon (<=30 min, amber), urgent (<=10 min, red+pulse), active (within 20 min, green)

### `zekr-daemon/src/*.rs` (main.rs, config.rs, scheduler.rs, sampler.rs, notifier.rs, suppressor.rs, watcher.rs)
- **Type**: standalone binary (built from Rust, installed to `~/.local/bin/zekr-daemon`)
- **Integrates with**: systemd (`systemd/zekr-daemon.service`), reads `~/.cache/muslim-linux/times.json` written by prayer-bar
- **Purpose**: Background daemon firing periodic Islamic reminder notifications (random interval 30-60min, weighted morning/evening adhkar, athan-aware suppression)

### `data/azkar.json`
- **Type**: data file (copied to `~/.config/muslim-linux/azkar.json`)
- **Integrates with**: zekr-daemon (reads at runtime)
- **Purpose**: 27 adhkar from Hisn al-Muslim, weighted by category

### `data/ahadith.json`
- **Type**: data file (copied to `~/.config/muslim-linux/ahadith.json`)
- **Integrates with**: zekr-daemon (reads at runtime)
- **Purpose**: 12 sahih hadith for notification rotation

### `config/config.toml.example`
- **Type**: standalone config (copied to `~/.config/muslim-linux/config.toml`)
- **Integrates with**: Both prayer-bar and zekr-daemon
- **Purpose**: Central config for location (Cairo, Karachi method), prayer settings, zekr intervals/weights, quiet hours, notification style

### `systemd/zekr-daemon.service`
- **Type**: systemd user unit (installed to `~/.config/systemd/user/`)
- **Integrates with**: zekr-daemon binary
- **Purpose**: Keep zekr-daemon running as a background service

### `waybar/config-snippet.jsonc`
- **Type**: reference snippet (already applied to dotfiles-sevens waybar)
- **Integrates with**: `dotfiles-sevens/waybar/.config/waybar/modules.json`
- **Purpose**: Documentation — the `custom/prayer` block is already in `modules.json:272-278`

### `waybar/style-snippet.css`
- **Type**: reference snippet (already applied to dotfiles-sevens waybar)
- **Integrates with**: `dotfiles-sevens/waybar/.config/waybar/style.css`
- **Purpose**: Documentation — prayer CSS rules already in `style.css:119-149`

### `install.sh`
- **Type**: installer script
- **Purpose**: Automates building zekr-daemon, copying binaries, deploying config/data, installing systemd service

---

## Full symlink map

Every symlink `stow.sh` creates, plus the manual script symlinks:

| Source (in repo) | Symlink (in `$HOME`) | Package | Active? |
|---|---|---|---|
| `alacritty/.config/alacritty/alacritty.toml` | `~/.config/alacritty/alacritty.toml` | alacritty | Yes |
| `alacritty/.config/alacritty/colors.toml` | `~/.config/alacritty/colors.toml` | alacritty | Yes |
| `btop/.config/btop/btop.conf` | `~/.config/btop/btop.conf` | btop | Yes |
| `fastfetch/.config/fastfetch/config.jsonc` | `~/.config/fastfetch/config.jsonc` | fastfetch | Yes |
| `fastfetch/.config/fastfetch/logo.txt` | `~/.config/fastfetch/logo.txt` | fastfetch | Yes |
| `fish/.config/fish/config.fish` | `~/.config/fish/config.fish` | fish | Yes |
| `fish/.config/fish/fish_variables` | `~/.config/fish/fish_variables` | fish | Yes |
| `git/.gitconfig` | `~/.gitconfig` | git | Yes |
| `gtk/.config/gtk-3.0/settings.ini` | `~/.config/gtk-3.0/settings.ini` | gtk | Yes |
| `gtk/.config/gtk-3.0/colors.css` | `~/.config/gtk-3.0/colors.css` | gtk | Yes |
| `gtk/.config/gtk-4.0/settings.ini` | `~/.config/gtk-4.0/settings.ini` | gtk | Yes |
| `gtk/.config/gtk-4.0/colors.css` | `~/.config/gtk-4.0/colors.css` | gtk | Yes |
| `gtklock/.config/gtklock/config.ini` | `~/.config/gtklock/config.ini` | gtklock | Yes |
| `gtklock/.config/gtklock/wallust.css` | `~/.config/gtklock/wallust.css` | gtklock | Yes |
| `gtklock/.config/gtklock/themes/*.css` | `~/.config/gtklock/themes/*.css` | gtklock | Yes |
| `hypr/.config/hypr/hyprland.conf` | `~/.config/hypr/hyprland.conf` | hypr | Yes |
| `kbind-daemon/.config/systemd/user/kbind-daemon.service` | `~/.config/systemd/user/kbind-daemon.service` | kbind-daemon | Yes |
| `kitty/.config/kitty/kitty.conf` | `~/.config/kitty/kitty.conf` | kitty | Yes |
| `kitty/.config/kitty/colors.conf` | `~/.config/kitty/colors.conf` | kitty | Yes |
| `mako/.config/mako/config` | `~/.config/mako/config` | mako | Yes |
| `niri/.config/niri/config.kdl` | `~/.config/niri/config.kdl` | niri | Yes |
| `nvim/.config/nvim/init.lua` | `~/.config/nvim/init.lua` | nvim | Yes |
| `nvim/.config/nvim/lua/...` | `~/.config/nvim/lua/...` | nvim | Yes |
| `nvim/.config/nvim/lazy-lock.json` | `~/.config/nvim/lazy-lock.json` | nvim | Yes |
| `opencode/.config/opencode/opencode.json` | `~/.config/opencode/opencode.json` | opencode | Yes |
| `opencode/.config/opencode/opencode.jsonc` | `~/.config/opencode/opencode.jsonc` | opencode | Yes |
| `opencode/.config/opencode/AGENTS.md` | `~/.config/opencode/AGENTS.md` | opencode | Yes |
| `opencode/.config/opencode/agents/*` | `~/.config/opencode/agents/*` | opencode | Yes |
| `opencode/.config/opencode/commands/*` | `~/.config/opencode/commands/*` | opencode | Yes |
| `opencode/.config/opencode/knowledge/projects.md` | `~/.config/opencode/knowledge/projects.md` | opencode | Yes |
| `pavucontrol/.config/pavucontrol.ini` | `~/.config/pavucontrol.ini` | pavucontrol | Yes |
| `rofi/.config/rofi/config.rasi` | `~/.config/rofi/config.rasi` | rofi | Yes |
| `rofi/.config/rofi/colors/wallust.rasi` | `~/.config/rofi/colors/wallust.rasi` | rofi | Yes |
| `rofi/.config/rofi/bgselector/style.rasi` | `~/.config/rofi/bgselector/style.rasi` | rofi | Yes |
| `rofi/.config/rofi/powermenu/powermenu.sh` | `~/.config/rofi/powermenu/powermenu.sh` | rofi | Yes |
| `scripts/` (directory) | `~/.config/scripts/` (symlink) | scripts | Yes |
| `scripts/*.sh`, `scripts/mediactl`, etc. | `~/.local/bin/*` (symlinks) | scripts | Yes |
| `starship/.config/starship/starship.toml` | `~/.config/starship/starship.toml` | starship | Yes |
| `systemd/.config/systemd/user/gtklock.service` | `~/.config/systemd/user/gtklock.service` | systemd | Yes |
| `systemd/.config/systemd/user/low-battery-notify.service` | `~/.config/systemd/user/low-battery-notify.service` | systemd | Yes |
| `vicinae/.config/vicinae/settings.json` | `~/.config/vicinae/settings.json` | vicinae | Yes |
| `vicinae/.config/vicinae/vicinae.json` | `~/.config/vicinae/vicinae.json` | vicinae | Yes |
| `wallust/.config/wallust/wallust.toml` | `~/.config/wallust/wallust.toml` | wallust | Yes |
| `wallust/.config/wallust/templates/*` | `~/.config/wallust/templates/*` | wallust | Yes |
| `waybar/.config/waybar/config.jsonc` | `~/.config/waybar/config.jsonc` | waybar | Yes |
| `waybar/.config/waybar/modules.json` | `~/.config/waybar/modules.json` | waybar | Yes |
| `waybar/.config/waybar/style.css` | `~/.config/waybar/style.css` | waybar | Yes |
| `waybar/.config/waybar/colors.css` | `~/.config/waybar/colors.css` | waybar | Yes |
| `yazi/.config/yazi/yazi.toml` | `~/.config/yazi/yazi.toml` | yazi | Yes |
| `zathura/.config/zathura/zathurarc` | `~/.config/zathura/zathurarc` | zathura | Yes |
| `zsh/.zshrc` | `~/.zshrc` | zsh | Yes |
| `zsh/.zshenv` | `~/.zshenv` | zsh | Yes |
| `zsh/.config/zsh/config.zsh` | `~/.config/zsh/config.zsh` | zsh | Yes |

---

## Source / load chain

```
Shell login
│
├── Zsh path
│   ├── ~/.zshenv                    (zsh package — empty, placeholder)
│   └── ~/.zshrc                     (zsh package — stowed)
│       └── source ~/.config/zsh/config.zsh   (zsh package — stowed)
│           ├── starship init zsh    (→ ~/.config/starship/starship.toml)
│           ├── atuin init zsh       (shell history)
│           ├── zoxide init zsh      (smart cd, aliases cd → z)
│           ├── export PATH: ~/.local/bin, ~/Applications/depot_tools, /opt/node
│           ├── fzf key-bindings + completion
│           └── export MANPAGER (bat)
│
├── Fish path
│   └── ~/.config/fish/config.fish    (fish package — stowed)
│       ├── starship init fish        (→ ~/.config/starship/starship.toml)
│       ├── fish_vi_key_bindings
│       ├── source ~/.fish_profile    (if exists — extension point)
│       ├── set PATH: /opt/node, ~/.local/bin, ~/Applications/depot_tools
│       ├── set PATH: $GOPATH/bin, $CARGO_HOME/bin
│       └── zoxide (integrated via fish)
│
└── Muslim additions (NOT sourced by shell — run independently)
    ├── Waybar polls prayer-bar every 60s
    │   └── ~/.local/bin/prayer-bar
    │       └── reads ~/.config/muslim-linux/config.toml
    │       └── writes ~/.cache/muslim-linux/times.json
    └── systemd user service runs zekr-daemon
        └── ~/.config/systemd/user/zekr-daemon.service
            └── ~/.local/bin/zekr-daemon
                └── reads ~/.config/muslim-linux/{config.toml,azkar.json,ahadith.json}
                └── reads ~/.cache/muslim-linux/times.json (from prayer-bar)
```

---

## Quick edit guide

| I want to… | Edit this file | In repo | Notes |
|---|---|---|---|
| Add an alias (Zsh) | `zsh/.config/zsh/config.zsh` | dotfiles-sevens | Re-run `stow.sh` or manually `stow zsh` |
| Add an alias (Fish) | `fish/.config/fish/config.fish` | dotfiles-sevens | Re-run `stow.sh` or manually `stow fish` |
| Change PATH | `zsh/.config/zsh/config.zsh` or `fish/.config/fish/config.fish` | dotfiles-sevens | Both shells have separate PATH blocks |
| Add env var | `zsh/.config/zsh/config.zsh` or `fish/.config/fish/config.fish` | dotfiles-sevens | Zsh: `export VAR=val`, Fish: `set -gx VAR val` |
| Change prompt | `starship/.config/starship/starship.toml` | dotfiles-sevens | Re-stow `starship` |
| Add Git alias | `git/.gitconfig` | dotfiles-sevens | Edit directly, then `stow git` |
| Change Niri keybind | `niri/.config/niri/config.kdl` | dotfiles-sevens | Re-stow `niri` |
| Change Waybar layout | `waybar/.config/waybar/config.jsonc` | dotfiles-sevens | Re-stow `waybar` |
| Change Waybar module | `waybar/.config/waybar/modules.json` | dotfiles-sevens | Re-stow `waybar` |
| Add prayer time feature | Edit prayer-bar code in `prayer-bar/prayer-bar.py` or config in `config/config.toml.example` | muslim-dotfiles | Then re-run `install.sh` or manually copy to `~/.config/muslim-linux/` |
| Add hijri date to prompt | `prayer-bar/prayer-bar.py` (add hijri to Waybar tooltip) OR `starship/starship.toml` (custom module) | muslim-dotfiles OR dotfiles-sevens | Two approaches: Waybar tooltip or Starship custom command |
| Change zekr interval | `config/config.toml.example` → deploy to `~/.config/muslim-linux/config.toml` | muslim-dotfiles | Hot-reloads automatically in zekr-daemon |
| Add/edit adhkar | `data/azkar.json` → deploy to `~/.config/muslim-linux/azkar.json` | muslim-dotfiles | Hot-reloads automatically |
| Change GTK theme | `gtk/.config/gtk-3.0/settings.ini` and `gtk/.config/gtk-4.0/settings.ini` | dotfiles-sevens | Re-stow `gtk` |
| Change wallpaper | Run `~/.config/scripts/bgselector.sh` OR edit `wallust/.config/wallust/wallust.toml` | dotfiles-sevens | Wallust auto-generates colors for all apps |
| Rebuild daemons | Run `~/.config/scripts/build-daemons.sh` | dotfiles-sevens | Compiles C sources to `~/.local/bin/` |
| Change terminal colors | Edit the wallust template, NOT the colors file directly | dotfiles-sevens | See ⚠ Wallust-managed files section above |
| Add a new wallust template | Create file in `wallust/.config/wallust/templates/<name>` + add entry in `wallust.toml` | dotfiles-sevens | Run `wallust run` to apply |
| Add a new script to ~/.local/bin | Drop file in `scripts/` directory | dotfiles-sevens | Re-run `stow.sh` to create symlink |
| Add a new C daemon | Add source to `scripts/`, update `build-daemons.sh` | dotfiles-sevens | Run `build-daemons.sh` to compile |
| Enable adhan audio | Edit `~/.config/muslim-linux/config.toml`, set `adhan.enabled = true`, add audio file path | muslim-dotfiles | Audio file must exist; not currently wired |
| Fully integrate zekr-daemon | Run `cd ~/projects/muslim-dotfiles && ./install.sh` then `systemctl --user enable --now zekr-daemon` | muslim-dotfiles | One-time setup, see Integration Status section |
| Update location for prayer times | Edit `~/.config/muslim-linux/config.toml`, change `[location]` block | muslim-dotfiles | Prayer-bar hot-reloads on next poll (60s) |
| Change notification quiet hours | Edit `~/.config/muslim-linux/config.toml`, `[quiet_hours]` block | muslim-dotfiles | zekr-daemon hot-reloads automatically |

---

## Integration status — muslim-dotfiles

### Already wired in:

| Component | Status | Evidence |
|---|---|---|
| **prayer-bar in Waybar** | ✅ FULLY INTEGRATED | `waybar/.config/waybar/modules.json:272-278` has `custom/prayer` block pointing to `~/.local/bin/prayer-bar`. `config.jsonc:14` has `"custom/prayer"` in `modules-center`. `style.css:119-149` has all 4 prayer CSS states with pulse animation. |
| **prayer-bar binary** | ✅ DEPLOYED | Must be at `~/.local/bin/prayer-bar` (copied there by muslim-dotfiles `install.sh`). |
| **Waybar colors** | ✅ COLORS INTEGRATED | Hardcoded Catppuccin teal/amber/red/green values for prayer states in `style.css`. Not using wallust variables — these are static. |

### NOT yet connected:

| Component | What's missing | Needed action |
|---|---|---|
| **zekr-daemon binary** | No build/deploy step in dotfiles-sevens stow.sh | Run `~/projects/muslim-dotfiles/install.sh` to build and deploy. Or add a build step to `stow.sh` / `build-daemons.sh`. |
| **zekr-daemon systemd service** | No systemd unit for zekr-daemon in dotfiles-sevens | Copy `systemd/zekr-daemon.service` to `~/.config/systemd/user/`, then `systemctl --user daemon-reload && systemctl --user enable --now zekr-daemon`. |
| **muslim-linux config** | `~/.config/muslim-linux/config.toml` not managed by stow | Could add a `muslim` stow package in dotfiles-sevens, or rely on muslim-dotfiles `install.sh` to deploy it. Currently no stow package for this. |
| **muslim-linux data files** | `azkar.json` and `ahadith.json` not deployed | `install.sh` copies them, but they're not in dotfiles-sevens. They live in muslim-dotfiles repo only. |
| **prayer-bar —notify click action** | Works if `~/.local/bin/prayer-bar` exists | Already configured in `modules.json:277`. No action needed. |
| **adhan audio** | Disabled by default (`adhan.enabled = false` in config.toml) | Would need audio file + enable in config. Not currently wired. |

### What needs to be done for full integration:

1. **Run the installer**: `cd ~/projects/muslim-dotfiles && ./install.sh` — this builds zekr-daemon, deploys binaries, config, and data files.
2. **Enable zekr-daemon**: `systemctl --user daemon-reload && systemctl --user enable --now zekr-daemon`
3. **Optional**: Create a `muslim` stow package in dotfiles-sevens to manage `~/.config/muslim-linux/` via stow instead of manual copy.

