#!/usr/bin/env bash
set -euo pipefail

sudo pacman -Sy

# git + base-devel are installed manually before cloning this repo.
# go is installed by the core_packages ansible role (needed to build yay).
sudo pacman -S --needed --noconfirm \
    ansible \
    python \
    stow
