docker:
	docker build -t yocto-stm32mp17-kirkstone . && \
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	yocto-stm32mp17-kirkstone \
	--workdir=$${PWD}


build:
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	yocto-stm32mp17-kirkstone \
	--workdir=$${PWD} \
	/bin/bash -c 'source ./layers/openembedded-core/oe-init-build-env ./build-openstlinuxweston-stm32mp1/ && bitbake st-image-weston && exit'


env:
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	yocto-stm32mp17-kirkstone \
	--workdir=$${PWD} \
	/bin/bash -c 'source ./layers/openembedded-core/oe-init-build-env build-openstlinuxweston-stm32mp1/ && bash'


STM32_PROGRAMMER_PATH := $(shell dirname "$(shell find / -type f -name STM32_Programmer_CLI -print -quit 2>/dev/null)")
export PATH := $(STM32_PROGRAMMER_PATH):$(PATH)

flash:	
	cd ./build-openstlinuxweston-stm32mp1/tmp-glibc/deploy/images/stm32mp1/ && STM32_Programmer_CLI -c port=usb1 -w flashlayout_st-image-weston/trusted/FlashLayout_sdcard_stm32mp157c-dk2-trusted.tsv && cd -
