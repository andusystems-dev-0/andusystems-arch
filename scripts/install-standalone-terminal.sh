#!/usr/bin/env bash
# =============================================================================
# install-terminal.sh — minimal terminal-only install.
# Installs neovim + tmux + deps (C compiler for treesitter, ripgrep for plugin
# search), then symlinks ONLY those two configs into ~/.config.
# Detects the package manager (pacman / apt / dnf / brew).
# =============================================================================

set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_SRC="$REPO_ROOT/dotfiles/home/.config"
CONFIG_DST="${XDG_CONFIG_HOME:-$HOME/.config}"

install_packages() {
    if command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --needed --noconfirm \
            git neovim tmux curl base-devel ripgrep unzip
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update
        sudo apt install -y \
            git neovim tmux curl build-essential ripgrep unzip
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y \
            git neovim tmux curl gcc make ripgrep unzip
    elif command -v brew >/dev/null 2>&1; then
        brew install git neovim tmux ripgrep
    else
        echo "install-terminal.sh: no supported package manager found." >&2
        echo "install manually: git neovim tmux curl gcc/make ripgrep unzip" >&2
        exit 1
    fi
}

link_config() {
    local name=$1
    local src="$CONFIG_SRC/$name"
    local dst="$CONFIG_DST/$name"

    [ -d "$src" ] || { echo "missing source: $src" >&2; return 1; }
    mkdir -p "$CONFIG_DST"

    if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
        echo "already linked: $dst"
        return 0
    fi
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local backup="$dst.bak.$(date +%Y%m%d-%H%M%S)"
        echo "backing up $dst -> $backup"
        mv "$dst" "$backup"
    fi
    ln -s "$src" "$dst"
    echo "linked: $dst -> $src"
}

install_packages
link_config tmux
link_config nvim

cat <<'EOF'

Done. Next:
  - Open nvim once; lazy.nvim auto-installs plugins and runs :TSUpdate.
  - Start tmux; prefix is Alt+A.
EOF
