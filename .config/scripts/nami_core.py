#!/usr/bin/env python3

import os
import subprocess
from pathlib import Path

# ====================== Constants ====================== #
HOME = Path.home()
CONFIG_DIR = Path(os.getenv("XDG_CONFIG_HOME", HOME / ".config"))
CACHE_DIR = HOME / ".cache"
NAMICONFIG_DIR = HOME / "NamiConfig"
THEMES_DIR = CONFIG_DIR / "NamiThemes"
STATE_FILE = CONFIG_DIR / ".theme_state.json"

# App-specific paths
HYPR_COLORS_CONF = CONFIG_DIR / "hypr/themes/colors.conf"
WAYBAR_STYLE_DIR = CONFIG_DIR / "waybar/style"
WAYBAR_COLORS = WAYBAR_STYLE_DIR / "colors.css"
SWAYNC_COLORS = CONFIG_DIR / "swaync/colors.css"
ROFI_PYWAL_COLORS = CONFIG_DIR / "rofi/colors/namipywal.rasi"
ROFI_THEME_COLORS = CONFIG_DIR / "rofi/colors/theme.rasi"
ZED_SETTINGS = CONFIG_DIR / "zed/settings.json"
ZED_THEMES_DIR = CONFIG_DIR / "zed/themes"
WAL_CACHE = CACHE_DIR / "wal/colors.json"

# ====================== Core Functions ====================== #

def run_command(cmd, check=True, timeout=None, capture_output=False):
    """Safe wrapper for subprocess.run"""
    try:
        return subprocess.run(
            cmd, 
            check=check, 
            timeout=timeout, 
            capture_output=capture_output, 
            text=True if capture_output else False
        )
    except Exception as e:
        print(f"❌ Command failed: {' '.join(cmd)} - {e}")
        return None

def reload_components():
    """Unified component reload"""
    commands = [
        ["pkill", "-SIGUSR1", "kitty"],
        ["pkill", "-SIGUSR1", "ghostty"],
        ["pkill", "-SIGUSR2", "waybar"],
        ["swaync-client", "-rs"],
        ["hyprctl", "reload"]
    ]
    for cmd in commands:
        run_command(cmd, check=False)

def notify(message, title="NamiConfig", icon="weather-clear"):
    """System notification"""
    run_command(["notify-send", "-a", title, "-i", icon, message], check=False)

def ensure_dir(path):
    """Ensure directory exists"""
    Path(path).parent.mkdir(parents=True, exist_ok=True)
