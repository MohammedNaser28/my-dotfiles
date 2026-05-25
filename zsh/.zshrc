# Source sevens-dots configuration
source ${HOME}/.config/zsh/config.zsh
export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH
# Prevent zsh-newuser-install wizard
zstyle :compinstall filename '/home/mohammed-niri/.zshrc'
