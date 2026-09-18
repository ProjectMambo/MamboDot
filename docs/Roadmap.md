---
title: MamboDot roadmap
description: Implemented deployment, session, display, and parallel AGS shell foundations with planned cutover and configuration coverage.
order: 40
---

::page{layout="docs" width="normal" sidebar=true}

# MamboDot roadmap

MamboDot should reproduce intentional workstation configuration without treating volatile application state as configuration. Safe deployment, session environment, displays, and the parallel AGS bar, four-mode launcher, and sidebars are implemented; notification ownership, cutover, and configuration coverage remain planned rather than current behavior.

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
- A keyboard-first launcher provides Apps, Run, Windows, and Power modes, follows the focused monitor, accepts validated AGS requests, supports dedicated-GPU application launch, focuses mapped Hyprland clients, executes commands without a shell, and confirms disruptive power actions.
- The interface follows MamboSite's dark semantic palette, MamboFont-first typography, square controls, strong two-pixel structure, and short eased state transitions.

The sidebars are implemented in the same parallel preview:

- The left overlay shows battery status and care, CPU/iGPU telemetry, fan RPM, firmware thermal profiles, confirmed graphics-mode requests, and current display brightness. Raw fan curves and CPU-governor switches stay out of AGS. Brightness writes now target the FA507XV backlight through `brightnessctl`'s native systemd-logind path, without a new host permission.
- The right overlay exposes Wi-Fi, Bluetooth, audio, Mako do-not-disturb and history, a native calendar, and today's read-only schedule. Native NetworkManager, Blueman, PulseAudio, and Obsidian applications remain the advanced settings surfaces.
- Both sidebars follow the focused monitor, slide through Hyprland's native layer animation, exclude one another and the launcher, close on Escape or outside click, and poll only while visible.

The schedule reader resolves a local daily note such as `Periodic/2026-09-18-W38-D5.md`, tolerates the current padded or unpadded ISO-week filename, reads only the exact `## Schedule` section, and accepts bullets shaped as `- HH:mm - HH:mm event`. The Notes project should still standardize its `W` versus `WW` generator mismatch for single-digit weeks. The reader does not edit or index the vault.

The remaining shell design is planned: add AGS notification popups before moving ownership away from Mako, cover the clipboard and any remaining daily controls, validate startup, keybindings, and recovery paths, then remove superseded fallback configuration. Waybar, Rofi, and Mako remain active until that cutover is complete.

## Delivery phases

1. **Foundation — implemented:** guarded Stow link/unlink commands, no adoption, focused deployment tests, safer Hyprland reload behavior, native helper notifications, corrected workspace interchange, and monitor-origin geometry.
2. **Session environment — implemented:** use the standard SDDM/Hyprland login path, propagate its environment once to D-Bus and systemd, keep session identity out of Zsh, remove the fake KDE session, and pass the startup Hyprlock password to GNOME Keyring through explicit FA507XV policy.
3. **Displays — implemented:** use Hyprland's catch-all preferred-mode, automatic-placement rule for current and hot-plugged outputs, apply one Hyprpaper fallback to every output, and size floating-window helpers from the active monitor instead of a fixed resolution.
4. **AGS core — implemented in parallel:** add a Stow-managed, hotplug-aware per-monitor bar and focused-monitor Apps/Run/Windows/Power launcher with a validated request interface; bundle-check and live-test them while leaving Waybar/Rofi startup and keybindings unchanged.
5. **Sidebars — implemented in parallel:** add focused-monitor left laptop controls and a right quick-control, calendar, Mako-history, and Obsidian day-planner overlay with visibility-scoped polling and native layer animations.
6. **Cutover:** finish notification ownership and remaining daily shell surfaces; validate AGS startup, requests, keybindings, and recovery, then switch the session and remove superseded Waybar, Rofi, Mako, and helper configuration.
7. **Coverage:** add reviewed package/service manifests, a machine doctor, and only the stable Code OSS, Dolphin, KDE, and desktop settings that survive the ownership rules above.

Each phase should be usable, tested, documented, and reversible before the next one begins.
