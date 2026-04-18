
# andusystems-arch

Ansible-managed Arch Linux workstation configuration with Hyprland (Wayland compositor), automated wallpaper-driven Material You theming, and dotfiles management via GNU Stow.

This repository provisions a complete development-ready desktop environment from a fresh Arch Linux install — including packages, dotfile symlinks, NVIDIA drivers, a wallpaper-driven color theming pipeline, and workspace repository cloning.

## Quick Start

### Prerequisites

- Fresh Arch Linux install with network connectivity
- A user account with sudo access
- NVIDIA GPU (optional — the `nvidia` role can be skipped)

### Installation

**1. Clone the repo**

```bash
git clone <repo-url> ~/andusystems/andusystems-arch
cd ~/andusystems/andusystems-arch
```

**2. Run the bootstrap script**

Installs Ansible, Python, Git, Go, and base-devel:

```bash
sudo bash scripts/bootstrap.sh
```

**3. Run the full playbook**

The `-K` flag prompts for your sudo password:

```bash
ansible-playbook ansible/configurations/arch.yml -K
```

### Running Individual Roles

Each role has its own tag for selective execution:

| Tag | What it does |
|-----|-------------|
| `core_packages` | yay (AUR helper), Neovim + LazyVim, stow, lazygit, networking |
| `desktop_packages` | Wayland stack, browser, audio (PipeWire), bluetooth, fonts, media tools |
| `dotfiles` | Adopt unmanaged configs and stow all dotfiles |
| `app_cleanup` | Remove unwanted packages, install replacements, hide launcher entries |
| `theming` | Wallpaper directory, script permissions, systemd services, matugen colors |
| `nvidia` | NVIDIA open drivers, DRM kernel modules, initramfs rebuild |
| `workspace_repos` | Clone all workspace repos from the internal Git host |

Example — only apply dotfiles:

```bash
ansible-playbook ansible/configurations/arch.yml --tags dotfiles -K
```

## Architecture Summary

```
andusystems-arch/
├── ansible/configurations/
│   ├── arch.yml                 # Main playbook (imports all roles)
│   └── roles/
│       ├── core_packages/       # CLI tools + yay + LazyVim
│       ├── desktop_packages/    # Wayland, audio, bluetooth, browser, fonts
│       ├── dotfiles/            # Stow-based config management
│       ├── app_cleanup/         # Package removal + launcher hiding
│       ├── theming/             # Wallpaper/color pipeline + systemd units
│       ├── nvidia/              # NVIDIA driver + kernel module config
│       └── workspace_repos/     # Git repo cloning from internal host
├── dotfiles/home/.config/       # All managed dotfiles (symlinked via stow)
├── scripts/
│   └── bootstrap.sh             # Initial Ansible + dependency installer
└── docs/                        # Extended documentation
```

### Theming Pipeline

The system uses wallpaper-driven color generation via [matugen](https://github.com/InioX/matugen) (Material You color extraction):

1. `theme-switch.sh` picks a random wallpaper from `~/Wallpapers/`
2. Sets it via `awww` with an animated fade transition
3. Runs `matugen` to extract a Material You color palette from the wallpaper
4. Color templates are rendered and applied to: Hyprland, Kitty, Waybar, Rofi, GTK 3/4, Neovim, swaync
5. All themed applications are hot-reloaded automatically (signals, socket commands)
6. A systemd timer rotates wallpapers and regenerates colors every 5 minutes

### Workspace Layout

On login, Hyprland autostarts persistent windows across two workspaces:

- **Workspace 1**: [AI_ASSISTANT] Code terminal (top-right), shell (bottom-right)
- **Workspace 2**: Full-screen Neovim (LazyVim)

Scratchpad-style special workspaces provide quick access to btop, nmtui, and bluetuith.

### Dotfiles Management

Configs in `dotfiles/home/.config/` are symlinked to `~/.config/` via GNU Stow. The dotfiles role auto-adopts unmanaged configs from `~/.config/` into the repo (excluding sensitive directories like browser profiles, credentials, and runtime state).

To adopt new configs:

```bash
ansible-playbook ansible/configurations/arch.yml --tags dotfiles -K
```


### Security Model

Two independent mechanisms prevent secrets from being committed:

1. **`dotfiles_exclude` list** — the primary defense. Prevents the dotfiles Ansible role from ever adopting sensitive directories (browser profiles, cloud credentials, IDE sessions, shell history).
2. **`.gitignore`** — the safety net. Blocks git from tracking sensitive paths that might be adopted accidentally.

Both lists are kept in sync for defense-in-depth.

## Configuration Reference

### Key Config Files

| File | Purpose |
|------|---------|
| `dotfiles/home/.config/hypr/hyprland.conf` | Hyprland compositor (monitors, keybinds, window rules, animations) |
| `dotfiles/home/.config/matugen/config.toml` | Matugen template registry for color generation |
| `dotfiles/home/.config/kitty/kitty.conf` | Terminal emulator settings and fonts |
| `dotfiles/home/.config/waybar/config.jsonc` | Status bar modules and layout |
| `dotfiles/home/.config/rofi/config.rasi` | Application launcher configuration |
| `dotfiles/home/.config/rofi/theme.rasi` | Application launcher theme |
| `dotfiles/home/.config/swaync/config.json` | Notification center settings |
| `dotfiles/home/.config/hypr/hypridle.conf` | Idle timeout behavior (dim, screen off) |
| `ansible/configurations/roles/dotfiles/defaults/main.yml` | Directories excluded from dotfile tracking |
| `.gitignore` | Defense-in-depth exclusion of secrets and generated files |

### Systemd User Services

| Unit | Type | Description |
|------|------|-------------|
| `theme-switch.service` | oneshot | Selects random wallpaper and regenerates colors |
| `theme-switch.timer` | timer | Triggers wallpaper rotation every 5 minutes |
| `nightlight.service` | oneshot | Adjusts display color temperature by time of day |
| `nightlight.timer` | timer | Triggers nightlight at 07:00 and 21:00 |
| `waybar.service` | service | Status bar (auto-restart on crash) |
| `swaync.service` | service | Notification center (D-Bus activated via systemd) |

### Customization

See [docs/customization.md](docs/customization.md) for:

- Monitor resolution adjustments
- Username changes (hardcoded paths)
- Nightlight location
- Wallpaper management
- Adding apps to the matugen theming pipeline
- Font changes
- Excluding configs from dotfile tracking

## Further Documentation

- [Architecture](docs/architecture.md) — component design, data flows, theming pipeline details
- [Development](docs/development.md) — prerequisites, local dev setup, testing, adding roles
- [Packages](docs/packages.md) — full package inventory
- [Keybinds](docs/keybinds.md) — keyboard shortcut reference
- [Customization](docs/customization.md) — adapting to your system
- [Troubleshooting](docs/troubleshooting.md) — common issues and fixes
- [Changelog](CHANGELOG.md) — version history
