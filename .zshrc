export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"

plugins=(
  git
  node
  npm
  yarn
  python
  pip
  docker
  vscode
  sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
eval "$(starship init zsh)"

# Editor preferences
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Safer operations
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

# Git shortcuts
alias gs="git status"
alias gp="git push"
alias gl="git pull"

# Node/NPM/Yarn
alias serve="npx serve"
alias start="npm start"
alias test="npm test"
alias lint="npm run lint"
alias dev="npm run dev"
alias py="python3"
alias pipi="pip install"
export PATH="./node_modules/.bin:$PATH"

# Quality-of-life
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias c='clear'
alias ls="ls --color=auto -F"
alias ll="ls -lah"
alias la="ls -A"
alias l="ls -CF"
alias ip="ip a"
alias ping="ping -c 5"
alias myip="curl ifconfig.me"
alias ports="sudo lsof -i -P -n | grep LISTEN"

# Arch package management
alias update="sudo pacman -Syu"
alias upgrade="sudo pacman -Syu"
alias install="sudo pacman -S"
alias remove="sudo pacman -Rns"
alias search="pacman -Ss"
alias files="pacman -Ql"
alias info="pacman -Si"

# AUR (yay)
alias ya="yay"
alias yau="yay -Syu"
alias yai="yay -S"
alias yar="yay -Rns"
alias yas="yay -Ss"

# Arch housekeeping
alias orphan="pacman -Qdt"
alias remove-orphan="sudo pacman -Rns \$(pacman -Qdtq)"
alias foreign="pacman -Qm"
alias explicit="pacman -Qe"
alias bigpkgs='pacman -Qq | xargs pacman -Qi | awk "/^Name/ {name=\$3} /^Installed Size/ {print \$4, \$5, name}" | sort -h | tail -20'
alias badpkg="pacman -Qk"
alias paccheck="paccache -r && sudo pacman -D --asdeps \$(pacman -Qdtq) && sudo pacman -Qk"

# System
alias reboot="sudo systemctl reboot"
alias poweroff="sudo systemctl poweroff"
alias suspend="systemctl suspend"

# Disk usage
alias dfh="df -h"
alias duh="du -h --max-depth=1"

# Kitty socket fix
alias kitty='kitty --listen-on unix:/tmp/kitty-socket'

# Environment
ENABLE_CORRECTION="true"
HYPHEN_INSENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
export NODE_ENV=development
export PATH="$HOME/.local/bin:$PATH"
export QT_STYLE_OVERRIDE=qt5ct

fpath=(~/.zsh/completions $fpath)
