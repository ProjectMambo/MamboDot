#!/usr/bin/env bash

# Color codes for clean scannable terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

NUM_WORKSPACE=8 # Number of workspaces for each monitor
ACTION=$1 # Workspace action
TARGET_WORKSPACE=$2 # Target workspace id/name
CURRENT_WORKSPACE=$(hyprctl activeworkspace -j | jq '.id') # Current workspace id
TEMP_WORKSPACE=99 

# Wrap workspace id for left/right target
get_wrapped_workspace() {
    local current=$1
    local target=$2

    if [[ "$target" == "l" ]]; then
        if [[ "$current" -eq 1 ]]; then
            echo "$NUM_WORKSPACE"
        else
            echo $((current - 1))
        fi
    elif [[ "$target" == "r" ]]; then
        if [[ "$current" -eq "$NUM_WORKSPACE" ]]; then
            echo 1
        else
            echo $((current + 1))
        fi
    else
        echo "$target"
    fi
}

# Helper to swap workspace content
move_workspace_content() {
    local source=$1
    local target=$2
    
    hyprctl clients -j | jq -r ".[] | select(.workspace.id == $source) | .address" | while read -r addr; do
        hyprctl dispatch movetoworkspacesilent "$target,address:$addr"
    done
}

echo -e "${BLUE}------------------------------------------${NC}"
echo -e " Action: [${GREEN}${ACTION^^}${NC}]"
echo -e " Target: $TARGET_WORKSPACE"
echo -e "${BLUE}------------------------------------------${NC}"

# Run workspace action
case $ACTION in
    "workspace"|"movetoworkspace"|"movetoworkspacesilent")
        dest=$(get_wrapped_workspace "$CURRENT_WORKSPACE" "$TARGET_WORKSPACE")
        hyprctl dispatch "$ACTION" "$dest"
        ;;

    "togglespecialworkspace")
        hyprctl dispatch togglespecialworkspace "$TARGET_WORKSPACE"
        ;;

    "interchange")
        dest=$(get_wrapped_workspace "$CURRENT_WORKSPACE" "$TARGET_WORKSPACE")
        echo -e "${BLUE}[*] Swapping contents: ${NC}$CURRENT_WORKSPACE <-> $dest"
        move_workspace_content "$CURRENT_WORKSPACE" "$TEMP_WORKSPACE"
        move_workspace_content "$dest" "$CURRENT_WORKSPACE"
        move_workspace_content "$TEMP_WORKSPACE" "$dest"
        ;;
        
    *)
        echo -e "${RED}[!] Error: Invalid workspace action${NC}" >&2
        exit 1
        ;;
esac