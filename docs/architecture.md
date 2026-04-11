# Architecture

## Overview

andusystems-arch is an Ansible-driven system configuration tool that provisions an Arch Linux workstation with a Hyprland Wayland compositor, automated wallpaper-driven Material You theming, and managed dotfiles. It runs entirely on localhost — no remote hosts are involved.

The system is organized into three layers: Ansible roles (provisioning), dotfiles (runtime configuration), and scripts + systemd units (ongoing automation).

## Component Diagram

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         ansible/configurations/                          │
│                                                                          │
│  arch.yml (main playbook — localhost only)                                │
│    │                                                                     │
│    ├── core_packages ──────► yay (AUR helper), neovim + LazyVim, stow   │
│    ├── desktop_packages ───► wayland stack, browser, PipeWire audio,     │
│    │                         bluetooth, fonts, media tools               │
│    ├── dotfiles ───────────► stow symlinks: dotfiles/ ↔ ~/.config/      │
│    ├── app_cleanup ────────► remove unwanted pkgs, hide launcher entries │
│    ├── theming ────────────► wallpaper dirs, script perms, systemd units │
│    ├── nvidia ─────────────► drivers, DRM kernel modules, initramfs     │
│    └── workspace_repos ────► clone repos from internal git host          │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                          dotfiles/home/.config/                           │
│                                                                          │
│  hypr/           Hyprland compositor config + matugen color variables     │
│  kitty/          Terminal emulator (+ matugen color overlay)              │
│  waybar/         Status bar config and styling (+ matugen colors)        │
│  rofi/           Application launcher config and theme (+ matugen)       │
│  swaync/         Notification daemon config and styling (+ matugen)      │
│  matugen/        Color template engine config + 8 templates              │
│  nvim/           Neovim / LazyVim (+ matugen color palette)              │
│  btop/           System monitor config                                   │
│  bluetuith/      Bluetooth TUI config                                    │
│  neofetch/       System info display config                              │
│  git/            Global git ignore rules                                 │
│  systemd/user/   User-level systemd units (waybar, swaync, timers)       │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────┐
│                          ~/.local/bin/ (scripts)                          │
│                                                                          │
│  theme-switch.sh      Wallpaper rotation + matugen color generation      │
│  rofi-launcher.sh     Smart app launcher with auto-close on focus loss   │
│  nightlight.sh        Time-based display color temperature (wlsunset)    │
│  launch-btop.sh       Scratchpad toggle for btop system monitor          │
│  launch-nmtui.sh      Scratchpad toggle for network manager TUI          │
│  launch-bluetuith.sh  Scratchpad toggle for bluetooth TUI                │
│                                                                          │
└──────────────────────────────────────────────────────────────────────────┘
```

## Data Flows

### Playbook Execution Flow

```
scripts/bootstrap.sh
  └─► pacman -Syu + install ansible, python, git, base-devel, go
        └─► ansible-playbook ansible/configurations/arch.yml -K
              │
              ├─► core_packages
              │     Clone + build yay from source
              │     Install CLI packages via yay (--needed for idempotency)
              │     Clone LazyVim starter config (if not present)
              │
              ├─► desktop_packages
              │     Install Wayland/desktop packages via yay
              │     Enable + start bluetooth.service
              │
              ├─► dotfiles
              │     Find unmanaged dirs in ~/.config/
              │     Filter against dotfiles_exclude list (secrets defense)
              │     Move unmanaged configs into dotfiles/home/.config/
              │     stow --restow home (create symlinks)
              │
              ├─► app_cleanup
              │     Remove unwanted packages (htop, dolphin, vim)
              │     Install replacements (btop)
              │     Copy .desktop files locally and set NoDisplay=true
              │
              ├─► theming
              │     Create ~/Wallpapers/ and ~/.local/bin/
              │     Set scripts executable
              │     Create fallback color configs
              │     Enable systemd user services and timers
              │     Override swaync D-Bus activation to use systemd
              │
              ├─► nvidia
              │     Enable multilib repo in pacman.conf
              │     Install NVIDIA open drivers + utils
              │     Configure DRM kernel modules (modeset=1, fbdev=1)
              │     Add NVIDIA modules to initramfs and rebuild
              │     Enable nvidia-persistenced.service
              │
              └─► workspace_repos
                    Clone repositories from internal git host (forgejo remote)
                    Add GitHub mirror URL as "origin" remote (where configured)
