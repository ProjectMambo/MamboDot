#!/usr/bin/env bash

NUM_WORKSPACE=8 # Number of workspace for each monitor
ACTION=$1 # Workspace action
TARGET_WORKSPACE=$2 # Target workspace id/name
CURRENT_WORKSPACE=$(hyprctl activeworkspace -j | jq '.id') # Current workspace id
temp_workspace=99 

# Wrap workspace id for left/right target
get_wrapped_workspace() {
    local current=$1
    local target=$2

    if [[ "$target" == "l" ]]; then
        if [[ "$current" -eq 1 ]]; then
            echo "$NUM_WORKSPACE";
        else
            echo $((current - 1));
        fi
    elif [[ "$target" == "r" ]]; then
        if [[ "$current" -eq "$NUM_WORKSPACE" ]]; then
            echo 1;
        else
            echo $((current + 1));
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

# Run workspace action
case $ACTION in
    "workspace")
        dest=$(get_wrapped_workspace "$CURRENT_WORKSPACE" "$TARGET_WORKSPACE")
        hyprctl dispatch workspace "$dest"
        ;;

    "movetoworkspace")
        dest=$(get_wrapped_workspace "$CURRENT_WORKSPACE" "$TARGET_WORKSPACE")
        hyprctl dispatch movetoworkspace "$dest"
        ;;

    "movetoworkspacesilent")
        dest=$(get_wrapped_workspace "$CURRENT_WORKSPACE" "$TARGET_WORKSPACE")
        hyprctl dispatch movetoworkspacesilent "$dest"
        ;;

    "togglespecialworkspace")
        dest=$TARGET_WORKSPACE
        hyprctl dispatch togglespecialworkspace "$dest"
        ;;

    "interchange")
        dest=$(get_wrapped_workspace "$CURRENT_WORKSPACE" "$TARGET_WORKSPACE")
        move_workspace_content "$CURRENT_WORKSPACE" "$temp_workspace"
        move_workspace_content "$dest" "$CURRENT_WORKSPACE"
        move_workspace_content "$temp_workspace" "$dest"
        ;;
esac
