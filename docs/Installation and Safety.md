---
title: Installation and Safety
description: Review MamboDot's assumptions, link its Stow packages, and apply its live desktop setup safely.
order: 10
---

::page{layout="docs" width="normal" sidebar=true}

# Installation and Safety

MamboDot manages a complete personal home-directory configuration. Installation can replace links, adopt existing files into the repository, reload the desktop, and expose machine-specific commands. Back up important configuration and inspect the scripts before running them.

## Requirements

The active configuration references these groups of software:

- Arch Linux, Hyprland with the Lua `hl` configuration API, Hypridle, Hyprlock, and Hyprpaper.
- GNU Stow, Git, Bash, Zsh, Oh My Zsh, `zsh-autosuggestions`, and `zsh-syntax-highlighting`.
- Waybar, Rofi, Kitty, Dolphin, FeatherPad, Qalculate-Qt, Neovim, Code OSS, Fastfetch, and KDE/Qt desktop utilities.
- Fcitx5 with Pinyin and Mozc input methods.
- Avizo volume/brightness helpers, Playerctl, Cliphist, wl-clipboard, wl-kbptr, Quickshell with HyprQuickFrame, and the screenshot tools used by that shell.
- MamboColour's installed `mbcolor` command. MamboFont is not an installation dependency.

The repository does not install system packages. Package names and providers vary, so resolve them for the target Arch system before linking the configuration.

## Review machine-specific values

Before installation, search the checkout for values tied to the maintainer's machine:

```bash
rg -n 'eDP-1|DP-9|ProjectMambo/MamboDot|Windows|kohkohnut' dot script
```

At minimum, review monitor names, wallpaper paths, the Windows boot entry, launch-preset applications, application commands in `variables.lua`, and any absolute home paths.

## Clone into the expected path

The Hyprland modules currently derive resources from this exact checkout location:

```bash
git clone https://github.com/ProjectMambo/MamboDot.git "$HOME/ProjectMambo/MamboDot"
cd "$HOME/ProjectMambo/MamboDot"
```

Using another location requires updating the corresponding path configuration first.

## Preview Stow operations

Each direct child of `dot/` is a Stow package. Preview individual packages before using the repository-wide helper:

```bash
cd dot
stow -n -v -R -t "$HOME" hypr
stow -n -v -R -t "$HOME" zsh
cd ..
```

`script/stow.sh stow` runs `stow -R --adopt` across **every** package. `--adopt` can move an existing target file into this repository before replacing it with a symlink. After running it, inspect `git status` and `git diff` immediately; restore or deliberately commit any adopted content.

## Link and initialize

Once the preview and backup are complete:

```bash
./script/stow.sh stow
./script/install.sh
```

The second script delegates tracked MamboColour generation to `script/mambodot.sh update`, installs configured Code OSS extensions, refreshes desktop caches, sources `.zshenv`, and asks Hyprland to reload. It does not build MamboFont or run font-cache commands. Run it from the intended live desktop session.

The script assumes the Stow step has already made helpers such as `~/.local/bin/powermenu.sh` available.

## Unlink

```bash
./script/stow.sh unstow
```

Unstow removes managed links. It does not reconstruct files that were previously adopted, uninstall packages, remove generated caches, or revert desktop settings outside those links.

## Verify

```bash
./script/mambodot.sh update
./script/test.sh
git status --short
hyprctl reload
```

The provider check verifies all 12 expected staged `mbcolor` calls while preserving the tracked artifact bytes. Test launchers, input methods, workspace navigation, screenshots, media controls, and power actions individually before relying on them.
