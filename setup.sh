#! /bin/sh

# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >>/Users/lmichel/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>/Users/lmichel/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
brew update
brew upgrade

# wget
brew install wget

# certs
path_to_cert=~/.config/cognex/CGNX_cacert.pem
wget http://usna-wbscrptp01.pc.cognex.com/COMBINED_CERT_PACKAGE.pem -O ${path_to_cert}
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ${path_to_cert}

cat <<EOF >>~/.zshrc
export SSL_CERT_FILE=${path_to_cert}
EOF

cat <<'EOF' >>~/.zshrc
export NODE_EXTRA_CA_CERTS=${SSL_CERT_FILE}
export REQUESTS_CA_BUNDLE=${SSL_CERT_FILE}
EOF

# raycast
brew install --cask raycast

# karabiner
brew install --cask karabiner-elements
mkdir -p ~/.config/karabiner
cp ./karabiner.json ~/.config/karabiner

# wezterm
brew install --cask wezterm
brew install font-meslo-lg-nerd-font
cp ./.wezterm.lua ~/

# spotify
brew install --cask spotify

# pass
brew install pass

# zsh
brew install powerlevel10k zsh-autosuggestions zsh-syntax-highlighting zsh-vi-mode
echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >>~/.zshrc
echo "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >>~/.zshrc
echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >>~/.zshrc
echo "source $(brew --prefix)/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh" >>~/.zshrc
source ~/.zshrc

cat <<'EOF' >>~/.zshrc
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
EOF

# tmux
brew install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
cp .tmux.conf ~/

# eza
brew install eza
echo "alias ls=\"eza --icons=always\"" >>~/.zshrc

# zoxide
brew install zoxide
eval "$(zoxide init zsh)"
alias cd="z"

# diverse utilities
brew install yazi fzf rg fd

# git
brew install lazygit
cp lazygit-config.yml ~/Library/Application\ Support/lazygit/config.yml
ssh-keygen -t ed25519 -b 4096 -C "laurent.michel@cognex.com" -f ~/.ssh/git_rsa
cat <<'EOF' >>~/.zshrc
eval "$(ssh-agent -s)" > /dev/null
ssh-add ~/.ssh/git_rsa ssh-add > /dev/null 2>&1
EOF

# python
brew install xz pyenv pyenv-virtualenv
cat <<'EOF' >>~/.zshrc
eval "$(pyenv init -)"
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
EOF
source ~/.zshrc
pyenv install 3.10.17 3.11.12 3.12.10 3.13.3
# TODO this does not work
# for v in $(pyenv versions --bare); do
# PYENV_VERSION=$v pip install ruff black flake8
# done

# terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# k8s
brew install kubectl helm derailed/k9s/k9s

# Azure
brew install azure-cli
az aks install-cli

cat <<'EOF' >>~/.zshrc
alias azl="az login --tenant 35f551b8-4936-4cae-b5d5-ede25fc4816f"
EOF

cat ${path_to_cert} >>/opt/homebrew/Cellar/azure-cli/2.71.0/libexec/lib/python3.12/site-packages/certifi/cacert.pem

# nodejs
brew install node

# intellij
brew install --cask intellij-idea

# neovim
brew install neovim
git clone git@github.com:zadigus/neovim-wsl.git ~/.config/nvim

# environment variables
cat <<'EOF' >>~/.zshrc
export ARTIFACTORY_UR=Lusaw-artifactoryp01.pc.cognex.com
export ARTIFACTORY_USERNAME=lmichel
export ARTIFACTORY_PASSWORD=changeme
export DOCKER_REGISTRY=${ARTIFACTORY_URL}:7004/

export PIP_EXTRA_INDEX_URL="https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}@${ARTIFACTORY_URL}/artifactory/api/pypi/pypi-usaw-local-MDL/simple/ https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}@${ARTIFACTORY_URL}/artifactory/api/pypi/pypi-usaw-local-Edge_Learning/simple/ https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}@${ARTIFACTORY_URL}/artifactory/api/pypi/pypi-usaw-local-DLCore/simple/"
export PIP_INDEX_URL="https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}@${ARTIFACTORY_URL}/artifactory/api/pypi/pypi-usaw-virtual-cognex/simple/"

export UV_INDEX_URL=${PIP_INDEX_URL}
export UV_EXTRA_INDEX_URL=${PIP_EXTRA_INDEX_URL}

alias docker-python-3.8="docker run --mount type=bind,src=$(pwd),target=/work -e PIP_EXTRA_INDEX_URL -e PIP_INDEX_URL -it ${DOCKER_REGISTRY}python:3.8 bash"
alias docker-python-3.9="docker run --mount type=bind,src=$(pwd),target=/work -e PIP_EXTRA_INDEX_URL -e PIP_INDEX_URL -e UV_INDEX_URL -e UV_EXTRA_INDEX_URL -it ${DOCKER_REGISTRY}python:3.9 bash"
alias docker-python-3.10="docker run --mount type=bind,src=$(pwd),target=/work -e PIP_EXTRA_INDEX_URL -e PIP_INDEX_URL -e UV_INDEX_URL -e UV_EXTRA_INDEX_URL -it ${DOCKER_REGISTRY}python:3.10 bash"
alias docker-python-3.11="docker run --mount type=bind,src=$(pwd),target=/work -e PIP_EXTRA_INDEX_URL -e PIP_INDEX_URL -e UV_INDEX_URL -e UV_EXTRA_INDEX_URL -it ${DOCKER_REGISTRY}python:3.11 bash"
alias docker-python-3.12="docker run --mount type=bind,src=$(pwd),target=/work -e PIP_EXTRA_INDEX_URL -e PIP_INDEX_URL -e UV_INDEX_URL -e UV_EXTRA_INDEX_URL -it ${DOCKER_REGISTRY}python:3.12 bash"
EOF
