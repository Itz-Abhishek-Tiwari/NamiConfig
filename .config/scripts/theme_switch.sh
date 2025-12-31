
#!/bin/bash

# Path to your Python script
PYTHON_FILE="/home/abhishek/.config/scripts/mode_toggle.py"  # <- update this
THEME_LIST_FILE="/home/abhishek/.config/NamiThemes/themes"      # <- file with all themes, one per line

# Read themes into an array
mapfile -t THEMES < "$THEME_LIST_FILE"

# Detect the current theme in the Python script
CURRENT_THEME=$(grep -oP '(?<=Colloid-(Dark|Light)-)[^"]+' "$PYTHON_FILE" | head -1)

# Find the next theme in the list
NEXT_THEME=""
for i in "${!THEMES[@]}"; do
    if [[ "${THEMES[$i]}" == "$CURRENT_THEME" ]]; then
        NEXT_THEME_INDEX=$(( (i + 1) % ${#THEMES[@]} ))
        NEXT_THEME="${THEMES[$NEXT_THEME_INDEX]}"
        break
    fi
done

# If current theme not found in the list, default to first theme
if [[ -z "$NEXT_THEME" ]]; then
    NEXT_THEME="${THEMES[0]}"
fi

# Replace all occurrences of the current theme in the Python script
sed -i "s/$CURRENT_THEME/$NEXT_THEME/g" "$PYTHON_FILE"

# Output to terminal
echo "Switched theme from $CURRENT_THEME to $NEXT_THEME in $PYTHON_FILE"

# Send desktop notification
notify-send "Theme Changed" "$NEXT_THEME"
