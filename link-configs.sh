#!/bin/bash
# Simplified dotfiles restoration script
# Creates symlinks from repository to system config locations

# Exit if any command fails
set -e

echo "=== Creating symlinks for dotfiles ==="
echo ""

# 1. FISH SHELL
echo "1. Fish shell config..."

echo "source $HOME/dotfiles/config.fish" >>"$HOME/.config/fish/config.fish"
# 2. SHELL ALIASES
# Aliases create shortcuts for common commands
echo ""
echo "2. Shell aliases..."
ln -sf "$PWD/aliases" "$HOME/.config/aliases" && echo "  ✓ Aliases linked"

# 4. COLOR SCHEME
# Controls colors for windows, buttons, text, etc.
echo ""
echo "5. Color scheme..."
mkdir -p "$HOME/.local/share/color-schemes" # Create directory if needed
ln -sf "$PWD/Purple_White.colors" "$HOME/.local/share/color-schemes/Purple_White.colors" && echo "  ✓ Color scheme linked"
