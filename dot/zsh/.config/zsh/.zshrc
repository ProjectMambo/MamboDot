# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set Fcitx5 as the input method
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx5

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

# Custom Teleport (tp) Directory Bookmarker
tp() {
    # Color codes for clean scannable terminal output
    local GREEN='\033[0;32m'
    local RED='\033[0;31m'
    local BLUE='\033[0;34m'
    local YELLOW='\033[0;33m'
    local NC='\033[0m' # No Color

    # Dynamically locate the physical path of this running .zshrc file
    local current_rc="${(%):-%x}"
    local rc_dir=$(dirname "$(readlink -f "$current_rc")")
    local bookmark_file="$rc_dir/tp_bookmarks.txt"
    
    # Ensure storage file exists silently
    touch "$bookmark_file"

    # CASE 1: Add a new bookmark (tp -a name path)
    if [[ "$1" == "-a" ]]; then
        if [[ -z "$2" || -z "$3" ]]; then
            echo -e "${RED}[!] Error: Usage is 'tp -a <name> <path>'${NC}" >&2
            return 1
        fi
        
        local name="${2:l}"
        local absolute_path=$(realpath "$3")
        
        # Filter out old entries
        local temp_file=$(mktemp)
        awk -v n="$name" '$1 != n' "$bookmark_file" > "$temp_file"
        mv "$temp_file" "$bookmark_file"
        
        # Append new entry row
        echo "$name $absolute_path" >> "$bookmark_file"
        echo -e "${GREEN}[+] Teleport bound:${NC} $name ➔ $absolute_path"
        return 0
    fi

    # CASE 2: Delete an existing bookmark (tp -d name)
    if [[ "$1" == "-d" ]]; then
        if [[ -z "$2" ]]; then
            echo -e "${RED}[!] Error: Usage is 'tp -d <name>'${NC}" >&2
            return 1
        fi

        local name="${2:l}"

        if ! grep -q "^$name " "$bookmark_file"; then
            echo -e "${YELLOW}[!] Warning: Teleport point '$name' does not exist.${NC}" >&2
            return 1
        fi

        local temp_file=$(mktemp)
        awk -v n="$name" '$1 != n' "$bookmark_file" > "$temp_file"
        mv "$temp_file" "$bookmark_file"
        
        echo -e "${GREEN}[+] Teleport point '$name' deleted.${NC}"
        return 0
    fi

    # CASE 3: List all current added shortcuts (tp -l)
    if [[ "$1" == "-l" ]]; then
        echo -e "${BLUE}------------------------------------------${NC}"
        echo -e " ${BLUE}[*] Active Teleport Points${NC}"
        echo -e "${BLUE}------------------------------------------${NC}"
        if [[ ! -s "$bookmark_file" ]]; then
            echo "  (No bookmarks saved yet)"
        else
            awk -v g="$GREEN" -v n="$NC" '{printf "  " g "%-12s" n " ➔  %s\n", $1, $2}' "$bookmark_file"
        fi
        echo -e "${BLUE}------------------------------------------${NC}"
        return 0
    fi

    # CASE 4: Standard behavior (tp name) -> Jump to directory
    if [[ -n "$1" ]]; then
        local target="${1:l}"
        
        # Fallback direct cd if path exists
        if [[ -d "$1" ]]; then
            cd "$1"
            return 0
        fi
        
        local target_dir=$(awk -v name="$target" '$1 == name {print $2}' "$bookmark_file")
        
        if [[ -n "$target_dir" ]]; then
            if [[ -d "$target_dir" ]]; then
                cd "$target_dir"
                return 0
            else
                echo -e "${RED}[!] Error: Target path '$target_dir' no longer exists!${NC}" >&2
                return 1
            fi
        else
            echo -e "${RED}[!] Error: Teleport point '$target' not found.${NC}" >&2
            return 1
        fi
    else
        # Help Menu
        echo -e "${BLUE}------------------------------------------${NC}"
        echo -e " Usage:${NC}"
        echo -e "  tp <name>          - Jump to bookmark"
        echo -e "  tp <path>          - Fallback direct cd (e.g. tp ~)"
        echo -e "  tp -a <name> <dir> - Add teleport point"
        echo -e "  tp -d <name>       - Delete teleport point"
        echo -e "  tp -l              - List active points"
        echo -e "${BLUE}------------------------------------------${NC}"
    fi
}