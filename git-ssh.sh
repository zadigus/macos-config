#! /bin/bash

eval "$(ssh-agent -s)" >/dev/null
ssh-add ~/.ssh/github_rsa >/dev/null 2>&1
