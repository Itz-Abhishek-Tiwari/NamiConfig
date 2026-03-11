# Waybar Configuration

Modular status bar for Wayland.

## Structure

- `config.jsonc`: Main configuration file (JSON with comments).
- `style.css`: Main stylesheet.
- `colors.css`: Theme-specific color variables (dynamically updated).

## Features

- **Workspaces**: Shows current Hyprland workspaces.
- **Clock**: Display with calendar on click.
- **Battery/CPU/Memory**: System resource monitoring.
- **Network/Bluetooth**: Connectivity status.
- **Volume/Brightness**: Sliders and status.
- **Tray**: System tray icons.

## Theming

The bar uses `colors.css` for its color palette. This file is updated by the `theme-switch` script when toggling between dark and light modes.
