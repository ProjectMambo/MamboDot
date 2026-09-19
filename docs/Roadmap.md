---
title: MamboDot roadmap
description: Implemented deployment, session, display, and AGS shell cutover with planned configuration coverage.
order: 40
---

::page{layout="docs" width="normal" sidebar=true}

# MamboDot roadmap

MamboDot should reproduce intentional workstation configuration without treating volatile application state as configuration. Safe deployment, session environment, displays, and the active AGS bar, five-mode launcher, sidebars, native notifications, and shell cutover are implemented; configuration coverage remains planned rather than current behavior.

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

The active shell uses the already-installed AGS 3, Astal, GTK4, and Gio stack without another launcher framework:

- A hotplug-aware bar is created for each monitor and shows its ten-workspace block, focused title, clock, tray, network, audio, and battery state without hardware polling scripts.
- A keyboard-first launcher provides Apps, Run, Windows, Power, and binary-safe Clipboard modes, follows the focused monitor, accepts validated AGS requests, supports dedicated-GPU application launch, focuses mapped Hyprland clients, executes commands without a shell, and confirms disruptive power actions.
- Astal owns notification delivery independently of AGS restarts. AGS renders square top-right popups with actions, applies do-not-disturb in the frontend, and retains bounded process-local history without persisting notification bodies.
- The interface follows MamboSite's dark semantic palette, MamboFont-first typography, square controls, strong two-pixel structure, and short eased state transitions.

The sidebars run with the active shell:

- The left overlay shows battery status and care, CPU/iGPU telemetry, fan RPM, firmware thermal profiles, confirmed graphics-mode requests, and current display brightness. Raw fan curves and CPU-governor switches stay out of AGS. Brightness writes now target the FA507XV backlight through `brightnessctl`'s native systemd-logind path, without a new host permission.
- The right overlay exposes Wi-Fi, Bluetooth, audio, Astal do-not-disturb, active notifications and history, a native calendar, and today's read-only schedule. Native NetworkManager, Blueman, PulseAudio, and Obsidian applications remain the advanced settings surfaces.
- Both sidebars follow the focused monitor, slide through Hyprland's native layer animation, exclude one another and the launcher, close on Escape or outside click, and poll only while visible.

The schedule reader resolves a local daily note such as `Periodic/2026-09-18-W38-D5.md`, tolerates the current padded or unpadded ISO-week filename, reads only the exact `## Schedule` section, and accepts bullets shaped as `- HH:mm - HH:mm event`. The Notes project should still standardize its `W` versus `WW` generator mismatch for single-digit weeks. The reader does not edit or index the vault.

Hyprland now starts Astal and AGS, and its shell keybindings target AGS. Waybar, Rofi, and Mako remain reviewed, linked manual-recovery configuration but are absent from normal startup. Removing them is deliberately deferred until the active shell has enough daily use to make that recovery path unnecessary.

## Delivery phases

1. **Foundation — implemented:** guarded Stow link/unlink commands, no adoption, focused deployment tests, safer Hyprland reload behavior, native helper notifications, corrected workspace interchange, and monitor-origin geometry.
2. **Session environment — implemented:** use the standard SDDM/Hyprland login path, propagate its environment once to D-Bus and systemd, keep session identity out of Zsh, remove the fake KDE session, and pass the startup Hyprlock password to GNOME Keyring through explicit FA507XV policy.
3. **Displays — implemented:** use Hyprland's catch-all preferred-mode, automatic-placement rule for current and hot-plugged outputs, apply one Hyprpaper fallback to every output, and size floating-window helpers from the active monitor instead of a fixed resolution.
4. **AGS core — implemented:** add a Stow-managed, hotplug-aware per-monitor bar and focused-monitor Apps/Run/Windows/Power launcher with a validated request interface; bundle-check and live-test them before session activation.
5. **Sidebars — implemented:** add focused-monitor left laptop controls and a right quick-control, calendar, notification-history, and Obsidian day-planner overlay with visibility-scoped polling and native layer animations.
6. **Cutover — implemented:** move notification ownership to Astal, add binary-safe Clipboard mode, switch startup and keybindings to AGS, validate the full shell under a guarded live preview, and document recovery while retaining Waybar/Rofi/Mako configuration outside normal startup.
7. **Coverage:** add reviewed package/service manifests, a machine doctor, and only the stable Code OSS, Dolphin, KDE, and desktop settings that survive the ownership rules above.

Each phase should be usable, tested, documented, and reversible before the next one begins.
