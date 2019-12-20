FROM ubuntu:eoan
MAINTAINER Scott Pierce <ddrscott@gmail.com>

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8
ENV LANGUAGE C.UTF-8

# Terminal settings and colors
ENV TERM xterm-256color
ENV BASE16_THEME ocean

# Configure environment
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH

# Configure Miniconda
ENV MINICONDA_VER 4.7.12
ENV MINICONDA Miniconda3-$MINICONDA_VER-Linux-x86_64.sh
ENV MINICONDA_URL https://repo.continuum.io/miniconda/$MINICONDA
ENV MINICONDA_MD5_SUM 0dba759b8ecfc8948f626fa18785e3d8

RUN apt-get update -y && \
    apt-get install -y \
    build-essential \
    openssh-server \
    sudo \
    curl \
    zsh \
    git \
    unzip \
    curl \
    tmux \
    neovim \
    nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /var/run/sshd

WORKDIR /tmp

RUN mkdir -p $CONDA_DIR && \
    curl -L $MINICONDA_URL  -o miniconda.sh && \
    echo "$MINICONDA_MD5_SUM  miniconda.sh" | md5sum -c - && \
    sh miniconda.sh -f -b -p $CONDA_DIR && \
    rm miniconda.sh && \
    $CONDA_DIR/bin/conda install --yes conda==$MINICONDA_VER && \
    $CONDA_DIR/bin/conda install --yes \
        ruby \
        numpy \
        pandas \
        nomkl \
        pygments \
        sqlparse \
        pylint \
        black \
        jedi \
        future \
        pluggy \
        autopep8 \
        flake8 \
        pycodestyle \
        pydocstyle \
        pyflakes \
        rope \
        yapf \
        parso \
        entrypoints \
        snowballstemmer \
    && /opt/conda/bin/conda clean -afy \
    && find /opt/conda/ -follow -type f -name '*.a' -delete \
    && find /opt/conda/ -follow -type f -name '*.pyc' -delete \
    && find /opt/conda/ -follow -type f -name '*.js.map' -delete

RUN curl -sSO https://dl.yarnpkg.com/debian/pubkey.gpg && \
    apt-key add pubkey.gpg && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" >> /etc/apt/sources.list.d/yarn.list && \
    apt update && \
    apt install -y yarn && \
    yarn global add neovim && \
    pip install --no-cache-dir \
       neovim \
       python-language-server\[all\]

# Setup development user (instead of root)
# These defaults are for OSX
ARG username=drvim
ARG user_id=1000
ARG group_id=1000


RUN groupadd -fg ${group_id} drvim \
    && useradd -m -l -u ${user_id} -g ${group_id} -s /bin/zsh ${username} \
    && echo 'ALL ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Do everything else as created user
USER ${username}

RUN curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o install-zsh.sh \
  && chmod +x ./install-zsh.sh \
  && zsh /tmp/install-zsh.sh --unattended

ADD ./etc /etc

RUN git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell \
   && git clone https://github.com/ddrscott/ddrscott.git ~/ddrscott \
   && cd ~/ddrscott \
   && rake links \
   && git clone https://github.com/ddrscott/config-nvim.git ~/.config/nvim \
   && echo ':PlugInstall started' \
   && nvim -E -s -u ~/.config/nvim/plugins.vim -c 'PlugInstall | q' || echo '' \
   && echo ':PlugInstall finished' \
   && echo ':CocInstall started' \
   && nvim -c 'CocInstall -sync coc-python coc-tsserver | q' \
   && echo ':CocInstall finished'

RUN echo 'export PATH=$PATH:/opt/conda/bin' >> ~/.zshrc
WORKDIR /home/${username}

RUN echo Built for: user=${username}, uid=${user_id}, gid=${group_id}

CMD ["/usr/bin/tmux"]
