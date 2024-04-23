.PHONY: docker build env

# Modifiy these as needed
DOCKER_IMAGE_NAME=rzboardv2l-dunfell
BIBTAKE_IMAGE_NAME=avnet-core-image
BUILD_FOLDER_PATH=build/
OE_INIT_PATH=./poky/oe-init-build-env

docker:
	docker build -t $(DOCKER_IMAGE_NAME) . && \
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	$(DOCKER_IMAGE_NAME) \
	--workdir=$${PWD}

build:
	docker build -t $(DOCKER_IMAGE_NAME) . && \
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	$(DOCKER_IMAGE_NAME) \
	--workdir=$${PWD} \
	/bin/bash -c 'source $(OE_INIT_PATH) $(BUILD_FOLDER_PATH) && bitbake $(BIBTAKE_IMAGE_NAME) && exit'

env:
	docker build -t $(DOCKER_IMAGE_NAME) . && \
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	$(DOCKER_IMAGE_NAME) \
	--workdir=$${PWD} \
	/bin/bash -c 'source $(OE_INIT_PATH) $(BUILD_FOLDER_PATH) && bash'
