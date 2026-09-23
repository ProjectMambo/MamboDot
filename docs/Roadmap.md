---
title: MamboDot roadmap
description: Implemented deployment, session, display, AGS shell, and reviewed workstation coverage.
order: 40
---

::page{layout="docs" width="normal" sidebar=true}

# MamboDot roadmap

MamboDot should reproduce intentional workstation configuration without treating volatile application state as configuration. Safe deployment, session environment, displays, the active AGS shell, post-cutover stabilization, reviewed workstation coverage, and user-tool environment hardening are implemented.

## Configuration ownership

Use GNU Stow for portable, user-owned text configuration:

| Scope | Ownership |
|---|---|
| Hyprland, AGS, Neovim, Zsh, terminal, launcher, bar, notifications, and user scripts | Fully managed Stow packages |
| Code OSS settings/keybindings/extensions, Dolphin, KDE, Fcitx, GTK, and XDG defaults | Reviewed leaf files only, when stable across reinstalls |
| Credentials, cookies, caches, histories, databases, device state, window/session state, and generated runtime files | Never tracked |
| Obsidian vault and `.obsidian` | Owned by the Notes project; MamboDot owns only the AGS reader and optional `MAMBO_NOTES_DIR` override |
| Root-owned hardware and login policy | Explicit `system/hosts/<host>/` files applied individually, never normal Stow or wholesale daemon state |

Coverage now includes reviewed Arch/AUR/Flatpak and enabled-service manifests, a read-only machine doctor, Git identity and defaults, every installed Code OSS extension ID, stable Dolphin and KDE leaf settings, Fcitx5 preferences, and the FA507XV SDDM/Fcitx/PAM host policy. Browser and Electron profiles, credentials, histories, learned input data, generated daemon state, and mixed runtime preference files remain local. Additional application settings should be added only when a stable leaf file has a clear owner and does not dirty the repository during ordinary use.

## AGS desktop shell

The active shell uses the already-installed AGS 3, Astal, GTK4, and Gio stack without another launcher framework:

- A hotplug-aware 40-pixel bar is created for each monitor and shows its clickable ten-workspace block, focused title, clock, larger GTK idle-inhibitor and status glyphs, tray, network, audio, and battery state without hardware polling scripts.
- A keyboard-first launcher provides Apps, Run, Windows, Power, and binary-safe Clipboard modes, follows the focused monitor while dimming every output, accepts validated AGS requests, switches modes with `Alt-Shift-1` through `Alt-Shift-5`, exposes complete app and 5,000-entry Cliphist result sets through a virtualized scrolling list with native keyboard selection, refreshes installed applications on open, supports dedicated-GPU application launch, focuses mapped Hyprland clients, executes commands without a shell, and confirms disruptive power actions.
- A focused-monitor keybind sheet renders the maintained keybind documentation directly, so the overlay adds no second shortcut registry.
- Astal owns notification delivery independently of AGS restarts. AGS renders square top-right popups with actions, applies do-not-disturb in the frontend, and retains bounded process-local history without persisting notification bodies.
- The interface follows MamboSite's dark semantic palette, MamboFont-first typography, opaque bar groups, square controls, strong two-pixel structure, distinct sidebar accents, and short eased state transitions.

The workspace buttons and Windows launcher mode deliberately send Hyprland's current Lua `hl.dsp.focus(...)` expressions. Astal's convenience focus methods still emit legacy dispatcher strings that Lua-configured Hyprland 0.55 rejects.

The sidebars run with the active shell:

- The left overlay uses a dense two-column 1080p layout for battery health/rate, CPU policy and load, CPU/iGPU/dGPU temperatures and utilization, active-dGPU VRAM and power, fan RPM and curve ownership, memory, NVMe read/write rate, and storage/DIMM temperatures. It controls battery care, firmware thermal profiles, confirmed graphics modes, display and keyboard brightness, and panel overdrive; full fan-curve editing opens ROG Control Center. Raw PWM, CPU-governor, and TDP writes stay out of AGS. Brightness writes target the FA507XV backlight through `brightnessctl`'s native systemd-logind path, without a new host permission.
- The right overlay exposes Wi-Fi, Bluetooth, audio, Astal do-not-disturb, active notifications and history, a native calendar, and today's read-only schedule. Native NetworkManager, Blueman, PulseAudio, and Obsidian applications remain the advanced settings surfaces.
- Both sidebars follow the focused monitor, slide through Hyprland's native layer animation, exclude one another and the launcher, close on Escape or outside click, and poll only while visible.

The schedule reader resolves a local daily note such as `Periodic/2026-09-18-W38-D5.md`, tolerates legacy padded ISO-week filenames, reads only the exact `## Schedule` section, and accepts bullets shaped as `- HH:mm - HH:mm event`. Periodic Notes and the weekly generator both use the unpadded `W` format. The reader does not edit or index the vault.

