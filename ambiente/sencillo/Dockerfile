FROM ubuntu:latest
# FROM mechanicofthesequence:base
MAINTAINER Kenneth Bentley "mechanicofthesequence@gmail.com"

# TODO: commit this to mechanicofthesequence/base

# this is a direct ripoff of boot2docker...
ENV KERNEL_VERSION  3.14.1
ENV AUFS_BRANCH     aufs3.14

RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install build-essential \
                    curl \
                    wget \
                    git-remote-gcrypt \
                    python -y
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /depot_tools
ENV PATH $PATH:/depot_tools

RUN git config --global user.email "mechanicofthesequence@gmail.com"
RUN git config --global user.name "flames of love"
# EACH REPO HERE
RUN git clone https://github.com/joyent/node.git /opt/node
RUN cd /opt/node && \
    git checkout v0.10.28 && \
    ./configure && \
    make -j8 install
# RUN mkdir /opt/Blueshift && \
#     cd /opt/Blueshift && \
#     repo init -u https://github.com/duralog/Blueshift.git \
#       --repo-url https://github.com/duralog/repo.git \
#       --no-repo-verify --depth=1
# RUN cd /opt/Blueshift && repo sync

ADD src /opt/Blueshift/src