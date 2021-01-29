# k8s-workstation

An immutable Docker environment that I use as an experiment when working with Kubernetes and Golang.
I started this project because I regularly switch between Windows and Linux distros. Running the environment in Docker saves me time re-installing and configuring all the VIM and ZSH plugins.

* getGithubRelease script is used to fetch binaries of some commonly used tools.

- helm2/helm3
- stern
- k9s
- linkerd/linkerd2
- argo-cd
- pluto
- velero
- terraform
- terraform-docs
- vault

## Getting Started

* to build
```
docker build . -t k8s-workstation
```

* to run with local volumes
```
docker run \
  -v ~/k8s-workstation:/home/dev \
  -v ~/go:/home/dev/go
  -e ZSH_THEME=gruvbox
  -p 8080:8080
  -ti k8s-workstation
```

### Golang autocompletion
For the golang autocompletion to work, some golang binaries are required. 

* open vim and run `:GoInstallBinaries` to install binaries in $GOPATH (/home/dev/go).

### kubectl port-forward
To access port-forwards on host, make sure to bind on 0.0.0.0 address.
Also make sure that the port is exposed when running the k8s-workstation container.

* `kubectl port-forward --address 0.0.0.0 svc/argocd-server -n argocd 8080:443`

## Todo
- Retrieve secrets like kubeconfig from Vault on container start

## Limitations
- No docker in docker
- Image size large due to prepacking multiple tools


