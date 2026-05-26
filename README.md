# Dotfiles

Niri WM dotfiles for Arch Linux. Fork of [saatvik333/niri-dotfiles](https://github.com/saatvik333/niri-dotfiles).

## Quick Install (Arch Linux)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/MohammedNaser28/my-dotfiles/main/install.sh)
```

Runs the full install script: installs packages, themes, builds tools, symlinks configs, and sets up wallpapers.

## Manual Setup

```bash
git clone https://github.com/MohammedNaser28/my-dotfiles ~/.dotfiles-sevens
cd ~/.dotfiles-sevens
./stow.sh
```

Requires: `stow`, `git-lfs`, `gcc` (for evdev tools), `cargo` (for niri-display-manager).

# Tracked Packages

`.config/` applications:

- **WM**: Niri, Hyprland (standalone)
- **Bar**: Waybar
- **Terminals**: Alacritty, Kitty
- **Shell**: Zsh, Fish
- **Notifications**: Mako
- **Launcher**: Rofi
- **Locker**: GTKLock
- **Editor**: Neovim (LazyVim)
- **File manager**: Yazi
- **PDF**: Zathura
- **Info**: Fastfetch
- **Theme**: Wallust, Starship
- **Theming**: GTK 3/4 (colors & CSS), wallust templates
- **System**: btop, systemd user services
- **AI**: OpenCode config
- **Input**: Vicinae (app launcher)

## Themes

[Wallust](https://codeberg.org/explosion-mental/wallust) is used for the theming using it's color palettes and it's palette generation using wallpaper.

| Theme      | GTK Theme                                                                                   | Icon Theme                                                                           |
| ---------- | ------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| Catppuccin | [Colloid (Light/Dark) Catppuccin](https://github.com/vinceliuice/Colloid-gtk-theme)         | [Colloid Catppuccin (Light/Dark)](https://github.com/vinceliuice/Colloid-icon-theme) |
| Everforest | [Colloid (Light/Dark) Everforest](https://github.com/vinceliuice/Colloid-gtk-theme)         | [Colloid Everforest (Light/Dark)](https://github.com/vinceliuice/Colloid-icon-theme) |
| Gruvbox    | [Colloid (Light/Dark) Gruvbox](https://github.com/vinceliuice/Colloid-gtk-theme)            | [Colloid Gruvbox (Light/Dark)](https://github.com/vinceliuice/Colloid-icon-theme)    |
| Nord       | [Colloid (Light/Dark) Nord](https://github.com/vinceliuice/Colloid-gtk-theme)               | [Colloid Nord (Light/Dark)](https://github.com/vinceliuice/Colloid-icon-theme)       |
| Rosé Pine  | [Rose Pine GTK Theme (Light/Dark)](https://github.com/Fausto-Korpsvart/Rose-Pine-GTK-Theme) | [Colloid Catppuccin (Light/Dark)](https://github.com/vinceliuice/Colloid-icon-theme) |
| Dracula    | [Colloid (Light/Dark) Dracula](https://github.com/vinceliuice/Colloid-gtk-theme)            | [Colloid Dracula (Light/Dark)](https://github.com/vinceliuice/Colloid-icon-theme)    |
| Material   | [Colloid Grey (Light/Dark)](https://github.com/vinceliuice/Colloid-gtk-theme)               | [Colloid (Light/Dark)](https://github.com/vinceliuice/Colloid-icon-theme)            |
| Solarized  | [Osaka GTK Theme (Light/Dark)](https://github.com/Fausto-Korpsvart/Osaka-GTK-Theme)         | [Colloid Everforest (Light/Dark)](https://github.com/vinceliuice/Colloid-icon-theme) |

Thanks to [vinceliuice](https://github.com/vinceliuice) and [Fausto-Korpsvart](https://github.com/Fausto-Korpsvart) for providing awesome GTK themes.

## Keybinds

See [KEYBINDS.md](./KEYBINDS.md) for the full keybind reference.

---
