# andusystems-arch

Ansible-based Arch Linux system configuration with dotfiles management via GNU Stow.

## Prerequisites

- Fresh Arch Linux install with network connectivity
- A user account with sudo access

## Installation

**1. Clone the repo**
```bash
git clone https://github.com/dts-dev-0/andusystems-arch.git
cd andusystems-arch
```

**2. Run the bootstrap script**

Installs Ansible and base requirements.
```bash
bash scripts/bootstrap.sh
```

**3. Run the playbook**

The `-K` flag will prompt for your sudo password.
```bash
ansible-playbook ansible/configurations/arch.yml -K
```

## What gets installed

- `yay` — AUR helper
- `neovim` — text editor, configured with LazyVim
- `stow` — dotfiles symlink manager
- Zen Browser
- [AI_ASSISTANT] Code

## Dotfiles

Configs are stored in `dotfiles/home/.config/` and symlinked to `~/.config/` via Stow.

To adopt new configs from `~/.config/` into the repo, re-run the dotfiles playbook:
```bash
ansible-playbook ansible/configurations/arch.yml --tags dotfiles -K
```

The following are intentionally excluded from tracking:
`gh`, `go`, `zen`, `pulse`, `dconf`, `gtk-3.0`, `ibus`, `session`
