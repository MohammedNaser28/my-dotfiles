# Source sevens-dots configuration
source ${HOME}/.config/zsh/config.zsh
export LD_LIBRARY_PATH=/opt/cuda/lib64:$LD_LIBRARY_PATH
# Prevent zsh-newuser-install wizard
zstyle :compinstall filename "${HOME}/.zshrc"

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

path=('/home/mohammed-niri/.juliaup/bin' $path)
export PATH
# Tab completion for juliaup and julia channel selection
[ -f "/home/mohammed-niri/.julia/juliaup/completions/zsh.zsh" ] && source "/home/mohammed-niri/.julia/juliaup/completions/zsh.zsh"

# <<< juliaup initialize <<<
