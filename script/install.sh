#!/usr/bin/env bash

# Color codes for clean scannable terminal output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Get the absolute path
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Generate themes
THEME_HYPRLAND="$PROJECT_DIR/dot/hypr/.config/hypr/themes"
mkdir -p "$THEME_HYPRLAND"
mbcolor mamboorchelight hyprlua -o "$THEME_HYPRLAND"
mbcolor mamboorchedark hyprlua -o "$THEME_HYPRLAND"
mbcolor mambooutbacklight hyprlua -o "$THEME_HYPRLAND"
mbcolor mambooutbackdark hyprlua -o "$THEME_HYPRLAND"
mbcolor mamboorchelight hyprlang -o "$THEME_HYPRLAND"
mbcolor mamboorchedark hyprlang -o "$THEME_HYPRLAND"
mbcolor mambooutbacklight hyprlang -o "$THEME_HYPRLAND"
mbcolor mambooutbackdark hyprlang -o "$THEME_HYPRLAND"

THEME_WAYBAR="$PROJECT_DIR/dot/waybar/.config/waybar"
mkdir -p "$THEME_WAYBAR"
mbcolor mamboorchelight waybar -o "$THEME_WAYBAR"
mbcolor mamboorchedark waybar -o "$THEME_WAYBAR"
mbcolor mambooutbacklight waybar -o "$THEME_WAYBAR"
mbcolor mambooutbackdark waybar -o "$THEME_WAYBAR"

# Install code oss extensions
CODE_OSS_SCRIPT="$SCRIPT_DIR/code-oss/install_extensions.sh"
if [ -f "$CODE_OSS_SCRIPT" ]; then
    echo -e "${BLUE}[*] Executing extension installer...${NC}"
    chmod +x "$CODE_OSS_SCRIPT"
    bash "$CODE_OSS_SCRIPT"
else
    echo -e "${YELLOW}[!] Warning: Code OSS installation script not found${NC}" >&2
fi

# fcitx5 -d
# fcitx5-configtool
# add language

if command -v mbfont &> /dev/null; then
    FONT_DIR=~/.local/share/fonts/mambofont
    mkdir -p "$FONT_DIR"
    mbfont compile 0.0.0 -o "$FONT_DIR" -t ttf
fi
fc-cache -fv
fc-list | grep -i "mambofont"

update-desktop-database ~/.local/share/applications
kbuildsycoca6 --noincremental

source ~/.zshenv
hyprctl reload

echo -e "${BLUE}------------------------------------------${NC}"
echo -e " Tool:   ${GREEN}MamboDot${NC}"
echo -e " Source: $PROJECT_DIR"
echo -e "${GREEN}[+] Installation complete!${NC}"
echo -e "${BLUE}------------------------------------------${NC}"