#!/usr/bin/env bash

# 🌅 NamiConfig Wallpaper Theme Picker
# Select a light and dark wallpaper for your current theme

WALLPAPER_DIR="$HOME/.config/hypr/wall"
THEMES_DIR="$HOME/NamiConfig/.config/NamiThemes"
STATE_FILE="$HOME/.config/.theme_state.json"
nami_core="python3 $HOME/NamiConfig/.config/scripts/nami_core.py"

# Get current theme from state file
if [ -f "$STATE_FILE" ]; then
    CURRENT_THEME=$(jq -r '.theme' "$STATE_FILE")
else
    CURRENT_THEME="catppuccin" # Fallback
fi

# 1. Select Mode (Light or Dark)
MODE=$(echo -e "light\ndark" | rofi -dmenu -i -p "Select Variant for $CURRENT_THEME")

if [ -z "$MODE" ]; then
    exit 0
fi

# 2. Select Wallpaper
# Get list of wallpapers (filenames only)
WALLPAPER=$(ls "$WALLPAPER_DIR" | grep -E "\.(jpg|jpeg|png|webp)$" | rofi -dmenu -i -p "Select Wallpaper for $MODE variant")

if [ -z "$WALLPAPER" ]; then
    exit 0
fi

# 3. Create Symlink
TARGET_DIR="$THEMES_DIR/$CURRENT_THEME/wallpapers"
mkdir -p "$TARGET_DIR"

# Target filename (we force .png for simplicity in mode_toggle.py, or handle extension)
# Actually mode_toggle.py checks for both .png and .jpg
EXT="${WALLPAPER##*.}"
TARGET_FILE="$TARGET_DIR/$MODE.$EXT"

# Remove existing symlinks for this mode (regardless of extension)
rm -f "$TARGET_DIR/$MODE.png" "$TARGET_DIR/$MODE.jpg"

ln -sf "$WALLPAPER_DIR/$WALLPAPER" "$TARGET_FILE"

$nami_core notify "Set $WALLPAPER as $MODE wallpaper for $CURRENT_THEME" --title "NamiConfig" --icon "image"

# 4. Trigger reload if the current mode matches the one we just set
ACTIVE_MODE=$(jq -r '.mode' "$STATE_FILE")
if [ "$ACTIVE_MODE" == "$MODE" ]; then
    python3 "$HOME/NamiConfig/.config/scripts/mode_toggle.py" --theme "$CURRENT_THEME" --mode "$MODE"
fi
