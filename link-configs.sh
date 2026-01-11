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

# 3. KDE DESKTOP CONFIG
# KDE is a graphical desktop environment for Linux
echo ""
echo "3. KDE desktop settings..."
ln -sf "$PWD/kdeglobals" "$HOME/.config/kdeglobals" && echo "  ✓ KDE globals linked"
ln -sf "$PWD/kglobalshortcutsrc" "$HOME/.config/kglobalshortcutsrc" && echo "  ✓ KDE shortcuts linked"
ln -sf "$PWD/kwinrc" "$HOME/.config/kwinrc" && echo "  ✓ KWin settings linked"

# 4. KWIN TILING SCRIPT
# Krohnkite automatically arranges windows in tiles
echo ""
echo "4. Window tiling script (Krohnkite)..."
mkdir -p "$HOME/.local/share/kwin/scripts"  # Create directory if needed
ln -sf "$PWD/krohnkite" "$HOME/.local/share/kwin/scripts/krohnkite" && echo "  ✓ Krohnkite linked"

# 5. COLOR SCHEME
# Controls colors for windows, buttons, text, etc.
echo ""
echo "5. Color scheme..."
mkdir -p "$HOME/.local/share/color-schemes"  # Create directory if needed
ln -sf "$PWD/IridescentLightly2Custom.colors" "$HOME/.local/share/color-schemes/IridescentLightly2Custom.colors" && echo "  ✓ Color scheme linked"

echo ""
echo "=== All symlinks created successfully! ==="
echo ""
echo "Next steps:"
echo "1. Restart your terminal or run: exec fish"
echo "2. For KDE changes: Log out and back in"
echo "3. Enable Krohnkite in: System Settings → Window Management → KWin Scripts"
