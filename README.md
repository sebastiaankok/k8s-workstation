# k8s-workstation

An immutable Docker environment that I use when working with Kubernetes and Golang.
It contains several vim and zsh plugins to improve development experience.

## Getting Started

* to build
```
docker build . -t k8s-workstation
```

* to run with local volumes or use run.sh 
```
docker run \
  -v ~/k8s-workstation:/home/k8s \
  -v ~/go:/home/k8s/go \
  -ti k8s-workstation
```

### Golang autocompletion
For the golang autocompletion to work, some golang binaries are required. 

* open vim and run `:GoInstallBinaries` to install binaries in $GOPATH (/home/k8s/go)
