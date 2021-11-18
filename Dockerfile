FROM ubuntu:21.04

ENV k8s=v1.21.0 \
    username="k8s" \
    coc_plugins="coc-yaml coc-docker coc-golang coc-json coc-php coc-python coc-sh"

## -- PACKAGES -------------------------------------------------------------
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common \
    unzip \
    dnsutils \
    net-tools \
    iproute2 \
    iputils-ping \
    less \
    jq \
    git \
    sudo \
    openssh-client \
    zsh \
    vim \
    awscli \
    python3-pip \
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
    vim +"CocInstall -sync $coc_plugins" +qa && \
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
    chmod +x /usr/local/bin/dl-github-binary

### -- CLEANUP -------------------------------------------------------------
RUN find /root -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} \;

### -- START -------------------------------------------------------------
USER ${username:-user}
WORKDIR /home/${username:-user}

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
