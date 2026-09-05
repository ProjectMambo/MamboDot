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

MamboDot is the live, GNU Stow-managed Arch Linux desktop configuration used by Project Mambo. It combines a Lua-driven Hyprland setup with application dotfiles, generated MamboColour themes, shell helpers, and small installation scripts.

This is a personal workstation profile rather than a portable distribution or unattended installer. Review its paths, hardware identifiers, applications, and destructive Stow behavior before using it.

## Start here

| Goal | Document |
|---|---|
| Read the canonical Wiki documentation | [projectmambo.org/mambodot/](https://projectmambo.org/mambodot/) |
| Review requirements and install safely | [Installation and Safety](Installation%20and%20Safety.md) |
| Learn desktop shortcuts | [Keybinds](Keybinds.md) |
| Regenerate colours or use the `tp` helper | [Command Reference](Commands.md) |

## Configuration scope

- Hyprland session, idle, lock, wallpaper, window, workspace, group, input, and launcher behavior.
- Waybar, Rofi, Kitty, Dolphin, Zsh, Neovim, Code OSS, notification, and desktop-integration settings.
- MamboColour-generated Hyprland and Waybar palettes.
- Screenshot, clipboard, media, cursor, floating-window, power, and application-launcher helpers.
- The Zsh `tp` directory-bookmark function.

Direct children of `dot/` are Stow packages. `script/stow.sh` links or unlinks every package; `script/install.sh` delegates theme generation to `script/mambodot.sh update` and performs live desktop refresh work but does **not** run Stow or build MamboFont.

## Machine assumptions

- The checkout lives at `$HOME/ProjectMambo/MamboDot`.
- Monitor rules currently name `eDP-1` and `DP-9`.
- The power menu contains a machine-specific Windows boot target.
- Application commands assume the exact programs configured in `variables.lua` and the launch preset.
- Some visual assets and status modules are specific to the maintainer's hardware and home layout.

Adjust these before activating the configuration on another machine.

## Quick start

```bash
git clone https://github.com/ProjectMambo/MamboDot.git "$HOME/ProjectMambo/MamboDot"
cd "$HOME/ProjectMambo/MamboDot"
./script/stow.sh stow
./script/install.sh
```

Do not run that sequence before reading [Installation and Safety](Installation%20and%20Safety.md). In particular, Stow uses `--adopt`, which can move existing target files into this repository and change tracked content.

## Repository layout

```text
dot/<package>/                 Stow packages rooted at the home directory
dot/hypr/.config/hypr/        Lua Hyprland entry, modules, rules, and assets
dot/zsh/.config/zsh/          Zsh configuration and local bookmark storage
script/stow.sh                all-package stow/unstow operation
script/mambodot.sh            repository-owned MamboColour update adapter
script/install.sh             post-link generation and live refresh
script/test.sh                colour-provider and installer regression checks
script/code-oss/              editor extension installer
docs/                         operating documentation
```

## Development checks

The repository has a focused local provider regression script, but no CI workflow. Before committing configuration changes, run the available checks, regenerate MamboColour outputs, and inspect the exact diff:

```bash
bash -n script/install.sh script/mambodot.sh script/stow.sh script/test.sh script/code-oss/install_extensions.sh
./script/test.sh
./script/mambodot.sh update
find dot/hypr/.config/hypr -name '*.lua' -print0 | xargs -0 -n1 luac -p
git diff --check
git status --short
```

## Issues and feedback

This is a personal desktop environment, so external pull requests are not currently requested. Bug reports and focused suggestions are welcome as repository issues.

## License

Distributed under the MIT License. See **[LICENSE](../LICENSE)** for details.
