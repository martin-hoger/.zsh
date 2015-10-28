#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/..

# Update all the git repost
git pull origin master
git submodule init && git submodule update
echo

# Upgrade ZSH
OH_MY_ZSH_DIR=$DIR/../oh-my-zsh
env ZSH=$OH_MY_ZSH_DIR /bin/sh $OH_MY_ZSH_DIR/tools/upgrade.sh

#Update submodules
if [[ "$1" == "all" ]]; then
    git submodule foreach git pull origin master
    git commit -a -m "Submodules updated"
    git push
fi


