.PHONY: docker build env

docker:
	docker build -t yocto-rzboard . && \
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	yocto-rzboard \
	--workdir=$${PWD}


build:
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	yocto-rzboard \
	--workdir=$${PWD}/yocto_rzboard \
	/bin/bash -c 'source poky/oe-init-build-env build/ && bitbake avnet-core-image && exit'


env:
	docker run --rm -it \
	--security-opt seccomp=unconfined \
	-v  $${PWD}:$${PWD}:Z \
	-v ~/.gitconfig:/etc/gitconfig:Z \
	yocto-rzboard \
	--workdir=$${PWD}/yocto_rzboard \
	/bin/bash -c 'source poky/oe-init-build-env build/ && bash'
