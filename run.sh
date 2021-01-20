#!/bin/bash

image="k8s-workstation"

# Find running containers
ps="$(docker ps | grep "$image" | grep -v "CONTAINER")"

# If multiple containers are running, exit
if [ "$( wc -l <<< "$ps")" -gt 1 ]; then
  echo "Multiple $image containers running:"
  echo "$ps" && exit 0
# If only one container is running, exec
elif [ -n "$ps" ] && [ "$( wc -l <<< "$ps")" -eq 1 ] ; then
  echo "Exec into container $(awk '{print $1 " " $2}' <<< $ps)"
  docker exec -ti "$(awk '{print $1}' <<< $ps)" /bin/zsh 
# No containers running, start new one 
else
  docker run \
    -v ~/k8s-workstation:/home/k8s \
    -v ~/go:/home/k8s/go \
    -e ZSH_THEME=kafeitu \
    -ti "$image"
fi
