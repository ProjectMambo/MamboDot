#!/usr/bin/env bash

NUM_WORKSPACE=8
action=$1
target_workspace=$2
current_workspace=$(hyprctl activeworkspace -j | jq '.id')
temp_workspace=99

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

move_workspace_content() {
    local source=$1
    local target=$2
    
    hyprctl clients -j | jq -r ".[] | select(.workspace.id == $source) | .address" | while read -r addr; do
        hyprctl dispatch movetoworkspacesilent "$target,address:$addr"
    done
}

case $action in
    "workspace")
        dest=$(get_wrapped_workspace "$current_workspace" "$target_workspace")
        hyprctl dispatch workspace "$dest"
        ;;

    "movetoworkspace")
        dest=$(get_wrapped_workspace "$current_workspace" "$target_workspace")
        hyprctl dispatch movetoworkspace "$dest"
        ;;

    "movetoworkspacesilent")
        dest=$(get_wrapped_workspace "$current_workspace" "$target_workspace")
        hyprctl dispatch movetoworkspacesilent "$dest"
        ;;

    "togglespecialworkspace")
        dest=$target_workspace
        hyprctl dispatch togglespecialworkspace "$dest"
        ;;

    "interchange")
        dest=$(get_wrapped_workspace "$current_workspace" "$target_workspace")
        move_workspace_content "$current_workspace" "$temp_workspace"
        move_workspace_content "$dest" "$current_workspace"
        move_workspace_content "$temp_workspace" "$dest"
        ;;
esac
