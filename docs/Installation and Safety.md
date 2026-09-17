---
title: Installation and safety
description: Review MamboDot's assumptions and link selected Stow packages without adopting existing files.
order: 10
---

::page{layout="docs" width="normal" sidebar=true}

# Installation and safety

MamboDot is a personal home-directory configuration, not an unattended installer. Its repository command previews one complete link or unlink operation before applying it, refuses conflicts, and never adopts existing home-directory files into the repository. Back up important configuration and review each selected package before linking it.

## Requirements

The active configuration references these groups of software:

- Arch Linux, Hyprland with the Lua `hl` configuration API, Hypridle, Hyprlock, and Hyprpaper.
- GNU Stow, Git, Bash, Zsh, Oh My Zsh, `zsh-autosuggestions`, and `zsh-syntax-highlighting`.
- Waybar, Rofi, Kitty, Dolphin, FeatherPad, Qalculate-Qt, Neovim, Code OSS, Fastfetch, and KDE/Qt desktop utilities.
- Fcitx5 with Pinyin and Mozc input methods.
- Avizo volume/brightness helpers, Playerctl, Cliphist, wl-clipboard, wl-kbptr, Quickshell with HyprQuickFrame, and the screenshot tools used by that shell.
- MamboColour's installed `mbcolor` command. MamboFont is not an installation dependency.

The repository does not install system packages or enable services. Package and service manifests are planned; until then, resolve requirements for the target Arch system before linking the configuration.

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

## Link selected packages

Each direct child of `dot/` is a Stow package. Prefer an explicit reviewed list:

```bash
./script/mambodot.sh link hypr kitty zsh
```

The command validates every name, previews the complete selection, and only applies it when the preview succeeds. It runs GNU Stow with `--no-folding`, so real parent directories contain leaf symlinks and applications may keep their untracked runtime files beside them. User Stow resource files are ignored, preventing a local `.stowrc` from silently changing this policy.

Use `all` only after reviewing every package:

```bash
./script/mambodot.sh link all
```

Linking does not install packages, rebuild caches, reload Hyprland, source shell files, or start services.

## Resolve a conflict

An existing file at a managed path stops the whole selection. To import it deliberately:

1. Compare the existing file with the tracked version.
2. Copy only the reviewed content into the matching `dot/<package>/` path.
3. Inspect `git diff` and keep or discard that repository change deliberately.
4. Back up or move the original home-directory file.
5. Run `link` again.

Do not bypass this process with Stow's `--adopt` option.

## Optional initialization

Code OSS extensions and generated colour output are explicit, independent actions:

```bash
./script/code-oss/install_extensions.sh
./script/mambodot.sh update
```

Run `update` only when `mbcolor` is installed and the generated palette artifacts should change. Review its diff before committing.

## Unlink

```bash
./script/mambodot.sh unlink hypr kitty zsh
./script/mambodot.sh unlink all
```

Unlinking previews the complete selection before removing managed links. It does not remove application-created runtime files, uninstall packages, or revert settings outside those links.

## Verify

```bash
bash -n script/mambodot.sh script/test.sh script/code-oss/install_extensions.sh
shellcheck script/mambodot.sh script/test.sh script/code-oss/install_extensions.sh
./script/test.sh
find dot/hypr/.config/hypr -name '*.lua' -print0 | xargs -0 -n1 luac -p
Hyprland --verify-config --config "$PWD/dot/hypr/.config/hypr/hyprland.lua"
git diff --check
git status --short
```

The regression suite tests safe linking and unlinking, conflict handling, hostile Stow resource files, all 12 staged MamboColour calls, and key Lua helpers. The Hyprland command validates the complete configuration without changing the live session. Test launchers, input methods, screenshots, media controls, and power actions individually before relying on them.
