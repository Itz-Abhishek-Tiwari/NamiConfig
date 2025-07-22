#!/usr/bin/env python3

import os
import sys
import random
import json
import subprocess
from pathlib import Path

# === CONFIG ===
WALLPAPER_DIR = Path.home() / ".config/hypr/wall"
STATE_FILE = Path.home() / ".cache" / "swww_wallpaper_state.json"
TRANSITION_TYPE = "right"
TRANSITION_DURATION = "2"


# === Functions ===
def start_swww_daemon():
    try:
        subprocess.run(
            ["pgrep", "-x", "swww-daemon"], check=True, stdout=subprocess.DEVNULL
        )
    except subprocess.CalledProcessError:
        subprocess.Popen(["swww-daemon"])


def get_wallpapers():
    if not WALLPAPER_DIR.exists():
        print(f"❌ Wallpaper directory not found: {WALLPAPER_DIR}")
        sys.exit(1)
    wallpapers = sorted(
        [
            str(f)
            for f in WALLPAPER_DIR.glob("**/*")
            if f.suffix.lower() in [".jpg", ".jpeg", ".png", ".webp"]
        ]
    )
    if not wallpapers:
        print("❌ No wallpapers found.")
        sys.exit(1)
    return wallpapers


def save_state(index):
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(STATE_FILE, "w") as f:
        json.dump({"index": index}, f)


def load_state():
    if STATE_FILE.exists():
        with open(STATE_FILE) as f:
            data = json.load(f)
            return data.get("index", 0)
    return 0


def set_wallpaper(path):
    subprocess.run(
        [
            "swww",
            "img",
            path,
            "--transition-type",
            TRANSITION_TYPE,
            "--transition-duration",
            TRANSITION_DURATION,
        ]
    )
    print(f"🌄 Wallpaper set: {path}")


# === Main Logic ===
def main():
    wallpapers = get_wallpapers()
    total = len(wallpapers)
    index = load_state()

    if len(sys.argv) < 2:
        print("Usage:")
        print("  -i → random wallpaper")
        print("  -0 → next wallpaper")
        print("  -p → previous wallpaper")
        sys.exit(1)

    arg = sys.argv[1]

    if arg == "-i":
        index = random.randint(0, total - 1)
    elif arg == "-0":
        index = (index + 1) % total
    elif arg == "-p":
        index = (index - 1) % total
    else:
        print("❌ Invalid argument. Use -i / -0 / -p")
        sys.exit(1)

    start_swww_daemon()
    set_wallpaper(wallpapers[index])
    save_state(index)


if __name__ == "__main__":
    main()
