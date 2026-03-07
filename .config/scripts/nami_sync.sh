#!/usr/bin/env bash

# NamiConfig Auto-Sync Script
DOTFILES_DIR="$HOME/NamiConfig"

notify-send "NamiConfig" "Starting dotfiles sync..."

cd "$DOTFILES_DIR" || exit 1

# Check for git status
if [[ -z $(git status -s) ]]; then
    notify-send "NamiConfig" "No changes to sync."
    exit 0
fi

# Sync
git add .
git commit -m "Auto-sync: $(date '+%Y-%m-%d %H:%M:%S')"
if git push origin; then
    notify-send "NamiConfig" "Successfully synced to GitHub! 🚀"
else
    notify-send "NamiConfig" "Sync failed! Check your connection or SSH keys. ❌"
    exit 1
fi
