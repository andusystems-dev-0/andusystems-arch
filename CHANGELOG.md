# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### Added
- Initial dotfiles scaffold: GNU Stow layout targeting `~/` with `dotfiles/home/` package
- Ansible playbook `ansible/configurations/arch.yml` with three roles: `bootstrap`,
  `core_packages`, `dotfiles`
- `bootstrap` role: enables `bluetooth.service` and `pangolin.service`, configures
  lid-close suspend policy, injects static `/etc/hosts` entries, sets git identity
- `core_packages` role: builds and installs `yay` (AUR helper) from source, installs full
  package list, auto-detects NVIDIA GPU and installs proprietary open-kernel drivers,
  blacklists `nouveau`, patches GRUB command line with `nvidia_drm.modeset=1`
- `dotfiles` role: idempotent GNU Stow linking with automatic conflict backup to
  `~/.dotfiles-backup/<timestamp>/`
- Hyprland compositor configuration: workspace layout, multi-monitor support via
  `nwg-displays`, keybindings, animations, border styling (orange Kanagawa gradient)
- Waybar status bar: auto-hide with Super-key peek, interactive shell menus for audio,
  network, Bluetooth, display, power, and system monitor
- Kitty terminal emulator configuration: Kanagawa Wave theme, JetBrains Mono Nerd Font,
  90% opacity with blur
- Tmux configuration: Alt+A prefix, vim-style pane navigation, Kanagawa Wave theme,
  date/time in status bar
- Neovim Lua configuration: lazy.nvim plugin manager, Kanagawa Wave colorscheme,
  neo-tree file browser, lazygit integration, lint support, Treesitter parsers
- Rofi application launcher: Kanagawa Wave dark theme, drun mode, vim controls, icon and
  scrollbar hidden
- Starship shell prompt: minimal directory-only format, 3-level truncation
- `hyprpaper` wallpaper daemon with `wallpaper.sh` rotation script and systemd user timer
- Qt5 and Qt6 theme configuration (`qt5ct`, `qt6ct`) for consistent GTK/Qt appearance
- Pangolin systemd unit (`pangolin.service`) installed by the `bootstrap` role: runs as
  root, reads cached auth from the `admin` user home directory
- `scripts/bootstrap.sh`: installs `ansible`, `python`, `stow` via pacman before first run
- `scripts/clone-repos.sh`: clones all andusystems repositories into `~/andusystems/`
  using credential-helper-based authentication
- `scripts/install-standalone-terminal.sh`: cross-distro installer for Neovim and Tmux
  only, with config symlinking; supports pacman, apt, dnf, and brew

### Changed
- Rofi replaced `blueman` with `bluetoothctl`-based Bluetooth menu scripts for a
  consistent CLI-driven approach across all Waybar menus
- Ansible roles refactored into logically separated files (`bootstrap.yml`,
  `core_packages.yml`, `dotfiles.yml`) to allow per-role re-runs via tags
- Hyprland workspace configuration rewritten with named, human-readable workspace
  assignments rather than index-based mapping
- Tmux status bar updated to display current date and day of the week alongside the time

### Fixed
- Hardware cursor flickering on NVIDIA proprietary drivers resolved by setting
  `no_hardware_cursors = true` in `hyprland.conf`
- Pangolin service DNS lookup failure resolved by adding the control-plane endpoint as a
  static `/etc/hosts` entry in the `bootstrap` role
- GNU Stow idempotency issue on re-runs resolved by detecting and removing broken symlinks
  before stowing; git config task made idempotent

---

*Dates reflect the git commit history. All changes were made between 2026-04-19 and 2026-04-26.*
