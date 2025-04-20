#!/bin/bash

set -e


# --- Configuration ---
DOTFILES_REPO="https://github.com/dragneelfps/dotfiles"
DOTFILES_DIR="$HOME/dotfiles"

# List of packages to install (adjust for your distribution's package manager)
PACKAGES=(
    htop
    github-cli
)

# --- Functions ---

install_packages() {
    echo "Installing necessary packages..."
    sudo pacman -Syu --noconfirm "${PACKAGES[@]}"
    echo "Package installation complete."
}

clone_dotfiles() {
    echo "Cloning dotfiles repository..."
    if [ -d "$DOTFILES_DIR" ]; then
        echo "Dotfiles directory already exists. Pulling latest changes."
        git -C "$DOTFILES_DIR" pull
    else
        git clone --recursive "$DOTFILES_REPO" "$DOTFILES_DIR"
    fi
    echo "Dotfiles cloning complete."
}

deploy_dotfiles_stow() {
    echo "Deploying dotfiles with Stow..."
    cd "$DOTFILES_DIR" || { echo "Error: Could not change to dotfiles directory."; exit 1; }

    # Stow each package
    for package in */; do
        if [ -d "$package" ]; then
            package_name=$(basename "$package")
            echo "Stowing $package_name..."
            stow "$package_name"
        fi
    done
    echo "Dotfiles deployment complete."
}

# --- Main Script Execution ---

# Ensure we are in the home directory
cd "$HOME" || { echo "Error: Could not change to home directory."; exit 1; }

install_packages
clone_dotfiles
deploy_dotfiles_stow

# --- Optional: Run a post-setup script from your dotfiles ---
if [ -f "$DOTFILES_DIR/setup.sh" ]; then
    echo "Running post-setup script..."
    "$DOTFILES_DIR/setup.sh"
fi

echo "Linux setup complete!"
