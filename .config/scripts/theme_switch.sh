#!/bin/bash

# 🎨 NamiConfig Dynamic Theme Switcher
# Populates rofi menu from ~/.config/NamiThemes/

THEMES_DIR="$HOME/NamiConfig/.config/NamiThemes"
PYTHON_SCRIPT="$HOME/NamiConfig/.config/scripts/mode_toggle.py"
ROFI_THEME="$HOME/NamiConfig/.config/rofi/themes/theme_selector.rasi"
STATE_FILE="$HOME/.config/.theme_state.json"
nami_core="python3 $HOME/NamiConfig/.config/scripts/nami_core.py"

if [ ! -d "$THEMES_DIR" ]; then
    $nami_core notify "NamiThemes directory not found" --title "Error" --icon "dialog-error"
    exit 1
fi

# Read current mode from state file (default to dark)
if [ -f "$STATE_FILE" ]; then
    CURRENT_MODE=$(jq -r '.mode' "$STATE_FILE")
else
    CURRENT_MODE="dark"
fi

# Show theme list in rofi and get selection
SELECTED_THEME=$(ls -d "$THEMES_DIR"/*/ | xargs -n 1 basename | sort | rofi -dmenu -i \
    -theme "$ROFI_THEME" \
    -p "Select Theme Family")

# Exit if nothing selected
[ -z "$SELECTED_THEME" ] && exit 0

# Apply selected theme while preserving current mode
python3 "$PYTHON_SCRIPT" --theme "$SELECTED_THEME" --mode "$CURRENT_MODE"
