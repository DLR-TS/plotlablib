SHELL:=/bin/bash

.DEFAULT_GOAL := all

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

CPPZMQ_PROJECT=cppzmq
CPPZMQ_VERSION=latest
CPPZMQ_TAG="${CPPZMQ_PROJECT}:${CPPZMQ_VERSION}" 

.PHONY: build_cppzmq
build_cppzmq: set_cppzmq_env build
set_cppzmq_env: 
	$(eval PROJECT := ${CPPZMQ_PROJECT}) 
	$(eval TAG := ${CPPZMQ_TAG})

.PHONY: all
all: build_cppzmq 

.PHONY: build
build:
	rm -rf ${PROJECT}/build
	docker build --network="host" --tag $(shell echo ${TAG} | tr A-Z a-z) --build-arg PROJECT=${PROJECT} .
	mkdir -p "${ROOT_DIR}/tmp/${PROJECT}/build"
	docker cp $$(docker create --rm $(shell echo ${TAG} | tr A-Z a-z)):/tmp/${PROJECT}/build tmp/${PROJECT}/build
	cp -r "${ROOT_DIR}/tmp/${PROJECT}/build/build" "${ROOT_DIR}/${PROJECT}"
	rm -rf ${ROOT_DIR}/tmp

.PHONY: clean_cppzmq 
clean_cppzmq: set_cppzmq_env clean

.PHONY: clean
clean: clean_cppzmq
	rm -rf "${ROOT_DIR}/*/build"
	rm -rf "${ROOT_DIR}/tmp"
	docker rm $$(docker ps -a -q --filter "ancestor=${TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${TAG}) 2> /dev/null || true
