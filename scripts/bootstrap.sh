#!/bin/bash
set -e

# -------------------------------------------
# bootstrap.sh - Arch Linux Ansible installer
# -------------------------------------------

echo “==> Syncing package databases…”
pacman -Syu --noconfirm

echo “==> Installing Ansible and dependencies…”
pacman -Syu --noconfirm ansible python python-pip git base-devel go

echo “==> Verifying Ansible install…”
ansible –-version

echo “”
echo “✓ Bootstrap complete. Ansible is ready.”
echo “  Run your playbook with: ansible-playbook -i localhost, playbook.yml”
