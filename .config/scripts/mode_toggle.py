#!/usr/bin/env python3

import json
import sys
import argparse
import fcntl
from pathlib import Path
import nami_core as core
import generate_colors

# ====================== Constants ====================== #
LOCK_FILE = Path("/tmp/namitheme_toggle.lock")

# App-specific paths
GTK3_PATH = core.CONFIG_DIR / "gtk-3.0/settings.ini"
GTK4_PATH = core.CONFIG_DIR / "gtk-4.0/settings.ini"

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
    if core.STATE_FILE.exists():
        try:
            return json.loads(core.STATE_FILE.read_text())
        except Exception:
            pass
    return {"theme": "catppuccin", "mode": "dark"}

def save_state(theme, mode):
    core.STATE_FILE.write_text(json.dumps({"theme": theme, "mode": mode}, indent=2))

def get_theme_path(theme_name, app_name, variant):
    base = core.THEMES_DIR / theme_name / app_name / "themes"
    for ext in ["", ".conf", ".css", ".rasi"]:
        p = base / f"theme-{variant}{ext}"
        if p.exists():
            return p
    return None

def symlink_theme(app, target_path, theme_family, mode):
    src = get_theme_path(theme_family, app, mode)
    if not src or not src.exists():
        return
    core.ensure_dir(target_path)
    if target_path.exists() or target_path.is_symlink():
        target_path.unlink()
    target_path.symlink_to(src)

# ====================== Core Actions ====================== #

def set_gtk_theme(theme_mode, theme_family):
    theme_name = f"Colloid-{theme_mode.capitalize()}-{theme_family}"
    icon_theme = "Papirus-Light" if theme_mode == "light" else "Papirus-Dark"
    prefer_dark = theme_mode == "dark"

    core.run_command(["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", theme_name], check=False)
    core.run_command(["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", icon_theme], check=False)
    core.run_command(["gsettings", "set", "org.gnome.desktop.interface", "color-scheme", 
                    "prefer-dark" if prefer_dark else "prefer-light"], check=False)

    lines = ["[Settings]", f"gtk-theme-name={theme_name}", f"gtk-icon-theme-name={icon_theme}",
             f"gtk-application-prefer-dark-theme={int(prefer_dark)}"]
    lines.extend(f"{k}={v}" for k, v in GTK_COMMON_SETTINGS.items())
    ini = "\n".join(lines)

    for p in [GTK3_PATH, GTK4_PATH]:
        core.ensure_dir(p)
        p.write_text(ini)


def switch_wallpapers(family, mode, force=False):
    if not force:
        # If not forcing, we only regenerate colors for NamiPywal using current wallpaper
        if family.lower() == "namipywal":
            wallpaper = core.get_current_wallpaper()
            if wallpaper and wallpaper.exists():
                generate_colors.generate_all(wallpaper, mode)
        return

    wall_dir = core.THEMES_DIR / family / "wallpapers"
    wallpaper = wall_dir / f"{mode}.png"
    if not wallpaper.exists():
        wallpaper = wall_dir / f"{mode}.jpg"
    
    if not wallpaper.exists():
        fallback_dir = core.CONFIG_DIR / "hypr/wall"
        defaults = {"dark": "2.jpg", "light": "1.png"}
        wallpaper = fallback_dir / defaults[mode]

    if wallpaper.exists():
        core.run_command(["swww", "img", str(wallpaper), "--transition-type", "wipe", "--transition-fps", "60"], check=False)
        
        # Trigger dynamic color generation if theme is NamiPywal
        if family.lower() == "namipywal":
            generate_colors.generate_all(wallpaper, mode)

def set_zed_theme(theme_family, mode):
    if not core.ZED_SETTINGS.exists():
        return
        
    try:
        settings = json.loads(core.ZED_SETTINGS.read_text())
        
        # Mapping system themes to Zed theme names
        # namipywal uses the ones we generate in generate_colors.py
        mapping = {
            "namipywal": {"dark": "namipywal_dark", "light": "namipywal_light"},
            "rosepine": {"dark": "rosePine_dark", "light": "rosePine_light"},
            "catppuccin": {"dark": "Catppuccin Mocha", "light": "catppuccin_light"},
            "gruvbox": {"dark": "Gruvbox Dark", "light": "Gruvbox Light"}
        }
        
        theme_info = mapping.get(theme_family.lower(), mapping["namipywal"])
        
        settings["theme"] = {
            "mode": mode,
            "dark": theme_info["dark"],
            "light": theme_info["light"]
        }
        
        core.ZED_SETTINGS.write_text(json.dumps(settings, indent=2))
    except Exception as e:
        print(f"❌ Failed to update Zed theme: {e}")

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
        "kitty": core.CONFIG_DIR / "kitty/theme.conf",
        "waybar": core.CONFIG_DIR / "waybar/style.css",
        "mako": core.CONFIG_DIR / "mako/config",
        "rofi": core.ROFI_THEME_COLORS,
        "swaync": core.CONFIG_DIR / "swaync/style.css",
        "ghostty": core.CONFIG_DIR / "ghostty/themes/theme",
    }
    for app, path in apps.items():
        if app == "rofi" and theme.lower() == "namipywal":
            # Direct link to generated colors for NamiPywal
            src = core.ROFI_PYWAL_COLORS
            if src.exists():
                core.ensure_dir(path)
                if path.exists() or path.is_symlink():
                    path.unlink()
                path.symlink_to(src)
        else:
            symlink_theme(app, path, theme, mode)

    # 2. Update GTK & Wallpapers
    gtk_map = {"rosepine": "catppuccin", "namipywal": "catppuccin"}
    gtk_family = gtk_map.get(theme.lower(), theme)
    set_gtk_theme(mode, gtk_family)
    
    # 3. Update Zed Theme
    set_zed_theme(theme, mode)

    # 4. Switch wallpaper (forced only when theme family is explicitly changed)
    force_wallpaper = args.theme is not None
    switch_wallpapers(theme, mode, force=force_wallpaper)

    # 5. Reload Everything
    core.reload_components()
    save_state(theme, mode)
    
    core.notify(f"Unified Theme: {theme} ({mode.capitalize()})", title="NamiTheme")

if __name__ == "__main__":
    main()
