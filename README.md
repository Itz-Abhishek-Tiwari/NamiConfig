# NamiConfig

Arch Linux · Hyprland · Gruvbox Hard · Performance-first



---

## Overview

A premium, performant, and aesthetically pleasing dotfiles setup focused on the Gruvbox color palette. This configuration is modular, well-documented, and optimized for both productivity and visual excellence using Hyprland and standard Wayland tools.

## Structure

```
dotfiles/
├── [.config/](.config/README.md)
│   ├── [hypr/](.config/hypr/README.md)         # Window manager (Hyprland)
│   ├── [waybar/](.config/waybar/README.md)       # Status bar
│   ├── swww/           # Wallpaper (implicitly used)
│   ├── wallpapers/     # Wallpaper assets
│   ├── [fuzzel/](.config/fuzzel/README.md)       # App launcher
│   ├── [swaync/](.config/swaync/README.md)       # Notifications
│   ├── [ghostty/](.config/ghostty/README.md)      # Terminal
│   ├── [kitty/](.config/kitty/README.md)        # Terminal (fallback/alternative)
│   ├── themes/         # Theme files (gruvbox)
│   ├── fastfetch/      # System info
│   └── [zsh/](.config/zsh/README.md)          # Shell extras
├── [.local/bin/](.local/bin/README.md)       # Scripts (theme-switch, screenshot, volume…)
├── [.themes/](.themes/README.md)          # GTK themes
├── .zshrc              # Main shell config
├── install.sh
└── README.md
```

## Quick Start

```bash
cd ~/dotfiles
bash install.sh
```

This will:
1. Check for missing packages
2. Generate a default Gruvbox wallpaper
3. Make scripts executable
4. Create symlinks in `~/.config` (per category) and `~/.local/bin`
5. Check that `~/.local/bin` is in `$PATH`

## Symlink Layout

`install.sh` links each config category individually:

```
~/.config/hypr    → ~/dotfiles/.config/hypr
~/.config/waybar  → ~/dotfiles/.config/waybar
~/.config/swaync  → ~/dotfiles/.config/swaync
~/.config/fuzzel  → ~/dotfiles/.config/fuzzel
~/.local/bin      → ~/dotfiles/.local/bin (each item)
```

This approach is compatible with a running system where `~/.config` already exists.

> **Note on stow:** `stow .` would conflict with the real `~/.config` directory. The install script handles this by symlinking each subcategory directly.

## Theme System

```bash
theme-switch          # toggle dark/light (includes random wallpaper)
theme-switch dark     # force dark
theme-switch light    # force light
wallpaper-cycle       # rotate through current theme wallpapers
gsync                 # sync dotfiles to git
```

Theme files live in `.config/themes/gruvbox/`:

| File | Purpose |
|---|---|
| `dark.conf` | Hyprland `$color` vars (dark) |
| `light.conf` | Hyprland `$color` vars (light) |
| `dark.css` | CSS custom properties (dark) |
| `light.css` | CSS custom properties (light) |

Active theme → `wm/hypr/configs/theme.conf` + `wm/waybar/colors.css`

## Key Bindings

| Key | Action |
|---|---|
| `SUPER + T` | Open terminal (ghostty) |
| `SUPER + SPACE` | Open launcher (fuzzel) |
| `SUPER + Q` | Close window |
| `SUPER + W` | Toggle float |
| `SUPER + M` | Fullscreen |
| `SUPER + L` | Lock screen |
| `SUPER + N` | Notifications |
| `SUPER + SHIFT + T` | Toggle dark/light theme |
| `SUPER + ALT + W` | Cycle current theme wallpapers |
| `SUPER + SHIFT + P` | Power menu |
| `SUPER + 1-0` | Switch workspace |
| `SUPER + SHIFT + 1-0` | Move window to workspace |
| `SUPER + H/J/K/L` | Focus window (hjkl) |
| `Print` | Screenshot to clipboard |
| `SUPER + Print` | Region screenshot |

## Ecosystem

| Tool | Purpose |
|---|---|
| Hyprland | Wayland compositor |
| Waybar | Status bar (vertical left) |
| fuzzel | App launcher |
| swaync | Notifications |
| hyprpaper | Wallpaper |
| hyprlock | Lock screen |
| hypridle | Idle daemon |
| ghostty | Terminal |
| wl-clipboard + cliphist | Clipboard manager |
| grim + slurp | Screenshots |
| wpctl (wireplumber) | Volume |
| brightnessctl | Brightness |

## Adding New Themes

1. Create `.config/themes/<name>/dark.conf` and `light.conf`
2. Create `.config/themes/<name>/dark.css` and `light.css`
3. Update `~/.local/bin/theme-switch` to point to the new path

## Hardware

Tested on: **Ryzen 5 4600H + GTX 1650 (NVIDIA hybrid/Prime)**

NVIDIA Prime env vars are pre-configured in `env.conf`.
