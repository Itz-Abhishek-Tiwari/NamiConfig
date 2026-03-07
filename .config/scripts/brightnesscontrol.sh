#!/usr/bin/env bash

# Define variables
nami_core="python3 $HOME/NamiConfig/.config/scripts/nami_core.py"

# Print error message for invalid arguments
print_error() {
    cat <<"EOF"
Usage: ./brightnesscontrol.sh <action>
Valid actions are:
    i -- <i>ncrease brightness [+2%]
    d -- <d>ecrease brightness [-2%]
EOF
}

# Send a notification with brightness info
send_notification() {
    brightness=$(brightnessctl info | grep -oP "(?<=\()\d+(?=%)")
    $nami_core notify "Brightness: ${brightness}%" --title "System" --icon "display-brightness" --progress "$brightness" --sync-id "sys-brightness"
}

# Get the current brightness percentage and device name
get_brightness() {
    brightness=$(brightnessctl -m | grep -o '[0-9]\+%' | head -c-2)
    device=$(brightnessctl -m | head -n 1 | awk -F',' '{print $1}' | sed 's/_/ /g; s/\<./\U&/g')
    current_brightness=$(brightnessctl -m | head -n 1 | awk -F',' '{print $3}')
    max_brightness=$(brightnessctl -m | head -n 1 | awk -F',' '{print $5}')
}

get_brightness

# Handle options
while getopts o: opt; do
    case "${opt}" in
    o)
        case $OPTARG in
        i) # Increase brightness
            if [[ $brightness -lt 10 ]]; then
                brightnessctl set +1%
            else
                brightnessctl set +2%
            fi
            send_notification
            ;;
        d) # Decrease brightness
            if [[ $brightness -le 1 ]]; then
                brightnessctl set 1%
            elif [[ $brightness -le 10 ]]; then
                brightnessctl set 1%-
            else
                brightnessctl set 2%-
            fi
            send_notification
            ;;
        *)
            print_error
            ;;
        esac
        ;;
    *)
        print_error
        ;;
    esac
done

# Backlight module for Waybar (preserving the JSON output format)
get_icon() {
    if ((brightness <= 5)); then icon=""; elif ((brightness <= 15)); then icon=""; elif ((brightness <= 30)); then icon=""
    elif ((brightness <= 45)); then icon=""; elif ((brightness <= 55)); then icon=""; elif ((brightness <= 65)); then icon=""
    elif ((brightness <= 80)); then icon=""; elif ((brightness <= 95)); then icon=""; else icon=""; fi
}

get_icon
module="${icon} ${brightness}%"
tooltip="Device: ${device}\nBrightness: ${current_brightness} / ${max_brightness}"

echo "{\"text\": \"${module}\", \"tooltip\": \"${tooltip}\"}"
