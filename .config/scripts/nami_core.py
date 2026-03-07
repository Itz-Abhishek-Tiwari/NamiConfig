#!/usr/bin/env python3

import os
import sys
import random
import json
import subprocess
import argparse
import shutil
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

# Wallpaper
WALL_DIR = CONFIG_DIR / "hypr/wall"
WALL_STATE_FILE = CACHE_DIR / "swww_wallpaper_state.json"
WALL_TRANSITION_TYPE = "right"
WALL_TRANSITION_DURATION = "2"

# Focus mode
HYPR_WINDOWRULES_CONF = CONFIG_DIR / "hypr/windowrules.conf"
FOCUS_STATE_FILE = CONFIG_DIR / ".hypr_rule_state"
FOCUS_RULE_LINE = "windowrule = opacity 1.0 override 1.0 override, match:class .*"
FOCUS_WALL_ON = WALL_DIR / "08.png"
FOCUS_WALL_OFF = WALL_DIR / "24.png"

# ====================== Core Functions ====================== #

def run_command(cmd, check=True, timeout=10, capture_output=False):
    """Safe wrapper for subprocess.run with timeout"""
    try:
        return subprocess.run(
            cmd,
            check=check,
            timeout=timeout,
            capture_output=capture_output,
            text=True if capture_output else False
        )
    except subprocess.TimeoutExpired:
        print(f"⌛ Command timed out: {' '.join(cmd)}")
        return None
    except Exception as e:
        print(f"❌ Command failed: {' '.join(cmd)} - {e}")
        return None

def reload_components():
    """Unified component reload with safety timeouts"""
    commands = [
        ["pkill", "-SIGUSR1", "kitty"],
        ["pkill", "-SIGUSR1", "ghostty"],
        ["pkill", "-SIGUSR2", "waybar"],
        ["swaync-client", "-rs"],
        ["hyprctl", "reload"]
    ]
    for cmd in commands:
        run_command(cmd, check=False, timeout=5)

def notify(message, title="NamiConfig", icon="weather-clear", progress=None, sync_id=None, actions=None):
    """Enhanced system notification"""
    cmd = ["notify-send", "-a", title, "-i", icon]

    if progress is not None:
        cmd.extend(["-h", f"int:value:{progress}"])

    if sync_id:
        cmd.extend(["-h", f"string:x-canonical-private-synchronous:{sync_id}"])

    if actions:
        for act_id, label in actions:
            cmd.extend([f"--action={act_id}={label}"])

    cmd.append(message)

    res = run_command(cmd, check=False, capture_output=True if actions else False)
    if actions and res:
        return res.stdout.strip()
    return None

def play_sound(sound_name_or_path):
    """Unified sound player"""
    path = Path(sound_name_or_path)
    if not path.exists():
        system_paths = [
            Path("/usr/share/sounds/freedesktop/stereo") / f"{sound_name_or_path}.oga",
            Path("/usr/share/sounds") / sound_name_or_path
        ]
        for p in system_paths:
            if p.exists():
                path = p
                break

    if not path.exists():
        return False

    players = ["pw-play", "paplay", "canberra-gtk-play"]
    for player in players:
        if shutil.which(player):
            cmd = [player, str(path)]
            if player == "canberra-gtk-play":
                cmd = [player, "-f", str(path)]
            subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            return True
    return False

def ensure_dir(path):
    """Ensure directory exists"""
    p = Path(path)
    if p.suffix:  # Likely a file
        p.parent.mkdir(parents=True, exist_ok=True)
    else:
        p.mkdir(parents=True, exist_ok=True)

def get_current_wallpaper():
    """Get the currently displayed wallpaper from swww"""
    res = run_command(["swww", "query"], check=False, capture_output=True)
    if res and res.returncode == 0:
        lines = res.stdout.splitlines()
        if lines and ": " in lines[0]:
            return Path(lines[0].split(": ")[-1].strip())
    return None

# ====================== Wallpaper Functions ====================== #

def _start_swww_daemon():
    res = run_command(["pgrep", "-x", "swww-daemon"], check=False)
    if res and res.returncode != 0:
        subprocess.Popen(["swww-daemon"])

def _get_wallpapers():
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

def _save_wall_state(index):
    ensure_dir(WALL_STATE_FILE)
    WALL_STATE_FILE.write_text(json.dumps({"index": index}))

def _load_wall_state():
    if WALL_STATE_FILE.exists():
        try:
            return json.loads(WALL_STATE_FILE.read_text()).get("index", 0)
        except Exception:
            pass
    return 0

