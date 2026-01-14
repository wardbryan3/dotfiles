#!/usr/bin/env bash

# This Script is to be used on arch-based systems with KDE only
# Arch Linux System setup script
#
# Description: Sets up my arch based systems with essential packages,
#              developement tools, and user configurations.
#_____________________________________________________________________

set -euo pipefail

# Color variables for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration variables
readonly ESSENTIAL_PACKAGES=(
  lazygit
  github-cli
  neovim
  btop
  fastfetch
  eza
  vivaldi
  kitty
  fish
)

readonly FONT_PACKAGES=(
  ttf-jetbrains-mono
)

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_SCRIPT="${SCRIPT_DIR}/link-configs.sh"

# Helper Functions
print_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

confirm_continue() {
  local prompt="$1"
  read -p "$prompt (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Operation cancelled by user."
    return 1
  fi
  return 0
}

# Validation Functions
validate_environment() {
  print_info "Validating environment..."

  # Check if running on an Arch-based system
  if ! command -v pacman >/dev/null 2>&1; then
    print_error "This script is for Arch-based systems only (pacman not found)."
    exit 1
  fi

  # Check if KDE is installed
  if ! command -v kpackagetool6 >/dev/null 2>&1; then
    print_error "This script requires KDE to be installed"
    exit 1
  fi

  # Check if script is ran with sudo
  if [[ $EUID -eq 0 ]]; then
    print_warning "Script is running as root. It is better to run as a normal user
    and use sudo for specific commands."
    confirm_continue "Continue as root?" || exit 1
  fi

  # Check for configuration script
  if [[ ! -f "$CONFIG_SCRIPT" ]]; then
    print_warning "Configuration script not found: $CONFIG_SCRIPT"
    print_info "Some configurations will be skipped."
  fi

  print_success "Environment validation passed."
}

# System update function
update_system() {
  print_info "Checking for system updates..."
  if ! confirm_continue "Update system packages?"; then
    print_info "Skipping system update."
    return 0
  fi

  print_info "Updating system packages..."
  sudo pacman -Syu --noconfirm
  print_success "System update completed"
}

