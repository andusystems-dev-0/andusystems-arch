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
