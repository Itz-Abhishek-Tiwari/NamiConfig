#!/usr/bin/env sh

# --- CONFIGURATION ---

XDG_PICTURES_DIR="${XDG_PICTURES_DIR:-$HOME/Pictures}"
save_dir="${2:-$XDG_PICTURES_DIR/Screenshots}"
swpy_dir="$HOME/.config/swappy"
save_file="$(date +'%y%m%d_%Hh%Mm%Ss_screenshot.png')"
temp_screenshot="/tmp/screenshot.png"

# --- FUNCTIONS ---

restore_shader() {
	if [ -n "$shader" ]; then
		hyprshade on "$shader"
	fi
}

save_shader() {
	shader=$(hyprshade current)
	hyprshade off
	trap restore_shader EXIT
}

print_error() {
	cat <<"EOF"
    ./screenshot.sh <action>
    ...valid actions are...
        p  : print all screens
        s  : snip current screen
        sf : snip current screen (frozen)
        m  : print focused monitor
EOF
}

# --- MAIN LOGIC ---

save_shader

mkdir -p "$save_dir"
mkdir -p "$swpy_dir"
echo -e "[Default]\nsave_dir=$save_dir\nsave_filename_format=$save_file" > "$swpy_dir/config"

case "$1" in
	p)  grimblast copysave screen "$temp_screenshot" && swappy -f "$temp_screenshot" ;;
	s)  grimblast copysave area "$temp_screenshot" && swappy -f "$temp_screenshot" ;;
	sf) grimblast --freeze copysave area "$temp_screenshot" && swappy -f "$temp_screenshot" ;;
	m)  grimblast copysave output "$temp_screenshot" && swappy -f "$temp_screenshot" ;;
	*)  print_error && exit 1 ;;
esac

rm -f "$temp_screenshot"

if [ -f "${save_dir}/${save_file}" ]; then
	notify-send -a "t1" -i "${save_dir}/${save_file}" "saved in ${save_dir}"
fi

