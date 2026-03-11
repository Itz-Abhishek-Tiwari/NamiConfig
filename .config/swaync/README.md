# SwayNC Configuration

[SwayNotificationCenter](https://github.com/ErikReider/SwayNotificationCenter) (SwayNC) is a simple Wayland notification daemon with a GTK gui.

## Structure

- `config.json`: Main configuration for the notification center.
- `style.css`: Main stylesheet for the control center and notifications.
- `colors.css`: Theme-specific color variables (dynamically updated).

## Features

- **Control Center**: Manage notifications and system settings.
- **Widgets**: Custom widgets like Title, DND, Mute, and Clear All.
- **Animations**: Smooth transitions for notifications.

## Theming

SwayNC uses `colors.css` for its styling, which is updated by the `theme-switch` script.
