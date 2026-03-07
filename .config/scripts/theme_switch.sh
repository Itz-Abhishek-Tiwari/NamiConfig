#!/bin/bash

# 🎨 NamiConfig Dynamic Theme Switcher
# Populates rofi menu from ~/.config/NamiThemes/

THEMES_DIR="$HOME/.config/NamiThemes"
PYTHON_SCRIPT="$HOME/.config/scripts/mode_toggle.py"
ROFI_THEME="$HOME/.config/rofi/themes/theme_selector.rasi"

if [ ! -d "$THEMES_DIR" ]; then
    notify-send "Error" "NamiThemes directory not found"
    exit 1
fi

# Professional Nerd Font Icon Mapping
get_icon() {
    case "$1" in
        catppuccin)  echo "󰄛" ;;
        gruvBox)     echo "󰼭" ;;
        nightFox)     echo "󰇧" ;;
        monoChrome)   echo "󰈊" ;;
        *)            echo "󰏘" ;;
    esac
}

# Show theme list in rofi and get selection
SELECTED_WITH_ICON=$(while read -r theme; do
    icon=$(get_icon "$theme")
    printf "%s %s\n" "$icon" "$theme"
done < <(ls -d "$THEMES_DIR"/*/ | xargs -n 1 basename | sort) | rofi -dmenu -i \
    -theme "$ROFI_THEME" \
    -p "Select Theme Family")

# Exit if nothing selected
if [ -z "$SELECTED_WITH_ICON" ]; then
    exit 0
fi

# Strip the icon prefix reliably
SELECTED_THEME=$(echo "$SELECTED_WITH_ICON" | awk '{print $NF}')

# Apply the selected theme with the Python script
# By default, this will set the theme but keep the current mode (or toggle if asked)
# Here we just want to set the theme family
python3 "$PYTHON_SCRIPT" --theme "$SELECTED_THEME" --mode toggle
