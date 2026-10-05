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

MamboDot is the live, GNU Stow-managed Arch Linux desktop configuration used by Project Mambo. It combines a Lua-driven Hyprland setup with application dotfiles, a vendored MamboColour API snapshot, shell helpers, and a guarded repository command.

## Motivation

MamboDot keeps one reviewable source for the maintainer's intentional workstation configuration while leaving credentials, caches, histories, databases, and other volatile application state on the machine that owns them. Its guarded Stow workflow makes configuration reproducible without silently adopting or overwriting existing home-directory files.

## Status

MamboDot is active on the maintainer's Arch Linux workstation. It is a personal workstation profile rather than a portable distribution or unattended installer. Review its paths, hardware identifiers, and applications before using it. Linking is previewed as one operation and stops on existing-file conflicts; MamboDot never adopts home-directory files into the repository.

### Machine assumptions

- The checkout lives at `$HOME/ProjectMambo/MamboDot`.
- Displays use their preferred mode, automatic placement, and scale 1; review the catch-all rule if an output needs a different arrangement.
- The power menu contains a machine-specific Windows boot target.
- AGS brightness controls target `nvidia_wmi_ec_backlight` and rely on active-session systemd-logind authorization.
- Application commands assume the exact programs configured in `variables.lua` and the launch preset.
- The manifests describe this FA507XV workstation rather than a minimal or distribution-neutral package set.
- Some visual assets and status modules are specific to the maintainer's hardware and home layout.

Adjust these before activating the configuration on another machine.

## User stories

- As the workstation owner, I can preview and link only the configuration packages I reviewed without replacing unrelated files.
- As the workstation owner, I can detect missing packages, disabled services, and bounded managed-dotfile drift without an unattended tool changing the machine.
- As a maintainer, I can update one pinned MamboColour snapshot, regenerate MamboDot's semantic adapters, and verify the desktop configuration before committing it.

### Configuration scope

- Hyprland session, hotplug display layout, idle, lock, wallpaper, window, workspace, group, input, and launcher behavior.
- The active AGS 3 per-monitor bar, Apps/Run/Windows/Power/Clipboard launcher, keybind sheet, laptop-control sidebar, general/day-planner sidebar, and native notification UI, with Waybar/Rofi/Mako retained for manual recovery.
- Stow-managed systemd user supervision for AGS, Astal notification ownership, and both Cliphist watchers.
- Git, Kitty, Dolphin, KDE, Fcitx5, Zsh, Neovim, Code OSS, Feh, ROG Control Center, notification, and desktop-integration settings.
- One deduplicated user-tool `PATH` shared by Hyprland applications, D-Bus/systemd user activations, and Zsh.
- Reviewed Arch/AUR/Flatpak package and system/user service manifests for the current workstation.
- Stable MamboColour roles shared by Hyprland, Hyprlock, AGS, and the recovery Waybar without depending on provider-internal colour names.
- Screenshot, clipboard, media, cursor, floating-window, power, and application-launcher helpers.
- The Zsh `tp` directory-bookmark function.
- Explicit host policy kept outside normal Stow packages.

Direct children of `dot/` are Stow packages. `script/mambodot.sh` accepts only `doctor`, `link`, and `unlink`: it previews selected Stow operations and reports package/service drift plus bounded managed-dotfile drift. The doctor checks known retired MamboColour links and packages it can infer are currently or partially linked; intentionally unlinked or wholly absent packages are not assumed. After repository layout changes, rerun `link` for affected packages. The command never installs packages, enables services, or reloads the desktop. Colour maintenance is a separate repository script rather than a deployment command.

## Getting started

```bash
git clone https://github.com/ProjectMambo/MamboDot.git "$HOME/ProjectMambo/MamboDot"
cd "$HOME/ProjectMambo/MamboDot"
./script/test.sh
./script/mambodot.sh doctor
./script/mambodot.sh link hypr ags script git kitty zsh
```

Replace that package list with the configuration you reviewed. Do not use `all` before reading [Installation and safety](Installation%20and%20Safety.md). Existing conflicting files are left unchanged and must be resolved deliberately.

## Dependencies

`manifest/packages.tsv` and `manifest/services.tsv` are the authoritative inventories for this workstation's direct desktop packages and enabled services. The table below declares the repository-level boundaries and update paths; transitive system dependencies remain owned by Arch packaging.

