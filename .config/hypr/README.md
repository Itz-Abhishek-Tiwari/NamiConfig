# Hyprland Configuration

This directory contains the configuration for [Hyprland](https://hyprland.org/), a dynamic tiling Wayland compositor.

## Structure

- `hyprland.conf`: Main configuration file.
- `hypridle.conf`: Idle management configuration.
- `hyprlock.conf`: Screen locker configuration.
- `hyprpaper.conf`: Wallpaper utility configuration.
- `configs/`: Modular configuration files for specific settings.
    - `keybinds.conf`: Keyboard shortcuts.
    - `theme.conf`: Theme-specific color variables (dynamically updated).

## Key Bindings

Common key bindings (see `configs/keybinds.conf` for the full list):

| Key | Action |
|---|---|
| `SUPER + T` | Open terminal (Ghostty) |
| `SUPER + SPACE` | App launcher (Fuzzel) |
| `SUPER + Q` | Close window |
| `SUPER + M` | Fullscreen |
| `SUPER + L` | Lock screen |
| `SUPER + N` | Notification center |
| `SUPER + SHIFT + T` | Toggle Dark/Light theme |

## Theming

The theme is handled dynamically by the `theme-switch` script. It updates `configs/theme.conf` with the appropriate colors from the Gruvbox palette.
