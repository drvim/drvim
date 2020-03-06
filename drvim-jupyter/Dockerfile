ARG BASE_CONTAINER=drvim/drvim-base
FROM $BASE_CONTAINER
LABEL maintainer="Scott Pierce <ddrscott@gmail.com>"

ARG username=drvim

USER ${username}

RUN sudo pip install jupyterlab \
    numpy \
    pandas \
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
    parso

EXPOSE 8888

CMD ["jupyter", "lab", "--ip=0.0.0.0"]
