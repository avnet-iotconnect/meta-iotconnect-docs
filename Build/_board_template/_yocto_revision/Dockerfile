# Select version of CROPS to use, for example ubuntu-22.04 for kirkstone, ubuntu-20.04 for dunfell 
FROM crops/poky:ubuntu-22.04

# Add extra packages to the image if needed
USER root
RUN apt-get update && \
    apt-get install -y \
    bsdmainutils \
    libgmp-dev \
    libmpc-dev \
    libssl-dev \
    python3-pip


# Return back to crops user, make sure this command is executed last.
USER usersetup