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
- AGS 3 with GTK4 and the Astal Hyprland, battery, network, tray, and WirePlumber libraries; its SCSS bundle also requires Sass.
- GNU Stow, Git, Bash, Zsh, Oh My Zsh, `zsh-autosuggestions`, and `zsh-syntax-highlighting`.
- Waybar, Rofi, Kitty, Dolphin, FeatherPad, Qalculate-Qt, Neovim, Code OSS, Fastfetch, and KDE/Qt desktop utilities.
- Fcitx5 with Pinyin and Mozc input methods.
- Avizo volume/brightness helpers, Playerctl, Cliphist, wl-clipboard, wl-kbptr, Quickshell with HyprQuickFrame, and the screenshot tools used by that shell.
- MamboColour's installed `mbcolor` command. MamboFont is not an installation dependency.

The repository does not install system packages or enable services. Package and service manifests are planned; until then, resolve requirements for the target Arch system before linking the configuration.

## Review machine-specific values

Before installation, search the checkout for values tied to the maintainer's machine:

```bash
rg -n 'ProjectMambo/MamboDot|Windows|kohkohnut' dot script
```

At minimum, review the scale-1 display policy, wallpaper paths, the Windows boot entry, launch-preset applications, application commands in `variables.lua`, and any absolute home paths.

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

## Apply host-specific system policy

Files below `system/hosts/` are root-owned machine policy, not Stow packages. Inspect and apply them individually.

The FA507XV profile keeps SDDM autologin and starts Hyprlock immediately. Autologin cannot provide a password to GNOME Keyring, so the first secret-using application otherwise opens a second password dialog. The tracked PAM file reuses the password already authenticated by Hyprlock:

```bash
diff -u /etc/pam.d/hyprlock system/hosts/fa507xv/etc/pam.d/hyprlock
sudo install --backup=numbered -D -m 0644 \
    system/hosts/fa507xv/etc/pam.d/hyprlock /etc/pam.d/hyprlock
```

The install command leaves a numbered backup beside the target. Restore that backup from a TTY if Hyprlock authentication fails. Package upgrades may provide a `.pacnew`; compare it with the tracked policy before replacing either file.

## Session environment

The active login path is `SDDM` → the standard Hyprland session → `/usr/bin/start-hyprland` → Hyprland's Lua startup → one `dbus-update-activation-environment --systemd` propagation.

| Owner | Responsibility |
|---|---|
| SDDM's standard Hyprland desktop entry | Session identity: `XDG_CURRENT_DESKTOP`, `XDG_SESSION_DESKTOP`, and `XDG_SESSION_TYPE` |
| `variables.lua` | XDG base directories and Qt/GTK preferences for applications launched by Hyprland |
| `exec.lua` | Propagate the environment once to D-Bus and the systemd user manager, then start the current session processes |
| `/etc/environment` | Fcitx input-method variables; this remains host state until the coverage phase reviews it |
| `.zshrc` | Interactive shell behavior only; it must not redefine the desktop or input method |

UWSM is not installed or required. Do not select the optional `Hyprland (uwsm-managed)` session unless a later phase deliberately migrates the complete login lifecycle to UWSM.

Environment changes require a fresh login, preferably a reboot on the autologin host; `hyprctl reload` cannot replace the environment inherited by the compositor or already-running services. After login, verify that every layer agrees and that `KDE_SESSION_VERSION` is absent:

```bash
loginctl show-session "$XDG_SESSION_ID" -p Desktop -p Type
printenv XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
systemctl --user show-environment |
    rg '^(XDG_CURRENT_DESKTOP|XDG_SESSION_DESKTOP|XDG_SESSION_TYPE|KDE_SESSION_VERSION)='
```

## Displays

Hyprland applies one catch-all rule to every current or hot-plugged output: preferred mode, automatic placement, and scale 1. Output removal is handled by the compositor; no listener or external layout daemon is involved. Hyprpaper uses one empty-monitor fallback for every output, and floating-window size steps use the active monitor dimensions rather than a fixed resolution.

Reload Hyprland for layout and geometry changes. Hyprpaper reads its configuration at startup, so restart it or log in again before testing a changed fallback. Then run `hyprctl monitors all`, connect and disconnect each external display, and confirm placement, wallpaper, and floating-window controls. Review the catch-all rule if hardware needs a different scale, transform, or fixed placement.

## AGS preview boundary

The `ags` Stow package contains a live-tested per-monitor bar and application launcher, but Hyprland does not start it and no current keybinding depends on it. Waybar and Rofi remain the default session path until the sidebars and remaining shell surfaces are complete. This prevents a partial shell from becoming the only recovery path.

Link and exercise AGS only as an explicit preview. The [command reference](Commands.md#ags-preview) provides a guarded command that temporarily stops Waybar, forces the Wayland GTK backend, and restores Waybar when AGS exits. The launcher can then be toggled through AGS's own command interface. Do not add AGS to `exec.lua` or replace the Rofi keybinding before the cutover phase validates the complete workflow.

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
diff -u system/hosts/fa507xv/etc/pam.d/hyprlock /etc/pam.d/hyprlock
git diff --check
git status --short
```

The regression suite tests safe linking and unlinking, including the AGS package, conflict handling, hostile Stow resource files, all 12 staged MamboColour calls, an AGS production bundle, monitor-relative sizing, the catch-all display and wallpaper rules, and key Lua helpers. The Hyprland command validates the complete configuration without changing the live session. Test physical display connect/disconnect, the AGS preview, launchers, input methods, screenshots, media controls, and power actions individually before relying on them.
