#!/usr/bin/env bash
# -*- coding: utf-8 -*-
set -euo pipefail

# Usuário atual
USER_NAME="${SUDO_USER:-$USER}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "🔄 Atualizando repositórios e pacotes..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "📦 Instalando pacotes essenciais: git, zsh, curl, eza..."
# adiciona universe para garantir que o eza esteja disponível
sudo add-apt-repository universe -y
sudo apt-get update -y
sudo apt-get install -y git zsh curl eza

echo "🧙 Instalando Oh My Zsh (sem abrir novo shell)..."
RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "🚀 Instalando Starship prompt..."
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes

echo "Estilizando o terminal com Starship..."
starship preset gruvbox-rainbow -o ~/.config/starship.toml


echo "🔌 Clonando plugins do Zsh..."
mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/completions"

# zsh-autosuggestions
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] \
  || git clone https://github.com/zsh-users/zsh-autosuggestions.git \
       "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# zsh-syntax-highlighting
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] \
  || git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
       "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# fast-syntax-highlighting
[ -d "$ZSH_CUSTOM/plugins/fast-syntax-highlighting" ] \
  || git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
       "$ZSH_CUSTOM/plugins/fast-syntax-highlighting"

echo "🔧 Gerando autocompletion do eza..."
# eza (fork do exa) suporta geração de completions:
eza --generate-completion zsh > "$ZSH_CUSTOM/completions/_eza"

echo "🐚 Definindo zsh como shell padrão para $USER_NAME..."
sudo chsh -s "$(which zsh)" "$USER_NAME"

echo "✅ Configuração inicial concluída! Abra um novo terminal para começar."
