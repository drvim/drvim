#!/bin/sh

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LANGUAGE=C.UTF-8

# Terminal settings and colors
export TERM=xterm-256color
export BASE16_THEME=ocean

# Configure environment
export CONDA_DIR=/opt/conda
export PATH=$CONDA_DIR/bin:$PATH

# Configure Miniconda
export MINICONDA_VER=4.7.12
export MINICONDA=Miniconda3-$MINICONDA_VER-Linux-x86_64.sh
export MINICONDA_URL=https://repo.continuum.io/miniconda/$MINICONDA
export MINICONDA_MD5_SUM=0dba759b8ecfc8948f626fa18785e3d8


apt-get update -y && \
    apt-get install -y \
    build-essential \
    openssh-server \
    sudo \
    curl \
    zsh \
    git \
    rsync \
    htop \
    unzip \
    curl \
    tmux \
    neovim \
    nodejs \
    ruby

cd /tmp

mkdir -p $CONDA_DIR && \
    curl -L $MINICONDA_URL  -o miniconda.sh && \
    echo "$MINICONDA_MD5_SUM  miniconda.sh" | md5sum -c - && \
    sh miniconda.sh -f -b -p $CONDA_DIR && \
    rm miniconda.sh && \
    $CONDA_DIR/bin/conda install --yes conda==$MINICONDA_VER && \
    $CONDA_DIR/bin/conda install --yes \
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

curl -sSO https://dl.yarnpkg.com/debian/pubkey.gpg && \
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
username=spierce
user_id=1000
group_id=1000


groupadd -fg ${group_id} drvim \
    && useradd -m -l -u ${user_id} -g ${group_id} -s /bin/zsh ${username} \
    && echo 'ALL ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Do everything else as created user
su ${username}

curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o install-zsh.sh \
  && chmod +x ./install-zsh.sh \
  && zsh /tmp/install-zsh.sh --unattended

git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell \
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

echo 'export PATH=/opt/conda/bin:$PATH' >> ~/.zshrc
