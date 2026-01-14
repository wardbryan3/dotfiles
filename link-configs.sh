#!/bin/bash

# Exit if any command fails
set -euo pipefail

# Variables
current_time=$(date "+%Y%m%d-%H%M%S")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#Helper Functions
backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    local backup="$file.${current_time}.bak"
    mv "$file" "$backup"
    echo "Backed up: $file to $backup"
  fi
}

check_source() {
  local source="$1"
  local description="$2"

  if [ ! -e "$source" ]; then
    echo "Error: $description not found at $source " >&2
    return 1
  fi
  return 0
}

link_config() {
  local source="$1"
  local target="$2"
  local description="$3"

  mkdir -p "$(dirname "$target")"
  ln -sf "$source" "$target" && echo "Linked $description"
}

# 1. FISH SHELL
echo "1. Fish shell config..."
if [ ! -d "$HOME/.config/fish" ]; then
  mkdir -p "$HOME/.config/fish"
fi

if ! grep -q "source $SCRIPT_DIR/dotfiles/fish/fish" "$HOME/.config/fish/config.fish" 2>/dev/null; then
  echo "source $SCRIPT_DIR/dotfiles/fish/fish" >>"$HOME/.config/fish/config.fish"
  echo "Added Fish config source"
fi

# 2. Kitty terminal Configs
# Backup Kitty terminal Configs
echo "2. Configuring Kitty..."
if [ -f "$HOME/.config/kitty/kitty.conf" ]; then
  backup_file "$HOME/.config/kitty/kitty.conf"
fi

link_config "$SCRIPT_DIR/kitty/kitty.conf" \
  "$HOME/.config/kitty/kitty.conf" \
  "Kitty Config"

# 3. COLOR SCHEME
# Controls colors for windows, buttons, text, etc.
echo "3. Color scheme..."
check_source "$SCRIPT_DIR/Purple_White.colors" "Color Scheme" &&
  link_config "$SCRIPT_DIR/Purple_White.colors" \
    "$HOME/.local/share/color-schemes/Purple_White.colors" \
    "color scheme"

# 4. KDE settings
echo "4. Configuring KDE..."
backup_file "$HOME/.config/kwinrc"
backup_file "$HOME/.config/kglobalshortcutsrc"

check_source "$SCRIPT_DIR/kde/kwinrc" "KDE window manager config" &&
  link_config "$SCRIPT_DIR/kde/kwinrc" "$HOME/.config/kwinrc" "KDE window manager config"

check_source "$SCRIPT_DIR/kde/kglobalshortcutsrc" "KDE shortcuts config" &&
  link_config "$SCRIPT_DIR/kde/kglobalshortcutsrc" \
    "$HOME/.config/kglobalshortcutsrc" "KDE shortcuts config"

echo "Configuration Complete"
