#!/usr/bin/env python3

import json
import os
import sys
import subprocess
import argparse
import fcntl
from pathlib import Path

# ====================== Constants ====================== #
CONFIG_DIR = Path(os.getenv("XDG_CONFIG_HOME", Path.home() / ".config"))
NAMICONFIG_DIR = Path.home() / "NamiConfig"
THEMES_DIR = CONFIG_DIR / "NamiThemes"
STATE_FILE = CONFIG_DIR / ".theme_state.json"
LOCK_FILE = Path("/tmp/namitheme_toggle.lock")

# App-specific paths
GTK3_PATH = CONFIG_DIR / "gtk-3.0/settings.ini"
GTK4_PATH = CONFIG_DIR / "gtk-4.0/settings.ini"
GTK3_CSS = CONFIG_DIR / "gtk-3.0/gtk.css"
GTK4_CSS = CONFIG_DIR / "gtk-4.0/gtk.css"
HYPR_COLORS_CONF = CONFIG_DIR / "hypr/themes/colors.conf"
ZED_SETTINGS_PATH = CONFIG_DIR / "zed/settings.json"

GTK_COMMON_SETTINGS = {
    "gtk-font-name": "Adwaita Sans 11",
    "gtk-cursor-theme-name": "Bibata-Modern-Ice",
    "gtk-cursor-theme-size": "24",
    "gtk-toolbar-style": "GTK_TOOLBAR_ICONS",
    "gtk-enable-event-sounds": "1",
    "gtk-xft-antialias": "1",
    "gtk-xft-hinting": "1",
    "gtk-xft-hintstyle": "hintslight",
}

# ====================== Helpers ====================== #

def get_state():
    if STATE_FILE.exists():
        try:
            return json.loads(STATE_FILE.read_text())
        except Exception:
            pass
    return {"theme": "catppuccin", "mode": "dark"}

def save_state(theme, mode):
    STATE_FILE.write_text(json.dumps({"theme": theme, "mode": mode}, indent=2))

def get_theme_path(theme_name, app_name, variant):
    base = THEMES_DIR / theme_name / app_name / "themes"
    for ext in ["", ".conf", ".css", ".rasi"]:
        p = base / f"theme-{variant}{ext}"
        if p.exists():
            return p
    return None

def symlink_theme(app, target_path, theme_family, mode):
    src = get_theme_path(theme_family, app, mode)
    if not src or not src.exists():
        return
    target_path.parent.mkdir(parents=True, exist_ok=True)
    if target_path.exists() or target_path.is_symlink():
        target_path.unlink()
    target_path.symlink_to(src)

# ====================== Core Actions ====================== #

def set_gtk_theme(theme_mode, theme_family):
    theme_name = f"Colloid-{theme_mode.capitalize()}-{theme_family}"
    icon_theme = "Papirus-Light" if theme_mode == "light" else "Papirus-Dark"
    prefer_dark = theme_mode == "dark"

    subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", theme_name])
    subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", icon_theme])
    subprocess.run(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", 
                    "prefer-dark" if prefer_dark else "prefer-light"])

    lines = ["[Settings]", f"gtk-theme-name={theme_name}", f"gtk-icon-theme-name={icon_theme}",
             f"gtk-application-prefer-dark-theme={int(prefer_dark)}"]
    lines.extend(f"{k}={v}" for k, v in GTK_COMMON_SETTINGS.items())
    ini = "\n".join(lines)

    for p in [GTK3_PATH, GTK4_PATH]:
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(ini)

def get_current_wallpaper():
    """Get the currently displayed wallpaper from swww"""
    try:
        res = subprocess.run(["swww", "query"], capture_output=True, text=True)
        if res.returncode == 0:
            # Format is typically: 'monitor: image_path'
            line = res.stdout.splitlines()[0]
            if ": " in line:
                return Path(line.split(": ")[-1].strip())
    except Exception:
        pass
    return None

