FROM crops/poky:ubuntu-20.04

USER root
RUN apt-get update && \
    apt-get install -y \
    gawk wget git-core diffstat unzip texinfo gcc-multilib \
    build-essential chrpath socat cpio python python3 python3-pip python3-pexpect \
    xz-utils debianutils iputils-ping libsdl1.2-dev xterm p7zip-full libyaml-dev \
    rsync curl locales bash-completion libpcre3-dev

USER usersetup
