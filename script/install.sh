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
mambogen "mamboheritage" "Hyprland" "$THEME_HYPRLAND"

THEME_WAYBAR="$PROJECT_DIR/dot/waybar/.config/waybar"
mkdir -p "$THEME_WAYBAR"
mambogen "mamboheritage" "Waybar" "$THEME_WAYBAR"

# Install code oss extensions
CODE_OSS_SCRIPT="$SCRIPT_DIR/code-oss/install_extensions.sh"
if [ -f "$CODE_OSS_SCRIPT" ]; then
    echo -e "${BLUE}[*] Executing extension installer...${NC}"
    chmod +x "$CODE_OSS_SCRIPT"
    bash "$CODE_OSS_SCRIPT"
else
    echo -e "${YELLOW}[!] Warning: Code OSS installation script not found${NC}" >&2
fi

echo -e "${BLUE}------------------------------------------${NC}"
echo -e " Tool:   ${GREEN}MamboDot${NC}"
echo -e " Source: $PROJECT_DIR"
echo -e "${GREEN}[+] Installation complete!${NC}"
echo -e "${BLUE}------------------------------------------${NC}"