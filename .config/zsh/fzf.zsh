# ── FZF Configuration ──────────────────────────
# Set up fzf key bindings and fuzzy completion
if (( $+commands[fzf] )); then
  # Completion
  [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh 2>/dev/null
  # Key bindings
  [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh 2>/dev/null
fi

# Gruvbox colors for fzf (Already handled in theme-switch, but ensuring defaults here)
if [[ -z "$FZF_DEFAULT_OPTS" ]]; then
  export FZF_DEFAULT_OPTS="--color=bg+:#3c3836,bg:#1d2021,spinner:#83a598,hl:#8ec07c,fg:#ebdbb2,header:#8ec07c,info:#fabd2f,pointer:#83a598,marker:#fe8019,fg+:#fbf1c7,prompt:#fabd2f,hl+:#8ec07c"
fi

# Use fd for fzf if available
if (( $+commands[fd] )); then
  export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
