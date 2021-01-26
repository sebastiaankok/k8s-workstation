#!/bin/bash

if [ -z "$ZSH_THEME" ]; then
  export ZSH_THEME=gruvbox
else
  export ZSH_THEME="$ZSH_THEME"
fi

if [ ! -f ~/.zshrc ] ; then
  echo "source $ZSH/zshrc" >> ~/.zshrc
fi

## Start ZSH shell
/bin/zsh
