# andusystems-arch

Dotfiles and Ansible configuration for a fresh Arch Linux install, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
andusystems-arch/
├── dotfiles/          # GNU Stow packages (symlinked to ~)
│   └── home/          # Stow directory targeting ~/
│       └── .config/   # XDG config directory
├── ansible/           # Ansible automation
│   ├── playbooks/     # Playbooks
│   ├── roles/         # Roles
│   └── inventory/     # Host inventory
```

## Usage

### Dotfiles

```bash
# From the repo root, stow the home package into ~/
cd dotfiles
stow -t ~ home
```

### Ansible

```bash
ansible-playbook -i ansible/inventory/hosts ansible/playbooks/site.yml
```

## Requirements

- Arch Linux (fresh install via archinstall)
- GNU Stow
- Python
- Git
- Ansible
