# Development

Guide for modifying and extending the andusystems-arch configuration.

## Prerequisites

| Requirement | Purpose |
|------------|---------|
| Arch Linux | Target OS (playbooks use pacman/yay) |
| sudo access | Package installation, systemd service management |
| `ansible` | Configuration management (installed by bootstrap.sh) |
| `python`, `python-pip` | Ansible runtime |
| `git` | Repo management, LazyVim clone, workspace repo cloning |
| `base-devel` | Required for building AUR packages via yay |
| `go` | Required for building yay from source |
| `stow` | Dotfile symlink management (installed by core_packages role) |

## Initial Setup

```bash
# 1. Clone the repository
git clone <repo-url> ~/andusystems/andusystems-arch
cd ~/andusystems/andusystems-arch

# 2. Bootstrap (installs ansible + dependencies)
sudo bash scripts/bootstrap.sh

# 3. Full provisioning run
ansible-playbook ansible/configurations/arch.yml -K
```

The bootstrap script runs `pacman -Syu` and installs: `ansible`, `python`, `python-pip`, `git`, `base-devel`, and `go`.

## Common Development Tasks

### Adding a New Package

1. Determine which role the package belongs to:
   - CLI/dev tools → `core_packages/defaults/main.yml` (`aur_packages` list)
   - Desktop/GUI apps → `desktop_packages/defaults/main.yml` (`aur_packages` list)
   - NVIDIA-specific → `nvidia/defaults/main.yml` (`nvidia_packages` list)

2. Add the package name to the appropriate list.

3. Test:
   ```bash
   ansible-playbook ansible/configurations/arch.yml --tags <role_tag> -K
   ```

### Adding a New Dotfile Config

1. Place the config directory under `dotfiles/home/.config/<app>/`.
2. Run the dotfiles role to create symlinks:
   ```bash
   ansible-playbook ansible/configurations/arch.yml --tags dotfiles -K
   ```
3. Verify the symlink exists: `ls -la ~/.config/<app>`.

### Excluding a Config from Tracking

Sensitive directories must be excluded from both the Ansible adoption step and git tracking. Add the directory name to both:

- `ansible/configurations/roles/dotfiles/defaults/main.yml` → `dotfiles_exclude` list
- `.gitignore` → under the appropriate section

### Adding a New Matugen-Themed App

1. Create a color template in `dotfiles/home/.config/matugen/templates/<app>.<ext>` using matugen's template variable syntax (e.g., `{{colors.primary.default.hex}}`).
2. Register the template in `dotfiles/home/.config/matugen/config.toml` with input path and output path.
3. Add a reload command in the `theme-switch.sh` script so the app picks up new colors without restart.

See [docs/customization.md](customization.md) for detailed examples.

### Adding a New Ansible Role

1. Create the role directory structure:
   ```
   ansible/configurations/roles/<role_name>/
   ├── defaults/main.yml    # Default variables
   └── tasks/
       ├── main.yml          # Entry point (includes subtasks)
       └── <subtask>.yml     # Actual task definitions
   ```

2. Create the role playbook wrapper:
   ```yaml
   # ansible/configurations/roles/<role_name>.yml
   - name: <Description>
     gather_facts: true
     hosts: localhost
     tasks:
       - include_role:
           name: <role_name>
         tags:
           - <role_name>
   ```

3. Import it in `ansible/configurations/arch.yml`:
   ```yaml
   - import_playbook: ./roles/<role_name>.yml
   ```

4. **Important:** Use `include_tasks` (not `import_tasks`) in `tasks/main.yml` when applying tags. `import_tasks` causes Ansible to silently skip tagged tasks — see [docs/troubleshooting.md](troubleshooting.md).

### Adding a New Script

1. Place the script in `dotfiles/home/.local/bin/<script-name>.sh`.
2. Add a `chmod +x` task in the theming role's `setup.yml` (or the appropriate role).
3. If it needs periodic execution, create a systemd timer + oneshot service pair in `dotfiles/home/.config/systemd/user/`.

### Modifying the Package Removal/Cleanup List

Edit `ansible/configurations/roles/app_cleanup/defaults/main.yml`:

- `packages_to_remove` — packages removed via `pacman -Rns`
- `packages_to_install` — replacement packages installed via yay
- `launchers_to_hide` — `.desktop` files that get `NoDisplay=true` set locally

## Testing

### Full Playbook Run

```bash
ansible-playbook ansible/configurations/arch.yml -K
```

### Single Role

```bash
ansible-playbook ansible/configurations/arch.yml --tags <tag> -K
```

### Dry Run (Check Mode)

```bash
ansible-playbook ansible/configurations/arch.yml --check -K
```

**Note:** Check mode will fail on shell tasks (yay installs, makepkg) since they cannot simulate execution. Use it primarily to verify file/directory operations and template rendering.

