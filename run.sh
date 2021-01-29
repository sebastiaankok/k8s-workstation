#!/bin/bash
image="k8s-workstation"

# These dirs get mounted in container
homedir="$HOME/k8s-workstation"
godir="$HOME/go"

# zsh theme
theme="gruvbox"

# Username that is used in Docker image
username="dev"

if [ ! -d "$homedir" ] ; then echo "Dir doesn't exist: $homedir" ; exit 1 ; fi
if [ ! -d "$godir" ] ; then echo "Dir doesn't exist: $godir" ; exit 1 ; fi

# Find running containers
ps="$(docker ps | grep "$image" | grep -v "CONTAINER")"

# If multiple containers are running, exit
if [ "$( wc -l <<< "$ps")" -gt 1 ]; then
  echo "Multiple $image containers running:"
  echo "$ps" && exit 1
# If only one container is running, exec
elif [ -n "$ps" ] && [ "$( wc -l <<< "$ps")" -eq 1 ] ; then
  echo "Exec into container $(awk '{print $1 " " $2}' <<< $ps)"
  docker exec -ti "$(awk '{print $1}' <<< $ps)" /bin/zsh 
# No containers running, start new one 
else
  docker run \
    -v $homedir:/home/$username \
    -v $godir:/home/$username/go \
    -e ZSH_THEME=$theme \
    -p 8080:8080
    -ti "$image"
fi
