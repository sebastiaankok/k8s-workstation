#!/bin/bash

if [ -z "$ZSH_THEME" ]; then
  export ZSH_THEME=kafeitu
else
  export $ZSH_THEME
fi

if [ ! -f ~/.zshrc ] ; then
  echo "source $ZSH/zshrc" >> ~/.zshrc
fi

## Start ZSH shell
/bin/zsh
