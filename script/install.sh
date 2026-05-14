#!/bin/bash

# Get the absolute path
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(dirname "$SCRIPT_DIR")

THEME_HYPRLAND="$PROJECT_DIR/dot/hypr/.config/hypr/themes"
mkdir -p "$THEME_HYPRLAND"
mambogen "mamboheritage" "Hyprland" "$THEME_HYPRLAND"

THEME_WAYBAR="$PROJECT_DIR/dot/waybar/.config/waybar"
mkdir -p "$THEME_WAYBAR"
mambogen "mamboheritage" "Waybar" "$THEME_WAYBAR"

echo "----- Parser ------" >&2
echo "MamboDot installed!" >&2
echo "Source: $PROJECT_DIR" >&2
echo "-------------------" >&2
