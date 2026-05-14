# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set Neovim as the default editor for everything
export EDITOR='nvim'
export VISUAL='nvim'

# Theme
ZSH_THEME="robbyrussell"

# Plugins (Add suggestions and highlighting here)
# NOTE: You need to download these two (see step 2 below)
plugins=(
    git 
    zsh-autosuggestions 
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# --- Custom Settings ---

# Alias Neovim to shorter commands
alias v='nvim'
alias vi='nvim'

# Case-insensitive tab completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# Use arrow keys in the tab menu
zstyle ':completion:*' menu select