# Package installation function
install_packages() {
  local package_list=("$@")
  local failed_packages=()

  for package in "${package_list[@]}"; do
    if pacman -Qi "$package" &>/dev/null; then
      print_info "$package is already installed."
    else
      print_info "Installing $package..."
      if sudo pacman -S --noconfirm --needed "$package"; then
        print_success "Installed $package"
      else
        print_error "Failed to install $package"
        failed_packages+=("$package")
      fi
    fi
  done

  if [[ ${#failed_packages[@]} -gt 0 ]]; then
    print_warning "Failed to install: ${failed_packages[*]}"
    return 1
  fi

  return 0

}

# KWIN Sctipt Installation

# Git Configuration function

configure_git() {
  print_info "Configuring Git..."

  # Use existing config or prompt for new values
  local current_name
  local current_email

  current_name=$(git config --global user.name || echo "")
  current_email=$(git config --global user.email || echo "")

  if [[ -n "$current_name" && -n "$current_email" ]]; then
    print_info "Git already configured: $current_name <$current_email>"
    if ! confirm_continue "Update Git configuration?"; then
      return 0
    fi
  fi

  # Prompt for new values
  local git_name
  local git_email

  if [[ -z "$current_name" ]]; then
    read -p "Enter Git user name: " git_name
  else
    read -p "Enter Git user name [$current_name]: " git_name
    git_name=${git_name: -current_name}
  fi

  if [[ -z "$current_email" ]]; then
    read -p "Enter Git user email: " git_email
  else
    read -p "Enter Git user email [$current_email]: " git_email
    git_email=${git_email:-$current_email}
  fi

  # Set configuration
  git config --global user.name "$git_name"
  git config --global user.email "$git_email"

  print_success "Git configured: $git_name <$git_email>"
}

# LazyVim Installation Function
install_lazyvim() {
  print_info "Setting up LazyVim..."

  local nvim_dir="$HOME/.config/nvim"
  local backup_dir=""

  # Check if nvim config exists
  if [[ -d "$nvim_dir" ]]; then
    print_warning "Existing nvim configuration found at $nvim_dir"

    if confirm_continue "Backup existing nvim configuration?"; then
      backup_dir="${nvim_dir}.bak.$(date +%Y%m%d_%H%M%S)"
      if mv "$nvim_dir" "$backup_dir"; then
        print_success "Backed up to: $backup_dir"
      else
        print_error "Failed to create backup"
        return 1
      fi
    else
      print_info "Skipping LazyVim installation."
      return 0
    fi
  fi

  # Create directory if it doesn't exist
  mkdir -p "$(dirname "$nvim_dir")"

  # Clone LazyVim starter
  print_info "Cloning LazyVim starter..."
  if git clone --depth=1 https://github.com/LazyVim/starter "$nvim_dir"; then
    # Remove .git directory to treat it as a personal config
    rm -rf "$nvim_dir/.git"
    print_success "LazyVim installed successfully"

    # Provide post-installation instructions
    print_info "After installation, open nvim and run:"
    print_info "  :Lazy sync"
  else
    print_error "Failed to clone LazyVim repository"

    # Restore backup if it exists
    if [[ -n "$backup_dir" && -d "$backup_dir" ]]; then
      print_info "Restoring backup..."
      mv "$backup_dir" "$nvim_dir"
    fi
    return 1
  fi
}

# GitHub CLI AUTHENTICATION
setup_github_auth() {
  print_info "Setting up GitHub CLI authentication..."

  if ! command -v gh &>/dev/null; then
    print_error "GitHub CLI (gh) not installed. Skipping Authentication."
    return 1
  fi

  if gh auth status &>/dev/null; then
    print_info "GitHub CLI is already authenticated."
    return 0
  fi

  print_warning "GitHub CLI requires interactive authentication."
  print_info "You will need to authenticate in your browser"

  if confirm_continue "Start GitHub CLI authentication now?"; then
    if gh auth login --web; then
      print_success "GitHub authentication successful."
    else
      print_warning "GitHub authetication may require manual setup."
      print_info "You can run 'gh auth login' manually later."
    fi
  else
    print_info "Skipping GitHub authentication."
    print_info "You can run 'gh auth login' manually when needed."
  fi
}

#Configuration Script Execution
run_configuration_script() {
  print_info "Running configuration script..."

  if [[ ! -f "$CONFIG_SCRIPT" ]]; then
    print_warning "Configuration script not found: $CONFIG_SCRIPT"
    return 1
  fi

  if [[ ! -x "$CONFIG_SCRIPT" ]]; then
    print_warning "Making configuration script executable..."
    chmod +x "$CONFIG_SCRIPT"
  fi

  if confirm_continue "Run configuration linking script?"; then
    print_info "Executing: $CONFIG_SCRIPT"
    if bash "$CONFIG_SCRIPT"; then
      print_success "Configuration script executed successfully."
    else
      print_error "Configuration script failed."
      return 1
    fi
  else
    print_info "Skipping configuration script."
  fi
}

# Main Execution Flow
main() {
  print_info "Starting Arch system setup"
  print_warning "This script will make changes to system configurations"
  print_warning "It is recommended to review the script before running"

  if ! confirm_continue "Continue with system setup?"; then
    print_info "Setup cancelled."
    exit 0
  fi

  # Main Flow
  validate_environment
  update_system

  print_info "Installing essential packages"
  intall_packages "${ESSENTIAL_PACKAGES[@]}"

  print_info "Installing fonts..."
  intall_packages "${FONT_PACKAGES[@]}"

  configure git
  install_lazyvim
  setup_github_auth
  run_configuration_script

  # Summary
  echo "==================================="
  print_success "System setup completed"

  print_info "Please Reboot System"
  echo "==================================="
}

# First update the system
sudo pacman -Syu

echo "Installing essential packages"
# Installls
sudo pacman -S lazygit github-cli neovim btop fastfetch eza vivaldi kitty fish --needed
echo "Installing fonts"
sudo pacman -S ttf-jetbrains-mono

echo "Installing Kwin Scripts (Khronkite and Remember Window Positions"
mkdir -p /tmp/kwin-install

# Install krohnkite
echo "Installing krohnkite..."
git clone https://github.com/esjeon/krohnkite /tmp/kwin-install/krohnkite
kpackagetool6 --type=KWin/Script -i /tmp/kwin-install/krohnkite

# Install RememberWindowPositions
echo "Installing RememberWindowPositions..."
git clone https://github.com/rxappdev/RememberWindowPositions /tmp/kwin-install/remember
kpackagetool6 --type=KWin/Script -i /tmp/kwin-install/remember

# Enable the scripts in configuration
echo "Enabling scripts in configuration..."
kwriteconfig6 --file kwinrc --group Plugins --key krohnkiteEnabled true
kwriteconfig6 --file kwinrc --group Plugins --key rememberwindowpositionsEnabled true

# Clean up
rm -rf /tmp/kwin-install

echo "Setting git config name and e-mail"
#git
git config --global user.name "Bryan Ward"
git config --global user.email "wardbryan3@gmail.com"

echo Installing LazyVim
#LazyVim
echo "Backing up current nvim configs"
mv ~/.config/nvim{,.bak}
echo "Installing LazyVim"
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

#github login
gh auth login

#Execute configuration imports
exec link-configs.sh
