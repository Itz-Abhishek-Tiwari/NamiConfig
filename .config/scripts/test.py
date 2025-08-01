#!/usr/bin/env python3

import subprocess
from pathlib import Path

CONFIG_DIR = Path.home() / ".config"
THEMES_DIR = CONFIG_DIR / "NamiThemes/all-themes"

theme_paths = {
    "kitty": {
        "target": CONFIG_DIR / "kitty/theme.conf",
        "subdir": "themes",
        "ext": ".conf",
    },
    "waybar": {
        "target": CONFIG_DIR / "waybar/style.css",
        "subdir": "themes",
        "ext": ".css",
    },
    "mako": {
        "target": CONFIG_DIR / "mako/config",
        "subdir": "themes",
        "ext": "",
    },
    "rofi": {
        "target": CONFIG_DIR / "rofi/colors/catppuccin.rasi",
        "subdir": "themes",
        "ext": ".rasi",
    },
    "swaync": {
        "target": CONFIG_DIR / "swaync/style.css",
        "subdir": "themes",
        "ext": ".css",
    },
}


def choose_theme_with_fzf():
    result = subprocess.run(
        ["fzf", "--prompt=Choose Theme: "],
        input="light\ndark",
        text=True,
        stdout=subprocess.PIPE,
    )
    selected = result.stdout.strip()
    if selected not in ("light", "dark"):
        print("No valid theme selected.")
        exit(1)
    return selected


def symlink_theme_file(app, theme_variant):
    app_info = theme_paths[app]
    subdir = app_info["subdir"]
    ext = app_info["ext"]

    filename = f"theme-{theme_variant}{ext}"
    source = THEMES_DIR / app / subdir / filename
    target = app_info["target"]

    if not source.exists():
        print(f"[!] Theme not found for {app}: {source}")
        return

    target.parent.mkdir(parents=True, exist_ok=True)
    if target.exists() or target.is_symlink():
        target.unlink()
    target.symlink_to(source)


def reload_apps():
    subprocess.run(["pkill", "waybar"])
    subprocess.run(["pkill", "-SIGUSR2", "mako"])
    subprocess.run(["pkill", "-SIGUSR2", "swaync"])
    subprocess.run(["killall", "-SIGUSR1", "kitty"], stderr=subprocess.DEVNULL)
    subprocess.run(["notify-send", "Theme switched"])


def apply_theme(theme_variant):
    for app in theme_paths:
        symlink_theme_file(app, theme_variant)
    reload_apps()
    print(f"[+] Applied '{theme_variant}' theme to all apps.")


if __name__ == "__main__":
    selected = choose_theme_with_fzf()
    apply_theme(selected)
