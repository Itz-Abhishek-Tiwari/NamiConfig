#!/bin/bash

# Keyboard name as detected in `hyprctl devices`
keyboard_name="at-translated-set-2-keyboard"

# Check if the script is called with --status argument
if [ "$1" == "--status" ]; then
    # Get the current state of the keyboard
    state=$(hyprctl devices | grep -A 4 "$keyboard_name" | grep "active keymap" | awk '{print $4}')
    if [ "$state" == "English" ]; then
        echo "enabled"
    else
        echo "disabled"
    fi
    exit 0
fi

# Toggle the state
state=$(hyprctl devices | grep -A 4 "$keyboard_name" | grep "active keymap" | awk '{print $4}')
if [ "$state" == "English" ]; then
    # Disable the keyboard
    hyprctl keyword input:"$keyboard_name":enabled false
    notify-send "Keyboard disabled"
else
    # Enable the keyboard
    hyprctl keyword input:"$keyboard_name":enabled true
    notify-send "Keyboard enabled"
fi

