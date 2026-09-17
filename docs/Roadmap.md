---
title: MamboDot roadmap
description: Implemented deployment, session, display, and parallel AGS foundations with planned sidebars, cutover, and configuration coverage.
order: 40
---

::page{layout="docs" width="normal" sidebar=true}

# MamboDot roadmap

MamboDot should reproduce intentional workstation configuration without treating volatile application state as configuration. Safe deployment, session environment, displays, and the parallel AGS core are implemented; the remaining phases below are planned rather than current behavior.

## Configuration ownership

Use GNU Stow for portable, user-owned text configuration:

| Scope | Ownership |
|---|---|
| Hyprland, AGS, Neovim, Zsh, terminal, launcher, bar, notifications, and user scripts | Fully managed Stow packages |
| Code OSS settings/keybindings/extensions, Dolphin, KDE, Fcitx, GTK, and XDG defaults | Reviewed leaf files only, when stable across reinstalls |
| Credentials, cookies, caches, histories, databases, device state, window/session state, and generated runtime files | Never tracked |
| Obsidian vault and `.obsidian` | Owned by the Notes project; MamboDot owns only the AGS reader and optional `MAMBO_NOTES_DIR` override |
| Root-owned hardware and login policy | Explicit `system/hosts/<host>/` files applied individually, never normal Stow or wholesale daemon state |

## AGS desktop shell

The tracked core uses the already-installed AGS 3, Astal, GTK4, and Gio stack without another launcher framework. It currently runs only on explicit preview, leaving Waybar and Rofi as the session defaults:

- A hotplug-aware bar is created for each monitor and shows its ten-workspace block, focused title, clock, tray, network, audio, and battery state without hardware polling scripts.
- A keyboard-first launcher reads native desktop entries, follows the focused monitor, ranks multi-term application matches, launches through Gio, and closes with Escape or an outside click.
- The interface follows MamboSite's dark semantic palette, MamboFont-first typography, square controls, strong two-pixel structure, and short eased state transitions.

The remaining shell design is planned:

- Extend the main menu with commands, windows, and power actions before it replaces Rofi.
- A left overlay sidebar shows ASUS TUF laptop telemetry and safe controls: thermal-profile buttons are the first-version fan control, with fan RPM, battery care, brightness, and GPU state alongside them. An advanced action opens ROG Control Center for curves. Graphics-mode changes require confirmation; raw fan curves and CPU-governor switches stay out of AGS.
- A right overlay sidebar exposes Wi-Fi, Bluetooth, audio, notifications, a calendar, and today's read-only schedule.
- Both sidebars slide in and out, close on Escape or outside click, and never reserve workspace area.

The schedule reader resolves a local daily note such as `Periodic/2026-09-17-W38-D4.md`, reads only the exact `## Schedule` section, and accepts bullets shaped as `- HH:mm - HH:mm event`. The Notes project must first standardize its current `W` versus `WW` filename mismatch for single-digit ISO weeks. The first version reads only; it does not edit or index the vault.

## Delivery phases

1. **Foundation — implemented:** guarded Stow link/unlink commands, no adoption, focused deployment tests, safer Hyprland reload behavior, native helper notifications, corrected workspace interchange, and monitor-origin geometry.
2. **Session environment — implemented:** use the standard SDDM/Hyprland login path, propagate its environment once to D-Bus and systemd, keep session identity out of Zsh, remove the fake KDE session, and pass the startup Hyprlock password to GNOME Keyring through explicit FA507XV policy.
3. **Displays — implemented:** use Hyprland's catch-all preferred-mode, automatic-placement rule for current and hot-plugged outputs, apply one Hyprpaper fallback to every output, and size floating-window helpers from the active monitor instead of a fixed resolution.
4. **AGS core — implemented in parallel:** add a Stow-managed, hotplug-aware per-monitor bar and focused-monitor application launcher; bundle-check and live-test them while leaving Waybar/Rofi startup and keybindings unchanged.
5. **Sidebars:** add the left laptop-controls overlay and right general/day-planner overlay with visibility-scoped polling.
6. **Cutover:** finish command, window, power, notification, and remaining control surfaces in AGS; validate the live workflow, then remove superseded Waybar, Rofi, Mako, and helper configuration.
7. **Coverage:** add reviewed package/service manifests, a machine doctor, and only the stable Code OSS, Dolphin, KDE, and desktop settings that survive the ownership rules above.

Each phase should be usable, tested, documented, and reversible before the next one begins.
