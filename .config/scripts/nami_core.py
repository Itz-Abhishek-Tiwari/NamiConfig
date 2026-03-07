import os
import sys
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

def notify(message, title="NamiConfig", icon="weather-clear", progress=None, sync_id=None, actions=None):
    """Enhanced system notification"""
    cmd = ["notify-send", "-a", title, "-i", icon]
    
    if progress is not None:
        cmd.extend(["-h", f"int:value:{progress}"])
        
    if sync_id:
        cmd.extend(["-h", f"string:x-canonical-private-synchronous:{sync_id}"])
    
    if actions:
        # actions format: [("id", "label"), ...]
        for act_id, label in actions:
            cmd.extend([f"--action={act_id}={label}"])
            
    cmd.append(message)
    
    # If we have actions, we need to handle them in a way that doesn't block
    # or just return the response if run via CLI
    res = run_command(cmd, check=False, capture_output=True if actions else False)
    if actions and res:
        return res.stdout.strip()
    return None

def play_sound(sound_name_or_path):
    """Unified sound player"""
    path = Path(sound_name_or_path)
    if not path.exists():
        # Try common paths if it's just a name
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
    if p.suffix: # Likely a file
        p.parent.mkdir(parents=True, exist_ok=True)
    else:
        p.mkdir(parents=True, exist_ok=True)

# ====================== CLI Interface ====================== #

def main():
    parser = argparse.ArgumentParser(description="NamiCore Utility CLI")
    subparsers = parser.add_subparsers(dest="command", help="Commands")

    # Notify command
    notify_parser = subparsers.add_parser("notify", help="Send system notification")
    notify_parser.add_argument("message", help="Notification message")
    notify_parser.add_argument("--title", default="NamiConfig", help="Notification title")
    notify_parser.add_argument("--icon", default="weather-clear", help="Icon name or path")
    notify_parser.add_argument("--progress", type=int, help="Progress value (0-100)")
    notify_parser.add_argument("--sync-id", help="Synchronous ID for progress bars")
    notify_parser.add_argument("--action", action="append", help="Action in format id:label")

    # Sound command
    sound_parser = subparsers.add_parser("play", help="Play sound")
    sound_parser.add_argument("sound", help="Sound name or file path")

    # Reload command
    subparsers.add_parser("reload", help="Reload system components")

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
            actions=actions
        )
        if response:
            print(response)

    elif args.command == "play":
        play_sound(args.sound)

    elif args.command == "reload":
        reload_components()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        main()
