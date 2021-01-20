#!/bin/bash

getGithubRelease() {
  # Get tag from release URL
  local repo="$1"
  local desired_version="$2"
  local desired_name="$3"
  local custom_url="$4"
  local repo_html="$(curl https://github.com/$repo/releases -Ls)"

  tags=$(grep -oP "(?<=href=./$repo/releases/tag/).*(?=\")" <<< "$repo_html")

  if [ -n "$desired_version" ]; then
    target_tag=$(grep "^$desired_version" <<< "$tags" | head -n 1)
  else
    target_tag="$( head -n 1 <<< "$tags" )"
  fi

  if [ -n "$custom_url" ] ; then
    download_url="$( sed "s/TAG/$target_tag/g" <<< "$4")"
    if ! curl -f -s $download_url > /dev/null ; then
      clean_target_tag="$( tr -d 'v' <<< $target_tag )"
      download_url="$( sed "s/TAG/$clean_target_tag/g" <<< "$4")"
    fi
  else
    download_url=$(grep -oPi "(?<=href=\").*$target_tag.*linux.*amd64.*\.tar\.gz(?=\")" <<< "$repo_html" | head -n 1)
    if [ -z "$download_url" ] ; then
      download_url=$(grep -oPi "(?<=href=\").*$target_tag.*linux.*amd64(?=\")" <<< "$repo_html" | head -n 1)
    fi
    if [ -z "$download_url" ] ; then
      download_url=$(grep -oPi "(?<=href=\").*$target_tag.*gz(?=\")" <<< "$repo_html" | head -n 1)
    fi
  fi

  cd /tmp
  if grep -q '^https://' <<< $download_url ; then
    echo "Fetching $download_url"
    curl -LO "$download_url"
  else 
    echo "Fetching https://github.com/$download_url"
    curl -LO "https://github.com/$download_url"
  fi 

  dl_file="$(find /tmp -type f)"
  extract "$dl_file" || mv "$dl_file" "/usr/local/bin/$desired_name" 
  rm -f "$dl_file"

  binary_files=$(find /tmp -type f -exec grep -IL . "{}" \;)

  ## Check which binary matches the desired name, otherwise mv to /usr/local/bin
  for i in $binary_files ; do
    if grep -qi "$desired_name" <<< "$(basename $i)" ; then
      if [ ! -f "/usr/local/bin/$desired_name" ] ; then
        mv "$i" "/usr/local/bin/$desired_name"
      else 
        echo "/usr/local/bin/$desired_name already exists"
        exit 1
      fi
    elif grep -qi "$(basename $i)" <<< "$desired_name" ; then
      if [ ! -f "/usr/local/bin/$desired_name" ] ; then
        mv "$i" "/usr/local/bin/$desired_name"
      else 
        echo "/usr/local/bin/$desired_name already exists"
        exit 1
      fi
    else 
      if [ ! -f "/usr/local/bin/$(basename $i)" ] ; then
        mv "$i" "/usr/local/bin"
      else
        echo "/usr/local/bin/$(basename $i) already exists"
        exit 1
      fi
    fi
  done 

  rm -rf /tmp/*

  echo "Installed $desired_name"

}

extract () {
  for arg in $@ ; do
    if [ -f $arg ] ; then
      case $arg in
        *.tar.bz2)  tar xjf $arg      ;;
        *.tar.gz)   tar xzf $arg      ;;
        *.bz2)      bunzip2 $arg      ;;
        *.gz)       gunzip $arg       ;;
        *.tar)      tar xf $arg       ;;
        *.tbz2)     tar xjf $arg      ;;
        *.tgz)      tar xzf $arg      ;;
        *.zip)      unzip $arg        ;;
        *.Z)        uncompress $arg   ;;
        *.rar)      rar x $arg        ;;  # 'rar' must to be installed
        *.jar)      jar -xvf $arg     ;;  # 'jdk' must to be installed
        *)          return 1 ;;
      esac
    else
        echo "'$arg' is not a valid file"
    fi
  done
}
