# MamboDot
<p align="left">
  <img src="https://img.shields.io/badge/OS-Arch_Linux-1793D1?style=flat-square&logo=arch-linux&logoColor=white" />
  <img src="https://img.shields.io/badge/WM-Hyprland-33CCFF?style=flat-square&logo=wayland&logoColor=white" />
  <img src="https://img.shields.io/badge/Managed_With-GNU_Stow-4A4A4A?style=flat-square&logo=gnu&logoColor=white" />
</p>
<p align="left">
  <img src="https://img.shields.io/badge/Maintenance-Active-brightgreen?style=flat-square" />
  <img src="https://img.shields.io/github/last-commit/ProjectMambo/MamboDot?style=flat-square&color=7a5fff" />
  <img src="https://img.shields.io/github/repo-size/ProjectMambo/MamboDot?style=flat-square&color=yellow" />
  <a href="LICENSE"><img src="https://img.shields.io/github/license/ProjectMambo/MamboDot?style=flat-square&color=orange" /></a>
</p>

A GNU Stow-managed dotfiles repository optimised for speed and consistent styling.

## Features
- Consistent **styling** across different apps.
- Complete **controls** for seamless use.
- Custom **commands** like `tp` for easier terminal controls.

## Demo
Not available for now.

## Getting Started

### Prerequisites
Before installing, ensure you have the following packages *(required)* installed on your system:
 - **[Arch Linux](https://archlinux.org)** - The base Linux distribution used for this environment.
 - **[Avizo](https://github.com/heyjuvi/avizo)** - A neat notification daemon for audio and brightness status.
 - **[brightnessctl](https://github.com/Hummer12007/brightnessctl)** - The core utility to control brightness.
 - **[Code OSS](https://github.com/microsoft/vscode)** - The open-source version of the Visual Studio Code editor.
 - **[Curl](https://curl.se/)** - A command-line utility for transferring data with URLs, used to fetch scripts.
 - **[Dolphin](https://wiki.archlinux.org/title/Dolphin)** - The default graphical file manager for navigating directories.
 - **[Fcitx5](https://github.com/fcitx/fcitx5)** - The input method framework for multi-languages support.
 - **[Git](https://git-scm.com/)** - Version control system used to clone and manage this repository.
 - **[GNU Stow](https://www.gnu.org/software/stow/)** - A symlink installation manager used to deploy configuration files.
 - **[grim](https://sr.ht/~emersion/grim/)** - The core utility that captures image data on Wayland.
 - **[Hyprland](https://hypr.land/)** - The dynamic tiling Wayland compositor acting as the desktop environment.
 - **[Kitty](https://github.com/kovidgoyal/kitty)** - A fast, feature-rich, GPU-accelerated terminal emulator.
 - **[Neovim (Nvim)](https://neovim.io/)** - Vim-based text editor used for terminal text editing.
 - **[Oh My Zsh](https://ohmyz.sh/)** - An open-source, community-driven framework for managing the Zsh configuration.
 - **[pamixer](https://github.com/cdemoulins/pamixer)** - The core utility to control volume.
 - **[Rofi](https://github.com/davatorium/rofi)** - A window switcher, application launcher, and dmenu replacement.
 - **[slurp](https://github.com/emersion/slurp)** - An interactive tool that allows on-screen region selection.
 - **[Waybar](https://waybar.org/)** - A highly customizable Wayland bar for Hyprland.
 - **[wl-clipboard](https://github.com/bugaevc/wl-clipboard)** - A clipboard manager utility.
 - **[Zsh](https://www.zsh.org/)** - The primary interactive command shell.
 - **[ProjectMambo/MamboColour](https://github.com/ProjectMambo/MamboColour)** - The centralized color palette system used across these configurations.

The following packages *(optional)* are encouraged to install:
- **[Obsidian](https://obsidian.md/)** - The default notes/markdown editor.
- **[Zen Browser](https://zen-browser.app/)** - The default browser.
> [!TIP]
> If you choose not to install the optional applications, you may need to manually update the target variables inside your Hyprland configuration files to prevent shortcut execution errors.

### Install Prerequisites

#### Install official packages through Pacman
```bash
sudo pacman -S brightnessctl code curl dolphin fcitx5-im fcitx5-chinese-addons git grim stow hyprland kitty neovim pamixer rofi slurp waybar wl-clipboard zsh zsh-completions
```

#### Install Oh My Zsh through Curl
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Install AUR packages through Yay
```bash
yay -S avizo
```

#### Install Custom Colour Palette
See the installation guide on **[MamboColour](https://github.com/ProjectMambo/MamboColour)** to set up the global theme dependency.

#### Install Optional Packages
```bash
sudo pacman -S obsidian
yay -S zen-browser-bin
```

### Quick Start
Clone and run the install script:
```bash
# Clone the repository and navigate into the directory
git clone https://github.com/ProjectMambo/MamboDot
cd MamboDot
# Make the installation script executable and run it
chmod +x script/install.sh
./script/install.sh
```
Once the install script completes successfully, reboot your machine to apply all system configurations:
```bash
reboot
```

## Usage
- **[Keybind Guide](docs/Keybinds.md)** - A list of keybinds for windows/workspace movements & system utilities.
- **[Custom Commands](docs/Commands.md)** - A list of custom commands for easier terminal controls.

## Issues & Feedback
Since this is our personal dotfiles environment, we are not looking for external pull requests. However, if you spot a bug or have a suggestion regarding the automation scripts, feel free to open an **Issue** to let me know!

## License
Distributed under the MIT License. See **[LICENSE](LICENSE)** for more information.