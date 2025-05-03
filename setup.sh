#! /bin/sh

# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> /Users/lmichel/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/lmichel/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
brew update
brew upgrade

# karabiner
brew install --cask karabiner-elements
mkdir -p ~/.config/karabiner
cp ./karabiner.json ~/.config/karabiner

# wezterm
brew install --cask wezterm
brew install font-meslo-lg-nerd-font
cp ./.wezterm.lua ~/

# pass
brew install pass

# zsh
brew install powerlevel10k zsh-autosuggestions zsh-syntax-highlighting
echo "source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
echo "source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
echo "source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme" >> ~/.zshrc
source ~/.zshrc

cat <<'EOF' >> ~/.zshrc
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
echo "alias ls=\"eza --icons=always\"" >> ~/.zshrc

# zoxide
brew install zoxide
eval "$(zoxide init zsh)"
alias cd="z"

# yazi
brew install yazi

# lazygit
brew install lazygit

# python
brew install xz pyenv pyenv-virtualenv
cat <<'EOF' >> ~/.zshrc
eval "$(pyenv init -)"
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
EOF
source ~/.zshrc
pyenv install 3.10.17 3.11.12 3.12.10 3.13.3
for v in $(pyenv versions --bare); do
  PYENV_VERSION=$v pip install ruff black flake8
done


# neovim
brew install neovim
