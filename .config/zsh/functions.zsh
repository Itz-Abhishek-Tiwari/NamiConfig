gitwho() {
  autoload -U colors && colors
  print -P ""
  print -P "%F{109} Git Dashboard%f"
  print -P "%F{243}────────────────────────────────%f"

  if git rev-parse --is-inside-work-tree &>/dev/null; then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    [[ -z "$branch" ]] && branch=$(git rev-parse --short HEAD)
    if [[ -n "$(git status --porcelain)" ]]; then
      repo_status="%F{167}● Dirty%f"
    else
      repo_status="%F{142}● Clean%f"
    fi
    local_name=$(git config user.name 2>/dev/null)
    local_email=$(git config user.email 2>/dev/null)

    print -P "%F{214} Branch:%f %F{109}$branch%f"
    print -P "%F{214} Status:%f $repo_status"
    print -P ""
    print -P "%F{208}📁 Local Identity%f"
    print -P "  %F{142} $local_name%f"
    print -P "  %F{175} $local_email%f"
  else
    print -P "%F{167}Not inside a Git repository%f"
  fi

  print -P ""
  print -P "%F{208}🌍 Global Identity%f"
  print -P "  %F{142} $(git config --global user.name)%f"
  print -P "  %F{175} $(git config --global user.email)%f"

  if [[ -f ~/.ssh/id_rsa.pub ]]; then
    fingerprint=$(ssh-keygen -lf ~/.ssh/id_rsa.pub | awk '{print $2}')
    print -P ""
    print -P "%F{109}🔐 SSH Fingerprint%f"
    print -P "  %F{109}$fingerprint%f"
  fi
  print -P ""
}
