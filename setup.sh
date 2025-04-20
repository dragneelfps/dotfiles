#!/bin/bash

set -e


# --- Configuration ---
DOTFILES_REPO="git@github.com:dragneelfps/dotfiles.git"
DOTFILES_DIR="$HOME/dotfiles"
GIT_EMAIL="s.rawat3.142@live.in"
GIT_NAME="Sourabh Singh Rawat"

# List of packages to install (adjust for your distribution's package manager)
PACKAGES=(
    github-cli
    openssh
    zsh
    curl
    stow
    neovim
    less
    uv
    jdk21-openjdk
    gradle
)

# --- Functions ---

install_packages() {
    echo "Installing necessary packages..."
    sudo pacman -Syu --noconfirm "${PACKAGES[@]}"
    echo "Package installation complete."
}

setup_zsh() {
    echo "Setting up Zsh and Oh My Zsh..."

    # Install Oh My Zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        # The || true at the end prevents set -e from exiting if the script
        # has a non-zero exit code but still largely succeeds (common with some installers).
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" || true
        echo "Oh My Zsh installation script executed. Review its output for any messages."
    else
        echo "Oh My Zsh is already installed."
    fi

    echo "Zsh and Oh My Zsh setup process finished."
}

setup_github() {
    echo "Setting up Github Auth..."

    set +e
    gh auth status --hostname github.com &> /dev/null # Redirect output to null to keep script clean
    GH_AUTH_EXIT_CODE=$?
    set -e
    # Check the exit code of the previous command (gh auth status)
    if [ $GH_AUTH_EXIT_CODE -eq 0 ]; then
        echo "GitHub CLI is already authenticated."
    else
        echo "logging..."
        gh auth login --hostname github.com --git-protocol ssh
    fi

    git config --global user.email "$GIT_EMAIL"
    git config --global user.name "$GIT_NAME"
}

setup_python() {
    echo "Setting up Python using uv..."

    uv python install --default --preview
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
setup_zsh
setup_github
setup_python
clone_dotfiles
deploy_dotfiles_stow

# --- Optional: Run a post-setup script from your dotfiles ---
if [ -f "$DOTFILES_DIR/setup_post.sh" ]; then
    echo "Running post-setup script..."
    "$DOTFILES_DIR/setup_post.sh"
fi

echo "Linux setup complete!"
