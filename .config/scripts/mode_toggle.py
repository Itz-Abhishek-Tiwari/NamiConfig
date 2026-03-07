#!/usr/bin/env python3

import json
import os
import subprocess
import argparse
from pathlib import Path

# ====================== Constants ====================== #
CONFIG_DIR = Path.home() / ".config"
THEMES_DIR = CONFIG_DIR / "NamiThemes"
STATE_FILE = CONFIG_DIR / ".theme_state.json"
WINDOWRULES_PATH = CONFIG_DIR / "hypr/windowrules.conf"
BLUR_RULE = "layerrule = blur,waybar"
ZED_SETTINGS_PATH = CONFIG_DIR / "zed/settings.json"
GTK_ENV_CONF = CONFIG_DIR / "hypr/themes/gtkTheme.conf"

# ====================== GTK Configuration ====================== #
GTK3_PATH = CONFIG_DIR / "gtk-3.0/settings.ini"
GTK4_PATH = CONFIG_DIR / "gtk-4.0/settings.ini"

GTK_COMMON_SETTINGS = {
    "gtk-font-name": "Adwaita Sans 11",
    "gtk-cursor-theme-name": "Bibata-Modern-Ice",
    "gtk-cursor-theme-size": "24",
    "gtk-toolbar-style": "GTK_TOOLBAR_ICONS",
    "gtk-toolbar-icon-size": "GTK_ICON_SIZE_LARGE_TOOLBAR",
    "gtk-button-images": "0",
    "gtk-menu-images": "0",
    "gtk-enable-event-sounds": "1",
    "gtk-enable-input-feedback-sounds": "0",
    "gtk-xft-antialias": "1",
    "gtk-xft-hinting": "1",
    "gtk-xft-hintstyle": "hintslight",
    "gtk-xft-rgba": "rgb",
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
    STATE_FILE.write_text(json.dumps({"theme": theme, "mode": mode}))

def get_theme_path(theme_name, app_name, variant):
    """Dynamically resolve theme path: NamiThemes/{ThemeName}/{App}/themes/theme-{variant}"""
    # Try different common extensions
    base = THEMES_DIR / theme_name / app_name / "themes"
    for ext in ["", ".conf", ".css", ".rasi"]:
        p = base / f"theme-{variant}{ext}"
        if p.exists():
            return p
    return None

def set_gtk_env(theme_mode, theme_family):
    """Set GTK_THEME environment variable dynamically"""
    # Assuming theme naming convention: Colloid-{Mode}-{Family}
    theme_name = f"Colloid-{theme_mode.capitalize()}-{theme_family}"
    subprocess.run(["hyprctl", "setenv", "GTK_THEME", theme_name], 
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def update_gtk_env_conf(theme_mode, theme_family):
    theme_name = f"Colloid-{theme_mode.capitalize()}-{theme_family}"
    line = f"env = GTK_THEME,{theme_name}\n"
    GTK_ENV_CONF.parent.mkdir(parents=True, exist_ok=True)
    if GTK_ENV_CONF.exists():
        lines = GTK_ENV_CONF.read_text().splitlines()
        lines = [l for l in lines if not l.strip().startswith("env = GTK_THEME")]
        lines.append(line.strip())
        GTK_ENV_CONF.write_text("\n".join(lines) + "\n")
    else:
        GTK_ENV_CONF.write_text(line)
    subprocess.run(["hyprctl", "reload"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

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

def symlink_theme(app, target_path, theme_family, mode):
    src = get_theme_path(theme_family, app, mode)
    if not src or not src.exists():
        return
    target_path.parent.mkdir(parents=True, exist_ok=True)
    if target_path.exists() or target_path.is_symlink():
        target_path.unlink()
    target_path.symlink_to(src)

# ====================== App Switchers ====================== #

def switch_apps(theme_family, mode):
    apps = {
        "kitty": CONFIG_DIR / "kitty/theme.conf",
        "waybar": CONFIG_DIR / "waybar/style.css",
        "mako": CONFIG_DIR / "mako/config",
        "rofi": CONFIG_DIR / "rofi/colors/theme.rasi",
        "swaync": CONFIG_DIR / "swaync/style.css",
        "ghostty": CONFIG_DIR / "ghostty/themes/theme",
    }
    
    for app, path in apps.items():
        symlink_theme(app, path, theme_family, mode)
    
    # Reload/Signalling
    subprocess.run(["pkill", "-SIGUSR1", "kitty"])
    subprocess.run(["pkill", "waybar"])
    subprocess.Popen(["waybar"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    subprocess.run(["pkill", "-SIGUSR2", "mako"])
    subprocess.run(["swaync-client", "-rs"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    subprocess.run(["pkill", "-SIGUSR1", "ghostty"])

def switch_editors(theme_family, mode):
    # VSCode
    vscode_path = CONFIG_DIR / "Code/User/settings.json"
    if vscode_path.exists():
        data = json.loads(vscode_path.read_text())
        variant = "Latte" if mode == "light" else "Mocha"
        data["workbench.colorTheme"] = f"{theme_family.capitalize()} {variant}"
        vscode_path.write_text(json.dumps(data, indent=2))
    
    # Zed
    if ZED_SETTINGS_PATH.exists():
        data = json.loads(ZED_SETTINGS_PATH.read_text())
        data.setdefault("theme", {})
        data["theme"]["mode"] = mode
        data["theme"]["light"] = f"{theme_family.lower()}_light"
        data["theme"]["dark"] = f"{theme_family.lower()}_dark"
        ZED_SETTINGS_PATH.write_text(json.dumps(data, indent=2))

def switch_spicetify(theme_family, mode):
    scheme = f"colloid-{mode}-{theme_family.lower()}"
    subprocess.run(["spicetify", "config", "color_scheme", scheme], stdout=subprocess.DEVNULL)
    subprocess.run(["spicetify", "apply"], stdout=subprocess.DEVNULL)

def notify(theme_family, mode):
    icon_mode = "Light" if mode == "light" else "Dark"
    subprocess.run(["notify-send", "-a", "NamiTheme", "-i", "weather-clear", 
                    f"Theme Applied: {theme_family} ({icon_mode})"])

# ====================== Main ====================== #

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="NamiConfig Theme Toggler")
    parser.add_argument("--theme", help="Theme family to apply (e.g. catppuccin, gruvBox)")
    parser.add_argument("--mode", choices=["light", "dark", "toggle"], default="toggle", help="Light or Dark mode")
    args = parser.parse_args()

    state = get_state()
    theme = args.theme if args.theme else state["theme"]
    
    if args.mode == "toggle":
        mode = "light" if state["mode"] == "dark" else "dark"
    else:
        mode = args.mode

    print(f"Applying {theme} in {mode} mode...")

    set_gtk_env(mode, theme)
    update_gtk_env_conf(mode, theme)
    set_gtk_theme(mode, theme)
    switch_apps(theme, mode)
    switch_editors(theme, mode)
    switch_spicetify(theme, mode)
    notify(theme, mode)
    
    save_state(theme, mode)
