#!/bin/bash

PYTHON_FILE="$HOME/.config/scripts/mode_toggle.py"
THEME_LIST_FILE="$HOME/.config/NamiThemes/themes"
ROFI_THEME="$HOME/.config/rofi/launcher/test.rasi"

# Exit if theme file is missing
if [ ! -f "$THEME_LIST_FILE" ]; then
    echo "Theme list file not found: $THEME_LIST_FILE"
    exit 1
fi

echo "Theme list file found: $THEME_LIST_FILE"

# Show theme list in rofi (style-15)
echo "Opening rofi to select theme..."
SELECTED_THEME=$(rofi -dmenu -i \
    -theme "$ROFI_THEME" \
    -p "Select Theme" < "$THEME_LIST_FILE")

# Exit if nothing selected
if [ -z "$SELECTED_THEME" ]; then
    echo "No theme selected. Exiting."
    exit 0
fi

echo "Selected theme: $SELECTED_THEME"

# Detect current theme in Python file
CURRENT_THEME=$(grep -oP '(?<=Colloid-(Dark|Light)-)[^"]+' "$PYTHON_FILE" | head -1)
echo "Current theme in Python file: $CURRENT_THEME"

# Replace old theme in Python file (existing functionality)
sed -i "s/$CURRENT_THEME/$SELECTED_THEME/g" "$PYTHON_FILE"
echo "Updated Python file with new theme: $SELECTED_THEME"

# Update CURRENT_THEME variable in Python file
# This will specifically change the line CURRENT_THEME = "..." to the new theme
sed -i "s/^CURRENT_THEME *= *.*/CURRENT_THEME = \"$SELECTED_THEME\"/" "$PYTHON_FILE"
echo "Updated CURRENT_THEME variable in Python file: $SELECTED_THEME"

# Notify
notify-send "Theme Changed" "$SELECTED_THEME"
echo "Notification sent for theme change."

# Run the Python script after selection
echo "Running Python theme toggle script..."
python3 "$PYTHON_FILE"
echo "Python script executed."
