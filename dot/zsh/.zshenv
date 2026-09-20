export ZDOTDIR=$HOME/.config/zsh

typeset -U path PATH
path=(
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
    "$HOME/.cargo/bin"
    "$HOME/.local/share/JetBrains/Toolbox/scripts"
    $path
)
export PATH
