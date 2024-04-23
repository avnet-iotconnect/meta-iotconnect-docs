FROM crops/poky:ubuntu-20.04

USER root
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    bash-completion \
    build-essential \
    chrpath \
    cpio \
    curl \
    debianutils \
    diffstat \
    gawk \
    gcc-multilib \
    git-core \
    iputils-ping \
    libpcre3-dev \
    libsdl1.2-dev \
    libyaml-dev \
    locales \
    p7zip-full \
    python \
    python3 \
    python3-pexpect \
    python3-pip \
    rsync \
    socat \
    texinfo \
    unzip \
    wget \
    xterm \
    xz-utils

USER usersetup
