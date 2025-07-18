#!/usr/bin/env python3

import os
import shutil
import subprocess

# Config directories
config_dir = os.path.expanduser("~/.config")
state_file = os.path.join(config_dir, ".current_theme")

# Kitty theme files
kitty_theme_dir = os.path.expanduser("~/.config/NamiThemes/kitty/themes")
kitty_dir = os.path.expanduser("~/.config/kitty")
kitty_light = os.path.join(kitty_theme_dir, "theme-light.conf")
kitty_dark = os.path.join(kitty_theme_dir, "theme-dark.conf")
kitty_target = os.path.join(kitty_dir, "theme.conf")

# Waybar theme files
waybar_theme_dir = os.path.expanduser("~/.config/NamiThemes/waybar/themes")
waybar_dir = os.path.expanduser("~/.config/waybar")
waybar_light = os.path.join(waybar_theme_dir, "theme-light.css")
waybar_dark = os.path.join(waybar_theme_dir, "theme-dark.css")
waybar_target = os.path.join(waybar_dir, "theme.css")

# Mako theme files
mako_theme_dir = os.path.expanduser("~/.config/NamiThemes/mako/themes")
mako_dir = os.path.expanduser("~/.config/mako")
mako_light = os.path.join(mako_theme_dir, "theme-light")
mako_dark = os.path.join(mako_theme_dir, "theme-dark")
mako_target = os.path.join(mako_dir, "config")

# Absolute Papirus-Dark icon paths
icon_light = "/usr/share/icons/Papirus-Dark/48x48/status/weather-clear.svg"
icon_dark = "/usr/share/icons/Papirus-Dark/48x48/status/weather-clear-night.svg"


def get_current_theme():
    if os.path.exists(state_file):
        with open(state_file, "r") as f:
            return f.read().strip()
    return "dark"


def set_current_theme(theme):
    with open(state_file, "w") as f:
        f.write(theme)


def switch_kitty(theme):
    source = kitty_light if theme == "light" else kitty_dark
    if os.path.exists(source):
        shutil.copy(source, kitty_target)
        subprocess.run("kill -10 $(pgrep kitty)", shell=True)


def switch_waybar(theme):
    source = waybar_light if theme == "light" else waybar_dark
    if os.path.exists(source):
        shutil.copy(source, waybar_target)
        subprocess.run(["pkill", "waybar"])
        subprocess.Popen(
            ["waybar"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )


def switch_mako(theme):
    source = mako_light if theme == "light" else mako_dark
    if os.path.exists(source):
        shutil.copy(source, mako_target)
        subprocess.run(["pkill", "-SIGUSR2", "mako"])


def notify(theme):
    icon = icon_light if theme == "light" else icon_dark
    message = f"Switched to {theme.capitalize()} Theme"
    subprocess.run(["notify-send", "-i", icon, message])


def main():
    current = get_current_theme()
    new_theme = "dark" if current == "light" else "light"

    switch_kitty(new_theme)
    switch_waybar(new_theme)
    switch_mako(new_theme)
    set_current_theme(new_theme)
    notify(new_theme)


if __name__ == "__main__":
    main()
