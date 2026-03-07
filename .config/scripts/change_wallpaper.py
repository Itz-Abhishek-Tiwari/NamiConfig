#!/usr/bin/env python3

import sys
import random
import json
from pathlib import Path
import nami_core as core

# === CONFIG ===
WALL_DIR = core.CONFIG_DIR / "hypr/wall"
STATE_FILE = core.CACHE_DIR / "swww_wallpaper_state.json"
TRANSITION_TYPE = "right"
TRANSITION_DURATION = "2"

def start_swww_daemon():
    res = core.run_command(["pgrep", "-x", "swww-daemon"], check=False)
    if res and res.returncode != 0:
        import subprocess
        subprocess.Popen(["swww-daemon"])

def get_wallpapers():
    if not WALL_DIR.exists():
        print(f"❌ Wallpaper directory not found: {WALL_DIR}")
        sys.exit(1)
    wallpapers = sorted([
        str(f) for f in WALL_DIR.glob("**/*")
        if f.suffix.lower() in [".jpg", ".jpeg", ".png", ".webp"]
    ])
    if not wallpapers:
        print("❌ No wallpapers found.")
        sys.exit(1)
    return wallpapers

def save_state(index):
    core.ensure_dir(STATE_FILE)
    STATE_FILE.write_text(json.dumps({"index": index}))

def load_state():
    if STATE_FILE.exists():
        try:
            data = json.loads(STATE_FILE.read_text())
            return data.get("index", 0)
        except Exception:
            pass
    return 0

def set_wallpaper(path):
    core.run_command([
        "swww", "img", path,
        "--transition-type", TRANSITION_TYPE,
        "--transition-duration", TRANSITION_DURATION
    ], check=False)
    
    # Sync system state (colors/reloads)
    # Import mode_toggle to run its main logic without spawning a new process
    try:
        import mode_toggle
        # We need to mock sys.argv or just call logic
        # Actually, running as subprocess is safer for now to avoid side effects of global state in mode_toggle
        core.run_command([sys.executable, str(core.CONFIG_DIR / "scripts/mode_toggle.py")], check=False)
    except Exception:
        pass
    
    print(f"🌄 Wallpaper set and system synced: {path}")

def main():
    wallpapers = get_wallpapers()
    total = len(wallpapers)
    index = load_state()

    if len(sys.argv) < 2:
        print("Usage: -i (random) | -0 (next) | -p (prev)")
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
