#!/usr/bin/env python3

from pathlib import Path
import nami_core as core

# === Paths ===
CONF_FILE = core.CONFIG_DIR / "hypr/windowrules.conf"
STATE_FILE = core.CONFIG_DIR / ".hypr_rule_state"

# New syntax rule
RULE_LINE = "windowrule = opacity 1.0 override 1.0 override, match:class .*"

WALL_DIR = core.CONFIG_DIR / "hypr/wall"
WALL_ON = WALL_DIR / "08.png"
WALL_OFF = WALL_DIR / "24.png"

# === Rule handlers ===
def add_rule():
    if CONF_FILE.exists() and RULE_LINE in CONF_FILE.read_text():
        return

    with open(CONF_FILE, "a") as f:
        f.write("\n" + RULE_LINE + "\n")

    STATE_FILE.touch()
    core.run_command(["hyprctl", "reload"], check=False)
    core.run_command(["swww", "img", str(WALL_ON)], check=False)
    core.notify("Activated", title="Focus Mode", icon="dialog-information")

def remove_rule():
    if not CONF_FILE.exists():
        return

    lines = CONF_FILE.read_text().splitlines()
    with open(CONF_FILE, "w") as f:
        for line in lines:
            if line.strip() != RULE_LINE:
                f.write(line + "\n")

    STATE_FILE.unlink(missing_ok=True)
    core.run_command(["hyprctl", "reload"], check=False)
    core.run_command(["swww", "img", str(WALL_OFF)], check=False)
    core.notify("Deactivated", title="Focus Mode", icon="weather-clear")

# === Toggle ===
if __name__ == "__main__":
    if STATE_FILE.exists():
        remove_rule()
    else:
        add_rule()