After propagating the session environment, Hyprland starts one Stow-managed systemd user target. It supervises Astal, AGS, and both Cliphist watchers, while the shell keybindings target AGS. Waybar, Rofi, and Mako remain reviewed, linked manual-recovery configuration but are absent from normal startup. Removing them is deliberately deferred until the active shell has enough daily use to make that recovery path unnecessary.

## Delivery phases

1. **Foundation — implemented:** guarded Stow link/unlink commands, no adoption, focused deployment tests, safer Hyprland reload behavior, native helper notifications, corrected workspace interchange, and monitor-origin geometry.
2. **Session environment — implemented:** use the standard SDDM/Hyprland login path, propagate its environment once to D-Bus and systemd, keep session identity out of Zsh, remove the fake KDE session, supervise the packaged Polkit agent through its user service, and pass the startup Hyprlock password to GNOME Keyring through explicit FA507XV policy.
3. **Displays — implemented:** use Hyprland's catch-all preferred-mode, automatic-placement rule for current and hot-plugged outputs, apply one Hyprpaper fallback to every output, and size floating-window helpers from the active monitor instead of a fixed resolution.
4. **AGS core — implemented:** add a Stow-managed, hotplug-aware per-monitor bar and focused-monitor Apps/Run/Windows/Power launcher with a validated request interface; bundle-check and live-test them before session activation.
5. **Sidebars — implemented:** add focused-monitor left laptop controls and a right quick-control, calendar, notification-history, and Obsidian day-planner overlay with visibility-scoped polling and native layer animations.
6. **Cutover — implemented:** move notification ownership to Astal, add binary-safe Clipboard mode, switch startup and keybindings to AGS, validate the full shell under a guarded live preview, and document recovery while retaining Waybar/Rofi/Mako configuration outside normal startup.
7. **Shell stabilization — implemented:** make every bar group opaque, distinguish both sidebar controls, launch desktop applications with the GJS-compatible empty file list, and move clickable workspace and window focus to Hyprland's Lua dispatcher syntax.
8. **Coverage — implemented:** add reviewed package/service manifests, a read-only machine doctor, and only the stable Code OSS, Dolphin, KDE, Fcitx5, XDG, and host settings that survive the ownership rules above.
9. **Environment and tooling — implemented:** give Hyprland applications and every Zsh the same deduplicated user-tool path, propagate it to D-Bus and systemd, and make Code OSS extension synchronization fail visibly instead of hiding query or installation errors.
10. **Keybind reference — implemented:** add a square AGS overlay on `SUPER /` that renders the maintained keybind tables, closes with Escape or an outside click, and remains mutually exclusive with the launcher and sidebars.
11. **Power and idle controls — implemented:** verify all seven fixed Power actions and host prerequisites, clear GRUB's one-shot Windows entry if reboot fails, keep failures in Power mode, and restore a visible GTK idle inhibitor to every AGS bar without stopping Hypridle.
12. **Shell density and hardware detail — implemented:** enlarge bar text and glyphs without changing its 40-pixel reservation, dim all active outputs behind the focused launcher, move mode shortcuts to `Alt-Shift`, and replace the laptop stack with a live two-column dashboard and safe supported ASUS controls.
13. **Deep launcher lists — implemented:** show and keyboard-navigate the complete refreshed desktop-application list, search every retained clipboard entry, virtualize the shared scrolling result view, and raise native Cliphist retention to 5,000 entries without adding a second history store.
14. **Git coverage — implemented:** Stow the stable global identity, default branch, and helper selection while keeping credential payloads, GitHub authentication, SSH keys, and repository-local settings outside MamboDot.
15. **Power-policy ownership — implemented:** disable the conflicting `auto-cpufreq` service, keep `asusd` as the sole platform-profile and energy-preference owner, and verify that Quiet remains at `power` after the former writer's update interval.
16. **Session supervision — implemented:** move AGS, Astal notification ownership, and both 5,000-entry Cliphist watchers into Stow-managed systemd user units, bracket one shell target with Hyprland's propagated startup and shutdown events, and route refresh and recovery through that target.

Future additions are maintenance rather than another broad import: compare battery life and performance before removing the retained `auto-cpufreq` rollback package, promote a long-tail application setting only after it proves stable, and retire the Waybar/Rofi/Mako recovery set only after enough daily use makes that rollback unnecessary. Never add power-profiles-daemon or TLP alongside the selected `asusd` owner. See the [ASUS Linux Arch guide](https://asus-linux.org/guides/arch-guide/) before changing ownership.
