# Dotfiles Map

Auto-generated reference for the general-clean branch.

## Stow packages

### `alacritty`
- **Files**: `.config/alacritty/alacritty.toml`, `.config/alacritty/colors.toml`
- **Purpose**: Terminal emulator config (JetBrainsMono Nerd Font 12pt, 90% opacity, no decorations, wallust colors)

### `btop`
- **Files**: `.config/btop/btop.conf`
- **Purpose**: System monitor presets

### `fastfetch`
- **Files**: `.config/fastfetch/config.jsonc`, `.config/fastfetch/logo.txt`
- **Purpose**: System fetch with custom Arch ASCII logo

### `fish`
- **Files**: `.config/fish/config.fish`, `.config/fish/fish_variables`
- **Purpose**: Fish shell — Starship prompt, vim bindings, eza aliases, zoxide

### `git`
- **Files**: `.gitconfig`
- **Purpose**: Global git config (update with your name/email)

### `gtk`
- **Files**: `.config/gtk-3.0/settings.ini`, `.config/gtk-3.0/colors.css`, `.config/gtk-4.0/settings.ini`, `.config/gtk-4.0/colors.css`
- **Purpose**: GTK theme settings + wallust colors

### `gtklock`
- **Files**: `.config/gtklock/config.ini`, `.config/gtklock/wallust.css`, themes
- **Purpose**: Lock screen with wallust theme support

### `kbind-daemon`
- **Files**: `.config/systemd/user/kbind-daemon.service`
- **Purpose**: systemd unit for evdev key rebinding daemon

### `kitty`
- **Files**: `.config/kitty/kitty.conf`, `.config/kitty/colors.conf`
- **Purpose**: Alternative terminal emulator

### `mako`
- **Files**: `.config/mako/config`
- **Purpose**: Notification daemon config (wallust-generated)

### `niri`
- **Files**: `.config/niri/config.kdl`
- **Purpose**: Niri window manager config (primary WM)
- **Key settings**: US/Arabic keyboard, Caps→Escape, waybar/awww/vicinae auto-start, cursor-speeder

### `nvim`
- **Files**: `.config/nvim/` (full LazyVim config)
- **Purpose**: Neovim editor

### `pavucontrol`
- **Files**: `.config/pavucontrol.ini`
- **Purpose**: PulseAudio volume control saved state

### `rofi`
- **Files**: `.config/rofi/config.rasi`, `.config/rofi/colors/wallust.rasi`, `.config/rofi/bgselector/`, `.config/rofi/powermenu/`
- **Purpose**: App launcher + powermenu + bg selector UI

### `scripts`
- **Managed by**: `stow.sh` (creates symlinks in `~/.local/bin/` and `~/.config/scripts/`)
- **Key scripts**: bgselector.sh, theme-sync.sh, lockscreen.sh, clipboard.sh, kb-layout.sh, mediactl, keybinds-view.sh, keybinds-manager.sh, keycapture.sh

### `starship`
- **Files**: `.config/starship/starship.toml`
- **Purpose**: Cross-shell prompt (username, hostname, directory, git, 25+ language modules)

### `systemd`
- **Files**: `.config/systemd/user/gtklock.service`, `.config/systemd/user/kbind-daemon.service`
- **Purpose**: User systemd services

### `vicinae`
- **Files**: `.config/vicinae/settings.json`, `.config/vicinae/vicinae.json`
- **Purpose**: App launcher (web-search style)

### `wallpapers` (git submodule + LFS)
- **Files**: Wallpaper collection organized by theme (Catppuccin, Dracula, Everforest, Gruvbox, Material, Nord, Osaka, Rose-Pine)
- **Purpose**: Wallpaper images (~170, ~34GB via LFS)

### `wallust`
- **Files**: `.config/wallust/wallust.toml`, 14 templates
- **Purpose**: Color scheme generator — regenerates colors from wallpaper for all apps

### `waybar`
- **Files**: `.config/waybar/config.jsonc`, `.config/waybar/modules.json`, `.config/waybar/style.css`, `.config/waybar/colors.css`
- **Purpose**: Vertical status bar on left side

### `yazi`
- **Files**: `.config/yazi/yazi.toml`
- **Purpose**: Terminal file manager

### `zathura`
- **Files**: `.config/zathura/zathurarc`
- **Purpose**: PDF reader (wallust-colored)

### `zsh`
- **Files**: `.zshrc`, `.zshenv`, `.config/zsh/config.zsh`
- **Purpose**: Zsh shell config (Starship, zoxide, atuin, fzf, eza aliases)
