# andusystems-arch

> Reproducible Arch Linux developer workstation — dotfiles and Ansible automation for the andusystems homelab.

## Purpose

This repository provisions and maintains a complete Arch Linux desktop environment from a
fresh `archinstall` base. It pairs GNU Stow-managed dotfiles with an Ansible playbook that
installs packages, enables system services, configures GPU drivers, and symlinks all
configuration files — all in a single idempotent run. The workstation runs Hyprland on
Wayland and is integrated with the broader andusystems homelab via the Pangolin tunnel
service for remote access and management.

## At a glance

| Field | Value |
|---|---|
| Type | tooling |
| Role | spoke |
| Primary stack | Ansible + GNU Stow + Hyprland (Wayland) |
| Deployed by | self-bootstrap |
| Status | production |

## Components

| Component | Purpose | Location |
|---|---|---|
| `bootstrap` Ansible role | Enables services, sets git identity, configures lid-close policy | `ansible/configurations/roles/bootstrap/` |
| `core_packages` Ansible role | Installs packages via yay (AUR); auto-detects and installs NVIDIA drivers | `ansible/configurations/roles/core_packages/` |
| `dotfiles` Ansible role | Symlinks all configs into `$HOME` via GNU Stow with conflict backup | `ansible/configurations/roles/dotfiles/` |
| Hyprland | Wayland compositor; workspaces, keybindings, multi-monitor layout | `dotfiles/home/.config/hypr/` |
| Waybar | Auto-hiding status bar; interactive menus for audio, network, Bluetooth | `dotfiles/home/.config/waybar/` |
| Neovim | Lua-based editor config using lazy.nvim plugin manager | `dotfiles/home/.config/nvim/` |
| Kitty | GPU-accelerated terminal emulator with Kanagawa Wave theme | `dotfiles/home/.config/kitty/` |
| Tmux | Terminal multiplexer; Alt-prefix, vim-style navigation, Kanagawa theme | `dotfiles/home/.config/tmux/` |
| Rofi | Wayland application launcher (drun mode) with Kanagawa Wave styling | `dotfiles/home/.config/rofi/` |
| `scripts/` | Bootstrap helpers: dependency installer, repo cloner, terminal-only setup | `scripts/` |

## Architecture

```
  ┌──────────────────────────────────────────────────────────┐
  │                   Arch Linux (Wayland)                    │
  │                                                          │
  │   ┌───────────────────────────────────────────────────┐  │
  │   │                    Hyprland                        │  │
  │   │       workspaces · keybindings · multi-monitor     │  │
  │   └──────┬────────────────────────────┬───────────────┘  │
  │          │                            │                   │
  │   ┌──────▼──────┐            ┌────────▼────────┐         │
  │   │   Waybar    │            │  Kitty → Tmux   │         │
  │   │ (auto-hide) │            │    → Neovim     │         │
  │   └──────┬──────┘            └─────────────────┘         │
  │          │  rofi · hyprpaper · starship · qt5/6ct        │
  │   Pangolin service ──────► homelab control plane          │
  └──────────────────────────────────────────────────────────┘

  Provision path:
  scripts/bootstrap.sh ──► ansible-playbook arch.yml
      ├── bootstrap role     (services, git config, /etc/hosts)
      ├── core_packages      (yay, package list, optional NVIDIA)
      └── dotfiles role      (GNU Stow: dotfiles/home/ ──► ~/)
```

Hyprland manages the Wayland compositor session; all applications share the Kanagawa Wave
colour palette for visual coherence. The Pangolin daemon runs as a systemd unit and
maintains a persistent tunnel to homelab infrastructure. See
[docs/architecture.md](docs/architecture.md) for component diagrams, data flows, and
design decisions.

## Quick start

### Prerequisites

| Tool | Min version | Purpose |
|---|---|---|
| Arch Linux | rolling | Target OS — install with `archinstall` |
| `git` | any | Clone this repository |
| `base-devel` | any | Build toolchain (required to compile yay) |
| `ansible` | ≥ 2.15 | Run the provisioning playbook |
| `python` | ≥ 3.11 | Ansible runtime dependency |
| `stow` | any | Dotfile symlink manager (installed by `bootstrap.sh`) |
| NVIDIA GPU | optional | Drivers are auto-detected and installed if present |

### Deploy / run

```bash
# 1. Install Ansible, Python, and Stow (run as non-root with sudo access)
bash scripts/bootstrap.sh

# 2. Clone this repository into ~/andusystems/
git clone <internal-git-host>/andusystems/andusystems-arch.git \
    ~/andusystems/andusystems-arch

# 3. Run the full provisioning playbook
cd ~/andusystems/andusystems-arch
ansible-playbook ansible/configurations/arch.yml

# 4. Reboot (or log out and back in) to start the Hyprland Wayland session
```

For a minimal terminal-only install on any Linux distro, run
`scripts/install-standalone-terminal.sh` instead — it installs Neovim and Tmux and links
only those configs. See [docs/development.md](docs/development.md) for the full workflow
and day-to-day usage.

## Configuration

| Key / variable | Required | Description |
|---|---|---|
| `bootstrap_enabled_services` | yes | Systemd units enabled on the host (Bluetooth, Pangolin) |
| `bootstrap_extra_hosts` | no | Static `/etc/hosts` entries injected by the bootstrap role |
| `core_packages_yay_packages` | yes | Full package list; edit role defaults to add or remove packages |
| `dotfiles_stow_dir` | yes | Absolute path to the Stow source tree (auto-derived from role path) |
| `dotfiles_target` | yes | Symlink destination; defaults to `$HOME` |
| `EDITOR` | no | Set in `.bashrc` to `nvim`; override in a local shell profile |
| Monitor layout | no | Managed interactively via `nwg-displays`; persisted to `monitors.conf` |

Role defaults live in `roles/<name>/defaults/main.yml`. No environment variables need to
be exported before running the playbook.

## Repository layout

```
.
├── ansible/
│   └── configurations/
│       ├── arch.yml                        # Main playbook entry point
│       └── roles/
│           ├── bootstrap/                  # Services, git config, lid policy
│           ├── core_packages/              # yay build + package installation
│           └── dotfiles/                   # GNU Stow symlink management
├── dotfiles/
│   └── home/                               # Stow package — targets ~/
│       ├── .bashrc                         # Shell config, aliases, starship init
│       └── .config/
│           ├── hypr/                       # Hyprland compositor + scripts
│           ├── kitty/                      # Terminal emulator
│           ├── nvim/                       # Neovim (Lua, lazy.nvim)
│           ├── rofi/                       # Application launcher
│           ├── tmux/                       # Terminal multiplexer
│           ├── waybar/                     # Status bar + shell menu scripts
│           └── starship.toml               # Shell prompt
└── scripts/
    ├── bootstrap.sh                        # Install Ansible + Stow pre-requisites
    ├── clone-repos.sh                      # Clone all andusystems repos
    └── install-standalone-terminal.sh      # Nvim + Tmux on non-Arch systems
```

## Related repos

| Repo | Relation |
|---|---|
| andusystems-management | hub — manages homelab-wide services this workstation connects to |
| andusystems-networking | homelab networking layer that the Pangolin tunnel terminates in |
| andusystems-sentinel | automated documentation generation for this and other repos |

## Further documentation

- [Architecture](docs/architecture.md) — component diagram, data flows, design decisions
- [Development](docs/development.md) — local setup, day-to-day workflow, adding packages
- [Changelog](CHANGELOG.md) — release history
