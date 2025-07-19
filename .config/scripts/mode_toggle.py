#!/usr/bin/env python3

import os
import shutil
import subprocess
import json
from pathlib import Path

# ====================== Theme Constants ====================== #
DARK = "Colloid-Dark-Catppuccin"
LIGHT = "Colloid-Light-Catppuccin"

CONFIG_DIR = Path.home() / ".config"
STATE_FILE = CONFIG_DIR / ".current_theme"

# ====================== GTK Configuration ====================== #
GTK3_PATH = CONFIG_DIR / "gtk-3.0/settings.ini"
GTK4_PATH = CONFIG_DIR / "gtk-4.0/settings.ini"
GTK_COMMON_SETTINGS = {
    "gtk-icon-theme-name": "Papirus-Dark",
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

# ====================== App Theme Paths ====================== #
theme_paths = {
    "kitty": {
        "target": CONFIG_DIR / "kitty/theme.conf",
        "light": CONFIG_DIR / "NamiThemes/kitty/themes/theme-light.conf",
        "dark": CONFIG_DIR / "NamiThemes/kitty/themes/theme-dark.conf",
    },
    "waybar": {
        "target": CONFIG_DIR / "waybar/style.css",
        "light": CONFIG_DIR / "NamiThemes/waybar/themes/theme-light.css",
        "dark": CONFIG_DIR / "NamiThemes/waybar/themes/theme-dark.css",
    },
    "mako": {
        "target": CONFIG_DIR / "mako/config",
        "light": CONFIG_DIR / "NamiThemes/mako/themes/theme-light",
        "dark": CONFIG_DIR / "NamiThemes/mako/themes/theme-dark",
    },
    "rofi": {
        "target": CONFIG_DIR / "rofi/colors/catppuccin.rasi",
        "light": CONFIG_DIR / "NamiThemes/rofi/themes/theme-light.rasi",
        "dark": CONFIG_DIR / "NamiThemes/rofi/themes/theme-dark.rasi",
    },
}

# ====================== Notification Icons ====================== #
icon_light = "/usr/share/icons/Papirus-Dark/48x48/status/weather-clear.svg"
icon_dark = "/usr/share/icons/Papirus-Dark/48x48/status/weather-clear-night.svg"


# ====================== Helper Functions ====================== #
def get_current_theme():
    """Detect current GTK theme via gsettings."""
    try:
        result = subprocess.run(
            ["gsettings", "get", "org.gnome.desktop.interface", "gtk-theme"],
            stdout=subprocess.PIPE,
            text=True,
            check=True,
        )
        theme = result.stdout.strip().strip("'")
        return "light" if theme == LIGHT else "dark"
    except subprocess.CalledProcessError:
        return "dark"


def set_gtk_theme(theme):
    """Set GTK 3/4 theme and color scheme."""
    theme_name = LIGHT if theme == "light" else DARK
    prefer_dark = theme == "dark"

    subprocess.run(
        ["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", theme_name]
    )
    subprocess.run(
        [
            "gsettings",
            "set",
            "org.gnome.desktop.interface",
            "color-scheme",
            "prefer-dark" if prefer_dark else "default",
        ]
    )

    def build_ini():
        lines = ["[Settings]"]
        lines.append(f"gtk-theme-name={theme_name}")
        lines.append(f"gtk-application-prefer-dark-theme={int(prefer_dark)}")
        lines.extend(f"{k}={v}" for k, v in GTK_COMMON_SETTINGS.items())
        return "\n".join(lines)

    ini_content = build_ini()
    GTK3_PATH.parent.mkdir(parents=True, exist_ok=True)
    GTK4_PATH.parent.mkdir(parents=True, exist_ok=True)
    GTK3_PATH.write_text(ini_content)
    GTK4_PATH.write_text(ini_content)


def copy_theme_file(app, theme):
    """Copy theme file to target location."""
    source = theme_paths[app][theme]
    target = theme_paths[app]["target"]
    if source.exists():
        shutil.copy(source, target)


def switch_kitty(theme):
    copy_theme_file("kitty", theme)
    subprocess.run("kill -10 $(pgrep kitty)", shell=True)


def switch_waybar(theme):
    copy_theme_file("waybar", theme)
    subprocess.run(["pkill", "waybar"])
    subprocess.Popen(["waybar"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def switch_mako(theme):
    copy_theme_file("mako", theme)
    subprocess.run(["pkill", "-SIGUSR2", "mako"])


def switch_rofi(theme):
    copy_theme_file("rofi", theme)


def reload_nemo():
    """Quit and restart Nemo if it's running."""
    if (
        subprocess.run(["pgrep", "-x", "nemo"], stdout=subprocess.DEVNULL).returncode
        == 0
    ):
        subprocess.run(["nemo", "--quit"])
        subprocess.Popen(["nemo"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def switch_vscode_theme(theme):
    """Update VSCode theme in settings.json."""
    settings_path = CONFIG_DIR / "Code/User/settings.json"
    if not settings_path.exists():
        print(f"VSCode settings not found at {settings_path}")
        return

    try:
        with open(settings_path, "r") as f:
            settings = json.load(f)
    except json.JSONDecodeError:
        print("Error: VSCode settings.json is not valid JSON.")
        return

    settings["workbench.colorTheme"] = (
        "Catppuccin Latte" if theme == "light" else "Catppuccin Mocha"
    )

    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)


def notify(theme):
    """Send desktop notification about theme change."""
    icon = icon_light if theme == "light" else icon_dark
    subprocess.run(
        ["notify-send", "-i", icon, f"Switched to {theme.capitalize()} Theme"]
    )


# ====================== Main ====================== #
def toggle_theme():
    current = get_current_theme()
    new_theme = "light" if current == "dark" else "dark"

    set_gtk_theme(new_theme)
    switch_kitty(new_theme)
    switch_waybar(new_theme)
    switch_mako(new_theme)
    switch_rofi(new_theme)
    switch_vscode_theme(new_theme)
    reload_nemo()
    notify(new_theme)

    print(f"Switched to {new_theme.capitalize()} Theme")


if __name__ == "__main__":
    toggle_theme()
