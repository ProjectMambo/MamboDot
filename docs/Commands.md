---
title: MamboDot command reference
description: Link configuration, control or recover AGS, run safe power actions, regenerate colour artifacts, install editor extensions, and use the Zsh directory-bookmark helper.
order: 20
---

::page{layout="docs" width="normal" sidebar=true}

# MamboDot command reference

## Configuration links

`script/mambodot.sh` is the guarded entry point for GNU Stow operations:

```bash
./script/mambodot.sh link hypr kitty zsh
./script/mambodot.sh unlink hypr kitty zsh
./script/mambodot.sh link all
./script/mambodot.sh unlink all
```

At least one package name or the exact word `all` is required. The command rejects unknown packages and path traversal, previews the complete selection, and applies it only after a successful preview. It uses leaf symlinks, ignores user Stow resource files, and never adopts an existing file. See [Installation and safety](Installation%20and%20Safety.md) for conflict handling.

## Machine doctor

Compare the current host with the reviewed package and enabled-service manifests:

```bash
./script/mambodot.sh doctor
```

The command reads `manifest/packages.tsv` and `manifest/services.tsv`, checks Arch and foreign package provenance, checks Flatpak applications, and checks system and user service enablement. It prints only missing or disabled entries and exits non-zero when the machine drifts. Extra packages and services are intentionally ignored.

`doctor` is read-only: it does not install, remove, enable, start, or stop anything. The two-column TSV files are the reviewable machine profile; use the reported rows to decide which changes are appropriate for the target host.

## Colour update

`script/mambodot.sh` is MamboDot's repository-local adapter for MamboColour. It is not installed as a global command.

```bash
./script/mambodot.sh update
```

The command requires `mbcolor` on `PATH` and makes exactly 12 calls into a temporary staging directory:

| Consumer | Formats per theme | Themes | Calls |
|---|---|---:|---:|
| `dot/hypr/.config/hypr/themes/` | `hyprlua`, `hyprlang` | 4 | 8 |
| `dot/waybar/.config/waybar/` | `waybar` | 4 | 4 |

The four themes are `mamboorchelight`, `mamboorchedark`, `mambooutbacklight`, and `mambooutbackdark`. All 12 staged files must exist and be non-empty before the wrapper replaces tracked outputs, and symlinked targets are refused. A provider failure therefore leaves the committed model untouched. The command does not compile MamboFont or run font-cache commands.

The current tracked model was refreshed and reviewed with MamboColour commit `66f0c26d6d6462c54c023a4842e49dc6fa0b3c1c`.

Run the regression suite after changing the command or its tests:

```bash
./script/test.sh
```

The check covers guarded Stow deployment, stubs `mbcolor` with copies of the current tracked model, verifies the exact staged calls, checks usage failures, and runs focused Lua regressions. It is not currently run by CI.

## AGS desktop shell

Hyprland starts a standalone Astal notification daemon and the Stow-managed AGS shell as ordinary session processes:

```bash
astal-notifd daemon
env GDK_BACKEND=wayland ags run
```

The standalone daemon remains the notification owner while AGS restarts and AGS acts as its visual frontend. No systemd user service is involved. Control the bar, launcher, sidebars, or instance from a terminal with:

```bash
ags toggle launcher
ags toggle sidebar-left
ags toggle sidebar-right
ags request bar toggle
ags list
ags quit
```

Open a specific launcher mode through the validated request interface:

```bash
ags request launcher apps
ags request launcher apps prime
ags request launcher run
ags request launcher windows
ags request launcher power
ags request launcher clipboard
```

Apps searches visible desktop entries; `prime` launches the selected application with the dedicated-GPU environment. Run parses a command into an argument vector and does not invoke a shell, so pipes, redirects, globs, and substitutions are not expanded. Windows focuses a mapped Hyprland client. Power exposes only the fixed actions documented below. Clipboard searches newest-first Cliphist entries and copies the selected bytes unchanged, including images. Use `Ctrl-1` through `Ctrl-5` to change mode and `Alt-1` through `Alt-9` to activate a visible result.

