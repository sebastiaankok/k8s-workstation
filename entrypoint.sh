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
  curl -s https://raw.githubusercontent.com/sebastiaankok/dl-github-binary/main/examples/install-k8s-tools.sh \
	  > ~/bin/install-k8s-tools.sh \
	  && chmod +x ~/bin/install-k8s-tools.sh
  echo "Run helper script ~/bin/install-k8s-tools.sh to install various k8s cli tools. You can also edit this files to add your own!"
fi

## -- Bitwarden fetch SSH key
if [ "$bitwarden_enabled" -ne 0 ] ; then
  if [ -z "$bitwarden_email" ] ; then
    echo "please set bitwarden_email variable"
    exit 1
  fi

  if [ ! -d ~/.ssh ] ; then
    mkdir ~/.ssh
  fi

  echo "[info] - Login into Bitwarden with email: $bitwarden_email"
  ## -- Try loggin in
  export BW_SESSION=$(/usr/local/bin/bw login "$bitwarden_email" --method 0 --raw)

  ## -- Try to unlock
  if [ -z "$BW_SESSION" ] ; then
    export BW_SESSION=$(/usr/local/bin/bw unlock --raw)
  fi

  ## -- Fetch SSH key and save to file
  if [ -n "$BW_SESSION" ] ; then
    echo -e "\n[info] - Login successful"
    if /usr/local/bin/bw sync > /dev/null 2>&1 ; then
      echo "[info] - Synced Bitwarden vault"
    fi
    if [ ! -f ~/.ssh/id_rsa ] ; then
      echo "[info] - Fetching ssh private key"
      /usr/local/bin/bw get notes ssh-priv > ~/.ssh/id_rsa
      echo "" >> ~/.ssh/id_rsa
      chmod 600 ~/.ssh/id_rsa
    fi
    if [ ! -f ~/.ssh/id_rsa.pub ] ; then
      echo "[info] - Fetching ssh public key"
      /usr/local/bin/bw get notes ssh-pub > ~/.ssh/id_rsa.pub
      echo "" >> ~/.ssh/id_rsa.pub
      chmod 600 ~/.ssh/id_rsa.pub
    fi

    ## -- Sign out to clean up token
    /usr/local/bin/bw logout > /dev/null 2>&1
  else
    echo "[error] - Bitwarden login failed"
  fi
fi

## -- Cleanup autocomplete files
rm ~/.zcompdump-* > /dev/null 2>&1

## Start ZSH shell
/bin/zsh
