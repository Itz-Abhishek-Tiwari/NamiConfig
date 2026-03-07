### =========================
### --- Oh My Zsh Setup ---
### =========================

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

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Starship prompt
eval "$(starship init zsh)"

# Custom completions
fpath=(~/.zsh/completions $fpath)


### =========================
### --- Editor ---
### =========================

[[ -n $SSH_CONNECTION ]] && export EDITOR='vim' || export EDITOR='nvim'


### =========================
### --- Environment Variables ---
### =========================

export NODE_ENV="development"
export QT_STYLE_OVERRIDE="qt5ct"
export BAT_THEME="Catppuccin-mocha"
export XDG_CURRENT_DESKTOP="KDE"
export KDE_FULL_SESSION="true"
export PATH="./node_modules/.bin:$HOME/.local/bin:$PATH"


### =========================
### --- Zsh Options ---
### =========================

ENABLE_CORRECTION="true"
HYPHEN_INSENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"
CASE_SENSITIVE="false"   # Case-insensitive completion


### =========================
### --- Safety Aliases ---
### =========================

alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"


### =========================
### --- Git Shortcuts ---
### =========================

alias gs="git status"
alias gp="git push"
alias gl="git pull"


### =========================
### --- NPM / Yarn Shortcuts ---
### =========================

alias serve="npx serve"
alias start="npm start"
alias test="npm test"
alias lint="npm run lint"
alias dev="npm run dev"
alias py="python3"
alias pipi="pip install"


### =========================
### --- Directory Shortcuts ---
### =========================

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias c="clear"


### =========================
### --- Listing Aliases (Eza) ---
### =========================

alias ls="eza --icons=always --group-directories-first --color=always"
alias ll="eza -lah --icons=always"
alias la="eza -a --icons=always"
alias l="eza -CF --icons=always"


### =========================
### --- Network Tools ---
### =========================

alias ping="ping -c 5"
alias myip="curl ifconfig.me"
alias ports="sudo lsof -i -P -n | grep LISTEN"


### =========================
### --- Pacman Shortcuts ---
### =========================

alias update="sudo pacman -Syu"
alias upgrade="sudo pacman -Syu"
alias install="sudo pacman -S"
alias remove="sudo pacman -Rns"
alias search="pacman -Ss"
alias files="pacman -Ql"
alias info="pacman -Si"


### =========================
### --- Yay Shortcuts ---
### =========================

alias ya="yay"
alias yau="yay -Syu"
alias yai="yay -S"
alias yar="yay -Rns"
alias yas="yay -Ss"


### =========================
### --- System Info & Cleanup ---
### =========================

alias fastfetch="fastfetch --config ascii-art"
alias orphan="pacman -Qdt"
alias remove-orphan="sudo pacman -Rns $(pacman -Qdtq)"
alias foreign="pacman -Qm"
alias explicit="pacman -Qe"
alias bigpkgs='pacman -Qq | xargs pacman -Qi | awk "/^Name/ {name=\$3} /^Installed Size/ {print \$4, \$5, name}" | sort -h | tail -20'
alias badpkg="pacman -Qk"
alias paccheck="paccache -r && sudo pacman -D --asdeps $(pacman -Qdtq) && sudo pacman -Qk"


### =========================
### --- System Control ---
### =========================

alias reboot="sudo systemctl reboot"
alias poweroff="sudo systemctl poweroff"
alias suspend="systemctl suspend"


### =========================
### --- Disk Usage ---
### =========================

alias dfh="df -h"
alias duh="du -h --max-depth=1"


### =========================
### --- Java ---
### =========================

export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"
export PATH="$JAVA_HOME/bin:$PATH"


### =========================
### --- Android SDK ---
### =========================

export ANDROID_HOME="$HOME/Android"
export ANDROID_SDK_ROOT="$HOME/Android"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"


### =========================
### --- Go ---
### =========================

export PATH="$PATH:$(go env GOPATH)/bin"


### =========================
### --- Git Dashboard Function ---
### =========================

gitwho() {
  autoload -U colors && colors
  print -P ""

  print -P "%F{39} Git Dashboard%f"
  print -P "%F{240}────────────────────────────────%f"

  if git rev-parse --is-inside-work-tree &>/dev/null; then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    [[ -z "$branch" ]] && branch=$(git rev-parse --short HEAD)

    if [[ -n "$(git status --porcelain)" ]]; then
      repo_status="%F{196}● Dirty%f"
    else
      repo_status="%F{46}● Clean%f"
    fi

    local_name=$(git config user.name 2>/dev/null)
    local_email=$(git config user.email 2>/dev/null)

    print -P "%F{220} Branch:%f %F{82}$branch%f"
    print -P "%F{220} Status:%f $repo_status"
    print -P ""

    print -P "%F{214}📁 Local Identity%f"
    print -P "  %F{76} $local_name%f"
    print -P "  %F{213} $local_email%f"

  else
    print -P "%F{196}Not inside a Git repository%f"
  fi

  print -P ""
  print -P "%F{214}🌍 Global Identity%f"
  print -P "  %F{76} $(git config --global user.name)%f"
  print -P "  %F{213} $(git config --global user.email)%f"

  if [[ -f ~/.ssh/id_rsa.pub ]]; then
    fingerprint=$(ssh-keygen -lf ~/.ssh/id_rsa.pub | awk '{print $2}')
    print -P ""
    print -P "%F{111}🔐 SSH Fingerprint%f"
    print -P "  %F{45}$fingerprint%f"
  fi

  print -P ""
}


### =========================
### --- Zsh Completion Fix ---
### =========================
export XDG_CURRENT_DESKTOP=Hyprland
export DESKTOP_SESSION=hyprland
unset KDE_FULL_SESSION
autoload -Uz compinit
compinit
