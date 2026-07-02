#!/usr/bin/env bash

# Color codes for clean scannable terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJECT_DIR="$(realpath "$SCRIPT_DIR/../../")"
EXTENSIONS_FILE="$PROJECT_DIR/dot/code-oss/.config/Code - OSS/User/extensions.txt"

# Install extensions from tracked list
if [ -f "$EXTENSIONS_FILE" ]; then
    echo -e "${BLUE}------------------------------------------${NC}"
    echo -e "${BLUE}[*] File:${NC} $EXTENSIONS_FILE"
    echo -e "${BLUE}------------------------------------------${NC}"
    
    while IFS= read -r extension || [ -n "$extension" ]; do
        # Skip empty lines or comments
        [[ "$extension" =~ ^[[:space:]]*# ]] && continue
        [ -z "$extension" ] && continue
        
        echo -e " -> Installing: ${GREEN}$extension${NC}"
        code-oss --install-extension "$extension" > /dev/null 2>&1
    done < "$EXTENSIONS_FILE"
else
    echo -e "${RED}[!] Error: extensions.txt not found${NC}" >&2
    exit 1
fi

echo -e "${BLUE}------------------------------------------${NC}"
echo -e "${GREEN}[+] Extensions sync complete!${NC}"
echo -e "${BLUE}------------------------------------------${NC}"