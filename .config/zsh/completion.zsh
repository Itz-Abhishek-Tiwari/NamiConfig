# ── Fast Completion ────────────────────────────
fpath=(~/.zsh/completions $fpath)
# Ensure fpath is set correctly for completions
fpath=($HOME/dotfiles/.config/zsh/completions $fpath)

autoload -Uz compinit
# Only run compinit once a day or if .zcompdump is missing
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.m-1) ]]; then
  compinit -C
else
  compinit
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
