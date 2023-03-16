
SHELL:=/bin/bash

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
MAKEFILE_PATH:=$(shell dirname "$(abspath "$(lastword $(MAKEFILE_LIST)"))")

.DEFAULT_GOAL := all

$(shell git submodule update --init --recursive --depth 1 plotlablib/external/*)

include plotlablib.mk

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

DOCKER_ARCHIVE="/var/tmp/plotlablib.tar"

.PHONY: save_docker_image
save_docker_image:
	docker save -o "${DOCKER_ARCHIVE}" ${PLOTLABLIB_PROJECT}:${PLOTLABLIB_TAG} 2>/dev/null || true

.PHONY: load_docker_image
load_docker_image:
	@docker load --input "${DOCKER_ARCHIVE}" 2>/dev/null || true

.PHONY: set_env 
set_env: 
	$(eval PROJECT := ${PLOTLABLIB_PROJECT}) 
	$(eval TAG := ${PLOTLABLIB_TAG})

.PHONY: all 
all: load_docker_image build_external build save_docker_image

.PHONY: build 
build: all

.PHONY: build
build: set_env clean ## Build plotlablib
	rm -rf "${ROOT_DIR}/${PROJECT}/build"
	make build_external
	docker build --network host \
		--tag ${PROJECT}:${TAG} \
                 --build-arg PROJECT=${PROJECT} .
	docker cp $$(docker create --rm ${PROJECT}:${TAG}):/tmp/${PROJECT}/${PROJECT}/build "${ROOT_DIR}/${PROJECT}"

.PHONY: clean 
clean: set_env clean_external ## Clean plotlablib 
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
