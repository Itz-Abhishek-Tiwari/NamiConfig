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
  zsh-autosuggestions
  zsh-syntax-highlighting
)


source $ZSH/oh-my-zsh.sh

eval "$(starship init zsh)"

# Set editor: nvim by default (common on Arch), vim over SSH
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Useful aliases
alias gs="git status"
alias gp="git push"
alias gl="git pull"
alias serve="npx serve"
alias start="npm start"
alias test="npm test"
alias lint="npm run lint"
alias dev="npm run dev"
alias py="python3"
alias pipi="pip install"

# Include local node_modules binaries
export PATH="./node_modules/.bin:$PATH"

ENABLE_CORRECTION="true"
HYPHEN_INSENSITIVE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

export NODE_ENV=development

# Arch-specific: add common user bin directory to PATH
export PATH="$HOME/.local/bin:$PATH"

# Arch Linux package management shortcuts
alias update="sudo pacman -Syu"             # Full system update
alias upgrade="sudo pacman -Syu"            # Same as update
alias install="sudo pacman -S"              # Install a package
alias remove="sudo pacman -Rns"             # Remove package + dependencies + config
alias search="pacman -Ss"                    # Search for a package
alias files="pacman -Ql"                     # List files installed by a package
alias info="pacman -Si"                      # Get info about a package

# AUR helper aliases (if you use yay)
alias ya="yay"
alias yau="yay -Syu"
alias yai="yay -S"
alias yar="yay -Rns"
alias yas="yay -Ss"

# System management
alias reboot="sudo systemctl reboot"
alias poweroff="sudo systemctl poweroff"
alias suspend="systemctl suspend"

# Disk usage and free space
alias dfh="df -h"
alias duh="du -h --max-depth=1"

# Faster directory navigation (optional)
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias c='clear'
