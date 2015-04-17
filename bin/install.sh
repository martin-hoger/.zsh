#!/usr/bin/env bash

TARGET_DIR=~/.zsh
GIT_SOURCE="https://github.com/martin-hoger/.zsh"

if [ -d "$TARGET_DIR" ]; then
  echo "You already have $TARGET_DIR present. You'll need to remove it if you want to install"
  exit
fi

echo "Cloning from git..."
hash git >/dev/null 2>&1 && env git clone "$GIT_SOURCE" "$TARGET_DIR" || {
  echo "git not installed"
  exit
}

#Update submodules
cd $TARGET_DIR
git submodule init && git submodule update

#If it doesn't exist in bin folder make symlink
mkdir -p ~/bin
[[ -f ~/bin/fasd ]] || ln -s ~/.zsh/custom/fasd/fasd ~/bin/fasd
[[ -f ~/bin/fzf ]] || ln -s ~/.zsh/custom/fzf/fzf ~/bin/fzf

ln -s ~/.zsh/zshrc ~/.zshrc
