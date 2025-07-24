#!/usr/bin/env python3

import subprocess
from pathlib import Path

# === Paths ===
conf_file = Path.home() / ".config" / "hypr" / "windowrules.conf"
state_file = Path.home() / ".config" / ".hypr_rule_state"
rule_line = "windowrulev2 = opacity 1 1,class:^(.*)$"

wall_dir = Path.home() / ".config" / "hypr" / "wall"
wallpaper_on_add = wall_dir / "08.png"
wallpaper_on_remove = wall_dir / "24.png"


# === Functions ===
def set_wallpaper(path: Path):
    subprocess.run(["swww", "img", str(path)], check=True)


def send_notification(title: str, body: str, icon: str):
    subprocess.run(["notify-send", "-i", icon, title, body])


def add_rule():
    with open(conf_file, "a") as f:
        f.write("\n" + rule_line)
    state_file.touch()
    set_wallpaper(wallpaper_on_add)
    send_notification("🧠 Focus Mode", "Activated", "dialog-information")


def remove_rule():
    lines = conf_file.read_text().splitlines()
    with open(conf_file, "w") as f:
        for line in lines:
            if line.strip() != rule_line:
                f.write(line + "\n")
    state_file.unlink(missing_ok=True)
    set_wallpaper(wallpaper_on_remove)
    send_notification("💤 Focus Mode", "Deactivated", "weather-clear")


# === Main Toggle ===
if state_file.exists():
    remove_rule()
else:
    add_rule()
