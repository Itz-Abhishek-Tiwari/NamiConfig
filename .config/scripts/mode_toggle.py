#!/usr/bin/env python3

import json
import subprocess
from pathlib import Path

# ====================== Theme Constants ====================== #
DARK = "Colloid-Dark-catppuccin"
LIGHT = "Colloid-Light-catppuccin"

CONFIG_DIR = Path.home() / ".config"
STATE_FILE = CONFIG_DIR / ".current_theme"
WINDOWRULES_PATH = CONFIG_DIR / "hypr/windowrules.conf"
BLUR_RULE = "layerrule = blur,waybar"
ZED_SETTINGS_PATH = CONFIG_DIR / "zed/settings.json"

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
        "target": CONFIG_DIR / "rofi/colors/theme.rasi",
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
icon_light = "/usr/share/icons/Papirus-Light/48x48/status/weather-clear.svg"
icon_dark = "/usr/share/icons/Papirus-Dark/48x48/status/weather-clear-night.svg"


# ====================== Helpers ====================== #
def get_current_theme():
    try:
        out = subprocess.check_output(
            ["gsettings", "get", "org.gnome.desktop.interface", "gtk-theme"],
            text=True,
        ).strip().strip("'")
        return "light" if out == LIGHT else "dark"
    except Exception:
        return "dark"


def set_gtk_env(theme):
    theme_name = LIGHT if theme == "light" else DARK
    subprocess.run(
        ["hyprctl", "setenv", "GTK_THEME", theme_name],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def set_gtk_theme(theme):
    theme_name = LIGHT if theme == "light" else DARK
    icon_theme = "Papirus-Light" if theme == "light" else "Papirus-Dark"
    prefer_dark = theme == "dark"

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

    lines = ["[Settings]"]
    lines.append(f"gtk-theme-name={theme_name}")
    lines.append(f"gtk-icon-theme-name={icon_theme}")
    lines.append(f"gtk-application-prefer-dark-theme={int(prefer_dark)}")
    lines.extend(f"{k}={v}" for k, v in GTK_COMMON_SETTINGS.items())
    ini = "\n".join(lines)

    GTK3_PATH.parent.mkdir(parents=True, exist_ok=True)
    GTK4_PATH.parent.mkdir(parents=True, exist_ok=True)
    GTK3_PATH.write_text(ini)
    GTK4_PATH.write_text(ini)


def symlink_theme_file(app, theme):
    src = theme_paths[app][theme]
    dst = theme_paths[app]["target"]
    if not src.exists():
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists() or dst.is_symlink():
        dst.unlink()
    dst.symlink_to(src)


def switch_kitty(theme):
    symlink_theme_file("kitty", theme)
    subprocess.run("pkill -SIGUSR1 kitty", shell=True)


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


def switch_ghostty(theme):
    symlink_theme_file("ghostty", theme)
    subprocess.run("pkill -SIGUSR1 ghostty", shell=True)


def switch_vscode_theme(theme):
    path = CONFIG_DIR / "Code/User/settings.json"
    if not path.exists():
        return
    data = json.loads(path.read_text())
    data["workbench.colorTheme"] = (
        "catppuccin Latte" if theme == "light" else "catppuccin Mocha"
    )
    path.write_text(json.dumps(data, indent=2))


def switch_zed_theme(theme):
    if not ZED_SETTINGS_PATH.exists():
        return
    data = json.loads(ZED_SETTINGS_PATH.read_text())
    data.setdefault("theme", {})
    data["theme"]["mode"] = theme
    data["theme"]["light"] = "catppuccin_light"
    data["theme"]["dark"] = "catppuccin_dark"
    ZED_SETTINGS_PATH.write_text(json.dumps(data, indent=2))


def switch_spicetify(theme):
    scheme = "latte" if theme == "light" else "mocha"
    subprocess.run(["spicetify", "config", "current_theme", "catppuccin"])
    subprocess.run(["spicetify", "config", "color_scheme", scheme])
    subprocess.run(["spicetify", "apply"])


def update_windowrules_for_blur(theme):
    if not WINDOWRULES_PATH.exists():
        return
    lines = WINDOWRULES_PATH.read_text().splitlines()
    if theme == "dark" and BLUR_RULE not in lines:
        lines.append(BLUR_RULE)
    if theme == "light":
        lines = [l for l in lines if l.strip() != BLUR_RULE]
    WINDOWRULES_PATH.write_text("\n".join(lines) + "\n")


def reload_nemo():
    if subprocess.run(["pgrep", "-x", "nemo"]).returncode == 0:
        subprocess.run(["nemo", "--quit"])
        subprocess.Popen(["nemo"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def notify(theme):
    subprocess.run(
        [
            "notify-send",
            "-a",
            "Theme Switcher",
            "-u",
            "low",
            "-i",
            icon_light if theme == "light" else icon_dark,
            f"{theme.capitalize()} mode applied",
        ]
    )


# ====================== Main ====================== #
def toggle_theme():
    current = get_current_theme()
    new = "light" if current == "dark" else "dark"

    set_gtk_env(new)
    set_gtk_theme(new)

    switch_kitty(new)
    switch_waybar(new)
    switch_mako(new)
    switch_rofi(new)
    switch_swaync(new)
    switch_ghostty(new)
    switch_vscode_theme(new)
    switch_zed_theme(new)
    switch_spicetify(new)

    update_windowrules_for_blur(new)
    reload_nemo()
    notify(new)

    STATE_FILE.write_text(new)


if __name__ == "__main__":
    toggle_theme()

