#!/usr/bin/env bash
# -*- coding: utf-8 -*-
set -euo pipefail

# Variáveis
USER_NAME="${SUDO_USER:-$USER}"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
ZSHRC="$HOME/.zshrc"
PLUGINS=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  fast-syntax-highlighting
)
REPOS=(
  https://github.com/zsh-users/zsh-autosuggestions.git
  https://github.com/zsh-users/zsh-syntax-highlighting.git
  https://github.com/zdharma-continuum/fast-syntax-highlighting.git
)

# Atualiza e instala pacotes
echo "🔄 Atualizando sistema e instalando dependências..."
sudo apt-get update -y \
  && sudo add-apt-repository universe -y \
  && sudo apt-get upgrade -y \
  && sudo apt-get install -y git zsh curl eza

# Instala Oh My Zsh sem mudar shell automaticamente
echo "🧙 Instalando Oh My Zsh..."
RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Instala Starship
echo "🚀 Instalando Starship prompt..."
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes
starship preset gruvbox-rainbow -o ~/.config/starship.toml

# Clona plugins Zsh
echo "🔌 Clonando plugins do Zsh..."
mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/completions"
for repo in "${REPOS[@]}"; do
  name=$(basename "$repo" .git)
  [ -d "$ZSH_CUSTOM/plugins/$name" ] || \
    git clone "$repo" "$ZSH_CUSTOM/plugins/$name"
done

# Gera autocompletion do eza
echo "🔧 Gerando completions do eza..."
eza --generate-completion zsh > "$ZSH_CUSTOM/completions/_eza"

# Atualiza plugins no .zshrc
echo "🔄 Atualizando plugins no $ZSHRC..."
if grep -q '^plugins=' "$ZSHRC"; then
  sed -i "/^plugins=/c\plugins=(${PLUGINS[*]})" "$ZSHRC"
else
  {
    echo ""
    echo "# Plugins do Oh My Zsh"
    echo "plugins=(${PLUGINS[*]})"
  } >> "$ZSHRC"
fi

# Define Zsh como shell padrão
echo "🐚 Definindo Zsh como padrão para $USER_NAME..."
sudo chsh -s "$(which zsh)" "$USER_NAME"

echo "✅ Concluído! Abra um novo terminal para aplicar as mudanças."
