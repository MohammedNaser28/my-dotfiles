# Dotfiles

Fork of [saatvik333/niri-dotfiles](https://github.com/saatvik333/niri-dotfiles) restructured for **GNU stow** symlink management.

**Upstream** is preserved at `git@github.com:saatvik333/niri-dotfiles.git` for pulling updates.

---

## Contents

- [Tracked Packages](#tracked-packages)
- [Themes](#themes)
- [Keybinds](#keybinds)
  - [System & Shortcuts](#system--shortcuts)
  - [Applications](#applications)
  - [Media Controls](#media-controls)
  - [Window Management](#window-management)
  - [Workspace Management](#workspace-management)
  - [Monitor Management](#monitor-management)
  - [Layout Controls](#layout-controls)
  - [Window Modes](#window-modes)
  - [Utilities](#utilities)

## Usage

### Deploy on a new machine

Requires [GNU stow](https://www.gnu.org/software/stow/):

```bash
sudo pacman -S stow
git clone <your-fork-url> ~/.dotfiles
cd ~/.dotfiles
./stow.sh
```

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
