#!/usr/bin/env bash
set -e

read -p "Enter VM name (for SSH key comment): " VM_NAME
read -p "Enter Git user name: " GIT_NAME
read -p "Enter Git user email: " GIT_EMAIL

# Update and install dependencies
apt update
apt install -y sudo curl git build-essential openssh-server \
    zsh neovim tmux jq unzip docker.io \
    golang rustc cargo python3 python3-pip gcc g++ make

# Install oh-my-zsh for root
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install LazyVim for root
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# Git config (root-based)
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch main

# Install mise under root properly
curl -sSL https://mise.jdx.dev/install.sh | sh

# Activate mise for zsh
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

# Load mise for use in script execution
export PATH="$HOME/.local/bin:$PATH"
eval "$(mise activate bash)"

# Install language runtimes through mise
mise use -g go
mise use -g python
mise use -g rust
mise use -g node

# Terminal configuration
echo 'export TERM=xterm-256color' >> ~/.zshrc

# SSH key generation for root
mkdir -p ~/.ssh
ssh-keygen -t ed25519 -C "$VM_NAME" -f ~/.ssh/id_ed25519 -N ""
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Enable docker to start on boot
systemctl enable docker

# Display SSH public key
echo
echo "---------------------------------------------------"
echo "SSH Public Key:"
cat ~/.ssh/id_ed25519.pub
echo "---------------------------------------------------"
echo
echo "Init complete. Recommended next steps:"
echo " - exec zsh"
echo " - docker run hello-world"
echo " - nvim"
echo " - mise doctor"
echo " - sudo reboot (kernel updates detected)"
