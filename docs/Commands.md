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

Hyprland first propagates its session environment, then starts `mambodot-shell.target`; its shutdown event stops the target again. The systemd user manager supervises the standalone Astal notification daemon, the Stow-managed AGS shell, and separate text and image Cliphist watchers. The target is session-started rather than enabled, so it cannot run before `WAYLAND_DISPLAY` reaches the user manager.

```bash
systemctl --user status mambodot-shell.target mambodot-ags.service mambodot-notifd.service 'mambodot-cliphist@*.service'
systemctl --user restart mambodot-ags.service
journalctl --user -u mambodot-ags.service -b
```

Long-lived applications launched by AGS, including Apps and Run selections, enter transient `app.slice` scopes. Restarting `mambodot-ags.service` therefore neither terminates those applications nor leaves their resource accounting attached to the shell service. The Astal daemon discards standard output so notification bodies are not persisted in the user journal; standard error remains journaled for diagnosis.

The standalone daemon remains the notification owner while AGS restarts, and AGS acts as its visual frontend. Control the bar, launcher, sidebars, or instance from a terminal with:

```bash
ags toggle launcher
ags toggle keybinds
ags toggle sidebar-left
ags toggle sidebar-right
ags request bar toggle
ags list
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

Apps opens the complete sorted list of visible desktop entries and refreshes it whenever the launcher opens; `prime` launches the selected application with the dedicated-GPU environment. Run parses a command into an argument vector and does not invoke a shell, so pipes, redirects, globs, and substitutions are not expanded. Windows focuses a mapped Hyprland client. Power exposes only the fixed actions documented below. Clipboard searches every newest-first Cliphist entry and copies the selected bytes unchanged, including images. Apps and Clipboard use a virtualized scrolling list, so the shell does not create one GTK widget for every stored result. Use `Alt-Shift-1` through `Alt-Shift-5` to change mode, Up/Down or Page Up/Page Down to move through results, Enter to activate the selection, and `Alt-1` through `Alt-9` to activate the first nine results; every result remains clickable.

The two supervised Cliphist watchers retain up to 5,000 text or image entries in Cliphist's own database. MamboDot does not duplicate that history or silently prune it in AGS. Existing entries remain intact when the watchers restart.

The 40-pixel bar exposes larger launcher, sidebar, status, and eye-shaped idle-inhibitor glyphs without reserving more screen space. Click the eye to keep the session awake; its warm background means inhibition is active. The control uses GTK's session idle inhibitor rather than stopping Hypridle, defaults to off, and is released automatically when AGS exits or restarts.

The keybind sheet, launcher, and sidebars follow the focused monitor, exclude one another, and close with Escape or an outside click. Launcher content stays on the focused monitor while its click-to-close dimming surface covers every active output. The sheet renders the maintained tables from `docs/Keybinds.md`; toggle it with `SUPER /` or the command above. Sidebar telemetry refreshes only while its panel is visible. The forced GTK backend is intentional because an XWayland-launched terminal may otherwise make GTK layer-shell unavailable.

The left panel is a two-column, no-scroll dashboard at 1080p. It shows battery health, voltage, cycles and charge/drain rate; CPU load, temperature, frequency and policy; both fan speeds and curve ownership; iGPU and active-dGPU load, temperature, clocks, VRAM and power; memory, NVMe read/write rate, and storage/DIMM temperatures. Safe controls cover 60/80-percent battery care, one-shot full charge, ASUS thermal profiles, confirmed graphics modes, panel and keyboard brightness, and panel overdrive. Advanced fan curves open the installed ROG Control Center; AGS never writes raw PWM, CPU governor, or TDP values. The right panel reads today's Obsidian `## Schedule` section without writing to the vault and shows the five newest notifications retained by the current AGS process.

Top-right notification popups support sender actions and dismissal. Do-not-disturb suppresses and clears popups while notifications continue into active state and session history. Resolved notifications cannot be restored because their sender context may no longer exist, and history intentionally resets with AGS rather than persisting notification contents.

### Manual recovery

Waybar, Rofi, and Mako remain linked as a reviewed recovery shell. From `SUPER Q`, stop the managed shell target, then start the old bar and notification daemon; Rofi can be opened directly:

```bash
systemctl --user stop mambodot-shell.target
env GDK_BACKEND=wayland waybar >/dev/null 2>&1 &
mako >/dev/null 2>&1 &
rofi -show drun -show-icons -terminal kitty
```

Restore the managed shell with a fresh login. For an immediate retry, stop Waybar and Mako, then start the target:

```bash
pkill -x waybar
pkill -x mako
systemctl --user start mambodot-shell.target
```

Mako and Astal must not compete for `org.freedesktop.Notifications`.

The recovery Waybar uses its native idle inhibitor and natural widget height. It intentionally omits the tray because the installed multi-output build cannot safely parent one tray across both output bars; AGS remains the complete tray shell.

## Power actions

After the `script` Stow package is linked, the shared backend accepts one fixed action:

```bash
~/.local/bin/powermenu.sh [shutdown|hibernate|reboot|windows|suspend|logout|lock]
```

With no argument it preserves the current Rofi menu. Unknown or extra arguments fail with a usage error, and action strings are selected by `case` rather than evaluated. The AGS Power mode confirms suspend, hibernate, logout, restart, restart-to-Windows, and shutdown before invoking this backend; Lock runs immediately. Direct command-line action calls are immediate.

The `windows` action asks Polkit to run only `/usr/bin/grub-reboot` for the reviewed Windows entry, then reboots only if that command succeeds. Cancelling or failing authorization leaves the current boot target and session unchanged. If setting the one-shot entry succeeds but reboot fails, the backend clears `next_entry` before returning an error.

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
