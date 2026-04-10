# Package Inventory

All packages are installed via `yay` (AUR helper). Packages in the official Arch repos are fetched from there; AUR-only packages are built from source.

---

## Core CLI Tools (`core_packages` role)

| Package | Purpose |
|---|---|
| `networkmanager` | Network management daemon |
| `neovim` | Primary editor (configured with LazyVim) |
| `stow` | Dotfiles symlink manager |
| `lazygit` | Git TUI (used from within Neovim via `<leader>gg`) |
| `neofetch` | System info display |
| `playerctl` | MPRIS media control (used by Waybar module and keybinds) |
| `lm_sensors` | Hardware temperature sensor readings (used by btop) |

> `yay` itself is built from AUR source by the `core_packages` role — it is not in this list because it is the installer, not a package.

---

## Desktop & Wayland Stack (`desktop_packages` role)

### Browser & AI

| Package | Purpose |
|---|---|
| `zen-browser-bin` | Primary web browser (Firefox-based) |
| `[AI_ASSISTANT]-code-stable` | AI coding assistant |
| `cursor-bin` | AI code editor |

### Wayland Compositor & Bar

| Package | Purpose |
|---|---|
| `rofi-wayland` | Application launcher |
| `waybar` | Status bar |
| `hypridle` | Idle management (dim + screen-off) |
| `awww` | Wallpaper daemon with animated transitions |
| `matugen` | Material You color generator from wallpaper |

### System & Settings

| Package | Purpose |
|---|---|
| `wlsunset` | Nightlight / color temperature (time-aware) |
| `brightnessctl` | Screen brightness control |
| `wl-clipboard` | Wayland clipboard tools (`wl-copy`, `wl-paste`) |
| `flameshot` | Screenshot tool |
| `power-profiles-daemon` | Power management profiles (balanced / performance / saver) |

### Audio (PipeWire stack)

| Package | Purpose |
|---|---|
| `pipewire` | Audio/video routing framework |
| `pipewire-audio` | Audio support for PipeWire |
| `pipewire-alsa` | ALSA compatibility layer |
| `pipewire-pulse` | PulseAudio compatibility layer |
| `wireplumber` | Session/policy manager for PipeWire |

### Bluetooth

| Package | Purpose |
|---|---|
| `bluez` | Bluetooth protocol stack |
| `bluez-utils` | Bluetooth utilities (`bluetoothctl`) |
| `bluetuith` | TUI Bluetooth manager (scratchpad) |

### Notifications

| Package | Purpose |
|---|---|
| `swaync` | Notification daemon with notification center |

### Media

| Package | Purpose |
|---|---|
| `mpv` | Video player |
| `mpv-mpris` | MPRIS plugin for mpv (enables Waybar MPRIS module) |
| `yt-dlp` | YouTube/video downloader (used by youtube-tui and yt-recommended) |
| `youtube-tui` | TUI YouTube browser (workspace 1 persistent window) |

### Python / Panel Dependencies

| Package | Purpose |
|---|---|
| `gtk-layer-shell` | GTK layer shell for Wayland overlay windows |
| `python-gobject` | PyGObject — GTK3 Python bindings for custom panels |
| `python-cairo` | Cairo rendering (used by panel drawing code) |

---

## Fonts

| Package | Usage |
|---|---|
| `ttf-hack-nerd` | **Primary font** — UI (Waybar, Rofi) and Kitty terminal |
| `ttf-jetbrains-mono-nerd` | Available alternative |
| `ttf-cascadia-code-nerd` | Available alternative |
| `ttf-firacode-nerd` | Available alternative |
| `ttf-liberation` | Arial-compatible (Liberation Sans/Serif/Mono) |
| `inter-font` | Clean UI font (web-safe alternative) |
| `noto-fonts` | Unicode fallback coverage |
| `noto-fonts-emoji` | Color emoji fallback (pairs with `noto-fonts`) |

---

## Icons

| Package | Usage |
|---|---|
| `papirus-icon-theme` | GTK / XDG icon theme — covers app icons in Nautilus, Rofi, Waybar tray, etc. |

---

## Removed & Replaced (`app_cleanup` role)

### Removed

| Package | Replaced by |
|---|---|
| `htop` | `btop` |
| `dolphin` | `nautilus` (already in desktop packages) |
| `vim` | `neovim` |

### Installed as replacements

| Package | Purpose |
|---|---|
| `btop` | System monitor (TUI scratchpad, center floating) |

---

## Hidden from Launcher

These packages remain installed but are hidden from Rofi and XDG app launchers via `NoDisplay=true` overrides in `~/.local/share/applications/`:

- `bssh.desktop`, `bvnc.desktop` — Avahi SSH/VNC browser
- `avahi-discover.desktop` — Avahi service browser
- `org.freedesktop.IBus.Setup.desktop` — IBus input method setup
- `org.freedesktop.IBus.Panel.*.desktop` — IBus panel utilities
- `rofi.desktop`, `rofi-theme-selector.desktop` — Rofi GUI launchers (used via keybind only)
- `qv4l2.desktop`, `qvidcap.desktop` — V4L2 utilities
- `uuctl.desktop` — UU control utility
- `xgps.desktop`, `xgpsspeed.desktop` — GPS utilities
- `mpv.desktop` — mpv file-open GUI entry (launched via scripts only)

---

## Manually Installed (not in Ansible)

| Package | Purpose |
|---|---|
| `yazi` | Terminal file manager |
