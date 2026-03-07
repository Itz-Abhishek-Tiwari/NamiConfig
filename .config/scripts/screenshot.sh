#!/usr/bin/env sh

# --- CONFIGURATION ---
XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
save_dir="${XDG_PICTURES_DIR}/Screenshots"
swpy_dir="$HOME/.config/swappy"
save_file="$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')"
temp_screenshot="/tmp/screenshot.png"
sound_file="/usr/share/sounds/freedesktop/stereo/camera-shutter.oga"

# --- DEFAULTS ---
timer=0
copy_only=false
save_only=false
freeze=false

# --- FUNCTIONS ---
restore_shader() {
	if [ -n "$shader" ]; then
		hyprshade on "$shader"
	fi
}

save_shader() {
	if command -v hyprshade >/dev/null; then
		shader=$(hyprshade current)
		hyprshade off
		trap restore_shader EXIT
	fi
}

play_sound() {
	if [ -f "$sound_file" ]; then
		if command -v pw-play >/dev/null; then
			pw-play "$sound_file" &
		elif command -v paplay >/dev/null; then
			paplay "$sound_file" &
		elif command -v canberra-gtk-play >/dev/null; then
			canberra-gtk-play -f "$sound_file" &
		fi
	fi
}

print_error() {
	cat <<EOF
Usage: ./screenshot.sh [options] <action>

Options:
    -d <sec> : Delay in seconds
    -c       : Copy to clipboard only (no file save, no editor)
    -s       : Save to file only (bypass swappy editor)
    -f       : Freeze screen (only for area snip)

Actions:
    p  : All screens (Full)
    s  : Snip area
    m  : Focused monitor
    w  : Active window
EOF
}

# --- PARSE OPTIONS ---
while getopts "d:csf" opt; do
	case $opt in
		d) timer=$OPTARG ;;
		c) copy_only=true ;;
		s) save_only=true ;;
		f) freeze=true ;;
		*) print_error && exit 1 ;;
	esac
done
shift $((OPTIND-1))

action=$1

if [ -z "$action" ]; then
    print_error && exit 1
fi

# --- MAIN LOGIC ---
if [ "$timer" -gt 0 ]; then
    notify-send -a "Screenshots" "Timer started" "Capturing in $timer seconds..." -t 2000
    sleep "$timer"
fi

save_shader

mkdir -p "$save_dir"
mkdir -p "$swpy_dir"
echo "[Default]
save_dir=$save_dir
save_filename_format=$save_file" > "$swpy_dir/config"

case "$action" in
	p)  target="screen" ;;
	s)  target="area" ;;
	m)  target="output" ;;
	w)  target="active" ;;
	*)  print_error && exit 1 ;;
esac

[ "$freeze" = true ] && [ "$action" = "s" ] && target="area --freeze"

# Handle Copy-Only mode
if [ "$copy_only" = true ]; then
    if grimblast copy $target; then
        play_sound
        notify-send -a "Screenshots" "Copied to clipboard" "Area: $action"
    fi
    exit 0
fi

# Capture and handle save/edit
if grimblast copysave $target "$temp_screenshot"; then
    play_sound
    
    if [ "$save_only" = true ]; then
        mv "$temp_screenshot" "$save_dir/$save_file"
        final_path="$save_dir/$save_file"
    else
        swappy -f "$temp_screenshot"
        final_path="$save_dir/$save_file"
    fi
    
    if [ -f "$final_path" ]; then
        notify-send -a "Screenshots" -i "$final_path" "Screenshot Saved" "Path: $save_dir" \
            --action="open=Open Folder" --action="view=View Image" | while read -r response; do
            case "$response" in
                "open") xdg-open "$save_dir" ;;
                "view") xdg-open "$final_path" ;;
            esac
        done
    else
        rm -f "$temp_screenshot"
    fi
fi

rm -f "$temp_screenshot"

