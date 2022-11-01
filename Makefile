
SHELL:=/bin/bash

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
MAKEFILE_PATH:=$(shell dirname "$(abspath "$(lastword $(MAKEFILE_LIST)"))")

.DEFAULT_GOAL := all

include make_gadgets/make_gadgets.mk
include make_gadgets/docker/docker-tools.mk
include plotlablib.mk

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=


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
		--tag ${PROJECT}:${TAG} \
                 --build-arg PROJECT=${PROJECT} .
	docker cp $$(docker create --rm ${PROJECT}:${TAG}):/tmp/${PROJECT}/${PROJECT}/build "${ROOT_DIR}/${PROJECT}"

.PHONY: clean 
clean: set_env clean_external 
	rm -rf "${ROOT_DIR}/${PROJECT}/build"
	docker rm $$(docker ps -a -q --filter "ancestor=:${PROJECT}:${TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${PROJECT}:${TAG}) --force 2> /dev/null || true

.PHONY: build_external
build_external:
	cd plotlablib/external && \
    make

.PHONY: clean_external
clean_external:
	cd plotlablib/external && \
    make clean
