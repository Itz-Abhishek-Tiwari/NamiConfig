# ── History & Core Options ─────────────────────
setopt PROMPT_SUBST
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# ── Options ────────────────────────────────────
setopt AUTO_CD
setopt CORRECT
setopt NO_CASE_GLOB
ENABLE_CORRECTION="true"
HYPHEN_INSENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
CASE_SENSITIVE="false"

# ── Key bindings ───────────────────────────────
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[3~' delete-char
