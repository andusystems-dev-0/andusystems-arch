#
# ~/.bashrc — andusystems
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------
HISTCONTROL=ignoredups:erasedups
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# -----------------------------------------------------------------------------
# Colorized defaults
# -----------------------------------------------------------------------------
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias grep='grep --color=auto'
alias ip='ip --color=auto'

# -----------------------------------------------------------------------------
# Editor
# -----------------------------------------------------------------------------
export EDITOR=nvim
export VISUAL=nvim

# -----------------------------------------------------------------------------
# Prompt — starship
# -----------------------------------------------------------------------------
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi

# --- TEMP: theme-rotation helper (remove after picking a theme) --------------
alias retheme='hyprctl reload; pkill -SIGUSR2 waybar; pkill -SIGUSR1 kitty; tmux source-file ~/.config/tmux/tmux.conf 2>/dev/null; echo "reloaded — restart nvim for the colorscheme"'
# --- END TEMP ----------------------------------------------------------------
