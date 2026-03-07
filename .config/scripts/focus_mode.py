#!/usr/bin/env python3

import subprocess
from pathlib import Path

# === Paths ===
conf_file = Path.home() / ".config/hypr/windowrules.conf"
state_file = Path.home() / ".config/.hypr_rule_state"

# New syntax rule
rule_line = "windowrule = opacity 1.0 override 1.0 override, match:class .*"

wall_dir = Path.home() / ".config/hypr/wall"
wallpaper_on_add = wall_dir / "08.png"
wallpaper_on_remove = wall_dir / "24.png"


# === Helpers ===
def set_wallpaper(path: Path):
    subprocess.run(["swww", "img", str(path)], check=False)


def notify(title: str, body: str, icon: str):
    subprocess.run(["notify-send", "-i", icon, title, body], check=False)


def reload_hyprland():
    subprocess.run(["hyprctl", "reload"], check=False)


# === Rule handlers ===
def add_rule():
    if conf_file.exists() and rule_line in conf_file.read_text():
        return

    with open(conf_file, "a") as f:
        f.write("\n" + rule_line + "\n")

    state_file.touch()
    reload_hyprland()
    set_wallpaper(wallpaper_on_add)
    notify("Focus Mode", "Activated", "dialog-information")


def remove_rule():
    if not conf_file.exists():
        return

    lines = conf_file.read_text().splitlines()
    with open(conf_file, "w") as f:
        for line in lines:
            if line.strip() != rule_line:
                f.write(line + "\n")

    state_file.unlink(missing_ok=True)
    reload_hyprland()
    set_wallpaper(wallpaper_on_remove)
    notify("Focus Mode", "Deactivated", "weather-clear")


# === Toggle ===
if state_file.exists():
    remove_rule()
else:
    add_rule()
