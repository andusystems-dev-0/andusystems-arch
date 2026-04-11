# Architecture

## Overview

andusystems-arch is an Ansible-driven system configuration tool that provisions an Arch Linux workstation with a Hyprland Wayland compositor, automated wallpaper-driven theming, and managed dotfiles. It runs entirely on localhost — no remote hosts are involved.

## Component Diagram

```
┌──────────────────────────────────────────────────────────────────────┐
│                        ansible/configurations/                       │
│                                                                      │
│  arch.yml (main playbook)                                            │
│    │                                                                 │
│    ├── core_packages ──────► yay (AUR), neovim+LazyVim, stow, etc.  │
│    ├── desktop_packages ───► wayland stack, browser, audio, fonts    │
│    ├── dotfiles ───────────► stow symlinks ~/.config ↔ dotfiles/    │
│    ├── app_cleanup ────────► remove/replace packages, hide launchers│
│    ├── theming ────────────► wallpaper dirs, scripts, systemd units  │
│    ├── youtube_tui ────────► yt-dlp + youtube-tui auth config        │
│    ├── nvidia ─────────────► drivers, DRM modules, initramfs         │
│    └── workspace_repos ────► clone repos from internal git host      │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────┐
│                         dotfiles/home/.config/                       │
│                                                                      │
│  hypr/          Hyprland compositor config + matugen color vars       │
│  kitty/         Terminal emulator (+ matugen color overlay)           │
│  waybar/        Status bar (+ matugen color overlay)                 │
│  rofi/          App launcher (+ matugen color overlay)               │
│  swaync/        Notification daemon (+ matugen color overlay)        │
│  matugen/       Color template engine config + templates             │
│  nvim/          Neovim / LazyVim (+ matugen color overlay)           │
│  btop/          System monitor config                                │
│  mpv/           Video player config                                  │
│  flameshot/     Screenshot tool config                               │
│  youtube-tui/   YouTube TUI browser config                           │
│  bluetuith/     Bluetooth TUI config                                 │
│  neofetch/      System info display config                           │
│  git/           Global git ignore rules                              │
│  systemd/user/  User-level systemd units (waybar, swaync, timers)    │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

## Data Flows

### Playbook Execution Flow

```
bootstrap.sh
  └─► pacman -Syu ansible python git base-devel go
        └─► ansible-playbook arch.yml -K
              ├─► core_packages:   clone+build yay → install packages → clone LazyVim
              ├─► desktop_packages: yay install → enable bluetooth
              ├─► dotfiles:        find ~/.config/* → adopt unmanaged → stow --restow
              ├─► app_cleanup:     pacman -Rns → yay -S replacements → hide launchers
              ├─► theming:         mkdir → chmod scripts → enable systemd units
              ├─► youtube_tui:     find Zen cookies → write yt-dlp config
              ├─► nvidia:          enable multilib → pacman install → mkinitcpio -P
              └─► workspace_repos: git clone (forgejo remote) → git remote add (origin)
```

### Theming Pipeline

The color theming system is the most complex data flow in the project. It generates consistent colors across all themed applications from a single wallpaper image.

```
~/Wallpapers/*.{jpg,png,webp}
        │
        ▼
theme-switch.sh (triggered by systemd timer or manual run)
        │
        ├─► awww set <wallpaper> --transition wipe
        │
        ├─► matugen image <wallpaper>
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
        └─► reload signals
              ├─► hyprctl reload
              ├─► pkill -SIGUSR2 waybar
              ├─► kitty @ set-colors (via socket)
              ├─► nvim --remote-send (via socket)
              └─► swaync reload
```

### Dotfiles Sync Flow

```
~/.config/<app>/  (live config on disk)
        │
        ▼
dotfiles role: find unmanaged dirs → filter against dotfiles_exclude list
        │
        ▼
mv to dotfiles/home/.config/<app>/
        │
        ▼
stow --restow home  →  symlinks dotfiles/home/.config/* → ~/.config/*
```

### Workspace Repos Flow

```
Internal Git host (forgejo remote — source of truth)
        │
        ▼
git clone → ~/andusystems/<repo-name>/
        │
        ▼
git remote add origin <github-mirror-url>  (if configured)
```

## Key Design Decisions

### Stow for Dotfile Management

GNU Stow creates symlinks from `dotfiles/home/.config/*` to `~/.config/*`. This means:
- The repo is the single source of truth for all tracked configs
- Changes to configs on disk are automatically reflected in the repo
- No copy/sync step needed after editing a config

### Defense-in-Depth for Secrets

Two independent mechanisms prevent secrets from being committed:

1. **`dotfiles_exclude` list** (`ansible/configurations/roles/dotfiles/defaults/main.yml`) — the primary defense. Prevents the dotfiles role from ever adopting sensitive directories into the repo.
2. **`.gitignore`** — the safety net. Blocks git from tracking any sensitive path that might get adopted accidentally.

Both lists must be kept in sync.

### Temporary Sudo Escalation for Package Installs

The yay AUR helper requires passwordless pacman access during installation. Each role that installs packages follows the same pattern:
1. Write a sudoers drop-in file granting passwordless pacman
2. Run yay/pacman install
3. Immediately revoke the sudoers file

This avoids leaving permanent passwordless access on the system.

### Systemd User Units for Runtime Services

Several services run as systemd user units rather than being launched directly by Hyprland:
- `waybar.service` — started by `graphical-session.target`
- `swaync.service` — started by `graphical-session.target`
- `theme-switch.timer` — periodic wallpaper rotation
- `nightlight.timer` — periodic nightlight color temperature

D-Bus activation for swaync is overridden to delegate to systemd, preventing duplicate instances.

### Local-Only Ansible

All playbooks target `localhost` with `gather_facts: true`. There is no inventory file for remote hosts. This is a single-machine provisioning tool, not a fleet management system.

## Invariants

- **No secrets in the repo**: The `dotfiles_exclude` list and `.gitignore` must always cover all directories containing tokens, credentials, session state, or browser profiles.
- **Idempotent playbook runs**: Every role must be safe to re-run. Package installs use `--needed`, directory creation uses `state: directory`, and conditional checks gate one-time operations (e.g., LazyVim clone).
- **Stow owns ~/.config symlinks**: After the dotfiles role runs, every tracked config under `~/.config/` is a symlink into the repo. Direct file edits under `~/.config/` modify the repo copy via the symlink.
- **Generated color files are gitignored**: All matugen output files (colors.conf, colors.css, colors.rasi, matugen.lua, style.css for swaync) are excluded from git tracking because they change on every wallpaper rotation.

## Concurrency Model

There is no concurrency concern in normal operation — Ansible runs tasks sequentially on localhost. The only potential conflict is between:

- The `theme-switch.timer` writing matugen color files
- A manual `theme-switch.sh` invocation at the same time

This is benign because matugen writes atomically and all reloads are idempotent signal-based (SIGUSR2, socket commands).
