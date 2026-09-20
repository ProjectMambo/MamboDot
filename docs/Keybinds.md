---
title: MamboDot Keybinds
description: Keyboard and pointer controls defined by the active Hyprland configuration.
order: 30
---

::page{layout="docs" width="normal" sidebar=true}

# MamboDot Keybinds

The AGS keybind sheet renders the tables on this page. `dot/hypr/.config/hypr/keybinds.lua` remains authoritative for live behavior, so update this guide with every binding change.

## Shell and environment controls

| Keybinding | Description |
|---|---|
| `SUPER`                    | Open AGS Apps                 |
| `CTRL` `SUPER`             | Open AGS Apps (dedicated GPU) |
| `SUPER` `Space`            | Select English input          |
| `SUPER` `Alt` `Space`      | Select Mandarin (`pinyin`)    |
| `SUPER` `SHIFT` `Space`    | Select Japanese (`mozc`)      |
| `SUPER` `Delete`           | Open AGS Power                |
| `SUPER` `SHIFT` `Delete`   | Lock screen                   |
| `SUPER` `SHIFT` `CTRL` `R` | Reload configs                |
| `SUPER` `B`                | Toggle AGS bar                |
| `SUPER` `Slash (/)`        | Toggle keybind sheet          |
| `SUPER` `Bracket Left ([)` | Toggle laptop controls        |
| `SUPER` `Bracket Right (])` | Toggle desktop/day planner   |

## System hardware utilities

| Keybinding | Description |
|---|---|
| `Audio Mute`              | Mute                          |
| `Audio Volume Up`         | Volume up                     |
| `Audio Volume Down`       | Volume down                   |
| `Mon Brightness Up`       | Brightness up                 |
| `Mon Brightness Down`     | Brightness down               |
| `SUPER` `Equal (=)`       | Volume up                     |
| `SUPER` `Minus (-)`       | Volume down                   |
| `SUPER` `M`               | Mute                          |
| `SUPER` `Alt` `Equal (=)` | Brightness up                 |
| `SUPER` `Alt` `Minus (-)` | Brightness down               |
| `SUPER` `V`               | Open AGS Clipboard            |
| `SUPER` `S`               | Screenshot region → clipboard |
| `SUPER` `Alt` `S`         | Screenshot window → clipboard |
| `SUPER` `SHIFT` `S`       | Screenshot region → edit      |
| `SUPER` `SHIFT` `Alt` `S` | Screenshot window → edit      |
| `SUPER` `CTRL` `S`        | Screenshot region → file      |
| `SUPER` `CTRL` `Alt` `S`  | Screenshot window → file      |
| `SUPER` `Comma (,)`       | Click-to-select cursor mode   |
| `SUPER` `Period (.)`      | Grid cursor mode              |

## Media player controls

| Keybinding | Description |
|---|---|
|`SUPER` `KP_Delete`|Current Player|
|`SUPER` `KP_Insert`|Play / Pause|
|`SUPER` `Left`|Seek back 5s|
|`SUPER` `Right`|Seek forward 5s|
|`SUPER` `Alt` `Left`|Previous track|
|`SUPER` `Alt` `Right`|Next track|
|`SUPER` `Up`|Volume up|
|`SUPER` `Down`|Volume down|
|`SUPER` `Alt` `Up`|Next player|
|`SUPER` `Alt` `Down`|Previous player|

## Application Launchers

| Keybinding | Description |
|---|---|
|`SUPER` `Q`|Open terminal|
|`SUPER` `W`|Open browser|
|`SUPER` `E`|Open file manager|
|`SUPER` `R`|Open text editor|
|`SUPER` `T`|Open calculator|
|`SUPER` `Alt` `KP_Insert`|Launch default preset|

## Window management

### Display and mouse controls

| Keybinding | Description |
|---|---|
| `SUPER` `Left Mouse Drag`  | Move window        |
| `SUPER` `Right Mouse Drag` | Resize window      |
| `SUPER` `C`                | Close window       |
| `SUPER` `SHIFT` `C`        | Force close window |
| `SUPER` `O`                | Toggle floating    |
| `SUPER` `D`                | Toggle maximize    |
| `SUPER` `F`                | Toggle fullscreen  |
| `SUPER` `P`                | Pin window         |
| `SUPER` `Middle Mouse`     | Toggle floating    |
| `SUPER` `Alt` `Middle Mouse` | Pin window       |
| `SUPER` `SHIFT` `Middle Mouse` | Float, pin, and size for video |
| `SUPER` `Mouse Wheel Up/Down` | Move a floating window clockwise/anticlockwise between corners |
| `SUPER` `SHIFT` `Mouse Wheel Up/Down` | Shrink/enlarge a floating window |

### Layout navigation and adjustments

| Keybinding | Description |
|---|---|
| `SUPER` `H` / `L` / `K` / `J`         | Focus left / right / up / down       |
| `SUPER` `SHIFT` `H` / `L` / `K` / `J` | Move window left / right / up / down |
| `SUPER` `SHIFT` `Minus (-)`           | Decrease split ratio                 |
| `SUPER` `SHIFT` `Equal (=)`           | Increase split ratio                 |

## Tabbed Windows (Groups)

| Keybinding | Description |
|---|---|
| `SUPER` `Alt` `Backslash (\)`       | Toggle window group                         |
| `SUPER` `Alt` `Bracket Left ([)`    | Previous tab in group                       |
| `SUPER` `Alt` `Bracket Right (])`   | Next tab in group                           |
| `SUPER` `Alt` `H` / `L` / `K` / `J` | Move window into group (left/right/up/down) |
| `SUPER` `Alt` `Backspace`           | Toggle group lock                           |

## Workspace controls

### Target navigation

| Keybinding | Description |
|---|---|
| `SUPER` `[1 - 0]`        | Go to workspace 1–10         |
| `SUPER` `Semicolon (;)`  | Go to workspace on the left  |
| `SUPER` `Apostrophe (')` | Go to workspace on the right |
| `SUPER` `Grave`          | Toggle scratchpad            |

### Workspace relocation and swapping

| Keybinding | Description |
|---|---|
| `SUPER` `SHIFT` `[1 - 0]`           | Move window to workspace and follow                  |
| `SUPER` `SHIFT` `Alt` `[1 - 0]`     | Move window to workspace, stay on current            |
| `SUPER` `SHIFT` `;` / `'`           | Move window to left/right workspace and follow       |
| `SUPER` `SHIFT` `Alt` `;` / `'`     | Move window to left/right workspace, stay on current |
| `SUPER` `SHIFT` `Grave`       | Move window to scratchpad and follow                 |
| `SUPER` `SHIFT` `Alt` `Grave` | Move window to scratchpad, stay on current           |
| `SUPER` `Alt` `[1 - 0]`             | Swap current workspace with another                  |
| `SUPER` `Alt` `;` / `'`             | Swap current workspace with left/right workspace     |

Workspace numbers are relative to the active monitor. Each monitor owns a block of ten workspace IDs.
