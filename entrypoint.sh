#!/bin/bash

if [ -z "$ZSH_THEME" ]; then
  export ZSH_THEME=gruvbox
else
  export ZSH_THEME="$ZSH_THEME"
fi

if [ ! -f ~/.zshrc ] ; then
  echo "source $ZSH/zshrc" >> ~/.zshrc
fi

## -- Create golang directory
if [ ! -d ~/go ] ; then
  mkdir ~/go
fi

## -- Setup bin directory which included in PATH variable
if [ ! -d ~/bin ] ; then
  mkdir ~/bin
fi

## -- Download script that helps installing various k8s tools.
if [ ! -f ~/bin/install-k8s-tools.sh ]; then
  curl -s https://raw.githubusercontent.com/sebastiaankok/dl-github-binary/main/examples/install-k8s-tools.sh > ~/bin/install-k8s-tools.sh && chmod +x ~/bin/install-k8s-tools.sh
  echo "Run helper script ~/bin/install-k8s-tools.sh to install various k8s cli tools. You can also edit this files to add your own!"
fi 

## Start ZSH shell
/bin/zsh
