FROM ubuntu:20.04

ENV k8s=v1.19.0 \
    terraform=v0.13 \
    argocd=v1.8 \
    username=dev

## -- PACKAGES -------------------------------------------------------------
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    unzip \
    less \
    jq \
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
    "https://storage.googleapis.com/kubernetes-release/release/$k8s/bin/linux/amd64/kubectl" && \
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

### -- Custom theme based on gruvbox and kafeitu
COPY config/zsh/gruvbox.zsh-theme "$ZSH/themes"

### -- plugins
RUN git clone https://github.com/superbrothers/zsh-kubectl-prompt.git "$ZSH/plugins/zsh-kubectl-prompt"

RUN usermod --shell /bin/zsh "${username:-user}"

### -- TOOLS -------------------------------------------------------------
RUN curl -fLo /usr/local/bin/dl-github-binary \
    https://raw.githubusercontent.com/sebastiaankok/dl-github-binary/main/dl-github-binary.sh && \
    chmod +x /usr/local/bin/dl-github-binary && \
    ### -- Download binaries && \
    dl-github-binary --repo helm/helm --filter v2 --save-as helm2 --dir /usr/local/bin && \
    dl-github-binary --repo helm/helm --filter v3 --save-as helm --dir /usr/local/bin && \
    dl-github-binary --repo wercker/stern --filter 1 --save-as stern --dir /usr/local/bin && \
    dl-github-binary --repo derailed/k9s --filter v0 --save-as k9s --dir /usr/local/bin && \
    dl-github-binary --repo linkerd/linkerd --filter 1 --save-as linkerd --dir /usr/local/bin && \
    dl-github-binary --repo linkerd/linkerd2 --filter stable-2 --save-as linkerd2 --dir /usr/local/bin && \
    dl-github-binary --repo argoproj/argo-cd --filter ${argocd} --save-as argocd --dir /usr/local/bin && \
    dl-github-binary --repo FairwindsOps/pluto --filter v4 --save-as pluto --dir /usr/local/bin && \
    dl-github-binary --repo vmware-tanzu/velero --filter v1 --save-as velero --dir /usr/local/bin && \
    dl-github-binary --repo terraform-docs/terraform-docs --filter v0 --save-as terraform-docs --dir /usr/local/bin && \
    dl-github-binary --repo hashicorp/terraform --filter ${terraform} --save-as terraform --dir /usr/local/bin \
    -c "https://releases.hashicorp.com/terraform/GITHUB_TAG/terraform_GITHUB_TAG_linux_amd64.zip" && \
    dl-github-binary --repo hashicorp/vault --filter v1 --save-as vault --dir /usr/local/bin \
    -c "https://releases.hashicorp.com/vault/GITHUB_TAG/vault_GITHUB_TAG_linux_amd64.zip" && \
    chmod +x /usr/local/bin/*

### -- CLOUD -------------------------------------------------------------

### -- CLEANUP -------------------------------------------------------------
RUN find /root -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;

### -- START -------------------------------------------------------------
USER ${username:-user}
WORKDIR /home/${username:-user}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