def _apply_wallpaper(path):
    """Set a wallpaper and trigger color/theme sync."""
    run_command([
        "swww", "img", str(path),
        "--transition-type", WALL_TRANSITION_TYPE,
        "--transition-duration", WALL_TRANSITION_DURATION,
    ], check=False)

    # Sync system colors without spawning a new process
    try:
        import mode_toggle
        state = mode_toggle.get_state()
        if state.get("theme", "").lower() == "namipywal":
            import generate_colors
            generate_colors.generate_all(path, state.get("mode", "dark"))
    except Exception as e:
        print(f"⚠️  Color sync skipped: {e}")

    print(f"🌄 Wallpaper set: {path}")

def cmd_wallpaper(arg):
    """Cycle wallpapers: -0 next | -p prev | -i random"""
    wallpapers = _get_wallpapers()
    total = len(wallpapers)
    index = _load_wall_state()

    if arg == "-i":
        index = random.randint(0, total - 1)
    elif arg == "-0":
        index = (index + 1) % total
    elif arg == "-p":
        index = (index - 1) % total
    else:
        print("❌ Invalid argument. Use -0 (next) / -p (prev) / -i (random)")
        sys.exit(1)

    _start_swww_daemon()
    _apply_wallpaper(wallpapers[index])
    _save_wall_state(index)

# ====================== Focus Mode Functions ====================== #

def cmd_focus_toggle():
    """Toggle focus mode (opacity rule + wallpaper swap)"""
    if FOCUS_STATE_FILE.exists():
        _focus_off()
    else:
        _focus_on()

def _focus_on():
    if HYPR_WINDOWRULES_CONF.exists() and FOCUS_RULE_LINE in HYPR_WINDOWRULES_CONF.read_text():
        return
    with open(HYPR_WINDOWRULES_CONF, "a") as f:
        f.write("\n" + FOCUS_RULE_LINE + "\n")
    FOCUS_STATE_FILE.touch()
    run_command(["hyprctl", "reload"], check=False)
    if FOCUS_WALL_ON.exists():
        run_command(["swww", "img", str(FOCUS_WALL_ON)], check=False)
    notify("Activated", title="Focus Mode", icon="dialog-information")

def _focus_off():
    if not HYPR_WINDOWRULES_CONF.exists():
        return
    lines = HYPR_WINDOWRULES_CONF.read_text().splitlines()
    with open(HYPR_WINDOWRULES_CONF, "w") as f:
        for line in lines:
            if line.strip() != FOCUS_RULE_LINE:
                f.write(line + "\n")
    FOCUS_STATE_FILE.unlink(missing_ok=True)
    run_command(["hyprctl", "reload"], check=False)
    if FOCUS_WALL_OFF.exists():
        run_command(["swww", "img", str(FOCUS_WALL_OFF)], check=False)
    notify("Deactivated", title="Focus Mode", icon="weather-clear")

# ====================== CLI Interface ====================== #

def main():
    parser = argparse.ArgumentParser(description="NamiCore Utility CLI")
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # notify
    notify_p = subparsers.add_parser("notify", help="Send system notification")
    notify_p.add_argument("message")
    notify_p.add_argument("--title", default="NamiConfig")
    notify_p.add_argument("--icon", default="weather-clear")
    notify_p.add_argument("--progress", type=int)
    notify_p.add_argument("--sync-id")
    notify_p.add_argument("--action", action="append", help="id:label")

    # play
    play_p = subparsers.add_parser("play", help="Play sound")
    play_p.add_argument("sound")

    # reload
    subparsers.add_parser("reload", help="Reload system components")

    # wallpaper
    wall_p = subparsers.add_parser("wallpaper", help="Change wallpaper")
    wall_p.add_argument("direction", choices=["-0", "-p", "-i"],
                        help="-0 next | -p prev | -i random")

    # focus
    subparsers.add_parser("focus", help="Toggle focus mode")

    args = parser.parse_args()

    if args.command == "notify":
        actions = []
        if args.action:
            for a in args.action:
                if ":" in a:
                    actions.append(tuple(a.split(":", 1)))
        response = notify(
            args.message,
            title=args.title,
            icon=args.icon,
            progress=args.progress,
            sync_id=args.sync_id,
            actions=actions,
        )
        if response:
            print(response)

    elif args.command == "play":
        play_sound(args.sound)

    elif args.command == "reload":
        reload_components()

    elif args.command == "wallpaper":
        cmd_wallpaper(args.direction)

    elif args.command == "focus":
        cmd_focus_toggle()

    else:
        parser.print_help()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        main()
