# Development guide

This document covers local setup, day-to-day workflow, and how to extend the configuration.

---

## Prerequisites

| Tool | Purpose | Install |
|---|---|---|
| Arch Linux | Target OS | `archinstall` |
| `git` | Version control | `sudo pacman -S git` |
| `base-devel` | Build toolchain (yay requires it) | `sudo pacman -S base-devel` |
| `ansible` ≥ 2.15 | Provisioning playbook | `sudo pacman -S ansible` |
| `python` ≥ 3.11 | Ansible runtime | `sudo pacman -S python` |
| `stow` | Symlink manager | `sudo pacman -S stow` |

`scripts/bootstrap.sh` installs `ansible`, `python`, and `stow` in one step.
`git` and `base-devel` must be present before cloning.

---

## Initial setup

### Full workstation provisioning

```bash
# Install bootstrap dependencies (ansible, python, stow)
bash scripts/bootstrap.sh

# Clone the repository
git clone <internal-git-host>/andusystems/andusystems-arch.git \
    ~/andusystems/andusystems-arch
cd ~/andusystems/andusystems-arch

# Run the full playbook (installs packages, enables services, links dotfiles)
ansible-playbook ansible/configurations/arch.yml

# Reboot to start the Hyprland Wayland session
reboot
```

### Terminal-only setup (non-Arch systems)

`scripts/install-standalone-terminal.sh` installs Neovim and Tmux and links only those two
configs. It detects the system package manager (`pacman`, `apt`, `dnf`, `brew`).

```bash
bash scripts/install-standalone-terminal.sh
```

After running, open `nvim` once to trigger lazy.nvim's automatic plugin installation, then
start `tmux` (prefix: `Alt+A`).

### Cloning all andusystems repositories

```bash
bash scripts/clone-repos.sh
# Enter your Forgejo username and password when prompted.
# Repos are cloned into ~/andusystems/.
```

---

## Running individual Ansible roles

Re-run a single role without touching the others using Ansible tags or
`--start-at-task`. The recommended approach is to target the role file directly:

```bash
# Re-link dotfiles only (e.g. after adding a new config file)
ansible-playbook ansible/configurations/arch.yml --tags dotfiles

# Re-install packages only
ansible-playbook ansible/configurations/arch.yml --tags core_packages

# Re-run bootstrap only (services, git config, /etc/hosts)
ansible-playbook ansible/configurations/arch.yml --tags bootstrap
```

Tags are defined in `ansible/configurations/roles/*.yml` wrapper files.

---

## Adding packages

1. Open `ansible/configurations/roles/core_packages/defaults/main.yml`.
2. Add the package name to the `yay_packages` list.
3. Re-run the `core_packages` role or the full playbook.

```yaml
# roles/core_packages/defaults/main.yml
yay_packages:
  - your-new-package
```

Packages are installed via `yay`, which handles both official repos and the AUR.
To remove a package, remove it from the list and run `yay -R <package>` manually;
the role does not remove packages that are no longer listed.

---

## Modifying dotfiles

All dotfiles live under `dotfiles/home/`. Because they are symlinked into `$HOME` by Stow,
editing a file in `~/.config/` is the same as editing it in the repository.

To add a new application config:

1. Create the config directory under `dotfiles/home/.config/<app>/`.
2. Re-run the `dotfiles` Ansible role (or run `stow -t ~ home` from `dotfiles/`).
3. Commit the new files.

```bash
# Manual stow (without Ansible)
cd dotfiles
stow -t ~ home
```

If a file already exists at the target path, Stow will refuse to overwrite it.
Back up or delete the conflicting file first, or let the Ansible `dotfiles` role handle
it — it backs up conflicts to `~/.dotfiles-backup/<timestamp>/` automatically.

---

## Reloading configuration at runtime

The `.bashrc` alias `retheme` reloads live configuration for Hyprland, Waybar, Kitty, and
Tmux without logging out:

```bash
retheme
```

This is equivalent to:
```bash
hyprctl reload
killall -SIGUSR2 waybar
kill -SIGUSR1 $(pgrep kitty)
tmux source-file ~/.config/tmux/tmux.conf
```

Neovim config changes take effect the next time `nvim` is started (or via `:source $MYVIMRC`).

---

## Monitor layout

Monitor configuration is managed interactively with `nwg-displays`. Run it from a terminal
or the Hyprland keybinding, adjust the layout, and click Apply. The result is written to
`dotfiles/home/.config/hypr/monitors.conf` automatically and takes effect immediately.

```bash
nwg-displays
```

Commit `monitors.conf` if you want the layout persisted across reinstalls.

---

## Waybar scripts

All interactive Waybar modules delegate to shell scripts in
`dotfiles/home/.config/waybar/scripts/`. The naming convention is:

| Script | Trigger |
|---|---|
| `audio-menu.sh` | Click audio module |
| `audio-tooltip.sh` | Hover audio module |
| `bluetooth-menu.sh` | Click Bluetooth module |
| `bluetooth-tooltip.sh` | Hover Bluetooth module |
| `network-menu.sh` | Click network module |
| `network-tooltip.sh` | Hover network module |
| `display-menu.sh` | Click display module |
| `power-menu.sh` | Click power module |
| `settings-menu.sh` | Click settings module |
| `sysmon.sh` | CPU/RAM status text |
| `sysmon-tooltip.sh` | CPU/RAM tooltip |
| `waybar-peek.sh` | Auto-hide/reveal logic (triggered by Hyprland) |
| `waybar-toggle.sh` | Manual toggle (keybinding) |

Scripts call `rofi` for interactive menus and `pactl`, `nmcli`, `bluetoothctl` for actions.

---

## Neovim plugins

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim). On first start,
lazy.nvim bootstraps itself and installs all plugins defined in
`dotfiles/home/.config/nvim/lua/config/lazy.lua` and `lua/plugins/`.

```
# Inside nvim
:Lazy          — open plugin manager UI
:Lazy sync     — install / update / clean plugins
:TSUpdate      — update Treesitter parsers
```

The lock file `lazy-lock.json` pins exact plugin versions for reproducibility.

---

## Environment variables

No environment variables are required to run the Ansible playbook. The following are set
by `.bashrc` at login:

| Variable | Value | Purpose |
|---|---|---|
| `EDITOR` | `nvim` | Default editor for git, etc. |
| `HISTSIZE` | `10000` | In-memory shell history limit |
| `HISTFILESIZE` | `10000` | On-disk shell history limit |

---

## Troubleshooting

**Stow conflict on re-run**: A file at the target path is not a symlink to the repo.
Back it up and remove it, then re-run stow or the `dotfiles` Ansible role.

**Cursor flickers after NVIDIA driver install**: Confirm `no_hardware_cursors = true`
is set in `hyprland.conf`. A reboot is required after the initial NVIDIA setup.

**Waybar not visible**: Press and hold the Super key to peek, or run `waybar-toggle.sh`
to force-show it. Check `journalctl --user -u waybar` for errors.

**Pangolin tunnel not connecting**: Verify `pangolin.service` is running with
`systemctl status pangolin` and check that the control-plane host is reachable.
