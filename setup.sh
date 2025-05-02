#! /bin/sh

# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> /Users/lmichel/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/lmichel/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# wezterm
brew install --cask wezterm


