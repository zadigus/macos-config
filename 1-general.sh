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
cat <<'EOF' >>~/.zshrc
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme
function zvm_config() {
  ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
}
source $(brew --prefix)/share/zsh-vi-mode/zsh-vi-mode.zsh
EOF

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
cat <<'EOF' >>~/.zshrc
alias ls="eza --icons=always"
EOF

# zoxide
brew install zoxide
cat <<'EOF' >>~/.zshrc
eval "$(zoxide init zsh)"
alias cd="z"
EOF

# diverse utilities
brew install yazi fzf rg fd

# git
brew install lazygit
cp lazygit-config.yml ~/Library/Application\ Support/lazygit/config.yml
ssh-keygen -t ed25519 -b 4096 -C "laurent.michel@cognex.com" -f ~/.ssh/git_rsa
cat <<'EOF' >>~/.zshrc
eval "$(ssh-agent -s)" > /dev/null
ssh-add ~/.ssh/git_rsa ssh-add > /dev/null 2>&1
autoload -Uz compinit && compinit
EOF

# obsidian
brew install --cask obsidian

# golang
brew install go
cat <<'EOF' >>~/.zshrc
export PATH=$HOME/go/bin:$PATH
EOF

# TODO: fix this - install python with uv
# python
brew install xz pyenv pyenv-virtualenv
curl -LsSf https://astral.sh/uv/install.sh | sh
cat <<'EOF' >>~/.zshrc
eval "$(pyenv init -)"
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
EOF
source ~/.zshrc
pyenv install 3.10.17 3.11.12 3.12.10 3.13.3

# terraform
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew install terragrunt

# k8s
brew install kubectl helm derailed/k9s/k9s kubectx

# Azure
brew install azure-cli
az aks install-cli
go install github.com/netr0m/az-pim-cli@latest

cat <<'EOF' >>~/.zshrc
alias azl="az login --tenant 35f551b8-4936-4cae-b5d5-ede25fc4816f"
EOF

cat ${path_to_cert} >>/opt/homebrew/Cellar/azure-cli/2.71.0/libexec/lib/python3.12/site-packages/certifi/cacert.pem

# nodejs
brew install node

# intellij
brew install --cask intellij-idea
brew install maven

# ocmal
brew install opam
opam init
opam install ocaml-lsp-server odoc ocamlformat utop merlin
opam user-setup install

# coq
# cf. https://rocq-prover.org/docs/using-opam
eval $(opam env)
opam pin add rocq-prover 9.0.0
opam install rocqide
opam repo add rocq-released https://rocq-prover.org/opam/released
# brew install coq
# brew install --cask coq-platform
# python3 -m pip install pynvim

# luarocks
brew install luarocks

# neovim
brew install vim neovim

# vim config
cat <<EOF >>~/.vimrc
inoremap jk <Esc>
" these are milliseconds
set timeoutlen=300
set relativenumber
EOF

ed -s ~/.vimrc <<EOF
0a
let mapleader = "\<Space>"
.
w
EOF

# coqtail support will work only on vim installed by homebrew
# because that version has python support (check with vim --version)
mkdir -p ~/.vim/pack/coq/start
git clone https://github.com/whonore/Coqtail.git ~/.vim/pack/coq/start/Coqtail
vim +helptags\ ~/.vim/pack/coq/start/Coqtail/doc +q

# environment variables
cat <<'EOF' >>~/.zshrc
export ARTIFACTORY_URL=usaw-artifactoryp01.pc.cognex.com
export ARTIFACTORY_USERNAME=lmichel
export ARTIFACTORY_PASSWORD=changeme
export DOCKER_REGISTRY=${ARTIFACTORY_URL}:7004/

export PIP_EXTRA_INDEX_URL="https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}@${ARTIFACTORY_URL}/artifactory/api/pypi/pypi-usaw-local-MDL/simple/ https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}@${ARTIFACTORY_URL}/artifactory/api/pypi/pypi-usaw-local-Edge_Learning/simple/ https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}@${ARTIFACTORY_URL}/artifactory/api/pypi/pypi-usaw-local-DLCore/simple/"
export PIP_INDEX_URL="https://${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}@${ARTIFACTORY_URL}/artifactory/api/pypi/pypi-usaw-virtual-cognex/simple/"

export UV_INDEX_URL=${PIP_INDEX_URL}
export UV_DEFAULT_INDEX=${UV_INDEX_URL}
export UV_EXTRA_INDEX_URL=${PIP_EXTRA_INDEX_URL}
export UV_INDEX=${UV_EXTRA_INDEX_URL}
export UV_INDEX_PYPI_USAW_LOCAL_MDL_USERNAME=${ARTIFACTORY_USERNAME}
export UV_INDEX_PYPI_USAW_LOCAL_MDL_PASSWORD=${ARTIFACTORY_PASSWORD}
export UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_USERNAME=${ARTIFACTORY_USERNAME}
export UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PASSWORD=${ARTIFACTORY_PASSWORD}
export UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PUBLIC_USERNAME=${ARTIFACTORY_USERNAME}
export UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PUBLIC_PASSWORD=${ARTIFACTORY_PASSWORD}
export UV_INDEX_PYPI_USAW_VIRTUAL_COGNEX_USERNAME=${ARTIFACTORY_USERNAME}
export UV_INDEX_PYPI_USAW_VIRTUAL_COGNEX_PASSWORD=${ARTIFACTORY_PASSWORD}

