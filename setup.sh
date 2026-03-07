#!/bin/bash

# 🌊 NamiConfig 2.0 Robust Bootstrap (Final Fix)
# Optimized for dynamic conflict resolution and GNU Stow

set -e

# Prevent running as root/sudo
if [ "$EUID" -eq 0 ]; then
    echo -e "\033[0;31mError: Do not run this script as root or with sudo.\033[0m"
    echo -e "This script is intended to stow dotfiles for your local user."
    exit 1
fi

# Automatically detect the directory where the script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET_DIR="$HOME"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🌊 NamiConfig 2.0 Bootstrap${NC}"
echo -e "----------------------------"

# Check for stow
if ! command -v stow &> /dev/null; then
    echo -e "${RED}Error: GNU Stow is not installed.${NC}"
    echo -e "Please install it with: sudo pacman -S stow"
    exit 1
fi

cd "$DOTFILES_DIR"

echo -e "${BLUE}Step 1: Identifying potential conflicts...${NC}"

# Identify all items in the current directory that would be stowed
# We use \ls to avoid aliases/icons and grep to filter known non-stow items
STOW_ITEMS=$(\ls -1A | grep -vE "^(\.git|README\.md|setup\.sh)$")

HAS_CONFLICTS=false
for item in $STOW_ITEMS; do
    # Check if entry exists in home (including broken symlinks!)
    if [ -e "$TARGET_DIR/$item" ] || [ -L "$TARGET_DIR/$item" ]; then
        # Check if it's already a symlink pointing to our dotfiles
        if [ -L "$TARGET_DIR/$item" ]; then
            LINK_TARGET=$(readlink -f "$TARGET_DIR/$item" || echo "broken")
            if [[ "$LINK_TARGET" == "$DOTFILES_DIR/$item" ]]; then
                # Already correctly symlinked, skipping
                continue
            fi
        fi
        
        # It's an actual file/dir or a symlink pointing elsewhere
        if [ "$HAS_CONFLICTS" = false ]; then
            echo -e "  Conflicts detected. Moving existing files to backup: $BACKUP_DIR"
            mkdir -p "$BACKUP_DIR"
            HAS_CONFLICTS=true
        fi
        
        echo -e "  Backing up $item -> $BACKUP_DIR/$item"
        # Mirror the structure in backup if needed
        mkdir -p "$BACKUP_DIR/$(dirname "$item")"
        
        # Use -f to force move in case of broken links
        mv -f "$TARGET_DIR/$item" "$BACKUP_DIR/$item" 2>/dev/null || rm -rf "$TARGET_DIR/$item"
    fi
done

if [ "$HAS_CONFLICTS" = false ]; then
    echo -e "  No conflicts found."
fi

# Stow everything
echo -e "${BLUE}Step 2: Symlinking dotfiles with Stow...${NC}"

# -v for verbose, -R for restow, -t for target
stow -v -R -t "$TARGET_DIR" .

echo -e "${GREEN}✅ Success! Dotfiles have been symlinked.${NC}"
echo -e "You can now reload Hyprland or restart your shell."
