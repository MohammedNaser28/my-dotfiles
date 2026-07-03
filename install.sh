#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/MohammedNaser28/my-dotfiles.git"
DOTDIR="${HOME}/.dotfiles-sevens"

PACMAN_PACKAGES=(
  niri waybar fish fastfetch mako alacritty kitty starship neovim yazi
  zathura zathura-pdf-mupdf ttf-jetbrains-mono-nerd
  qt5-wayland qt6-wayland polkit-gnome ffmpeg imagemagick unzip jq
  gtklock rofi curl libnotify brightnessctl playerctl acpi
  git-lfs wl-clipboard cliphist stow
)

info()  { echo -e "\033[0;34m==>\033[0m $*"; }
msg()   { echo -e "\033[0;32m==>\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARNING]\033[0m $*"; }
fatal() { echo -e "\033[0;31m[ERROR]\033[0m $*" >&2; exit 1; }

usage() {
  cat <<EOF
Usage: ${0##*/} [OPTIONS]

Install niri dotfiles and dependencies.

OPTIONS:
  -h, --help      Show this help
  -p, --packages  Install required packages (Arch pacman)
  -y, --yay       Also install AUR packages (vicinae-bin, wallust, etc.)

EOF
  exit 0
}

INSTALL_PACKAGES=false
INSTALL_AUR=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage ;;
    -p|--packages) INSTALL_PACKAGES=true ;;
    -y|--yay) INSTALL_AUR=true ;;
    *) fatal "Unknown option: $1" ;;
  esac
  shift
done

info "Dotfiles installer for niri Wayland compositor"
echo ""

if [[ "${INSTALL_PACKAGES}" == "true" ]]; then
  if ! command -v pacman &>/dev/null; then
    fatal "pacman not found. This script currently supports Arch-based distributions."
  fi

  info "Installing packages..."
  sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"

  if [[ "${INSTALL_AUR}" == "true" ]]; then
    if ! command -v yay &>/dev/null; then
      warn "yay not found. Installing yay..."
      sudo pacman -S --needed --noconfirm git base-devel curl
      git clone --depth=1 https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
      (cd /tmp/yay-bin && makepkg -si --noconfirm)
      rm -rf /tmp/yay-bin
    fi

    AUR_PACKAGES=(vicinae-bin wallust dust eza niri-switch ttf-nerd-fonts-symbols pavucontrol thunar minizip awww-git)
    yay -S --needed --noconfirm "${AUR_PACKAGES[@]}"
  fi

  msg "Packages installed."
fi

if [[ ! -d "${DOTDIR}" ]]; then
  info "Cloning dotfiles..."
  git clone --recursive "${REPO_URL}" "${DOTDIR}"
else
  info "Dotfiles directory exists. Pulling latest..."
  git -C "${DOTDIR}" pull --rebase --autostash
  git -C "${DOTDIR}" submodule update --init --recursive
fi

info "Running stow.sh to link configs..."
cd "${DOTDIR}"
bash stow.sh

msg "Done! Log out and log back in to start using niri."
