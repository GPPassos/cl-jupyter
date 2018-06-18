FROM ubuntu:16.04

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /root

# RUN set -ex

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-transport-https software-properties-common unzip wget \
    curl screen apt-utils make bzip2 git build-essential tmux libssl-dev \
    sbcl python3 libzmq3-dev

WORKDIR /root/
RUN curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py

RUN apt-get install libyaml-dev -y

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install jupyter

WORKDIR /root/
RUN curl -o /root/quicklisp.lisp https://beta.quicklisp.org/quicklisp.lisp
RUN if [ ! -e /root/.sbclrc ]; then sbcl --non-interactive --load quicklisp.lisp --eval '(quicklisp-quickstart:install :path "/root/quicklisp/")' --eval '(with-open-file (out "/root/.sbclrc" :direction :output) (format out "(load \"/root/quicklisp\/setup.lisp\")"))'; fi

WORKDIR /root/
RUN mkdir /root/cl-jupyter
WORKDIR /root/cl-jupyter
# git clone https://github.com/fredokun/cl-jupyter.git  # we are building from the local source
ADD clean.sh install-cl-jupyter.py cl-jupyter.lisp /root/cl-jupyter/
ADD profile /root/cl-jupyter/profile
ADD src /root/cl-jupyter/src

RUN python3 install-cl-jupyter.py
RUN sbcl --load cl-jupyter.lisp

WORKDIR /root/

CMD jupyter notebook --ip=0.0.0.0 --port=8080 --allow-root

