# Architecture

This document describes the structure, data flows, and design decisions behind
`andusystems-arch`.

## Overview

The repository has two distinct concerns that work together:

1. **Ansible automation** — one-shot provisioning of a fresh Arch Linux system.
2. **GNU Stow dotfiles** — persistent, symlink-based configuration management.

After a single `ansible-playbook` run, the machine is fully configured: packages are
installed, system services are running, NVIDIA drivers (if applicable) are wired into
initramfs, and every dotfile is symlinked from the repository into `$HOME`.

---

## Component diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          Arch Linux (Wayland)                            │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                         Hyprland (WM)                             │  │
│  │  ┌────────────┐  ┌───────────┐  ┌──────────┐  ┌──────────────┐  │  │
│  │  │ monitors   │  │ workspaces│  │keybindings│  │  animations  │  │  │
│  │  └────────────┘  └───────────┘  └──────────┘  └──────────────┘  │  │
│  └──┬────────────────────────────────────────────────────────────┬──┘  │
│     │                                                            │     │
│  ┌──▼──────────────┐                               ┌────────────▼──┐  │
│  │     Waybar       │                               │  Kitty (term) │  │
│  │ auto-hide/peek   │                               │  └─ Tmux      │  │
│  │ ┌─────────────┐ │                               │     └─ Neovim │  │
│  │ │ shell menus │ │                               └───────────────┘  │
│  │ │ (rofi)      │ │                                                   │
│  │ └─────────────┘ │  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  └─────────────────┘  │   Rofi   │  │hyprpaper │  │   starship   │  │
│                        │(launcher)│  │(wallpaper)│  │(shell prompt)│  │
│                        └──────────┘  └──────────┘  └──────────────┘  │
│                                                                         │
│  Pangolin (systemd unit) ─────────────► homelab control plane           │
└─────────────────────────────────────────────────────────────────────────┘

Provision layer (runs once on fresh install):

  scripts/bootstrap.sh
       │  installs: ansible, python, stow
       ▼
  ansible-playbook ansible/configurations/arch.yml
       ├── bootstrap role
       │       enables: bluetooth.service, pangolin.service
       │       writes:  /etc/systemd/logind.conf.d/ (lid policy)
       │       writes:  /etc/hosts (static homelab entries)
       │       sets:    git user.name / user.email
       │
       ├── core_packages role
       │       builds:  yay from source (AUR helper)
       │       installs: all packages in defaults/main.yml
       │       detects: NVIDIA GPU → installs proprietary drivers,
       │                            blacklists nouveau,
       │                            patches GRUB cmdline
       │
       └── dotfiles role
               removes: broken symlinks under $HOME
               backs up: conflicting files → ~/.dotfiles-backup/<timestamp>/
               stows:   dotfiles/home/ ──symlinks──► ~/
```

---

## Data flows

### Provisioning flow

```
1. User runs bash scripts/bootstrap.sh
       → pacman installs: ansible, python, stow

2. User runs ansible-playbook ansible/configurations/arch.yml
       → Ansible resolves roles in order: bootstrap, core_packages, dotfiles

3. core_packages role:
       → git clone + make yay in /tmp/yay
       → yay -S --noconfirm <package-list>
       → lspci | grep NVIDIA → if true, install nvidia-open-dkms + extras
       → curl install-script → pangolin CLI

4. dotfiles role:
       → stow --target=$HOME --dir=dotfiles home
       → all files under dotfiles/home/ appear as symlinks under ~/
```

### Runtime data flows

```
User input
   │
   ▼
Hyprland keybindings
   ├── Super+R   → rofi (app launcher) → launch application
   ├── Super+Q   → kitty -e tmux        → terminal session
   ├── Super+W   → kitty -e nvim        → editor
   ├── Volume/Brightness keys → brightnessctl / wpctl
   └── Super+E   → waybar settings-menu.sh → rofi sub-menu

