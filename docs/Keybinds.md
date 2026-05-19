This document outlines all system shortcuts, window rules, application launches, and workspace behaviors built into this environment.
# Shell & Environment Controls
Shortcuts dedicated to launching standard system interfaces, refreshing components, or toggling visual layout elements.

| Keybinding | Description |
|---|---|
| SUPER | Toggle application launcher via Rofi |
| SUPER + Space | Switch active keyboard input method language |
| SUPER + Delete | Toggle Rofi system session and power menu |
| SUPER + SHIFT + CTRL + R | Reload Hyprland configuration rules |
| SUPER + B | Toggle the Waybar status line |
| SUPER + SHIFT + CTRL + B | Reload Waybar configuration rules |
# System Hardware Utilities
Direct adjustments for hardware controls, media keys, and system accessories.

| Keybinding | Description |
|---|---|
| Volume Up | Raise system master output volume |
| Volume Down | Lower system master output volume |
| Mute Key | Toggle absolute master audio muting state |
| Brightness Up | Increase hardware monitor backlight brightness |
| Brightness Down | Decrease hardware monitor backlight brightness |
| SUPER + V | Launch clipboard history manager within Rofi menu |
| SUPER + SHIFT + S | Capture region selection screenshot to system clipboard |
# Application Launchers
Quick launch shortcuts mapping dedicated applications to primary layout rows.

| Keybinding | Description                           |
| ---------- | ------------------------------------- |
| SUPER + Q  | Open Kitty Terminal                   |
| SUPER + W  | Open Default Web Browser              |
| SUPER + E  | Open Dolphin File Manager             |
| SUPER + R  | Open Default Markdown or Notes Editor |
| SUPER + T  | Open Default Code Editor              |
# Window Management
Shortcuts dedicated to controlling focus, position layouts, dimensions, and states of active windows.
## Display & Mouse Controls
| Keybinding | Description |
|---|---|
| SUPER + Left Mouse Drag | Manually drag tile coordinates to move window |
| SUPER + Right Mouse Drag | Manually scale window boundaries to resize window |
| SUPER + C | Gracefully close targeted active window |
| SUPER + SHIFT + C | Instantly kill window process tree |
| SUPER + O | Shift window between tiling and floating states |
| SUPER + D | Maximize window layout while retaining status bar space |
| SUPER + F | Toggle global absolute fullscreen mode |
| SUPER + P | Pin floating window across all active workspaces |
## Layout Navigation & Adjustments
| Keybinding | Description |
|---|---|
| SUPER + H / L / K / J | Move window focus Left / Right / Up / Down |
| SUPER + SHIFT + H / L / K / J | Swap window position Left / Right / Up / Down |
| SUPER + SHIFT + Minus (-) | Reduce active split layout width ratio |
| SUPER + SHIFT + Equal (=) | Increase active split layout width ratio |
# Tabbed Windows (Groups)
Hyprland grouping utilities allowing multiple window instances to be bound together into a single tabbed layout cluster.

| Keybinding | Description |
|---|---|
| SUPER + ALT + Backslash (\\) | Form or dissolve an active window grouping profile |
| SUPER + ALT + Bracket Left (\[) | Switch focus to previous index tab inside active group |
| SUPER + ALT + Bracket Right (]) | Switch focus to next index tab inside active group |
| SUPER + ALT + H / L / K / J | Merge window or group towards Left / Right / Up / Down |
# Workspace Controls
Advanced environment shifting via custom automation framework execution parameters.
## Target Navigation
| Keybinding | Description |
|---|---|
| SUPER + [1 - 0] | Move desktop screen focus to the respective workspace index (1 - 10) |
| SUPER + Semicolon (;) | Focus the adjacent left workspace |
| SUPER + Apostrophe (') | Focus the adjacent right workspace |
| SUPER + Grave (\`) | Toggle the visualization layer of your background scratchpad |
## Workspace Relocation & Swapping
| Keybinding | Description |
|---|---|
| SUPER + SHIFT + [1 - 0] | Moves active window to selected index and follows focus |
| SUPER + SHIFT + ALT + [1 - 0] | Sends active window to selected index silently without switching view |
| SUPER + SHIFT + ; / ' | Moves active window to the adjacent Left or Right workspace |
| SUPER + SHIFT + ALT + ; / ' | Sends active window Left or Right without tracking target focus |
| SUPER + SHIFT + Grave (\`) | Dispatches targeted window directly into the primary background scratchpad |
| SUPER + SHIFT + ALT + Grave (\`) | Dispatches window into scratchpad silently without modifying current view |
| SUPER + ALT + [1 - 0] | Swaps current workspace contents with chosen workspace number |
| SUPER + ALT + ; / ' | Swaps current workspace layout structure with adjacent Left or Right index |
