SHELL:=/bin/bash

.DEFAULT_GOAL := all


ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

.PHONY: build_libzmq 
build_libzmq:
	cd libzmq && make

.PHONY: build_cppzmq
build_cppzmq: 
	cd cppzmq && make

.PHONY: all 
all: build_libzmq build_cppzmq 

.PHONY: clean
clean:
	cd cppzmq && make clean
	cd libzmq && make clean
