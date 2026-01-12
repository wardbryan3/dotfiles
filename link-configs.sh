#!/bin/bash
# Simplified dotfiles restoration script
# Creates symlinks from repository to system config locations

# Exit if any command fails
set -e

# Print section headers in a clear way
echo "=== Creating symlinks for dotfiles ==="
echo ""

# 1. FISH SHELL
# Fish is a modern shell with auto-suggestions and better scripting
echo "1. Fish shell config..."
ln -sf "$PWD/fish" "$HOME/.config/fish" && echo "  ✓ Fish config linked"

# 2. SHELL ALIASES
# Aliases create shortcuts for common commands
echo ""
echo "2. Shell aliases..."
ln -sf "$PWD/aliases" "$HOME/.config/aliases" && echo "  ✓ Aliases linked"


# 4. COLOR SCHEME
# Controls colors for windows, buttons, text, etc.
echo ""
echo "5. Color scheme..."
mkdir -p "$HOME/.local/share/color-schemes"  # Create directory if needed
ln -sf "$PWD/Purple_White.colors" "$HOME/.local/share/color-schemes/Purple_White.colors" && echo "  ✓ Color scheme linked"

echo ""
echo "=== All symlinks created successfully! ==="
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: exec fish"
echo "2. For KDE changes: Log out and back in"
echo "3. Enable Krohnkite in: System Settings → Window Management → KWin Scripts"
