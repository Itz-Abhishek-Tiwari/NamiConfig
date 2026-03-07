#!/usr/bin/env bash

# Define variables
nami_core="python3 $HOME/NamiConfig/.config/scripts/nami_core.py"

# Define functions
print_error() {
  cat <<"EOF"
Usage: ./volumecontrol.sh -[device] <actions>
...valid devices are...
    i   -- input device
    o   -- output device
    p   -- player application
...valid actions are...
    i   -- increase volume [+2]
    d   -- decrease volume [-2]
    m   -- mute [x]
EOF
  exit 1
}

get_volume() {
  pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//'
}

get_mute() {
  pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'
}

send_notification() {
  vol=$(get_volume)
  mute=$(get_mute)
  
  if [ "$mute" = "yes" ] || [ "$vol" -eq 0 ]; then
    icon="volume-level-muted"
    msg="Volume: Muted"
  elif [ "$vol" -lt 33 ]; then
    icon="volume-level-low"
    msg="Volume: ${vol}%"
  elif [ "$vol" -lt 66 ]; then
    icon="volume-level-medium"
    msg="Volume: ${vol}%"
  else
    icon="volume-level-high"
    msg="Volume: ${vol}%"
  fi

  $nami_core notify "$msg" --title "System" --icon "$icon" --progress "$vol" --sync-id "sys-volume"
}

action_volume() {
  case "${1}" in
  i)
    current_vol=$(get_volume)
    if [ "$current_vol" -lt 100 ]; then
      new_vol=$((current_vol + 2))
      [ "$new_vol" -gt 100 ] && new_vol=100
      pactl set-sink-volume @DEFAULT_SINK@ "${new_vol}%"
    fi
    ;;
  d)
    current_vol=$(get_volume)
    new_vol=$((current_vol - 2))
    [ "$new_vol" -lt 0 ] && new_vol=0
    pactl set-sink-volume @DEFAULT_SINK@ "${new_vol}%"
    ;;
  esac
}

select_output() {
  if [ "$@" ]; then
    desc="$*"
    device=$(pactl list sinks | grep -C2 -F "Description: $desc" | grep Name | cut -d: -f2 | xargs)
    if pactl set-default-sink "$device"; then
      $nami_core notify "Activated: $desc" --title "Audio Output" --icon "audio-card" --sync-id "sys-volume"
    else
      $nami_core notify "Error activating: $desc" --title "Audio Output" --icon "dialog-error" --sync-id "sys-volume"
    fi
  else
    pactl list sinks | grep -ie "Description:" | awk -F ': ' '{print $2}' | sort
  fi
}

# Evaluate device option
while getopts iops: DeviceOpt; do
  case "${DeviceOpt}" in
  i)
    nsink=$(pactl list sources short | awk '{print $2}')
    [ -z "${nsink}" ] && echo "ERROR: Input device not found..." && exit 0
    srce="--default-source"
    ;;
  o)
    nsink=$(pactl list sinks short | awk '{print $2}')
    [ -z "${nsink}" ] && echo "ERROR: Output device not found..." && exit 0
    srce=""
    ;;
  p)
    nsink=$(playerctl --list-all | grep -w "${OPTARG}")
    [ -z "${nsink}" ] && echo "ERROR: Player ${OPTARG} not active..." && exit 0
    srce="${nsink}"
    ;;
  s)
    select_output "$@"
    exit
    ;;
  *) print_error ;;
  esac
done

# Set default variables
shift $((OPTIND - 1))

# Execute action
case "${1}" in
i) action_volume i ;;
d) action_volume d ;;
m) pactl set-sink-mute @DEFAULT_SINK@ toggle ;;
*) print_error ;;
esac

send_notification
