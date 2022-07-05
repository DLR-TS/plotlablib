SHELL:=/bin/bash

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

.DEFAULT_GOAL := all

LIBZMQ_IMAGE_NAME="libzmq:v4.3.2"
PLOTLABLIB_IMAGE_NAME="plotlablib:latest"

.PHONY: help 
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all 
all: build_plotlablib

.PHONY: build 
build: all

.PHONY: lint 
lint:
	cd cpplint && \
        make lint CPP_PROJECT_DIRECTORY=$(realpath ${ROOT_DIR}/server) && \
		make lint CPP_PROJECT_DIRECTORY=$(realpath ${ROOT_DIR}/lib/include)

.PHONY: lintfix 
lintfix:
	cd cpplint && \
        make lintfix CPP_PROJECT_DIRECTORY=$(realpath ${ROOT_DIR}/server) && \
        make lintfix CPP_PROJECT_DIRECTORY=$(realpath ${ROOT_DIR}/lib/include)

.PHONY: lintfix_simulate 
lintfix_simulate:
	cd cpplint && \
        make lintfix_simulate CPP_PROJECT_DIRECTORY=$(realpath ${ROOT_DIR}/server) && \
        make lintfix_simulate CPP_PROJECT_DIRECTORY=$(realpath ${ROOT_DIR}/lib/include)

.PHONY: cppcheck 
cppcheck:
	cd cppcheck && \
        make cppcheck CPP_PROJECT_DIRECTORY=$(realpath ${ROOT_DIR}/server)

.PHONY: clean 
clean: clean_plotlab_lib clean_plotlab clean_platlab_server

.PHONY: build_plotlablib 
build_plotlablib: clean_plotlab_lib 
	cd plotlablib/external && make
	docker build --network="host" -t "${PLOTLABLIB_IMAGE_NAME}" .
	@mkdir -p "${ROOT_DIR}/tmp"
	docker cp $$(docker create --rm ${PLOTLABLIB_IMAGE_NAME}):/tmp/plotlab tmp
	@cp -r "${ROOT_DIR}/tmp/plotlab/plotlablib/build" "${ROOT_DIR}/plotlablib/"
	@rm -rf "${ROOT_DIR}/tmp"


.PHONY: build_plotlab_lib 
build_plotlab_lib:
	cd "${ROOT_DIR}/lib" && bash build.sh 

.PHONY: clean_plotlab_lib 
clean_plotlab_lib:
	rm -rf "${ROOT_DIR}/plotlablib/build"
	cd plotlablib/external && make clean

.PHONY: clean_plotlab 
clean_plotlab:
	rm -rf "${ROOT_DIR}/plotlablib/build"
	docker rm $$(docker ps -a -q --filter "ancestor=${PLOTLABLIB_IMAGE_NAME}") 2> /dev/null || true
	docker rmi $$(docker images -q ${PLOTLABLIB_IMAGE_NAME}) 2> /dev/null || true
	docker rm $$(docker ps -a -q --filter "ancestor=${PLOTLABLIB_SERVER_IMAGE_NAME}") 2> /dev/null || true

.PHONY: docker_clean 
docker_clean:
	docker rmi $$(docker images --filter "dangling=true" -q) --force
