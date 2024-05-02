.PHONY: docker build env

# Modifiy these as needed
DOCKER_IMAGE_NAME=sama5d2-iotc-kirkstone-docker
BIBTAKE_IMAGE_NAME=core-image-minimal
LAYERS_SOURCES_PATH=
BUILD_FOLDER_PATH=build-microchip/
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
	/bin/bash -c 'source $(OE_INIT_PATH) $(BUILD_FOLDER_PATH) && MACHINE=sama5d2-xplained-sd bitbake $(BIBTAKE_IMAGE_NAME) && exit'

env:
	docker build -t $(DOCKER_IMAGE_NAME) . && \
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	$(DOCKER_IMAGE_NAME) \
	--workdir=$${PWD}/$(LAYERS_SOURCES_PATH) \
	/bin/bash -c 'source $(OE_INIT_PATH) $(BUILD_FOLDER_PATH) && bash'
