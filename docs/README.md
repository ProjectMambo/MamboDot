# MamboDot

<p align="left">
  <img src="https://img.shields.io/badge/Arch_Linux-1793D1?style=flat-square&logo=arch-linux&logoColor=white" alt="Arch Linux" />
  <img src="https://img.shields.io/badge/Hyprland-33CCFF?style=flat-square&logo=hyprland&logoColor=white" alt="Hyprland" />
  <img src="https://img.shields.io/badge/GNU_Stow-4A4A4A?style=flat-square&logo=gnu&logoColor=white" alt="GNU Stow" />
</p>
<p align="left">
  <img src="https://img.shields.io/badge/Maintenance-Active-brightgreen?style=flat-square" alt="Maintenance status: active" />
  <img src="https://img.shields.io/github/last-commit/ProjectMambo/MamboDot?style=flat-square&color=7a5fff" alt="Last commit" />
  <img src="https://img.shields.io/github/repo-size/ProjectMambo/MamboDot?style=flat-square&color=yellow" alt="Repository size" />
  <a href="../LICENSE"><img src="https://img.shields.io/github/license/ProjectMambo/MamboDot?style=flat-square&color=orange" alt="License" /></a>
</p>

MamboDot is the live, GNU Stow-managed Arch Linux desktop configuration used by Project Mambo. It combines a Lua-driven Hyprland setup with application dotfiles, generated MamboColour themes, shell helpers, and a guarded repository command.

This is a personal workstation profile rather than a portable distribution or unattended installer. Review its paths, hardware identifiers, and applications before using it. Linking is previewed as one operation and stops on existing-file conflicts; MamboDot never adopts home-directory files into the repository.

## Start here

| Goal | Document |
|---|---|
| Read the canonical Wiki documentation | [projectmambo.org/mambodot/](https://projectmambo.org/mambodot/) |
| Review requirements and install safely | [Installation and Safety](Installation%20and%20Safety.md) |
| Learn desktop shortcuts | [Keybinds](Keybinds.md) |
| Link configuration, control or recover AGS, regenerate colours, or use `tp` | [Command Reference](Commands.md) |
| Review implemented milestones and remaining refinements | [Roadmap](Roadmap.md) |

## Configuration scope

- Hyprland session, hotplug display layout, idle, lock, wallpaper, window, workspace, group, input, and launcher behavior.
- The active AGS 3 per-monitor bar, Apps/Run/Windows/Power/Clipboard launcher, laptop-control sidebar, general/day-planner sidebar, and native notification UI, with Waybar/Rofi/Mako retained for manual recovery.
- Kitty, Dolphin, KDE, Fcitx5, Zsh, Neovim, Code OSS, notification, and desktop-integration settings.
- Reviewed Arch/AUR/Flatpak package and system/user service manifests for the current workstation.
- MamboColour-generated Hyprland and Waybar palettes.
- Screenshot, clipboard, media, cursor, floating-window, power, and application-launcher helpers.
- The Zsh `tp` directory-bookmark function.
- Explicit host policy kept outside normal Stow packages.

Direct children of `dot/` are Stow packages. `script/mambodot.sh` previews and links or unlinks explicit packages, reports package/service drift with `doctor`, and refreshes reviewed MamboColour output with `update`. None of these commands installs packages, enables services, or reloads the desktop.

## Machine assumptions

- The checkout lives at `$HOME/ProjectMambo/MamboDot`.
- Displays use their preferred mode, automatic placement, and scale 1; review the catch-all rule if an output needs a different arrangement.
- The power menu contains a machine-specific Windows boot target.
- AGS brightness controls target `nvidia_wmi_ec_backlight` and rely on active-session systemd-logind authorization.
- Application commands assume the exact programs configured in `variables.lua` and the launch preset.
- The manifests describe this FA507XV workstation rather than a minimal or distribution-neutral package set.
- Some visual assets and status modules are specific to the maintainer's hardware and home layout.

Adjust these before activating the configuration on another machine.

## Quick start

```bash
git clone https://github.com/ProjectMambo/MamboDot.git "$HOME/ProjectMambo/MamboDot"
cd "$HOME/ProjectMambo/MamboDot"
./script/test.sh
./script/mambodot.sh doctor
./script/mambodot.sh link hypr ags script kitty zsh
```

Replace that package list with the configuration you reviewed. Do not use `all` before reading [Installation and Safety](Installation%20and%20Safety.md). Existing conflicting files are left unchanged and must be resolved deliberately.

## Repository layout

```text
dot/<package>/                 Stow packages rooted at the home directory
dot/ags/.config/ags/          active AGS bar, launcher, sidebars, notifications, and square Mambo styling
dot/hypr/.config/hypr/        Lua Hyprland entry, modules, rules, and assets
dot/zsh/.config/zsh/          Zsh configuration and local bookmark storage
manifest/                     reviewed package and enabled-service inventories
script/mambodot.sh            safe link/unlink, machine doctor, and colour-update command
script/test.sh                deployment, provider, and Hyprland regression checks
script/code-oss/              editor extension installer
system/hosts/<host>/          reviewed root-owned host policy, applied explicitly
docs/                         operating documentation
```

## Development checks

The repository has a focused local regression suite, but no CI workflow. Before committing configuration changes, run the available checks and inspect the exact diff:

```bash
bash -n script/mambodot.sh script/test.sh script/code-oss/install_extensions.sh dot/script/.local/bin/powermenu.sh
shellcheck script/mambodot.sh script/test.sh script/code-oss/install_extensions.sh dot/script/.local/bin/powermenu.sh
./script/test.sh
find dot/hypr/.config/hypr -name '*.lua' -print0 | xargs -0 -n1 luac -p
Hyprland --verify-config --config "$PWD/dot/hypr/.config/hypr/hyprland.lua"
git diff --check
git status --short
```

Run `./script/mambodot.sh update` as a separate reviewed step only when changing generated MamboColour output.

## Issues and feedback

This is a personal desktop environment, so external pull requests are not currently requested. Bug reports and focused suggestions are welcome as repository issues.

## License

Distributed under the MIT License. See **[LICENSE](../LICENSE)** for details.
