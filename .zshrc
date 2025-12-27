### --- Oh My Zsh Setup ---
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
eval "$(rbenv init -)"
fpath=(~/.zsh/completions $fpath)

### --- Editor ---
[[ -n $SSH_CONNECTION ]] && export EDITOR='vim' || export EDITOR='nvim'

### --- Environment Variables ---
export NODE_ENV=development
export QT_STYLE_OVERRIDE=qt5ct
export BAT_THEME="Catppuccin-mocha"
export XDG_CURRENT_DESKTOP=KDE
export KDE_FULL_SESSION=true
export PATH="./node_modules/.bin:$HOME/.local/bin:$PATH"

### --- Zsh Options ---
ENABLE_CORRECTION="true"
HYPHEN_INSENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

### --- Safety Aliases ---
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

### --- Git Shortcuts ---
alias gs="git status"
alias gp="git push"
alias gl="git pull"

### --- NPM/Yarn Shortcuts ---
alias serve="npx serve"
alias start="npm start"
alias test="npm test"
alias lint="npm run lint"
alias dev="npm run dev"
alias py="python3"
alias pipi="pip install"

### --- Directory Shortcuts ---
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias c='clear'

### --- Listing Aliases (Eza) ---
alias ls="eza --icons=always --group-directories-first --color=always"
alias ll="eza -lah --icons=always"
alias la="eza -a --icons=always"
alias l="eza -CF --icons=always"

### --- Network Tools ---
alias ping="ping -c 5"
alias myip="curl ifconfig.me"
alias ports="sudo lsof -i -P -n | grep LISTEN"

### --- Pacman Shortcuts ---
alias update="sudo pacman -Syu"
alias upgrade="sudo pacman -Syu"
alias install="sudo pacman -S"
alias remove="sudo pacman -Rns"
alias search="pacman -Ss"
alias files="pacman -Ql"
alias info="pacman -Si"

### --- Yay Shortcuts ---
alias ya="yay"
alias yau="yay -Syu"
alias yai="yay -S"
alias yar="yay -Rns"
alias yas="yay -Ss"

### --- System Info & Cleanup ---
alias fastfetch="fastfetch --config ascii-art"
alias orphan="pacman -Qdt"
alias remove-orphan="sudo pacman -Rns $(pacman -Qdtq)"
alias foreign="pacman -Qm"
alias explicit="pacman -Qe"
alias bigpkgs='pacman -Qq | xargs pacman -Qi | awk "/^Name/ {name=\$3} /^Installed Size/ {print \$4, \$5, name}" | sort -h | tail -20'
alias badpkg="pacman -Qk"
alias paccheck="paccache -r && sudo pacman -D --asdeps $(pacman -Qdtq) && sudo pacman -Qk"

### --- System Control ---
alias reboot="sudo systemctl reboot"
alias poweroff="sudo systemctl poweroff"
alias suspend="systemctl suspend"

### --- Disk Usage ---
alias dfh="df -h"
alias duh="du -h --max-depth=1"


export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH




# Android SDK
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/emulator:$PATH

export PATH=$PATH:$(go env GOPATH)/bin