```

### Theming Pipeline

The color theming system is the most complex data flow in the project. It generates a consistent Material You color palette across all themed applications from a single wallpaper image.

```
~/Wallpapers/*.{jpg,jpeg,png,webp}
        │
        ▼
theme-switch.sh (triggered by systemd timer every 5 min, or manually)
        │
        ├─► Select random wallpaper (avoids repeating previous)
        │   Save path to ~/.cache/current-wallpaper
        │
        ├─► awww img <wallpaper> (animated fade transition, 2s at 60fps)
        │
        ├─► matugen image <wallpaper> (Material You color extraction)
        │     │
        │     │  Reads: matugen/config.toml (template registry)
        │     │
        │     ├─► templates/hypr-colors.conf    → ~/.config/hypr/colors.conf
        │     ├─► templates/kitty-colors.conf   → ~/.config/kitty/colors.conf
        │     ├─► templates/waybar-colors.css   → ~/.config/waybar/colors.css
        │     ├─► templates/rofi-colors.rasi    → ~/.config/rofi/colors.rasi
        │     ├─► templates/nvim-colors.lua     → ~/.config/nvim/lua/colors/matugen.lua
        │     ├─► templates/gtk3.css            → ~/.config/gtk-3.0/gtk.css
        │     ├─► templates/gtk4.css            → ~/.config/gtk-4.0/gtk.css
        │     └─► templates/swaync.css          → ~/.config/swaync/style.css
        │
        └─► Hot-reload signals (no logout required)
              ├─► hyprctl reload              (Hyprland re-reads colors.conf)
              ├─► pkill -SIGUSR2 waybar       (Waybar reloads styles)
              ├─► nvim --server <socket>      (Neovim reloads matugen palette)
              └─► swaync-client -rs           (swaync reloads CSS)
```

**Color palette flow:** Wallpaper image → matugen extracts Material You palette (primary, secondary, tertiary, error, background, surface variants) → templates map palette to app-specific config formats → reload signals apply changes live.

### Dotfiles Sync Flow

```
~/.config/<app>/  (live config on disk)
        │
        ▼
dotfiles role: find unmanaged dirs
        │
        ▼
Filter against dotfiles_exclude list
(browser profiles, cloud creds, IDE sessions, shell history — never adopted)
        │
        ▼
mv to dotfiles/home/.config/<app>/
        │
        ▼
stow --restow home  →  symlinks dotfiles/home/.config/* → ~/.config/*
```

After stow runs, editing a file under `~/.config/` modifies the repo copy directly via the symlink — no manual sync step needed.

### Workspace Repos Flow

```
Internal git host (forgejo remote — source of truth)
        │
        ▼
git clone → ~/andusystems/<repo-name>/
        │
        ▼
git remote add origin <github-mirror-url>  (if configured for that repo)
```

## Key Design Decisions

### GNU Stow for Dotfile Management

GNU Stow creates symlinks from `dotfiles/home/.config/*` to `~/.config/*`. This means:

- The repo is the single source of truth for all tracked configs
- Changes to configs on disk are automatically reflected in the repo (via symlink)
- No copy/sync step needed after editing a config
- `stow --restow` is safe to run repeatedly (idempotent re-linking)

### Defense-in-Depth for Secrets

Two independent mechanisms prevent secrets from being committed:

1. **`dotfiles_exclude` list** (`ansible/configurations/roles/dotfiles/defaults/main.yml`) — the primary defense. Prevents the dotfiles role from ever adopting sensitive directories into the repo. Covers browser profiles, cloud CLI credentials (helm, kubectl, gcloud, azure), IDE sessions, chat clients, and shell history.

2. **`.gitignore`** — the safety net. Blocks git from tracking any sensitive path that might get adopted accidentally. Also covers generated files (matugen outputs, wallpapers, Python bytecode).

Both lists must be kept in sync. If a new sensitive directory appears in `~/.config/`, it must be added to both.

### Temporary Sudo Escalation for Package Installs

The yay AUR helper requires passwordless pacman access during installation. Each role that installs packages follows the same pattern:

1. Write a sudoers drop-in file granting passwordless pacman
2. Run yay/pacman install commands
3. Immediately revoke the sudoers file

This avoids leaving permanent passwordless access on the system.

### Systemd User Units for Runtime Services

Desktop services run as systemd user units rather than being launched directly by Hyprland:

| Unit | Why systemd? |
|------|-------------|
| `waybar.service` | Auto-restart on crash (Restart=always, RestartSec=1) |
| `swaync.service` | D-Bus activation delegation prevents duplicate instances |
| `theme-switch.timer` | Reliable periodic execution with persistent state |
| `nightlight.timer` | Calendar-based triggers (07:00 and 21:00) with catch-up |

D-Bus activation for swaync is overridden with a custom service file in `~/.local/share/dbus-1/services/` to delegate activation to systemd, preventing race conditions with duplicate instances.

### Local-Only Ansible

All playbooks target `localhost` with `gather_facts: true`. There is no inventory file for remote hosts. This is a single-machine provisioning tool, not a fleet management system.

### Hyprland Window Management

The compositor uses a combination of:

- **Persistent windows**: Autostarted via `exec-once` with workspace dispatch rules
- **Special workspaces**: Scratchpad-style toggles for btop, nmtui, and bluetuith
- **Window rules**: Float/tile, opacity, size, and position per window class
- **Animations**: Custom bezier curves (easeOutQuint, easeOutExpo, spring) for smooth transitions

## Invariants

- **No secrets in the repo**: The `dotfiles_exclude` list and `.gitignore` must always cover all directories containing tokens, credentials, session state, or browser profiles.
- **Idempotent playbook runs**: Every role must be safe to re-run. Package installs use `--needed`, directory creation uses `state: directory`, and conditional checks gate one-time operations (e.g., LazyVim clone only if not present).
- **Stow owns ~/.config symlinks**: After the dotfiles role runs, every tracked config under `~/.config/` is a symlink into the repo. Direct file edits under `~/.config/` modify the repo copy via the symlink.
- **Generated color files are gitignored**: All matugen output files (`colors.conf`, `colors.css`, `colors.rasi`, `matugen.lua`, `style.css` for swaync, GTK CSS) are excluded from git tracking because they change on every wallpaper rotation.
- **Sudo escalation is temporary**: No role may leave a passwordless sudoers drop-in after completion.

## Concurrency Model

There is no concurrency concern in normal operation — Ansible runs tasks sequentially on localhost. The only potential conflict is between:

- The `theme-switch.timer` writing matugen color files
- A manual `theme-switch.sh` invocation at the same time

This is benign because matugen writes files atomically and all reloads are idempotent signal-based operations (SIGUSR2, hyprctl reload, socket commands). A concurrent run may trigger a redundant reload, but the result is always consistent.
