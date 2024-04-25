.PHONY: docker build env

# Modifiy these as needed
DOCKER_IMAGE_NAME=stm32m157-iotc-kirkstone-docker
BITBAKE_IMAGE_NAME=st-image-weston
LAYERS_SOURCES_PATH=layers
BUILD_FOLDER_PATH=build-openstlinuxweston-stm32mp1
OE_INIT_PATH=./openembedded-core/oe-init-build-env

docker:
	docker build -t $(DOCKER_IMAGE_NAME) . && \
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	$(DOCKER_IMAGE_NAME) \
	--workdir=$${PWD}/$(LAYERS_SOURCES_PATH)

build:
	docker build -t $(DOCKER_IMAGE_NAME) . && \
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	$(DOCKER_IMAGE_NAME) \
	--workdir=$${PWD} \
	/bin/bash -c 'source $(LAYERS_SOURCES_PATH)/$(OE_INIT_PATH) $(BUILD_FOLDER_PATH) && bitbake $(BITBAKE_IMAGE_NAME) && exit'

env:
	docker build -t $(DOCKER_IMAGE_NAME) . && \
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	$(DOCKER_IMAGE_NAME) \
	--workdir=$${PWD}/$(LAYERS_SOURCES_PATH) \
	/bin/bash -c 'source $(OE_INIT_PATH) $(BUILD_FOLDER_PATH) && bash'

STM32_PROGRAMMER_PATH := $(shell dirname "$(shell find / -type f -name STM32_Programmer_CLI -print -quit 2>/dev/null)")
export PATH := $(STM32_PROGRAMMER_PATH):$(PATH)

flash:	
	cd ./build-openstlinuxweston-stm32mp1/tmp-glibc/deploy/images/stm32mp1/ && STM32_Programmer_CLI -c port=usb1 -w flashlayout_st-image-weston/trusted/FlashLayout_sdcard_stm32mp157c-dk2-trusted.tsv && cd -
