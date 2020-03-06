ARG BASE_CONTAINER=ubuntu:eoan
FROM $BASE_CONTAINER

LABEL maintainer="Scott Pierce <ddrscott@gmail.com>"

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8

# Terminal settings and colors
ENV TERM xterm-256color
ENV BASE16_THEME ocean
ENV SHELL zsh

RUN apt-get update -y && \
    apt-get install -y \
    build-essential   \
    openssh-server    \
    silversearcher-ag \
    sudo              \
    curl              \
    zsh               \
    git               \
    rsync             \
    htop              \
    unzip             \
    curl              \
    tmux              \
    neovim            \
    nodejs            \
    python3-pip       \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/run/sshd

WORKDIR /tmp

RUN curl -sSO https://dl.yarnpkg.com/debian/pubkey.gpg && \
    apt-key add pubkey.gpg && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" >> /etc/apt/sources.list.d/yarn.list && \
    apt update && \
    apt install -y yarn && \
    yarn global add neovim

# Setup development user (instead of root)
# These defaults are for OSX
ARG username=drvim
ARG user_id=1000
ARG group_id=1000


RUN groupadd -fg ${group_id} drvim \
    && useradd -m -l -u ${user_id} -g ${group_id} -s /bin/zsh ${username} \
    && echo 'ALL ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && ln -sf /usr/bin/python3 /usr/bin/python \
    && ln -sf /usr/bin/pip3 /usr/bin/pip

# Do everything else as created user
USER ${username}

RUN curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o install-zsh.sh \
  && chmod +x ./install-zsh.sh \
  && zsh /tmp/install-zsh.sh --unattended

RUN git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell \
   && git clone https://github.com/ddrscott/ddrscott.git ~/ddrscott \
   && cd ~/ddrscott          \
   && git checkout ba3f0428e \
   && ./install.sh           \
   && git clone https://github.com/ddrscott/config-nvim.git ~/.config/nvim \
   && echo ':PlugInstall started'  \
   && nvim -E -s -u ~/.config/nvim/plugins.vim -c 'PlugInstall | q' || echo '' \
   && echo ':PlugInstall finished' \
   && echo ':CocInstall started'   \
   && nvim -c 'CocInstall -sync coc-python coc-tsserver | q' \
   && echo ':CocInstall finished'

RUN echo 'export PATH=/opt/conda/bin:$PATH' >> ~/.zshrc
WORKDIR /home/${username}

RUN echo Built for: user=${username}, uid=${user_id}, gid=${group_id}

CMD ["/usr/bin/tmux"]
