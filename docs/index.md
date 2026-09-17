---
title: MamboDot
description: The Stow-managed Arch Linux and Hyprland workstation configuration used by Project Mambo.
order: 30
---

::page{layout="project" width="normal" sidebar=true}

# MamboDot

MamboDot is Project Mambo's active desktop configuration: GNU Stow packages, a Lua-driven Hyprland setup, shared MamboColour output, application settings, and workstation helper scripts.

::button{label="Source code" href="https://github.com/ProjectMambo/MamboDot" variant="secondary" external=true}

> [!WARNING]
> This repository is hardware- and user-specific. Read the installation guide and review package contents before linking them.

## Main areas

- Hyprland windows, workspaces, groups, launchers, input methods, screenshots, media, and power controls.
- Native display hotplug, output-agnostic wallpapers, and monitor-relative floating-window geometry.
- A parallel AGS 3 per-monitor bar and application launcher, with Waybar and Rofi retained as the active fallback.
- Stow packages for the shell, terminal, editors, bar, launcher, file manager, and desktop services.
- Generated light and dark palettes supplied by MamboColour.
- Machine-specific monitor, boot, application, and filesystem assumptions.

## Documentation

::children{view="list" sort="order" direction="asc" show=["title","description"]}

## Current status

The configuration is actively used on the maintainer's Arch Linux workstation. Its foundation now provides conflict-safe, explicit Stow deployment, focused Hyprland regression checks, a normalized SDDM/Hyprland session environment with one activation propagation path, native output-agnostic display handling with monitor-relative window geometry, and a live-tested AGS bar and application launcher package. AGS is intentionally parallel-only for now rather than a login-session replacement. MamboDot is not yet a general-purpose installer, package manifest, or compatibility-tested desktop distribution.

The next phase will build the left laptop-controls and right general/day-planner sidebars. Later phases finish the remaining menu and notification surfaces, validate the complete shell, and only then cut over from Waybar, Rofi, and Mako. See the roadmap for the planned controls and configuration ownership.
