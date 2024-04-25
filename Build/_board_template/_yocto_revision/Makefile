.PHONY: docker build env

# Modifiy these as needed
DOCKER_IMAGE_NAME={BOARD_NAME}-iotc-{YOCTO_VERSION}-docker
BIBTAKE_IMAGE_NAME=core-image-base
LAYERS_SOURCES_PATH=layers
BUILD_FOLDER_PATH=build/
OE_INIT_PATH=./poky/oe-init-build-env

docker:
	docker build -t $(DOCKER_IMAGE_NAME) . && \
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	$(DOCKER_IMAGE_NAME) \
	--workdir=$${PWD}/$(LAYERS_SOURCES_PATH) \

build:
	docker build -t $(DOCKER_IMAGE_NAME) . && \
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	$(DOCKER_IMAGE_NAME) \
	--workdir=$${PWD}/$(LAYERS_SOURCES_PATH) \
	/bin/bash -c 'source $(OE_INIT_PATH) $(BUILD_FOLDER_PATH) && bitbake $(BIBTAKE_IMAGE_NAME) && exit'

env:
	docker build -t $(DOCKER_IMAGE_NAME) . && \
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	$(DOCKER_IMAGE_NAME) \
	--workdir=$${PWD}/$(LAYERS_SOURCES_PATH) \
	/bin/bash -c 'source $(OE_INIT_PATH) $(BUILD_FOLDER_PATH) && bash'
