#!/usr/bin/env python3

import subprocess
import json
from pathlib import Path

# ====================== Theme Constants ====================== #
DARK = "Colloid-Dark-Catppuccin"
LIGHT = "Colloid-Light-Catppuccin"

CONFIG_DIR = Path.home() / ".config"
STATE_FILE = CONFIG_DIR / ".current_theme"
WINDOWRULES_PATH = CONFIG_DIR / "hypr/windowrules.conf"
BLUR_RULE = "layerrule = blur,waybar"

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
        "light": CONFIG_DIR / "NamiThemes/catppuccin/kitty/themes/theme-light.conf",
        "dark": CONFIG_DIR / "NamiThemes/catppuccin/kitty/themes/theme-dark.conf",
    },
    "waybar": {
        "target": CONFIG_DIR / "waybar/style.css",
        "light": CONFIG_DIR / "NamiThemes/catppuccin/waybar/themes/theme-light.css",
        "dark": CONFIG_DIR / "NamiThemes/catppuccin/waybar/themes/theme-dark.css",
    },
    "mako": {
        "target": CONFIG_DIR / "mako/config",
        "light": CONFIG_DIR / "NamiThemes/catppuccin/mako/themes/theme-light",
        "dark": CONFIG_DIR / "NamiThemes/catppuccin/mako/themes/theme-dark",
    },
    "rofi": {
        "target": CONFIG_DIR / "rofi/colors/catppuccin.rasi",
        "light": CONFIG_DIR / "NamiThemes/catppuccin/rofi/themes/theme-light.rasi",
        "dark": CONFIG_DIR / "NamiThemes/catppuccin/rofi/themes/theme-dark.rasi",
    },
    "swaync": {
        "target": CONFIG_DIR / "swaync/style.css",
        "light": CONFIG_DIR / "NamiThemes/catppuccin/swaync/themes/theme-light.css",
        "dark": CONFIG_DIR / "NamiThemes/catppuccin/swaync/themes/theme-dark.css",
    },
    "ghostty": {
        "target": CONFIG_DIR / "ghostty/themes/theme",
        "light": CONFIG_DIR / "NamiThemes/catppuccin/ghostty/themes/theme-light",
        "dark": CONFIG_DIR / "NamiThemes/catppuccin/ghostty/themes/theme-dark",
    },
}

# ====================== Notification Icons ====================== #
icon_light = "/usr/share/icons/Papirus-Dark/48x48/status/weather-clear.svg"
icon_dark = "/usr/share/icons/Papirus-Dark/48x48/status/weather-clear-night.svg"


# ====================== Helper Functions ====================== #
def get_current_theme():
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
    if theme == "light":
        theme_name = LIGHT
        icon_theme = "Papirus-Light"
        prefer_dark = False
    else:
        theme_name = DARK
        icon_theme = "Papirus-Dark"
        prefer_dark = True

    subprocess.run(
        ["gsettings", "set", "org.gnome.desktop.interface", "gtk-theme", theme_name]
    )
    subprocess.run(
        ["gsettings", "set", "org.gnome.desktop.interface", "icon-theme", icon_theme]
    )
    subprocess.run(
        [
            "gsettings",
            "set",
            "org.gnome.desktop.interface",
            "color-scheme",
            "prefer-dark" if prefer_dark else "prefer-light",
        ]
    )

    def build_ini():
        lines = ["[Settings]"]
        lines.append(f"gtk-theme-name={theme_name}")
        lines.append(f"gtk-icon-theme-name={icon_theme}")
        lines.append(f"gtk-application-prefer-dark-theme={int(prefer_dark)}")
        lines.extend(f"{k}={v}" for k, v in GTK_COMMON_SETTINGS.items())
        return "\n".join(lines)

    ini_content = build_ini()
    GTK3_PATH.parent.mkdir(parents=True, exist_ok=True)
    GTK4_PATH.parent.mkdir(parents=True, exist_ok=True)
    GTK3_PATH.write_text(ini_content)
    GTK4_PATH.write_text(ini_content)


def symlink_theme_file(app, theme):
    source = theme_paths[app][theme]
    target = theme_paths[app]["target"]
    if not source.exists():
        return

    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists() or target.is_symlink():
        target.unlink()
    target.symlink_to(source)


def switch_kitty(theme):
    symlink_theme_file("kitty", theme)
    subprocess.run("kill -10 $(pgrep kitty)", shell=True)


def switch_ghostty(theme):
    symlink_theme_file("ghostty", theme)
    subprocess.run("kill -10 $(pgrep ghostty)", shell=True)


def switch_waybar(theme):
    symlink_theme_file("waybar", theme)
    subprocess.run(["pkill", "waybar"])
    subprocess.Popen(["waybar"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def switch_mako(theme):
    symlink_theme_file("mako", theme)
    subprocess.run(["pkill", "-SIGUSR2", "mako"])


def switch_rofi(theme):
    symlink_theme_file("rofi", theme)


def switch_swaync(theme):
    symlink_theme_file("swaync", theme)
    subprocess.run(["pkill", "-SIGUSR2", "swaync"])


def reload_nemo():
    if (
        subprocess.run(["pgrep", "-x", "nemo"], stdout=subprocess.DEVNULL).returncode
        == 0
    ):
        subprocess.run(["nemo", "--quit"])
        subprocess.Popen(["nemo"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def switch_vscode_theme(theme):
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
    icon = icon_light if theme == "light" else icon_dark
    subprocess.run(
        ["notify-send", "-i", icon, f"Switched to {theme.capitalize()} Theme"]
    )


def switch_spicetify(theme):
    color_scheme = "latte" if theme == "light" else "mocha"
    subprocess.run(["spicetify", "config", "current_theme", "catppuccin"])
    subprocess.run(["spicetify", "config", "color_scheme", color_scheme])
    subprocess.run(
        [
            "spicetify",
            "config",
            "inject_css",
            "1",
            "inject_theme_js",
            "1",
            "replace_colors",
            "1",
            "overwrite_assets",
            "1",
        ]
    )
    subprocess.run(["spicetify", "apply"])


def update_windowrules_for_blur(theme):
    if not WINDOWRULES_PATH.exists():
        return
    lines = WINDOWRULES_PATH.read_text().splitlines()

    if theme == "dark":
        if BLUR_RULE not in lines:
            lines.append(BLUR_RULE)
    else:
        lines = [line for line in lines if line.strip() != BLUR_RULE]

    WINDOWRULES_PATH.write_text("\n".join(lines) + "\n")


# ====================== Main ====================== #
def toggle_theme():
    current = get_current_theme()
    new_theme = "light" if current == "dark" else "dark"

    set_gtk_theme(new_theme)
    switch_kitty(new_theme)
    switch_waybar(new_theme)
    switch_mako(new_theme)
    switch_rofi(new_theme)
    switch_swaync(new_theme)
    switch_vscode_theme(new_theme)
    # switch_ghostty(new_theme)
    switch_spicetify(new_theme)
    update_windowrules_for_blur(new_theme)
    reload_nemo()
    notify(new_theme)

    print(f"Switched to {new_theme.capitalize()} Theme")


if __name__ == "__main__":
    toggle_theme()
