export ZSH="$HOME/.oh-my-zsh"
if [[ -d "$ZSH" ]]; then
    # Essential plugins only
    plugins=(git sudo zsh-defer)
    source "$ZSH/oh-my-zsh.sh"
    
    # Defer heavy plugins for faster interactive prompt
    zsh-defer source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    zsh-defer source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# ── FZF Integration ────────────────────────────
# Load fzf configuration if available
[[ -f "$HOME/.config/zsh/fzf.zsh" ]] && source "$HOME/.config/zsh/fzf.zsh"

# ── Load Custom Theme ──────────────────────────
[[ -f "$HOME/.config/zsh/theme.zsh" ]] && source "$HOME/.config/zsh/theme.zsh"
