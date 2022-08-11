SHELL:=/bin/bash

.DEFAULT_GOAL := all


ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=


LIBZMQ_PROJECT=libzmq
LIBZMQ_VERSION=latest
LIBZMQ_TAG="${LIBZMQ_PROJECT}:${LIBZMQ_VERSION}"

LIBSODIUM_PROJECT=libsodium
LIBSODIUM_VERSION=latest
LIBSODIUM_TAG="$(shell echo $(LIBSODIUM_PROJECT) | tr A-Z a-z):${LIBSODIUM_VERSION}"

.PHONY: build_libzmq
build_libzmq: set_libzmq_env build

.PHONY: set_libzmq_env
set_libzmq_env: 
	$(eval PROJECT := ${LIBZMQ_PROJECT}) 
	$(eval TAG := ${LIBZMQ_TAG})

.PHONY: build_libsodium
build_libsodium: set_libsodium_env build
.PHONY: set_libsodium_env
set_libsodium_env: 
	$(eval PROJECT := ${LIBSODIUM_PROJECT})
	$(eval TAG := ${LIBSODIUM_TAG})

.PHONY: all
all: build_libzmq

.PHONY: build
build:
	rm -rf ${PROJECT}/build
	docker build --network="host" --tag $(shell echo ${TAG} | tr A-Z a-z) --build-arg PROJECT=${PROJECT} .
	docker cp $$(docker create --rm $(shell echo ${TAG} | tr A-Z a-z)):/tmp/${PROJECT}/build ${PROJECT}/build

.PHONY: clean
clean: 
	rm -rf "${ROOT_DIR}/*/build"
	docker rm $$(docker ps -a -q --filter "ancestor=${LIBZMQ_TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${LIBZMQ_TAG}) 2> /dev/null || true
	docker rm $$(docker ps -a -q --filter "ancestor=${LIBSODIUM_TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${LIBSODIUM_TAG}) 2> /dev/null || true
