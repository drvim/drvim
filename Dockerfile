FROM alpine:latest
MAINTAINER Scott Pierce <ddrscott@gmail.com>

RUN apk add --update \
  zsh \
  git \
  alpine-sdk build-base\
  libtool \
  automake \
  m4 \
  autoconf \
  linux-headers \
  unzip \
  ncurses ncurses-dev ncurses-libs ncurses-terminfo \
  clang \
  xz \
  curl \
  make \
  cmake \
  tmux \
  gettext gettext-dev \
  python2-dev \
  python3 python3-dev \
  py-pip \
  go \
  rust \
  crystal \
  nodejs yarn \
  ruby ruby-dev ruby-nokogiri \
  && rm -rf /var/cache/apk/*

WORKDIR /tmp
ENV CMAKE_EXTRA_FLAGS=-DENABLE_JEMALLOC=OFF

RUN git clone https://github.com/neovim/libtermkey.git && \
  cd libtermkey && \
  make && \
  make install && \
  cd ../ && rm -rf libtermkey

RUN git clone https://github.com/neovim/libvterm.git && \
  cd libvterm && \
  make && \
  make install && \
  cd ../ && rm -rf libvterm

RUN git clone https://github.com/neovim/unibilium.git && \
  cd unibilium && \
  make && \
  make install && \
  cd ../ && rm -rf unibilium

RUN  git clone https://github.com/neovim/neovim.git && \
  cd neovim && \
  make CMAKE_BUILD_TYPE=Release && \
  make install && \
  cd ../ && rm -rf neovim

RUN gem install -N rake rdoc neovim solargraph
RUN yarn global add neovim && \
    pip3 install \
       neovim \
       pygments \
       sqlparse \
       pylint \
       python-language-server\[all\] \
       black

# Setup with colors and UTF-8
ENV TERM xterm-256color
ENV LC_ALL en_US.utf-8
ENV LANG en_US.utf-8
ENV BASE16_THEME ocean

# Setup development user (instead of root)
# These defaults are for OSX
ARG username=drvim
ARG user_id=1000
ARG group_id=1000

RUN adduser -S ${username} -u ${user_id} -g ${group_id} -s /bin/zsh \
    && echo 'ALL ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Do everything else as created user
USER ${username}

RUN curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o install-zsh.sh \
  && chmod +x ./install-zsh.sh \
  && zsh /tmp/install-zsh.sh --unattended

ADD ./nvim/plugins-only.vim /tmp
ADD ./etc /etc

RUN git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell \
   && git clone https://github.com/ddrscott/ddrscott.git ~/ddrscott \
   && cd ~/ddrscott \
   && rake links \
   && git clone https://github.com/ddrscott/config-nvim.git ~/.config/nvim \
   && nvim -E -s -u /tmp/plugins-only.vim -c 'PlugInstall | qall' || echo 'Vim Plugins Installed'

RUN nvim -c 'CocInstall -sync coc-python coc-tsserver coc-solargraph | q' && echo 'Coc Support Installed'

WORKDIR /home/${username}

RUN echo Built for: user=${username}, uid=${user_id}, gid=${group_id}
CMD ["/usr/bin/tmux"]
