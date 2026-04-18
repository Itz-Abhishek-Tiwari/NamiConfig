#!/usr/bin/env bash
# =====================================================
# install.sh — Dotfiles bootstrap script
# Run: bash ~/dotfiles/install.sh
# =====================================================

set -euo pipefail

DOTFILES="${HOME}/dotfiles"
cd "${DOTFILES}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Dotfiles Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── 1. Ensure dependencies ───────────────────────────
echo "[1/5] Checking dependencies..."
PKGS=(hyprland waybar fuzzel swaync waypaper awww hyprlock hypridle
      wl-clipboard cliphist grim slurp jq playerctl
      brightnessctl pipewire wireplumber
      ghostty thunar nm-applet polkit-gnome)

MISSING=()
for pkg in "${PKGS[@]}"; do
    if ! command -v "${pkg}" &>/dev/null && ! pacman -Q "${pkg}" &>/dev/null; then
        MISSING+=("${pkg}")
    fi
done

if [[ "${#MISSING[@]}" -gt 0 ]]; then
    echo "  ⚠ Missing packages: ${MISSING[*]}"
    echo "  Install with: paru -S ${MISSING[*]}"
else
    echo "  ✓ All dependencies found"
fi

# ── 2. Note waypaper setup ──────────────────────────
echo "[2/5] Wallpaper managed by waypaper..."
echo "  ✓ Launch waypaper (SUPER+ALT+W) to pick your wallpaper"

# ── 3. Make scripts executable ───────────────────────
echo "[3/5] Setting script permissions..."
chmod +x "${DOTFILES}/.local/bin/"*
echo "  ✓ Scripts are executable"

# ── 4. Symlink dotfiles ───────────────────────────────
echo "[4/5] Linking config categories..."

# -- Ensure ~/.config is a real, usable directory --
DOTCONFIG="${HOME}/.config"
if [[ -L "${DOTCONFIG}" ]] && [[ ! -e "${DOTCONFIG}" ]]; then
    echo "  ⚠ ~/.config is a broken symlink — removing and creating fresh directory"
    rm "${DOTCONFIG}"
    mkdir -p "${DOTCONFIG}"
elif [[ ! -d "${DOTCONFIG}" ]]; then
    mkdir -p "${DOTCONFIG}"
fi

link_dir() {
    local SRC="${1}"
    local DST="${2}"
    if [[ -L "${DST}" ]]; then
        echo "  ~ Already linked: ${DST}"
    elif [[ -e "${DST}" ]]; then
        echo "  ⚠ Conflict — not a symlink: ${DST} (skipping)"
    else
        ln -s "${SRC}" "${DST}"
        echo "  ✓ Linked: ${DST}"
    fi
}

link_items() {
    local SRC_DIR="${1}"
    local DST_DIR="${2}"
    [[ -d "${DST_DIR}" ]] || mkdir -p "${DST_DIR}" 2>/dev/null || true
    for item in "${SRC_DIR}"/*; do
        [[ -e "${item}" ]] || continue
        local name
        name="$(basename "${item}")"
        local target="${DST_DIR}/${name}"
        if [[ -L "${target}" ]]; then
            echo "  ~ Already linked: ${target}"
        elif [[ -e "${target}" ]]; then
            echo "  ⚠ Conflict (not symlink): ${target} — skipping"
        else
            ln -s "${item}" "${target}"
            echo "  ✓ Linked: ${target}"
        fi
    done
}

# Link individual scripts into ~/.local/bin
link_items "${DOTFILES}/.local/bin" "${HOME}/.local/bin"

# Link .zshrc
link_dir "${DOTFILES}/.zshrc" "${HOME}/.zshrc"

# Per-app symlinks — apps look for their config at ~/.config/appname/
link_dir "${DOTFILES}/.config/hypr"       "${DOTCONFIG}/hypr"
link_dir "${DOTFILES}/.config/waybar"     "${DOTCONFIG}/waybar"
link_dir "${DOTFILES}/.config/swaync"     "${DOTCONFIG}/swaync"
link_dir "${DOTFILES}/.config/fuzzel"     "${DOTCONFIG}/fuzzel"
link_dir "${DOTFILES}/.config/ghostty"    "${DOTCONFIG}/ghostty"
link_dir "${DOTFILES}/.config/kitty"      "${DOTCONFIG}/kitty"
link_dir "${DOTFILES}/.config/zsh"        "${DOTCONFIG}/zsh"
link_dir "${DOTFILES}/.config/fastfetch"  "${DOTCONFIG}/fastfetch"
link_dir "${DOTFILES}/.config/themes"     "${DOTCONFIG}/themes"
link_dir "${DOTFILES}/.config/waypaper"   "${DOTCONFIG}/waypaper"

# GTK Global — symlink dotfiles GTK configs to standard GNOME locations
link_dir "${DOTFILES}/.config/gtk-3.0" "${DOTCONFIG}/gtk-3.0"
link_dir "${DOTFILES}/.config/gtk-4.0" "${DOTCONFIG}/gtk-4.0"

echo "  ✓ Linking complete"

# ── 5. Final checks ──────────────────────────────────
echo "[5/5] Final checks..."
if [[ ":${PATH}:" != *":${HOME}/.local/bin:"* ]]; then
    echo "  ⚠ Reload your shell: source ~/.zshrc  (to pick up PATH updates)"
else
    echo "  ✓ ~/.local/bin is in PATH"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Done! Log out and select Hyprland."
echo "  Config lives at: ~/.config/hypr/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
