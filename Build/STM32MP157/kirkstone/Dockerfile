FROM crops/poky:ubuntu-22.04

USER root
RUN apt-get update && \
    apt-get install -y \
    bsdmainutils \
    libgmp-dev \
    libmpc-dev \
    libssl-dev \
    python3-pip

USER usersetup

