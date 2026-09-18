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
- A parallel AGS 3 per-monitor bar, application launcher, and two focused-monitor sidebars, with Waybar, Rofi, and Mako retained as active fallbacks.
- Stow packages for the shell, terminal, editors, bar, launcher, file manager, and desktop services.
- Generated light and dark palettes supplied by MamboColour.
- Machine-specific monitor, boot, application, and filesystem assumptions.

## Documentation

::children{view="list" sort="order" direction="asc" show=["title","description"]}

## Current status

The configuration is actively used on the maintainer's Arch Linux workstation. Its foundation now provides conflict-safe, explicit Stow deployment, focused Hyprland regression checks, a normalized SDDM/Hyprland session environment with one activation propagation path, native output-agnostic display handling with monitor-relative window geometry, and a live-tested AGS bar, launcher, laptop-control panel, and general/day-planner panel. AGS is intentionally parallel-only for now rather than a login-session replacement. MamboDot is not yet a general-purpose installer, package manifest, or compatibility-tested desktop distribution.

The next phase finishes command, window, power, and notification surfaces, resolves the host backlight permission, and validates the complete shell before any cutover from Waybar, Rofi, or Mako. Configuration coverage and fresh-machine manifests remain later work. See the roadmap for the delivery order and ownership rules.