The bar exposes the same three shell toggles. The launcher and sidebars follow the focused monitor, exclude one another, and close with Escape or an outside click. Sidebar telemetry refreshes only while its panel is visible. The forced GTK backend is intentional because an XWayland-launched terminal may otherwise make GTK layer-shell unavailable.

The left panel uses `asusctl` and `supergfxctl` without `sudo`; graphics-mode changes require an explicit second confirmation and never log out or reboot automatically. Brightness controls target `nvidia_wmi_ec_backlight` explicitly and let `brightnessctl` use the active session's systemd-logind `SetBrightness` path; no repository-managed backlight permission is required. The right panel reads today's Obsidian `## Schedule` section without writing to the vault and shows the five newest notifications retained by the current AGS process.

Top-right notification popups support sender actions and dismissal. Do-not-disturb suppresses and clears popups while notifications continue into active state and session history. Resolved notifications cannot be restored because their sender context may no longer exist, and history intentionally resets with AGS rather than persisting notification contents.

### Manual recovery

Waybar, Rofi, and Mako remain linked as a reviewed recovery shell. From `SUPER Q`, stop AGS and Astal, then start the old bar and notification daemon; Rofi can be opened directly:

```bash
ags quit
pkill -x astal-notifd
env GDK_BACKEND=wayland waybar >/dev/null 2>&1 &
mako >/dev/null 2>&1 &
rofi -show drun -show-icons -terminal kitty
```

Restore the managed shell with a fresh login. For an immediate retry, stop Waybar and Mako, start `astal-notifd daemon`, then run AGS with `GDK_BACKEND=wayland`. Mako and Astal must not compete for `org.freedesktop.Notifications`.

## Power actions

After the `script` Stow package is linked, the shared backend accepts one fixed action:

```bash
~/.local/bin/powermenu.sh [shutdown|hibernate|reboot|windows|suspend|logout|lock]
```

With no argument it preserves the current Rofi menu. Unknown or extra arguments fail with a usage error, and action strings are selected by `case` rather than evaluated. The AGS Power mode confirms suspend, hibernate, logout, restart, restart-to-Windows, and shutdown before invoking this backend; Lock runs immediately. Direct command-line action calls are immediate.

The `windows` action asks Polkit to run only `/usr/bin/grub-reboot` for the reviewed Windows entry, then reboots only if that command succeeds. Cancelling or failing authorization leaves the current boot target and session unchanged.

## Code OSS extensions

Install the reviewed extension list explicitly:

```bash
./script/code-oss/install_extensions.sh
```

The command accepts no arguments, compares extension IDs case-insensitively, installs only missing entries, and stops if listing or installation fails. It is intentionally separate from linking configuration.

## `tp`

`tp` is a Zsh function for jumping to directories and maintaining named bookmarks. It is defined by the managed Zsh configuration, so it is available after that configuration is linked and loaded.

```bash
tp <name-or-path>
tp -a <name> <path>
tp -d <name>
tp -l
```

| Form | Result |
|---|---|
| `tp <name>` | Change to the bookmarked directory |
| `tp <path>` | Change directly to an existing directory |
| `tp -a <name> <path>` | Add or replace a bookmark using the absolute target path |
| `tp -d <name>` | Remove a bookmark |
| `tp -l` | List saved bookmarks |
| `tp` | Show built-in help |

Bookmark names are stored in lowercase and matched case-insensitively.

## Examples

```bash
tp -a docs ~/Documents
tp -l
tp docs
tp -d docs
```

## Storage

Bookmarks live in `.config/zsh/tp_bookmarks.txt` beside the managed `.zshrc`. Both the Stow ignore rules and Git ignore rules exclude that machine-local file.

A bookmark record uses a whitespace-separated name and path. Paths containing spaces are therefore not represented safely by the current format.
