#!/usr/bin/env python3

import os
import shutil

# Paths
theme_dir = os.path.expanduser("~/.config/waybar/themes")
waybar_dir = os.path.expanduser("~/.config/waybar")
state_file = os.path.join(waybar_dir, ".current_theme")

light_theme = os.path.join(theme_dir, "theme-light.css")
dark_theme = os.path.join(theme_dir, "theme-dark.css")
target_theme = os.path.join(waybar_dir, "theme.css")

# Determine current theme
if os.path.exists(state_file):
    with open(state_file, "r") as f:
        current = f.read().strip()
else:
    current = "dark"

# Toggle and copy
if current == "dark":
    shutil.copy(light_theme, target_theme)
    with open(state_file, "w") as f:
        f.write("light")
    print("Switched to LIGHT theme")
else:
    shutil.copy(dark_theme, target_theme)
    with open(state_file, "w") as f:
        f.write("dark")
    print("Switched to DARK theme")

# Reload Waybar
os.system("pkill waybar; setsid waybar >/dev/null 2>&1 &")
