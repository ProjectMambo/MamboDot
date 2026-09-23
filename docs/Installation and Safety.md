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
- AGS 3 with GTK4, the Astal Hyprland, battery, network, notification, tray, and WirePlumber libraries, and the `astal-notifd` executable; its SCSS bundle also requires Sass.
- NetworkManager, BlueZ with `bluetoothctl`, Blueman, `lm_sensors`, `nvidia-utils`, `brightnessctl` with systemd-logind support, `asusctl`, and `supergfxctl` for the current sidebar controls. Obsidian is optional unless the day planner should open the vault.
- GNU Stow, Git, Bash, Zsh, Oh My Zsh, `zsh-autosuggestions`, and `zsh-syntax-highlighting`.
- Kitty, Dolphin, FeatherPad, Qalculate-Qt, Neovim, Code OSS, Fastfetch, and KDE/Qt desktop utilities. Waybar, Rofi, and Mako remain recovery dependencies rather than active shell processes.
- Fcitx5 with Pinyin and Mozc input methods.
- Avizo volume/brightness helpers, Playerctl, Cliphist, wl-clipboard, wl-kbptr, Quickshell with HyprQuickFrame, and the screenshot tools used by that shell.
- MamboColour's installed `mbcolor` command. MamboFont is not an installation dependency.

The repository does not install system packages or enable services. `manifest/packages.tsv` records the reviewed Arch, foreign/AUR, and Flatpak applications for this workstation; `manifest/services.tsv` records intended system and user enablement. They are a host profile, not an unattended bootstrap or a minimal dependency list.

## Audit machine state

Run the read-only doctor before linking or after a system change:

```bash
./script/mambodot.sh doctor
```

It reports missing packages, packages installed from the wrong source class, and disabled services. It ignores extra software and never installs, removes, enables, starts, or stops anything. Review each reported row before changing another machine: entries such as SDDM autologin, SSH, SMB, VPN, NVIDIA, and ASUS laptop services are intentionally specific to this workstation.

