#!/usr/bin/env bash

# Color codes for clean scannable terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOT_DIR="$PROJECT_DIR/dot"

# Exit if input mode invalid
MODE="$1"
if [[ "$MODE" != "stow" && "$MODE" != "unstow" ]]; then
    echo -e "${RED}Usage: $0 [stow|unstow]${NC}" >&2
    exit 1
fi

# Exit if directory not found
if [ ! -d "$DOT_DIR" ]; then
    echo -e "${RED}Error: 'dot' directory not found at $DOT_DIR${NC}" >&2
    exit 1
fi

echo -e "${BLUE}------------------------------------------${NC}"
echo -e " Mode: [${GREEN}${MODE^^}${NC}]"
echo -e " Target: $HOME"
echo -e "${BLUE}------------------------------------------${NC}"

# Stow all direct folder
cd "$DOT_DIR" || exit 1
for package in */; do
    package="${package%/}"
    [ ! -d "$package" ] && continue

    echo -e "\n${BLUE}[*] Package:${NC} ${GREEN}$package${NC}"
    echo -e "${BLUE}------------------------------------------${NC}"

    if [ "$MODE" == "stow" ]; then
        # -R: Restow (re-links)
        # --adopt: If a file exists in $HOME, move it into your dotfile repo
        #          and replace the original with a symlink.
        stow -v -R --adopt -t "$HOME" "$package"
        
    elif [ "$MODE" == "unstow" ]; then
        stow -v -D -t "$HOME" "$package"
    fi
done

echo -e "\n${BLUE}------------------------------------------${NC}"
echo -e "${GREEN}[+] Sync complete!${NC}"
echo -e "${BLUE}------------------------------------------${NC}"