#!/bin/sh

git config --global user.name "Laurent Michel"
git config --global user.email "laurent.michel@cognex.com"

# on the Macbook M5 Pro, ed25519 does not work, I had to use rsa
ssh-keygen -t ed25519 -b 4096 -C "laurent.michel@cognex.com" -f ~/.ssh/github_rsa
cat <<'EOF' >>~/.zshrc
eval "$(ssh-agent -s)" > /dev/null
ssh-add ~/.ssh/github_rsa ssh-add > /dev/null 2>&1
autoload -Uz compinit && compinit
EOF

# TODO: push the public key to github and bitbucket
# TODO: log on github and bitbucket
