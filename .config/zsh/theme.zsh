# ── Custom Gruvbox Flat-Block Zsh Theme ────────
# Sharp-edged segmented prompt (Non-rounded)

# Load colors
autoload -U colors && colors
setopt PROMPT_SUBST

# Gruvbox Palette (256-color)
BG_DIR=235 # Dark Gray
FG_DIR=214 # Yellow
BG_GIT=214 # Yellow
FG_GIT=235 # Dark Gray
BG_GIT_DIRTY=167 # Red
FG_GIT_DIRTY=235 # Dark Gray
FG_CMD=109 # Aqua

# Git segment
segment_git() {
  local ref=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z "$ref" ]] && return
  
  local bg=$BG_GIT
  local fg=$FG_GIT
  if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
    bg=$BG_GIT_DIRTY
    fg=$FG_GIT_DIRTY
  fi
  
  echo "%K{$bg}%F{$fg}  $ref %f%k"
}

# Directory segment
segment_dir() {
  echo "%K{$BG_DIR}%F{$FG_DIR}  %~ %f%k"
}

# Prompt implementation
# Combined blocks with a single space separator or just adjacent
PROMPT='
$(segment_dir)$(segment_git)
%F{$FG_CMD}❯%f '

# Right prompt for status and time
RPROMPT='%(?..%F{167}󰅙 %?%f) %F{243}%D{%I:%M:%S %p}%f'
