#!/bin/bash

# 🎨 NamiConfig Dynamic Theme Switcher
# Populates rofi menu from ~/.config/NamiThemes/

THEMES_DIR="$HOME/NamiConfig/.config/NamiThemes"
PYTHON_SCRIPT="$HOME/NamiConfig/.config/scripts/mode_toggle.py"
ROFI_THEME="$HOME/NamiConfig/.config/rofi/themes/theme_selector.rasi"

if [ ! -d "$THEMES_DIR" ]; then
    notify-send "Error" "NamiThemes directory not found"
    exit 1
fi

# Show theme list in rofi and get selection
SELECTED_THEME=$(ls -d "$THEMES_DIR"/*/ | xargs -n 1 basename | sort | rofi -dmenu -i \
    -theme "$ROFI_THEME" \
    -p "Select Theme Family")

# Exit if nothing selected
if [ -z "$SELECTED_THEME" ]; then
    exit 0
fi

# Apply the selected theme with the Python script
# By default, this will set the theme but keep the current mode (or toggle if asked)
# Here we just want to set the theme family
python3 "$PYTHON_SCRIPT" --theme "$SELECTED_THEME" --mode toggle