def switch_wallpapers(family, mode, force=False):
    if not force:
        # If not forcing, we only regenerate colors for NamiPywal using current wallpaper
        if family.lower() == "namipywal":
            wallpaper = get_current_wallpaper()
            if wallpaper and wallpaper.exists():
                gen_script = CONFIG_DIR / "scripts/generate_colors.py"
                if gen_script.exists():
                    subprocess.run([sys.executable, str(gen_script), str(wallpaper), "--mode", mode],
                                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return

    wall_dir = THEMES_DIR / family / "wallpapers"
    wallpaper = wall_dir / f"{mode}.png"
    if not wallpaper.exists():
        wallpaper = wall_dir / f"{mode}.jpg"
    
    if not wallpaper.exists():
        fallback_dir = CONFIG_DIR / "hypr/wall"
        defaults = {"dark": "2.jpg", "light": "1.png"}
        wallpaper = fallback_dir / defaults[mode]

    if wallpaper.exists():
        subprocess.run(["swww", "img", str(wallpaper), "--transition-type", "wipe", "--transition-fps", "60"], 
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
        # Trigger dynamic color generation if theme is NamiPywal
        if family.lower() == "namipywal":
            gen_script = CONFIG_DIR / "scripts/generate_colors.py"
            if gen_script.exists():
                subprocess.run([sys.executable, str(gen_script), str(wallpaper), "--mode", mode],
                               stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def reload_system():
    # Reload components in a unified way
    try:
        subprocess.run(["pkill", "-SIGUSR1", "kitty"], stderr=subprocess.DEVNULL)
        subprocess.run(["pkill", "-SIGUSR1", "ghostty"], stderr=subprocess.DEVNULL)
        subprocess.run(["pkill", "-SIGUSR2", "waybar"], stderr=subprocess.DEVNULL)
        subprocess.run(["swaync-client", "-rs"], stderr=subprocess.DEVNULL)
        subprocess.run(["hyprctl", "reload"], stderr=subprocess.DEVNULL)
    except Exception:
        pass

def main():
    parser = argparse.ArgumentParser(description="Unified NamiConfig Theme Orchestrator")
    parser.add_argument("--theme", help="Theme family to apply")
    parser.add_argument("--mode", choices=["light", "dark", "toggle"], default="toggle", help="Light or Dark mode")
    args = parser.parse_args()

    # File locking to prevent process explosion
    lock_file = open(LOCK_FILE, "w")
    try:
        fcntl.flock(lock_file, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except IOError:
        print("❌ Another instance is already running. Exiting.")
        sys.exit(1)

    state = get_state()
    theme = args.theme if args.theme else state["theme"]
    if args.mode == "toggle":
        mode = "light" if state["mode"] == "dark" else "dark"
    else:
        mode = args.mode

    print(f"🌊 Unifying system state: {theme} ({mode})")

    # 1. Update Symlinks for Apps
    apps = {
        "kitty": CONFIG_DIR / "kitty/theme.conf",
        "waybar": CONFIG_DIR / "waybar/style.css",
        "mako": CONFIG_DIR / "mako/config",
        "rofi": CONFIG_DIR / "rofi/colors/theme.rasi",
        "swaync": CONFIG_DIR / "swaync/style.css",
        "ghostty": CONFIG_DIR / "ghostty/themes/theme",
    }
    for app, path in apps.items():
        if app == "rofi" and theme.lower() == "namipywal":
            # Direct link to generated colors for NamiPywal
            src = CONFIG_DIR / "rofi/colors/namipywal.rasi"
            if src.exists():
                path.parent.mkdir(parents=True, exist_ok=True)
                if path.exists() or path.is_symlink():
                    path.unlink()
                path.symlink_to(src)
        else:
            symlink_theme(app, path, theme, mode)

    # 2. Update GTK & Wallpapers
    gtk_map = {"rosepine": "catppuccin", "namipywal": "catppuccin"}
    gtk_family = gtk_map.get(theme.lower(), theme)
    set_gtk_theme(mode, gtk_family)
    
    # Only force wallpaper change if theme family is explicitly changed via argument
    force_wallpaper = args.theme is not None
    switch_wallpapers(theme, mode, force=force_wallpaper)

    # 3. Reload Everything
    reload_system()
    save_state(theme, mode)
    
    subprocess.run(["notify-send", "-a", "NamiTheme", "-i", "weather-clear", 
                    f"Unified Theme: {theme} ({mode.capitalize()})"])

if __name__ == "__main__":
    main()
