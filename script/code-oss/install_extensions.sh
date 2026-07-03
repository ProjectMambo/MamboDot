#!/usr/bin/env bash

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
PROJECT_DIR="$(realpath "$SCRIPT_DIR/../../")"
EXTENSIONS_FILE="$PROJECT_DIR/dot/code-oss/.config/Code - OSS/User/extensions.txt"

if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo -e "${RED}[!] Error: extensions.txt not found${NC}" >&2
    exit 1
fi

# Get list of installed extensions into an array
echo -e "${BLUE}[*] Fetching currently installed extensions...${NC}"
declare -A INSTALLED
while read -r ext; do
    INSTALLED["${ext,,}"]=1
done < <(code-oss --list-extensions)

echo -e "${BLUE}------------------------------------------${NC}"
echo -e "${BLUE}[*] Processing: $EXTENSIONS_FILE${NC}"
echo -e "${BLUE}------------------------------------------${NC}"

while IFS= read -r extension || [ -n "$extension" ]; do
    # Skip comments and empty lines
    [[ "$extension" =~ ^[[:space:]]*# ]] && continue
    [ -z "$extension" ] && continue
    
    # Check if extension exists in our local array (case-insensitive)
    if [[ ${INSTALLED["${extension,,}"]} ]]; then
        echo -e " -> ${YELLOW}Skipping${NC}: $extension (already installed)"
    else
        echo -e " -> Installing: ${GREEN}$extension${NC}"
        code-oss --install-extension "$extension" > /dev/null 2>&1
    fi
done < "$EXTENSIONS_FILE"

echo -e "${BLUE}------------------------------------------${NC}"
echo -e "${GREEN}[+] Extensions sync complete!${NC}"
echo -e "${BLUE}------------------------------------------${NC}" 