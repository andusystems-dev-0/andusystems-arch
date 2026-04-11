# andusystems-arch

Ansible-managed Arch Linux workstation configuration with Hyprland (Wayland compositor), automated theming, and dotfiles management via GNU Stow.

This repo provisions a complete development-ready desktop from a fresh Arch Linux install — including packages, dotfile symlinks, NVIDIA drivers, wallpaper-driven color theming, and workspace repository cloning.

## Quick Start

### Prerequisites

- Fresh Arch Linux install with network connectivity
- A user account with sudo access
- NVIDIA GPU (optional — the nvidia role can be skipped)

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
| `desktop_packages` | Wayland stack, browser, audio, bluetooth, fonts, media tools |
| `dotfiles` | Adopt unmanaged configs and stow all dotfiles |
| `app_cleanup` | Remove unwanted packages, install replacements, hide launcher entries |
| `theming` | Wallpaper directory, script permissions, systemd services, matugen colors |
| `youtube_tui` | youtube-tui + yt-dlp configuration and authentication setup |
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
│       ├── desktop_packages/    # Wayland, audio, bluetooth, browser
│       ├── dotfiles/            # Stow-based config management
│       ├── app_cleanup/         # Package removal + launcher hiding
│       ├── theming/             # Wallpaper/color pipeline + systemd units
│       ├── youtube_tui/         # youtube-tui + yt-dlp auth setup
│       ├── nvidia/              # NVIDIA driver + kernel module config
│       └── workspace_repos/     # Git repo cloning from internal host
├── dotfiles/home/.config/       # All managed dotfiles (symlinked via stow)
├── scripts/
│   └── bootstrap.sh             # Initial Ansible + dependency installer
└── docs/                        # Extended documentation
```

### Theming Pipeline

The system uses wallpaper-driven color generation:

1. `theme-switch.sh` picks a random wallpaper from `~/Wallpapers/`
2. Sets it via `awww` with an animated transition
3. Runs `matugen` to generate Material You colors from the wallpaper
4. Color templates are applied to: Hyprland, Kitty, Waybar, Rofi, GTK 3/4, Neovim, swaync
5. All themed apps are reloaded automatically
6. A systemd timer runs this periodically

### Workspace Layout

On login, Hyprland autostarts persistent windows:

- **Workspace 1**: youtube-tui (bottom-left), [AI_ASSISTANT] Code terminal (top-right), shell (bottom-right)
- **Workspace 2**: Full-screen Neovim (LazyVim)

### Dotfiles Management

Configs in `dotfiles/home/.config/` are symlinked to `~/.config/` via GNU Stow. The dotfiles role auto-adopts unmanaged configs from `~/.config/` into the repo (excluding sensitive directories like browser profiles, credentials, and runtime state).

To adopt new configs:
```bash
ansible-playbook ansible/configurations/arch.yml --tags dotfiles -K
```

## Configuration Reference

### Key Config Files

| File | Purpose |
|------|---------|
| `dotfiles/home/.config/hypr/hyprland.conf` | Hyprland compositor config (monitors, keybinds, window rules) |
| `dotfiles/home/.config/matugen/config.toml` | Matugen template registry for color generation |
| `dotfiles/home/.config/kitty/kitty.conf` | Terminal emulator settings |
| `dotfiles/home/.config/waybar/` | Status bar config and styling |
| `dotfiles/home/.config/rofi/` | Application launcher config and theme |
| `dotfiles/home/.config/swaync/` | Notification center styling |
| `ansible/configurations/roles/dotfiles/defaults/main.yml` | Directories excluded from dotfile tracking |
| `.gitignore` | Defense-in-depth exclusion of secrets and generated files |

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

- [Architecture](docs/architecture.md) — component design, data flows, theming pipeline
- [Development](docs/development.md) — prerequisites, local dev setup, testing
- [Packages](docs/packages.md) — full package inventory
- [Keybinds](docs/keybinds.md) — keyboard shortcut reference
- [Customization](docs/customization.md) — adapting to your system
- [Troubleshooting](docs/troubleshooting.md) — common issues and fixes
- [Changelog](CHANGELOG.md) — version history
