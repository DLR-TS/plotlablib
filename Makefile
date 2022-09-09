
SHELL:=/bin/bash

.DEFAULT_GOAL := all

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

.PHONY: help  
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

PLOTLABLIB_PROJECT="plotlablib"
PLOTLABLIB_VERSION="latest"
PLOTLABLIB_TAG="${PLOTLABLIB_PROJECT}:${PLOTLABLIB_VERSION}"

.PHONY: set_env 
set_env: 
	$(eval PROJECT := ${PLOTLABLIB_PROJECT}) 
	$(eval TAG := ${PLOTLABLIB_TAG})

.PHONY: all 
all: build_external build

.PHONY: build 
build: all

.PHONY: build
build: set_env clean
	rm -rf "${ROOT_DIR}/${PROJECT}/build"
	make build_external
	docker build --network host \
                 --tag $(shell echo ${TAG} | tr A-Z a-z) \
                 --build-arg PROJECT=${PROJECT} .
	docker cp $$(docker create --rm $(shell echo ${TAG} | tr A-Z a-z)):/tmp/${PROJECT}/${PROJECT}/build "${ROOT_DIR}/${PROJECT}"

.PHONY: clean 
clean: set_env clean_external
	rm -rf "${ROOT_DIR}/${PROJECT}/build"
	docker rm $$(docker ps -a -q --filter "ancestor=${TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${PROJECT}) 2> /dev/null || true

.PHONY: build_external
build_external:
	cd plotlablib/external && \
    make

.PHONY: clean_external
clean_external:
	cd plotlablib/external && \
    make clean

.PHONY: docker_clean 
docker_clean:
	docker rmi $$(docker images --filter "dangling=true" -q) --force