| Dependency | Classification | Purpose | Provider, version pin, or source | Scope | Update path |
|---|---|---|---|---|---|
| Arch Linux and reviewed package/service manifests | Platform | Supply the workstation runtime and record its intended package provenance and service enablement | Rolling Arch system; exact reviewed names in `manifest/packages.tsv` and `manifest/services.tsv` | Host runtime and `doctor` | Update the manifests with the host change, run `./script/mambodot.sh doctor`, and review every reported difference |
| Hyprland and companion desktop services | Runtime platform | Run the Lua configuration, compositor integrations, lock/idle/wallpaper behavior, and systemd user shell lifecycle | System packages recorded in the manifests; the configuration requires Hyprland's Lua `hl` API | Active desktop session | Update system packages deliberately, then parse the Lua modules and run Hyprland's configuration verifier |
| AGS 3, Astal, GTK4, and Sass | Runtime and build packages | Build and run the active bar, launcher, sidebars, and notification UI | System packages recorded in the package manifest; no repository-local version pin | AGS desktop shell | Update the host packages, run the AGS production bundle through `./script/test.sh`, and test the shell on each display |
| GNU Stow | Deployment tool | Preview, link, and unlink selected configuration packages with leaf symlinks | System package recorded in the package manifest; no repository-local version pin | `script/mambodot.sh link` and `unlink` | Update the system package, then run the guarded link/unlink regression suite before deployment |
| Bash, Lua, and standard Unix utilities | Tooling | Run repository commands and tests, load the Hyprland configuration, and refresh static colour adapters | System runtimes recorded in the package manifest; no repository-local version pin | Runtime, maintenance, and tests | Update the host runtimes, then run `./script/test.sh`, Lua parsing, and the shell checks |
| [MamboColour](https://github.com/ProjectMambo/MamboColour) | Vendored Project Mambo sibling library | Provide stable UI roles and deterministic accent selection without exposing palette-private names to consumers | Exact provider 0.2 revision `39f0b4e45ce3bb7be8a3ecda8081d7f77c6948e0`, recorded in `vendor/mambocolour/REVISION` beside the copied Lua module, four CSV files, and upstream MIT `LICENSE`; it eagerly validates paired schemes and uses the shared `0..4294967295` (`u32`) seed domain | Hyprland reads the vendored Lua API directly; Hyprlock, Waybar, and AGS use three committed consumer adapters | Replace the source and licence snapshot from one reviewed provider commit, update `REVISION`, run `lua script/sync_mambocolour.lua`, then run `./script/test.sh` and inspect the complete diff |
| Git and the Project Mambo documentation workspace | Development tools and sibling workspace | Version source, author canonical docs, and synchronize repository/wiki snapshots | System Git plus `notes/Docs/Projects/MamboDot/` and `notes/Scripts/sync_docs.js`; no tool version pin | Maintainer workflow only | Update canonical notes first, synchronize MamboDot and MamboWiki, then validate both generated snapshots |

## Documentation

| Goal | Document |
|---|---|
| Read the published documentation | [projectmambo.org/mambodot/](https://projectmambo.org/mambodot/) |
| Review requirements and install safely | [Installation and safety](Installation%20and%20Safety.md) |
| Learn desktop shortcuts | [Keybindings](Keybinds.md) |
| Link configuration, control or recover AGS, refresh colour adapters, or use `tp` | [Command reference](Commands.md) |
| Review implemented milestones and remaining refinements | [Roadmap](Roadmap.md) |

## Project structure

```text
dot/<package>/                 Stow packages rooted at the home directory
dot/ags/.config/ags/          active AGS bar, launcher, sidebars, notifications, and square Mambo styling
dot/git/.gitconfig            reviewed Git identity, credential-helper choice, and default branch
dot/hypr/.config/hypr/        Lua Hyprland entry, modules, rules, and assets
dot/hypr/.config/systemd/user supervised desktop-shell units and target
dot/zsh/.config/zsh/          Zsh configuration and local bookmark storage
manifest/                     reviewed package and enabled-service inventories
script/mambodot.sh            safe link/unlink and machine doctor command
script/sync_mambocolour.lua   consumer-owned semantic adapter generator/checker
script/test.sh                deployment, provider, and Hyprland regression checks
script/code-oss/              editor extension installer
system/hosts/<host>/          reviewed root-owned host policy, applied explicitly
vendor/mambocolour/           exact Lua API and palette snapshot plus provider revision
docs/                         operating documentation
```

## Validation

The repository has a focused local regression suite, but no CI workflow. Before committing configuration changes, run the available checks and inspect the exact diff:

```bash
bash -n script/mambodot.sh script/test.sh script/code-oss/install_extensions.sh dot/script/.local/bin/powermenu.sh
shellcheck script/mambodot.sh script/test.sh script/code-oss/install_extensions.sh dot/script/.local/bin/powermenu.sh
lua script/sync_mambocolour.lua --check
./script/test.sh
find dot/hypr/.config/hypr -name '*.lua' -print0 | xargs -0 -n1 luac -p
Hyprland --verify-config --config "$PWD/dot/hypr/.config/hypr/hyprland.lua"
git diff --check
git status --short
```

The command reference documents the exit-status contract for the repository command and the separate manual workflow for updating the vendored MamboColour snapshot. `lua script/sync_mambocolour.lua --check` is read-only and fails when one of the three committed adapters is missing or stale.

## Development

Canonical documentation lives under `notes/Docs/Projects/MamboDot/`. Edit that source, update the changed page's `updated` field, then synchronize the project and its published mount from the notes repository:

```bash
cd ~/ProjectMambo/notes
node Scripts/sync_docs.js --sync MamboDot MamboWiki
```

Review the generated MamboDot and MamboWiki differences and rerun their owning checks before delivery. Repository `README.md` and `docs/` files are synchronized outputs.

This is a personal desktop environment, so external pull requests are not currently requested. Bug reports and focused suggestions are welcome as repository issues.

## License

Distributed under the MIT License. See **[LICENSE](../LICENSE)** for details.