### Stow Dry Run

Preview what stow would do without making changes:

```bash
stow --dir=dotfiles --target=$HOME --restow --simulate home
```

### Testing Theming

Manually trigger a wallpaper rotation and color regeneration:

```bash
~/.local/bin/theme-switch.sh
```

Or trigger via systemd:

```bash
systemctl --user start theme-switch.service
```

## Available Ansible Tags

| Tag | Role | Description |
|-----|------|-------------|
| `core_packages` | core_packages | Full core packages role |
| `desktop_packages` | desktop_packages | Full desktop packages role |
| `dotfiles` | dotfiles | Adopt + stow dotfiles |
| `app_cleanup` | app_cleanup | Full cleanup role |
| `remove` | app_cleanup | Remove unwanted packages only |
| `install` | app_cleanup / core / desktop / nvidia | Install packages only |
| `hide_launchers` | app_cleanup | Hide desktop launcher entries only |
| `theming` | theming | Full theming setup |
| `setup` | theming | Theming setup tasks |
| `youtube_tui` | youtube_tui | youtube-tui + yt-dlp config |
| `nvidia` | nvidia | Full NVIDIA driver setup |
| `workspace_repos` | workspace_repos | Clone workspace repositories |

## Project Structure

```
andusystems-arch/
├── ansible/configurations/
│   ├── arch.yml                          # Main playbook
│   └── roles/
│       ├── core_packages/
│       │   ├── defaults/main.yml         # Package list
│       │   └── tasks/
│       │       ├── main.yml              # Entry point
│       │       └── install.yml           # yay build + package install + LazyVim
│       ├── desktop_packages/
│       │   ├── defaults/main.yml         # Package list (37 packages)
│       │   └── tasks/
│       │       ├── main.yml
│       │       └── install.yml           # Package install + bluetooth enable
│       ├── dotfiles/
│       │   ├── defaults/main.yml         # Exclude list (secrets defense)
│       │   └── tasks/main.yml            # Find, adopt, stow
│       ├── app_cleanup/
│       │   ├── defaults/main.yml         # Remove/install/hide lists
│       │   └── tasks/
│       │       ├── main.yml
│       │       ├── remove.yml
│       │       ├── install.yml
│       │       └── hide_launchers.yml
│       ├── theming/
│       │   └── tasks/
│       │       ├── main.yml
│       │       └── setup.yml             # Dirs, script perms, systemd units
│       ├── youtube_tui/
│       │   └── tasks/
│       │       ├── main.yml
│       │       └── setup.yml             # Cookie detection + yt-dlp config
│       ├── nvidia/
│       │   ├── defaults/main.yml         # NVIDIA package list
│       │   └── tasks/
│       │       ├── main.yml
│       │       └── install.yml           # multilib, install, DRM, initramfs
│       └── workspace_repos/
│           ├── defaults/main.yml         # Repo list (names + URLs)
│           └── tasks/main.yml            # Clone + remote setup
├── dotfiles/
│   └── home/.config/                     # Managed dotfiles (stow package)
│       ├── hypr/                         # Hyprland compositor
│       ├── kitty/                        # Terminal emulator
│       ├── waybar/                       # Status bar
│       ├── rofi/                         # App launcher
│       ├── swaync/                       # Notification center
│       ├── matugen/                      # Color template engine
│       ├── btop/                         # System monitor
│       ├── mpv/                          # Media player
│       ├── youtube-tui/                  # YouTube TUI
│       ├── bluetuith/                    # Bluetooth TUI
│       ├── neofetch/                     # System info
│       ├── flameshot/                    # Screenshot tool
│       ├── git/                          # Global gitignore
│       └── systemd/user/                 # Systemd user units + timers
├── scripts/
│   └── bootstrap.sh                      # Initial system bootstrap
└── docs/                                 # Documentation
    ├── architecture.md
    ├── development.md (this file)
    ├── packages.md
    ├── keybinds.md
    ├── customization.md
    └── troubleshooting.md
```

## Environment Variables

No environment variables are required. All configuration is driven by:

- Ansible defaults in `roles/*/defaults/main.yml`
- Dotfiles in `dotfiles/home/.config/`
- The `-K` flag prompts for the sudo password at runtime

## Conventions

- **All playbooks run on localhost** — no remote inventory
- **`include_tasks` over `import_tasks`** in role task files to support `--tags` filtering
- **Temporary sudo escalation** — sudoers drop-in is created before package installs and revoked immediately after
- **`yay --needed`** — packages are only installed if not already present (idempotent)
- **Stow `--restow`** — re-symlinks everything, safe to run repeatedly
- **`changed_when: false`** — used on informational shell commands that don't modify system state
- **Generated files are gitignored** — all matugen color outputs are excluded from version control since they change on every wallpaper rotation
