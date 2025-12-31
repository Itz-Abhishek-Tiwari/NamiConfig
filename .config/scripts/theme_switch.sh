#!/bin/bash

PYTHON_FILE="$HOME/.config/scripts/mode_toggle.py"
THEME_LIST_FILE="$HOME/.config/NamiThemes/themes"
ROFI_THEME="$HOME/.config/rofi/launcher/test.rasi"

# Exit if theme file is missing
[ ! -f "$THEME_LIST_FILE" ] && exit 1

# Show theme list in rofi (style-15)
SELECTED_THEME=$(rofi -dmenu -i \
    -theme "$ROFI_THEME" \
    -p "Select Theme" < "$THEME_LIST_FILE")

# Exit if nothing selected
[ -z "$SELECTED_THEME" ] && exit 0

# Detect current theme
CURRENT_THEME=$(grep -oP '(?<=Colloid-(Dark|Light)-)[^"]+' "$PYTHON_FILE" | head -1)

# Replace theme in python file
sed -i "s/$CURRENT_THEME/$SELECTED_THEME/g" "$PYTHON_FILE"

# Notify
notify-send "Theme Changed" "$SELECTED_THEME"

# Run the Python script after selection
python3 "$PYTHON_FILE"
