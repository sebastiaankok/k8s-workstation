# k8s-workstation

I started this project to be able to easily switch between different operating systems while maintaining a consistent environment for working with Linux, Kubernetes and programming languages. The Docker image uses an Ubuntu base image in which zsh and vim plugins are configured and installed. In addition, some scripts are added to download various CLI tools.

![gif](images/k8s-workstation.gif)

## Getting Started

* build the container
```bash
docker build . -t k8s-workstation
```

* create directory that is used as local volume
```bash
mkdir ~/k8s-workstation
```

* to run the container
```bash
 docker run \
    -v ~/k8s-workstation:/home/k8s \
    -e ZSH_THEME=gruvbox \
    -ti k8s-workstation
```

### Startup script

This script can be used to easily start the k8s-workstation container. When the script is ran while a container is running, the script will exec into it.

#### Bitwarden SSH secrets

Enable Bitwarden to fetch a SSH key from Bitwarden by changing the bitwarden_enabled value to 1 and setting the bitwarden_email variable. It's also possible to enable bitwarden_tmpfs_ssh, which will mount a tmpfs on `~/.ssh` to make sure the SSH key is not persisted to disk.

The Bitwarden script can be found at entrypoint.sh and is executed on container start.
It expects that the following data can be retrieved:

* Secret Note : name - ssh-priv
* Secret Note : name - ssh-pub

```bash
#!/bin/bash

image="k8s-workstation"
homedir="$HOME/k8s-workstation"
theme="gruvbox"

## -- Bitwarden settings
bitwarden_enabled=0 ## -- Set to 1 to enable Bitwarden script in entrypoint
bitwarden_email="" ## -- Configure Bitwarden email
bitwarden_tmpfs_ssh=0 ## -- Set to 1 to enable tmpfs mount on ~/.ssh

if [ $bitwarden_tmpfs_ssh -ne 0 ]; then
  tmpfs_ssh='--tmpfs=/home/k8s/.ssh:uid=1000,gid=1000'
fi

if [ ! -d "$homedir" ] ; then echo "dir doesn't exist: $homedir" ; exit 1 ; fi

## -- Find running containers
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
  echo "[info] - Starting new k8s-workstation container ..."
  ## Run container and expose ports 8080-8085 (for exposing services) and port 8250 (vault)
  docker run \
     -v "$homedir":/home/k8s \
     $tmpfs_ssh \
     -e bitwarden_enabled="$bitwarden_enabled" \
     -e bitwarden_email="$bitwarden_email" \
     -e ZSH_THEME="$theme" \
     -p 8080-8085:8080-8085 \
     -p 8250:8250 \
     -ti $image
fi
```

### Exposing services from container

#### Windows WSL2

Make sure to run the container with --publish (-p) and a set of ports.
Also make sure the service uses listen address 0.0.0.0

* kubectl example:
`kubectl port-forward pods/podinfo-7cd6c96d57-ctlpn 8080:8080 --address 0.0.0.0`

* vault example:
`vault login -method=oidc listenaddress=0.0.0.0`

### vim Autocompletion
#### Golang
* open vim and run `:GoInstallBinaries` to install binaries in $GOPATH (/home/k8s/go).

### Python
* pip install jedi
