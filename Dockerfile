FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV K8S=v1.19.0
ENV username=k8s

## -- PACKAGES -------------------------------------------------------------
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update && apt-get install --no-install-recommends -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    unzip \
    git \
    sudo \
    openssh-client \
    zsh \
    vim \
    awscli \
    golang && \
    ## cleanup
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## -- KUBECTL -------------------------------------------------------------
RUN curl -fLo /usr/local/bin/kubectl \
    "https://storage.googleapis.com/kubernetes-release/release/$K8S/bin/linux/amd64/kubectl" && \
    chmod +x /usr/local/bin/kubectl

## -- USER -------------------------------------------------------------
RUN useradd "${username:-user}" -m && \
    usermod -aG sudo "${username:-user}" && \
    echo "${username:-user}:${userpass:-root}" | chpasswd

## -- VIM -------------------------------------------------------------
### -- settings
COPY config/vim/vimrc /etc/vim/vimrc

### -- colorscheme
RUN curl -fLo /etc/vim/colors/gruvbox.vim --create-dirs \
    https://raw.githubusercontent.com/morhetz/gruvbox/master/colors/gruvbox.vim && \
    chmod 755 /etc/vim/colors

### -- vim-plug
RUN curl -fLo /etc/vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    chmod 755 /etc/vim/autoload && \
    vim +'PlugInstall --sync' +qa

### -- language server coc.nvim
COPY config/vim/coc-settings.json /etc/vim/
RUN curl -sL install-node.now.sh/lts | bash -s -- --yes
RUN mkdir -p /etc/vim/coc && \
    vim +'CocInstall -sync coc-yaml coc-docker coc-golang coc-json coc-sh' +qa && \
    chown -R ${username:-user}: /etc/vim/coc

## -- ZSH -------------------------------------------------------------
### -- ohmyzsh
ENV ZSH="/etc/zsh/ohmyzsh"
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    chown -R ${username:-user}: "$ZSH/cache"
COPY config/zsh/zshrc "$ZSH"

### -- plugins
RUN git clone https://github.com/superbrothers/zsh-kubectl-prompt.git "$ZSH/plugins/zsh-kubectl-prompt"

RUN usermod --shell /bin/zsh "${username:-user}"

### -- TOOLS -------------------------------------------------------------
COPY scripts/functions.sh /opt
RUN source /opt/functions.sh && \
# getGithubRelease <repo> <filter_tag> <binary_name> <custom_url>
  getGithubRelease "helm/helm" "v2" "helm2" && \
  getGithubRelease "helm/helm" "v3" "helm" && \
  getGithubRelease "wercker/stern" "1" "stern" && \
  getGithubRelease "derailed/k9s" "v0" "k9s" && \
  getGithubRelease "linkerd/linkerd" "1" "linkerd" && \
  getGithubRelease "linkerd/linkerd2" "stable-2" "linkerd2" && \
  getGithubRelease "argoproj/argo-cd" "v1.8" "argocd" && \
  getGithubRelease "FairwindsOps/pluto" "v4" "pluto" && \
  getGithubRelease "vmware-tanzu/velero" "v1" "velero" && \
  getGithubRelease "terraform-docs/terraform-docs" "v0" "terraform-docs" && \
  getGithubRelease "hashicorp/terraform" "v0.13" "terraform" "https://releases.hashicorp.com/terraform/TAG/terraform_TAG_linux_amd64.zip" && \
  getGithubRelease "hashicorp/vault" "v1" "vault" "https://releases.hashicorp.com/vault/TAG/vault_TAG_linux_amd64.zip" && \
  chmod +x /usr/local/bin/*

### -- CLOUD -------------------------------------------------------------

### -- CLEANUP -------------------------------------------------------------
RUN find /root -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;

### -- START -------------------------------------------------------------
USER ${username:-user}
WORKDIR /home/${username:-user}

COPY scripts/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