alias docker-python-3.8="docker run --mount type=bind,src=$(pwd),target=/work -e PIP_EXTRA_INDEX_URL -e PIP_INDEX_URL -it ${DOCKER_REGISTRY}python:3.8 bash"
alias docker-python-3.9="docker run --mount type=bind,src=$(pwd),target=/work -e UV_INDEX_PYPI_USAW_LOCAL_MDL_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_MDL_PASSWORD -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PASSWORD -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PUBLIC_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PUBLIC_PASSWORD -e UV_INDEX_PYPI_USAW_VIRTUAL_COGNEX_USERNAME -e UV_INDEX_PYPI_USAW_VIRTUAL_COGNEX_PASSWORD -e PIP_EXTRA_INDEX_URL -e PIP_INDEX_URL -e UV_INDEX_URL -e UV_EXTRA_INDEX_URL -it ${DOCKER_REGISTRY}python:3.9 bash"
alias docker-python-3.10="docker run --mount type=bind,src=$(pwd),target=/work -e UV_INDEX_PYPI_USAW_LOCAL_MDL_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_MDL_PASSWORD -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PASSWORD -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PUBLIC_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PUBLIC_PASSWORD -e UV_INDEX_PYPI_USAW_VIRTUAL_COGNEX_USERNAME -e UV_INDEX_PYPI_USAW_VIRTUAL_COGNEX_PASSWORD -e PIP_EXTRA_INDEX_URL -e PIP_INDEX_URL -e UV_INDEX_URL -e UV_EXTRA_INDEX_URL -it ${DOCKER_REGISTRY}python:3.10 bash"
alias docker-python-3.11="docker run --mount type=bind,src=$(pwd),target=/work -e UV_INDEX_PYPI_USAW_LOCAL_MDL_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_MDL_PASSWORD -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PASSWORD -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PUBLIC_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PUBLIC_PASSWORD -e UV_INDEX_PYPI_USAW_VIRTUAL_COGNEX_USERNAME -e UV_INDEX_PYPI_USAW_VIRTUAL_COGNEX_PASSWORD -e PIP_EXTRA_INDEX_URL -e PIP_INDEX_URL -e UV_INDEX_URL -e UV_EXTRA_INDEX_URL -it ${DOCKER_REGISTRY}python:3.11 bash"
alias docker-python-3.12="docker run --mount type=bind,src=$(pwd),target=/work -e UV_INDEX_PYPI_USAW_LOCAL_MDL_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_MDL_PASSWORD -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PASSWORD -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PUBLIC_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PUBLIC_PASSWORD -e UV_INDEX_PYPI_USAW_VIRTUAL_COGNEX_USERNAME -e UV_INDEX_PYPI_USAW_VIRTUAL_COGNEX_PASSWORD -e PIP_EXTRA_INDEX_URL -e PIP_INDEX_URL -e UV_INDEX_URL -e UV_EXTRA_INDEX_URL -it ${DOCKER_REGISTRY}python:3.12 bash"
alias docker-python-3.13="docker run --mount type=bind,src=$(pwd),target=/work -e UV_INDEX_PYPI_USAW_LOCAL_MDL_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_MDL_PASSWORD -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PASSWORD -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PUBLIC_USERNAME -e UV_INDEX_PYPI_USAW_LOCAL_EDGE_LEARNING_PUBLIC_PASSWORD -e UV_INDEX_PYPI_USAW_VIRTUAL_COGNEX_USERNAME -e UV_INDEX_PYPI_USAW_VIRTUAL_COGNEX_PASSWORD -e PIP_EXTRA_INDEX_URL -e PIP_INDEX_URL -e UV_INDEX_URL -e UV_EXTRA_INDEX_URL -it ${DOCKER_REGISTRY}python:3.13 bash"
EOF

# devcontainer
brew install devcontainer
devcontainer_config_path=~/.config/cognex/devcontainer.json
cp devcontainer.json ${devcontainer_config_path}

cat <<EOF >>~/.zshrc
devup() {
  devcontainer up --config ${devcontainer_config_path} \
    --workspace-folder .
}
alias devnvim="devcontainer exec --config ${devcontainer_config_path} --workspace-folder . uv run nvim"
alias devdown="docker-compose -f docker-compose.fixture.yml -f docker-compose.dev.yml down --remove-orphans"
EOF