The profile deliberately excludes `thermald`, which reports this Ryzen platform as unsupported, and installed `-debug` split packages that are not runtime requirements. Because extras are ignored, `doctor` will not ask to remove them. The current profile retains `auto-cpufreq` alongside `asusd` until their overlapping power policy is benchmarked. Both currently write the AMD governor and energy-performance preference, so battery and manual ASUS profiles may be overwritten even though the current AC defaults happen to agree. Do not add or enable power-profiles-daemon or TLP at the same time. The [ASUS Linux Arch guide](https://asus-linux.org/guides/arch-guide/) likewise recommends choosing compatible power-policy ownership rather than stacking managers.

## Review machine-specific values

Before installation, search the checkout for values tied to the maintainer's machine:

```bash
rg -n 'ProjectMambo/MamboDot|Windows|kohkohnut' dot script system manifest
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
./script/mambodot.sh link hypr ags script git kitty zsh
```

The command validates every name, previews the complete selection, and only applies it when the preview succeeds. It runs GNU Stow with `--no-folding`, so real parent directories contain leaf symlinks and applications may keep their untracked runtime files beside them. User Stow resource files are ignored, preventing a local `.stowrc` from silently changing this policy.

Use `all` only after reviewing every package:

```bash
./script/mambodot.sh link all
```

Linking does not install packages, rebuild caches, reload Hyprland, source shell files, or start services.

## Configuration coverage

Stow only intentional user preferences. Current ownership is deliberately narrower than all of `~/.config`:

| Area | Tracked | Deliberately outside MamboDot |
|---|---|---|
| Hyprland and desktop shell | Hyprland, AGS, scripts, Kitty, Avizo, HyprQuickFrame, wl-kbptr, plus Waybar/Rofi/Mako recovery settings | Runtime sockets, logs, notification bodies, clipboard contents, and generated caches |
| Editors | Neovim configuration; Code OSS settings and reviewed extension IDs | Code chat/session storage, history, logs, machine IDs, and authentication |
| Developer identity | Git user identity, default branch, and credential-helper choice | `.git-credentials`, `gh/hosts.yml`, tokens, SSH keys, and repository-local settings |
| File manager and desktop integration | Dolphin preferences, metadata-field visibility, service-menu choices; KDE appearance and I/O policy; XDG MIME and portal defaults | KDE activities, global shortcuts owned by Hyprland, window/session state, trash state, and KDE Connect keys |
| Input | Fcitx5 profile, hotkeys, Pinyin, punctuation, notifications, and conversion preferences | Mozc history/databases, cached layouts, temporary files, and learned input data |
| Notes | The read-only AGS schedule integration | The Obsidian vault and `.obsidian`, which remain owned by the Notes project |
| System and hardware | Reviewed files under `system/hosts/fa507xv/` | Generated `asusd`/`supergfxd` state, raw sysfs controls, daemon databases, and broad `/etc` snapshots |
| Other applications | Package presence is recorded in the manifest | Browser/Electron profiles, credentials, cookies, caches, game state, and mixed runtime preference files remain local until a stable leaf file is reviewed |

GTK theme selection is already owned by Hyprland's environment and KDE globals. The current GTK CSS files are stale generated Matugen output without tracked source templates, so duplicating them would make the repository less reproducible rather than more complete.

The tracked Git configuration preserves the current `credential.helper=store` choice but never tracks its payload. Git stores that helper's credentials unencrypted in the mode-600 `~/.git-credentials` file; keep that file local, do not commit or sync it, and choose a different helper before using this profile on a machine where plaintext credential storage is inappropriate.

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

The extension command accepts no arguments, installs only IDs missing from the reviewed list, and stops if Code OSS cannot list or install extensions. Run `update` only when `mbcolor` is installed and the generated palette artifacts should change. Review its diff before committing.

## Apply host-specific system policy

Files below `system/hosts/` are root-owned machine policy, not Stow packages. Inspect and apply them individually. The FA507XV profile records SDDM autologin, Fcitx environment variables, and the Hyprlock PAM addition:

```bash
diff -u /etc/sddm.conf system/hosts/fa507xv/etc/sddm.conf
diff -u /etc/environment system/hosts/fa507xv/etc/environment
diff -u /etc/pam.d/hyprlock system/hosts/fa507xv/etc/pam.d/hyprlock
```

After reviewing each diff, apply only the intended files:

```bash
sudo install --backup=numbered -D -m 0644 \
    system/hosts/fa507xv/etc/sddm.conf /etc/sddm.conf
sudo install --backup=numbered -D -m 0644 \
    system/hosts/fa507xv/etc/environment /etc/environment
sudo install --backup=numbered -D -m 0644 \
    system/hosts/fa507xv/etc/pam.d/hyprlock /etc/pam.d/hyprlock
```

The FA507XV profile keeps SDDM autologin and starts Hyprlock immediately. Autologin cannot provide a password to GNOME Keyring, so the first secret-using application otherwise opens a second password dialog. The tracked PAM file reuses the password already authenticated by Hyprlock.

Each install command leaves a numbered backup beside the target. Restore the appropriate backup from a TTY if login or Hyprlock authentication fails. Changes to SDDM and `/etc/environment` require a fresh login, preferably a reboot. Package upgrades may provide a `.pacnew`; compare it with the tracked policy before replacing either file.

## Session environment

The active login path is `SDDM` → the standard Hyprland session → `/usr/bin/start-hyprland` → Hyprland's Lua startup → one `dbus-update-activation-environment --systemd` propagation.

| Owner | Responsibility |
|---|---|
| SDDM's standard Hyprland desktop entry | Session identity: `XDG_CURRENT_DESKTOP`, `XDG_SESSION_DESKTOP`, and `XDG_SESSION_TYPE` |
| `variables.lua` | XDG base directories, Qt/GTK preferences, and the user-tool `PATH` for applications launched by Hyprland |
| `exec.lua` | Propagate the environment, including `PATH`, once to D-Bus and the systemd user manager, then start the current session processes |
| Tracked `/etc/environment` host policy | Fcitx input-method variables |
| `.zshenv` | Apply the same user-tool path prefix to every Zsh, including TTY and SSH shells |
| `.zshrc` | Interactive shell behavior only; it must not redefine the desktop or input method |

UWSM is not installed or required. Do not select the optional `Hyprland (uwsm-managed)` session unless a later phase deliberately migrates the complete login lifecycle to UWSM.

The shared user-tool prefix is `$HOME/.local/bin`, `$HOME/.npm-global/bin`, `$HOME/.cargo/bin`, and `$HOME/.local/share/JetBrains/Toolbox/scripts`, followed by the inherited system path with duplicates removed.

A fresh login, preferably a reboot on the autologin host, is the complete way to apply environment changes. `hyprctl reload` updates future Hyprland-launched applications but cannot replace variables already inherited by the compositor or running services; the startup propagation updates future D-Bus and systemd user activations. After login, verify that every layer agrees and that `KDE_SESSION_VERSION` is absent:

```bash
loginctl show-session "$XDG_SESSION_ID" -p Desktop -p Type
printenv XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP XDG_SESSION_TYPE
systemctl --user show-environment |
    rg '^(PATH|XDG_CURRENT_DESKTOP|XDG_SESSION_DESKTOP|XDG_SESSION_TYPE|KDE_SESSION_VERSION)='
```

## Displays

Hyprland applies one catch-all rule to every current or hot-plugged output: preferred mode, automatic placement, and scale 1. Output removal is handled by the compositor; no listener or external layout daemon is involved. Hyprpaper uses one empty-monitor fallback for every output, and floating-window size steps use the active monitor dimensions rather than a fixed resolution.

Reload Hyprland for layout and geometry changes. Hyprpaper reads its configuration at startup, so restart it or log in again before testing a changed fallback. Then run `hyprctl monitors all`, connect and disconnect each external display, and confirm placement, wallpaper, and floating-window controls. Review the catch-all rule if hardware needs a different scale, transform, or fixed placement.

## AGS shell and recovery

The `ags` Stow package is the active desktop shell: a per-monitor bar, Apps/Run/Windows/Power/Clipboard launcher, documentation-backed keybind sheet, two sidebars, and notification popups. Hyprland starts `astal-notifd daemon` and `env GDK_BACKEND=wayland ags run`, keeps both `wl-paste` Cliphist watchers, and no longer starts Waybar or Mako. These are ordinary session processes rather than systemd user services.

Astal must be the sole owner of `org.freedesktop.Notifications`; it cannot proxy Mako. Waybar, Rofi, and Mako remain linked for manual recovery, but do not start Mako while Astal owns that bus name. The [command reference](Commands.md#manual-recovery) is authoritative for stopping the managed shell and restoring the recovery tools.

The left panel reads `/proc`, reviewed sysfs status, `sensors`, and `nvidia-smi` only while visible. It queries NVIDIA only when `supergfxctl` reports the dGPU active, avoiding a periodic wake-up while it sleeps. Firmware thermal profiles provide the safe quick fan control; the Advanced button opens ROG Control Center for deliberate curve editing. AGS never writes raw PWM, CPU-governor, boost, or TDP values, and it confirms every graphics-mode request because that change may require logout or reboot. It never performs that disruptive follow-up itself.

Display-brightness controls explicitly target the FA507XV's `nvidia_wmi_ec_backlight` device and keep the minimum at 1. The installed `brightnessctl` delegates writes to the active local session through systemd-logind's `SetBrightness` API, so root ownership of the raw sysfs attribute is expected; do not add a udev, `sudoers`, or extra Polkit rule. Keyboard-light levels and panel overdrive use supported `asusctl` interfaces without `sudo`. If writes fail, verify that `asusd` and systemd-logind are running and the session is active, local, and non-remote.

The Power launcher uses the fixed `powermenu.sh` action interface. AGS confirms every disruptive action; the direct backend is immediate. Restart to Windows is the only path that explicitly invokes `pkexec`, and reboot proceeds only after `grub-reboot` succeeds. If reboot fails after the one-shot entry is set, the backend clears that entry before reporting failure.

The eye button in the bar's right status group uses GTK's application idle inhibitor, which Hypridle honors while remaining active. A warm button background means inhibition is on. The inhibitor defaults to off and is released when AGS exits or restarts, so it cannot silently persist after a shell crash.

The launcher exposes every visible desktop application and the complete newest-first Cliphist database through a virtualized scrolling list. The text and image watchers raise Cliphist's retention ceiling from its 750-item default to 5,000 entries; the limit is applied by newly started watchers, not by AGS. Clipboard bodies remain in Cliphist's untracked cache database and can contain credentials or other sensitive material, so do not commit, sync, or back up that database without reviewing the privacy impact.

The right panel reads only today's `Periodic/` note under `MAMBO_NOTES_DIR` or `$HOME/ProjectMambo/notes`. It uses the vault's unpadded ISO-week filename and still accepts legacy padded names, parses only `## Schedule` rows shaped as `- HH:mm - HH:mm event`, and never creates, edits, or indexes vault files. Its notification history is process-local and intentionally does not persist bodies to disk.

## Unlink

```bash
./script/mambodot.sh unlink hypr kitty zsh
./script/mambodot.sh unlink all
```

Unlinking previews the complete selection before removing managed links. It does not remove application-created runtime files, uninstall packages, or revert settings outside those links.

## Verify

```bash
bash -n script/mambodot.sh script/test.sh script/code-oss/install_extensions.sh dot/script/.local/bin/powermenu.sh
shellcheck script/mambodot.sh script/test.sh script/code-oss/install_extensions.sh dot/script/.local/bin/powermenu.sh
./script/test.sh
./script/mambodot.sh doctor
find dot/hypr/.config/hypr -name '*.lua' -print0 | xargs -0 -n1 luac -p
Hyprland --verify-config --config "$PWD/dot/hypr/.config/hypr/hyprland.lua"
diff -u system/hosts/fa507xv/etc/sddm.conf /etc/sddm.conf
diff -u system/hosts/fa507xv/etc/environment /etc/environment
diff -u system/hosts/fa507xv/etc/pam.d/hyprlock /etc/pam.d/hyprlock
git diff --check
git status --short
```

The regression suite tests safe linking and unlinking, including the reviewed desktop packages, conflict handling, hostile Stow resource files, sorted machine manifests and doctor drift, all 12 staged MamboColour calls, strict Code OSS extension synchronization, the shared user-tool path, an AGS production bundle, all seven fixed power-action mappings and both restart-to-Windows failure paths, the idle-inhibitor wiring, multi-output launcher backdrop and mode-shortcut contracts, hardware telemetry parsers, AGS request grammar, the keybind, schedule, and binary-safe clipboard parser self-checks, session-process ownership, monitor-relative sizing, the catch-all display and wallpaper rules, and key Lua helpers. The Hyprland command validates the complete configuration without changing the live session. Test physical display connect/disconnect, the keybind sheet, both AGS sidebars, all launcher modes, notification popups/actions/do-not-disturb/history, text and image clipboard restoration, input methods, screenshots, media controls, and power actions individually before relying on them. Suspend and hibernate prerequisites can be inspected safely, but logout, sleep, restart, Windows boot selection, and shutdown still require deliberate manual testing.
