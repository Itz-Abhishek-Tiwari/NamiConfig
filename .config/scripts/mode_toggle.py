#!/usr/bin/env python3

import json
import os
import subprocess
import argparse
from pathlib import Path

# ====================== Constants ====================== #
CONFIG_DIR = Path.home() / "NamiConfig" / ".config"
THEMES_DIR = CONFIG_DIR / "NamiThemes"
STATE_FILE = CONFIG_DIR / ".theme_state.json"
WINDOWRULES_PATH = CONFIG_DIR / "hypr/windowrules.conf"
BLUR_RULE = "layerrule = blur,waybar"
ZED_SETTINGS_PATH = CONFIG_DIR / "zed/settings.json"
GTK_ENV_CONF = CONFIG_DIR / "hypr/themes/gtkTheme.conf"
HYPR_COLORS_CONF = CONFIG_DIR / "hypr/themes/colors.conf"

# ====================== GTK Configuration ====================== #
GTK3_PATH = CONFIG_DIR / "gtk-3.0/settings.ini"
GTK4_PATH = CONFIG_DIR / "gtk-4.0/settings.ini"
GTK3_CSS = CONFIG_DIR / "gtk-3.0/gtk.css"
GTK4_CSS = CONFIG_DIR / "gtk-4.0/gtk.css"

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

def set_gtk_theme(theme_mode, theme_family, color_family=None):
    if color_family is None:
        color_family = theme_family
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
    
    set_gtk_colors(theme_mode, color_family)

def set_gtk_colors(mode, family):
    """Inject CSS variables to force GTK colors (helpful for reloading and non-existent themes)"""
    palettes = {
        "rosepine": {
            "dark":  ("#191724", "#e0def4", "#31748f"),
            "light": ("#faf4ed", "#575279", "#286983")
        },
        "catppuccin": {
            "dark":  ("#1e1e2e", "#cdd6f4", "#89b4fa"),
            "light": ("#eff1f5", "#4c4f69", "#1e66f5")
        },
        "gruvbox": {
            "dark":  ("#282828", "#ebdbb2", "#fabd2f"),
            "light": ("#fbf1c7", "#3c3836", "#af3a03")
        },
        "nightfox": {
            "dark":  ("#192330", "#cdcecf", "#719cd6"),
            "light": ("#f2f5f7", "#374756", "#285577")
        },
        "monochrome": {
            "dark":  ("#101010", "#ffffff", "#ffffff"),
            "light": ("#ffffff", "#000000", "#000000")
        }
    }
    
    f_lower = family.lower().replace(" ", "")
    if f_lower not in palettes:
        return

    bg, fg, accent = palettes[f_lower][mode]
    
    css = f"""@define-color window_bg_color alpha({bg}, 1);
@define-color view_fg_color alpha({fg}, 1);
@define-color view_bg_color alpha({bg}, 1);
@define-color sidebar_bg_color alpha({bg}, 1);
@define-color headerbar_bg_color alpha({bg}, 1);
@define-color popover_bg_color alpha({bg}, 1);
@define-color selected_bg_color {accent};
@define-color selected_fg_color {fg if mode == "dark" else bg};
@define-color accent_color {accent};
@define-color accent_bg_color {accent};
@define-color accent_fg_color {fg if mode == "dark" else bg};
"""
    for p in [GTK3_CSS, GTK4_CSS]:
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(css)

def switch_hyprland_borders(family, mode):
    """Update Hyprland border colors in colors.conf"""
    palettes = {
        "rosepine": {
            "dark":  ("eb6f92ff", "f6c177ff"), # Gold / Rose
            "light": ("b4637aff", "ea9d34ff")
        },
        "catppuccin": {
            "dark":  ("cba6f7ee", "89b4faee"), # Mauve / Blue
            "light": ("8839efee", "1e66f5ee")
        },
        "gruvbox": {
            "dark":  ("fabd2fee", "fe8019ee"), # Yellow / Orange
            "light": ("af3a03ee", "d65d0eee")
        },
        "nightfox": {
            "dark":  ("719cd6ee", "81b29aee"), # Blue / Green
            "light": ("285577ee", "4d6d6bee")
        },
        "monochrome": {
            "dark":  ("ffffffff", "ffffffff"),
            "light": ("000000ff", "000000ff")
        }
    }
    
    f_lower = family.lower().replace(" ", "")
    if f_lower not in palettes:
        return
    
    c1, c2 = palettes[f_lower][mode]
    content = f"""# Dynamic Hyprland Colors
general {{
    col.active_border = rgba({c1}) rgba({c2}) 45deg
    col.inactive_border = rgba(585b70aa)
}}

group {{
    col.border_active = rgba({c1}) rgba({c2}) 45deg
    col.border_inactive = rgba(585b70aa)
}}
"""
    HYPR_COLORS_CONF.write_text(content)
    subprocess.run(["hyprctl", "reload"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def switch_wallpapers(family, mode):
    """Switch wallpaper based on theme and mode using swww"""
    wall_dir = THEMES_DIR / family / "wallpapers"
    wallpaper = wall_dir / f"{mode}.png"
    
    # Fallback to jpg or generic wallpaper if png doesn't exist
    if not wallpaper.exists():
        wallpaper = wall_dir / f"{mode}.jpg"
    
    if not wallpaper.exists():
        # Global fallback
        fallback_dir = CONFIG_DIR / "hypr/wall"
        defaults = {"dark": "2.jpg", "light": "1.png"}
        wallpaper = fallback_dir / defaults[mode]

    if wallpaper.exists():
        subprocess.run(["swww", "img", str(wallpaper), "--transition-type", "wipe", "--transition-fps", "60"], 
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

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
        zed_prefixes = {
            "catppuccin": "catppuccin",
            "gruvbox": "gruvBox",
            "nightfox": "nightFox",
            "monochrome": "monoChrome",
            "rosepine": "rosePine"
        }
        prefix = zed_prefixes.get(theme_family.lower(), theme_family.lower())
        
        data = json.loads(ZED_SETTINGS_PATH.read_text())
        data.setdefault("theme", {})
        data["theme"]["mode"] = mode
        data["theme"]["light"] = f"{prefix}_light"
        data["theme"]["dark"] = f"{prefix}_dark"
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

    theme_map = {
        "rosepine": "catppuccin", # Fallback for GTK
    }
    f_lower = theme.lower().replace(" ", "")
    gtk_theme_family = theme_map.get(f_lower, theme)

    set_gtk_env(mode, gtk_theme_family)
    update_gtk_env_conf(mode, gtk_theme_family)
    set_gtk_theme(mode, gtk_theme_family, theme)
    switch_apps(theme, mode)
    switch_editors(theme, mode)
    switch_spicetify(theme, mode)
    switch_hyprland_borders(theme, mode)
    switch_wallpapers(theme, mode)
    notify(theme, mode)
    
    save_state(theme, mode)