Waybar (auto-hide, peeks on Super keypress)
   ├── CPU/RAM module    → sysmon.sh        → tooltip via sysmon-tooltip.sh
   ├── Clock module      → system time      → calendar tooltip
   ├── Settings button   → settings-menu.sh → rofi menu
   ├── Audio button      → audio-menu.sh    → rofi menu → pactl / wpctl
   ├── Network button    → network-menu.sh  → rofi menu → nmcli
   └── Bluetooth button  → bluetooth-menu.sh → rofi menu → bluetoothctl
```

### Stow symlink model

```
Repository:                    Home directory (after stow):
dotfiles/
  home/
    .bashrc          ──────►  ~/.bashrc
    .config/
      hypr/          ──────►  ~/.config/hypr/
      kitty/         ──────►  ~/.config/kitty/
      nvim/          ──────►  ~/.config/nvim/
      tmux/          ──────►  ~/.config/tmux/
      waybar/        ──────►  ~/.config/waybar/
      rofi/          ──────►  ~/.config/rofi/
      starship.toml  ──────►  ~/.config/starship.toml
```

Symlinks mean edits in `$HOME` are edits in the repository — no sync step required.

---

## Design decisions

### GNU Stow for dotfiles

GNU Stow mirrors the directory structure of a stow package into the target directory as
symlinks. This keeps the dotfiles repository self-contained: every config file is under
version control, and editing `~/.config/hypr/hyprland.conf` directly edits the file in
the repo checkout. Alternatives (copy-based scripts, bare git repos) were rejected because
they require an explicit sync step or pollute `$HOME` with a git directory.

### Idempotent Ansible roles

All three roles are designed to be re-run safely. The `dotfiles` role backs up conflicting
files before stowing, the `core_packages` role skips already-installed packages, and the
`bootstrap` role uses Ansible's service/template/lineinfile modules which are idempotent by
default.

### NVIDIA auto-detection

The `core_packages` role runs `lspci | grep -i nvidia` to detect the GPU at provisioning
time, then conditionally installs `nvidia-open-dkms`, patches `/etc/mkinitcpio.conf`, and
adds `nvidia_drm.modeset=1` to the GRUB command line. This avoids maintaining separate
playbooks for Intel/AMD and NVIDIA machines.

### Software cursor (NVIDIA workaround)

Hyprland is configured with `no_hardware_cursors = true`. NVIDIA proprietary drivers on
Wayland exhibit cursor flickering with hardware cursor rendering; the software cursor
eliminates this at a negligible performance cost.

### Waybar auto-hide via key-hold

Waybar is hidden by default (`layer = overlay`, fully transparent when idle). A
`waybar-peek.sh` script uses `hyprctl` to detect when the Super key is held and briefly
reveals the bar. This keeps the desktop uncluttered while still providing quick status
access.

### Unified Kanagawa Wave theme

All applications (Hyprland, Kitty, Tmux, Rofi, Waybar) use the same Kanagawa Wave colour
palette (dark background `#141418`, foreground `#dcd7ba`, accent orange `#ff9e3b`). Theme
values are duplicated intentionally — a single source-of-truth theme file would require
per-application template rendering, adding complexity that outweighs the benefit for a
single-user setup.

### Logically separated Ansible roles

Bootstrap, package installation, and dotfile linking are separate roles so that any one
step can be re-run in isolation. For example, after adding a new config file to `dotfiles/`
it is enough to run only the `dotfiles` role without reinstalling packages.

---

## Invariants

- The `dotfiles/home/` stow package must mirror the home directory structure exactly.
  Files placed at the wrong depth will stow to the wrong location.
- The `core_packages` role installs `yay` from source in a temporary directory and removes
  it after installation. The AUR helper must be available for all subsequent `yay` calls in
  the same role.
- GRUB configuration is only patched when an NVIDIA GPU is detected. Running the role on
  a non-NVIDIA machine must not modify the GRUB command line.
- The `pangolin.service` unit is installed as a system service that runs as root but reads
  cached auth state from the `admin` user's home directory.

---

## Concurrency model

Ansible executes tasks sequentially within a role. The playbook runs roles in order:
`bootstrap` → `core_packages` → `dotfiles`. There is no parallelism within a single host
run. Stow itself is single-threaded. The Waybar shell scripts are invoked by user
interaction and run as short-lived subprocesses; they do not share state.
