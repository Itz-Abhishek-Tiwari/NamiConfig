# ==============================================
# ~/.zshrc — Optimized Zsh Configuration
# Managed via ~/dotfiles (Ported from NamiConfig)
# ==============================================

# ── Environment & Zsh Modular Load ─────────────
[[ -f "$HOME/.config/zsh/env.zsh"        ]] && source "$HOME/.config/zsh/env.zsh"
[[ -f "$HOME/.config/zsh/core.zsh"       ]] && source "$HOME/.config/zsh/core.zsh"
[[ -f "$HOME/.config/zsh/completion.zsh" ]] && source "$HOME/.config/zsh/completion.zsh"
[[ -f "$HOME/.config/zsh/plugins.zsh"    ]] && source "$HOME/.config/zsh/plugins.zsh"
[[ -f "$HOME/.config/zsh/aliases.zsh"    ]] && source "$HOME/.config/zsh/aliases.zsh"
[[ -f "$HOME/.config/zsh/functions.zsh"  ]] && source "$HOME/.config/zsh/functions.zsh"

# ── Dynamic Theme Integration ──────────────────
[[ -f "${HOME}/.cache/shell-theme.zsh" ]] && source "${HOME}/.cache/shell-theme.zsh"

true
