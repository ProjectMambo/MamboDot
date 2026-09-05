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
> This repository is hardware- and user-specific. Its Stow script uses `--adopt`, which can move existing files into the checkout. Read the installation guide and review every resulting Git change.

## Main areas

- Hyprland windows, workspaces, groups, launchers, input methods, screenshots, media, and power controls.
- Stow packages for the shell, terminal, editors, bar, launcher, file manager, and desktop services.
- Generated light and dark palettes supplied by MamboColour.
- Machine-specific monitor, boot, application, and filesystem assumptions.

## Documentation

::children{view="list" sort="order" direction="asc" show=["title","description"]}

## Current status

The configuration is actively used on the maintainer's Arch Linux workstation. It is not a general-purpose installer, package manifest, or compatibility-tested desktop distribution.
