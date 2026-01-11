#!/bin/bash
# Complete Restoration Script for Your Setup
set -e

echo "========================================"
echo "    Dotfiles Restoration Script"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Function to create symlink with backup
create_symlink() {
    local source_path="$1"
    local target_path="$2"
    local description="$3"

    echo ""
    echo "$description"
    echo "  Source: $source_path"
    echo "  Target: $target_path"

    # Check if source exists
    if [ ! -e "$source_path" ]; then
        print_error "Source does not exist: $source_path"
        return 1
    fi

    # If target already exists
    if [ -e "$target_path" ]; then
        # If it's already the correct symlink
        if [ -L "$target_path" ] && [ "$(readlink -f "$target_path")" = "$(readlink -f "$source_path")" ]; then
            print_status "Correct symlink already exists"
            return 0
        fi

        # Backup existing file/directory
        local backup="${target_path}.backup.$(date +%Y%m%d_%H%M%S)"
        print_warning "Backing up existing: $target_path → $backup"
        mv "$target_path" "$backup"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$target_path")"

    # Create symlink
    if ln -sf "$source_path" "$target_path"; then
        print_status "Symlink created successfully"
        return 0
    else
        print_error "Failed to create symlink"
        return 1
    fi
}

# ==================== MAIN RESTORATION ====================

echo ""
echo "1. FISH SHELL CONFIGURATION"
echo "============================"

# Fish configuration directory
create_symlink "$PWD/fish" "$HOME/.config/fish" "Fish shell configuration"

echo ""
echo "2. SHELL ALIASES (in ~/.config/)"
echo "================================="

# Aliases file - symlink to ~/.config/aliases
create_symlink "$PWD/aliases" "$HOME/.config/aliases" "Shell aliases file"

# Verify the aliases file is properly formatted for Fish
echo ""
echo "  Verifying aliases format for Fish..."
if ! grep -q "^alias " "$PWD/aliases" 2>/dev/null; then
    print_warning "Aliases file doesn't seem to have Fish-style aliases"
    print_warning "Fish uses: alias shortname 'long command'"
    echo "  Converting aliases format if needed..."

    # Backup original
    cp "$PWD/aliases" "$PWD/aliases.original"

    # Convert bash-style aliases to fish-style if needed
    # This is a simple conversion - adjust as needed
    sed -i 's/^alias \([^=]*\)=/\1 /g' "$PWD/aliases"
    sed -i "s/^alias \([^ ]*\) /alias \1 '/g" "$PWD/aliases"
    sed -i "s/\$/'"'/g" "$PWD/aliases"
fi

echo ""
echo "3. KDE CONFIGURATION"
echo "===================="

# KDE config files
create_symlink "$PWD/kdeglobals" "$HOME/.config/kdeglobals" "KDE global settings"
create_symlink "$PWD/kglobalshortcutsrc" "$HOME/.config/kglobalshortcutsrc" "KDE global shortcuts"
create_symlink "$PWD/kwinrc" "$HOME/.config/kwinrc" "KWin window manager settings"

echo ""
echo "4. KWIN SCRIPTS (Krohnkite)"
echo "============================"

# Krohnkite tiling script
create_symlink "$PWD/krohnkite" "$HOME/.local/share/kwin/scripts/krohnkite" "Krohnkite tiling script"

echo ""
echo "5. KDE COLOR SCHEME"
echo "==================="

# Color scheme
mkdir -p "$HOME/.local/share/color-schemes"
cp "$PWD/IridescentLightly2Custom.colors" "$HOME/.local/share/color-schemes/"
print_status "Color scheme installed to ~/.local/share/color-schemes/"

echo ""
echo "========================================"
echo "    RESTORATION COMPLETE!"
echo "========================================"

echo ""
echo "NEXT STEPS:"
echo "-----------"
echo "1. Restart your terminal or run: ${YELLOW}exec fish${NC}"
echo ""
echo "2. To apply KDE changes:"
echo "   - Log out and log back in, OR"
echo "   - Run: ${YELLOW}kquitapp5 plasmashell && kstart5 plasmashell${NC}"
echo ""
echo "3. To enable Krohnkite:"
echo "   - Open System Settings → Window Management → KWin Scripts"
echo "   - Enable 'krohnkite'"
echo ""
echo "4. To apply color scheme:"
echo "   - System Settings → Appearance → Colors"
echo "   - Select 'IridescentLightly2Custom'"
echo ""
echo "5. Verify aliases work:"
echo "   ${YELLOW}fish -c 'alias'${NC}"
