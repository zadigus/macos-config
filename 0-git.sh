#!/bin/sh

ssh-keygen -t ed25519 -b 4096 -C "laurent.michel@cognex.com" -f ~/.ssh/github_rsa
cat <<'EOF' >>~/.zshrc
eval "$(ssh-agent -s)" > /dev/null
ssh-add ~/.ssh/github_rsa ssh-add > /dev/null 2>&1
autoload -Uz compinit && compinit
EOF

# TODO: push the public key to github and bitbucket
# TODO: log on github and bitbucket
