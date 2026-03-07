#!/usr/bin/env bash

# File paths
KEYBINDS_FILE="$HOME/.config/hypr/keybinds.conf"

# Icons for rofi
ICON_BIND="󰌌"

if [ ! -f "$KEYBINDS_FILE" ]; then
    notify-send "Cheatsheet Error" "Could not find keybinds.conf"
    exit 1
fi

# Parse keybindings
# 1. Get lines starting with 'bind ='
# 2. Extract Mod, Key, and command/description
# 3. Format into a list for Rofi
list_keybinds() {
    grep -E '^bind[a-z]*\s*=' "$KEYBINDS_FILE" | while read -r line; do
        # Basic cleanup: remove 'bind[a-z]* = ' prefix
        clean_line=$(echo "$line" | sed -E 's/^bind[a-z]*\s*=\s*//')
        
        # Split by comma
        IFS=',' read -r mod key action target <<< "$clean_line"
        
        # Clean whitespaces
        mod=$(echo "$mod" | xargs)
        key=$(echo "$key" | xargs)
        action=$(echo "$action" | xargs)
        target=$(echo "$target" | xargs)

        # Simplify mod name
        mod=${mod//\$mainMod/SUPER}
        
        # Display nicely
        if [ -n "$target" ]; then
            printf "%-25s %s\n" "[$mod + $key]" "$target"
        else
            printf "%-25s %s\n" "[$mod + $key]" "$action"
        fi
    done | sort
}

# Run rofi
choice=$(list_keybinds | rofi -dmenu \
    -i \
    -p "Keybindings" \
    -theme-str 'window {width: 600px;} listview {lines: 15;}')

# Optional: If choice selected, just copy it or do nothing
exit 0
