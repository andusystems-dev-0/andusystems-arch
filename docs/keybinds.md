# Keybinds Reference

`$mainMod` = **Super** (Windows key)

---

## Hyprland — Window Management

| Key | Action |
|---|---|
| `Super+Q` | Open terminal (kitty) |
| `Super+C` | Close active window |
| `Super+V` | Toggle floating |
| `Super+R` | Open launcher (rofi drun) |
| `Super+E` | Open file manager (nautilus) |
| `Super+M` | Exit Hyprland (or `hyprshutdown` if installed) |
| `Super+P` | Toggle pseudotile (dwindle layout) |
| `Super+J` | Toggle split direction (dwindle layout) |
| `Super+S` | Toggle scratchpad (special:magic) |
| `Super+Shift+S` | Move active window to scratchpad |
| `Super+←` | Move focus left |
| `Super+→` | Move focus right |
| `Super+↑` | Move focus up |
| `Super+↓` | Move focus down |
| `Super+LMB drag` | Move floating window |
| `Super+RMB drag` | Resize floating window |

---

## Hyprland — Workspaces

| Key | Action |
|---|---|
| `Super+1` – `Super+0` | Switch to workspace 1–10 |
| `Super+Shift+1` – `Super+Shift+0` | Move active window to workspace 1–10 |
| `Super+Scroll Up` | Next workspace |
| `Super+Scroll Down` | Previous workspace |
| 3-finger swipe horizontal | Switch workspace (touchpad) |

---

## Hyprland — Media & System

| Key | Action |
|---|---|
| `Print` | Screenshot (flameshot GUI) |
| `XF86AudioRaiseVolume` | Volume +5% |
| `XF86AudioLowerVolume` | Volume −5% |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle microphone mute |
| `XF86MonBrightnessUp` | Brightness +5% |
| `XF86MonBrightnessDown` | Brightness −5% |
| `XF86AudioNext` | Next track (playerctl) |
| `XF86AudioPrev` | Previous track (playerctl) |
| `XF86AudioPlay` / `XF86AudioPause` | Play/pause (playerctl) |

---

## Waybar — Click Actions

| Module | Left click | Right click | Middle click | Scroll |
|---|---|---|---|---|
| MPRIS | Play/pause | Next track | Previous track | Volume ±5% |

---

## Neovim (LazyVim)

| Key | Action |
|---|---|
| `<leader>tt` | Toggle project terminal splits (bottom) |
| `<leader>gg` | Open lazygit (repo root) |
| `<leader>gG` | Open lazygit (cwd) |
| `<leader>gl` | Git log |
| `<leader>gf` | File git log |

The two bottom terminal splits open automatically on `VimEnter` when cwd is `~/andusystems-arch` and no file argument is passed. Left split runs [AI_ASSISTANT] Code, right split is a plain shell.

---

## youtube-tui

### Global bindings (all pages)

| Input | Action |
|---|---|
| `R` | Launch yt-recommended (mpv recommended feed) |
| `y` | Copy current video URL to clipboard |
| `Space` | Toggle mpv pause |
| `Left` (mode 3, mpv focused) | Skip to previous in mpv playlist |
| `Right` (mode 3, mpv focused) | Skip to next in mpv playlist |
| `Left` (mode 2, seek) | Rewind mpv 5 seconds |
| `Right` (mode 2, seek) | Fast-forward mpv 5 seconds |

### Custom commands (`:` prompt)

| Command | Action |
|---|---|
| `:r` | Launch yt-recommended (same as `R`) |
| `:rl` | Reload youtube-tui |

### Per-page bindings (mode 2 = hover, mode 1 = all items)

| Page | Key | Action |
|---|---|---|
| search / popular / trending / playlist / channel | `p` (mode 2) | Play hovered video in mpv |
| search / popular / trending / playlist / channel | `a` (mode 2) | Play hovered video audio-only in mpv |
| search / popular / trending / playlist / channel | `A` (mode 1) | Shuffle-play all as audio playlist |
| feed | `p` (mode 2) | Play hovered video in mpv |
| feed | `a` (mode 2) | Play hovered video audio-only |
| feed | `A` (mode 1) | Shuffle-play channel videos as audio playlist |
| feed | `P` (mode 1) | Same as `A` |
| any page with URL | `f` (mode 2) | Open hovered URL in Zen Browser |
