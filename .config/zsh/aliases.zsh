# ── System Aliases ─────────────────────────────
alias rm="rm -i"
alias cp="cp -iv"
alias mv="mv -iv"
alias mkdir="mkdir -pv"
alias c="clear"
alias cat="bat"
alias ..="cd .."
alias ...="cd ../.."
alias dfh="df -h"
alias duh="du -h --max-depth=1"
alias ports="sudo lsof -i -P -n | grep LISTEN"
alias ping="ping -c 5"
alias myip="curl ifconfig.me"
alias fastfetch="fastfetch --config /home/abhishek/dotfiles/.config/fastfetch/config.jsonc"

# Listing (Eza)
if command -v eza &>/dev/null; then
    alias ls="eza --icons=always --group-directories-first --color=always"
    alias ll="eza -lah --icons=always"
    alias la="eza -a --icons=always"
    alias l="eza -CF --icons=always"
else
    alias ls="ls --color=auto -h"
    alias ll="ls -lah"
fi

# ── Pacman & Yay Aliases ───────────────────────
alias update="sudo pacman -Syu"
alias install="sudo pacman -S"
alias remove="sudo pacman -Rns"
alias search="pacman -Ss"
alias orphan="pacman -Qdt"
alias remove-orphan="sudo pacman -Rns \$(pacman -Qdtq)"
alias ya="yay"
alias yau="yay -Syu"
alias yai="yay -S"
alias yar="yay -Rns"
alias yas="yay -Ss"

# ── Dev Aliases ────────────────────────────────
alias serve="npx serve"
alias dev="npm run dev"
alias py="python3"
alias pipi="pip install"

# ── Git & Gitwho Dashboard ─────────────────────
alias gs="git status"
alias gp="git push"
alias gl="git pull"
alias gsync="git-sync"

# ── FZF Interactive Functions ──────────────────
# Interactive process killer
fp() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m --ansi --preview 'echo {}' --preview-window=down:3:wrap | awk '{print $2}')
  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

# Interactive checkout git branch
fgb() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}
