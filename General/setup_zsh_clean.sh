#!/bin/bash

# setup_zsh.sh
# This script installs Oh My Zsh and custom plugins (zsh-autosuggestions, 
# zsh-syntax-highlighting, you-should-use, docker, argocd, aws, docker-compose, 
# fzf, gatsby, helm, zsh-interactive-cd), then sets up the .zshrc file
# with the exact same configuration as the user's current .zshrc.

set -e  # Exit immediately if a command exits with a non-zero status

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Log functions for better readability
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if Zsh is installed
check_zsh() {
    log_info "Checking if Zsh is installed..."
    if ! command -v zsh &> /dev/null; then
        log_error "Zsh is not installed. Please install Zsh first and then run this script again."
    else
        log_info "Zsh is installed at $(which zsh)"
    fi
}

# Install Oh My Zsh if not already installed
install_oh_my_zsh() {
    log_info "Checking if Oh My Zsh is already installed..."
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_info "Oh My Zsh is already installed."
    else
        log_info "Installing Oh My Zsh..."
        # Using the official installation method
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || log_error "Failed to install Oh My Zsh."
        log_info "Oh My Zsh installed successfully!"
    fi
}

# Install custom plugins
install_plugins() {
    local custom_plugins_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    # Install zsh-autosuggestions
    if [ ! -d "$custom_plugins_dir/zsh-autosuggestions" ]; then
        log_info "Installing zsh-autosuggestions plugin..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$custom_plugins_dir/zsh-autosuggestions" || log_error "Failed to install zsh-autosuggestions."
        log_info "zsh-autosuggestions installed successfully!"
    else
        log_info "zsh-autosuggestions is already installed."
    fi
    
    # Install zsh-syntax-highlighting
    if [ ! -d "$custom_plugins_dir/zsh-syntax-highlighting" ]; then
        log_info "Installing zsh-syntax-highlighting plugin..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$custom_plugins_dir/zsh-syntax-highlighting" || log_error "Failed to install zsh-syntax-highlighting."
        log_info "zsh-syntax-highlighting installed successfully!"
    else
        log_info "zsh-syntax-highlighting is already installed."
    fi
    
    # Install you-should-use
    if [ ! -d "$custom_plugins_dir/you-should-use" ]; then
        log_info "Installing you-should-use plugin..."
        git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$custom_plugins_dir/you-should-use" || log_error "Failed to install you-should-use."
        log_info "you-should-use installed successfully!"
    else
        log_info "you-should-use is already installed."
    fi
    
    # Install zsh-interactive-cd if not already in standard plugins
    if [ ! -d "$ZSH/plugins/zsh-interactive-cd" ] && [ ! -d "$custom_plugins_dir/zsh-interactive-cd" ]; then
        log_info "Installing zsh-interactive-cd plugin..."
        git clone https://github.com/changyuheng/zsh-interactive-cd.git "$custom_plugins_dir/zsh-interactive-cd" || log_error "Failed to install zsh-interactive-cd."
        log_info "zsh-interactive-cd installed successfully!"
    else
        log_info "zsh-interactive-cd is already installed."
    fi

    # Verify standard plugins are available
    log_info "Verifying standard Oh My Zsh plugins..."
    local standard_plugins=("git" "docker" "argocd" "aws" "docker-compose" "fzf" "gatsby" "helm")
    for plugin in "${standard_plugins[@]}"; do
        if [ -d "$ZSH/plugins/$plugin" ]; then
            log_info "Standard plugin '$plugin' is available."
        else
            log_warn "Standard plugin '$plugin' may not be available in your Oh My Zsh installation."
        fi
    done
}

# This function is no longer needed since we're using a fixed template
# But keeping a placeholder for script structure consistency
capture_current_zshrc() {
    local zshrc="$HOME/.zshrc"
    local backup_content=""
    
    if [ -f "$zshrc" ]; then
        log_info "Existing .zshrc found, will be backed up before replacement"
        return 0
    else
        log_warn "No existing .zshrc found"
        return 1
    fi
}

# Update or create .zshrc file
setup_zshrc() {
    local zshrc="$HOME/.zshrc"
    local backup="$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    
    # Backup existing .zshrc if it exists
    if [ -f "$zshrc" ]; then
        log_info "Backing up existing .zshrc to $backup"
        cp "$zshrc" "$backup" || log_error "Failed to backup .zshrc"
    fi
    
    # Create new .zshrc with exact template content
    log_info "Creating new .zshrc file with template content..."
    cat > "$zshrc" << 'EOF'
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker argocd aws docker-compose fzf gatsby helm zsh-interactive-cd you-should-use)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Custome Config for NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
EOF
    
    if [ $? -eq 0 ]; then
        log_info "Successfully created .zshrc with template content"
    else
        log_error "Failed to create .zshrc file"
    fi
}

# Main function to execute the script
main() {
    log_info "Starting Zsh and Oh My Zsh setup..."
    
    check_zsh
    install_oh_my_zsh
    install_plugins
    setup_zshrc
    
    log_info "Setup completed successfully!"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply the changes."
}

# Run the main function
main

