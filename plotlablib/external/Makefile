SHELL:=/bin/bash

.DEFAULT_GOAL := all


ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=


CPPZMQ_PROJECT="cppzmq"
CPPZMQ_VERSION="latest"
CPPZMQ_TAG="${CPPZMQ_PROJECT}:${CPPZMQ_VERSION}"
LIBZMQ_PROJECT="libzmq"
LIBZMQ_VERSION="latest"
LIBZMQ_TAG="${LIBZMQ_PROJECT}:${LIBZMQ_VERSION}"

DOCKER_REPOSITORY="andrewkoerner/adore"
EXTERNALS_DOCKER_ARCHIVE="/var/tmp/plotlablib_externals.tar"


.PHONY: update_submodules
update_submodules:
	git submodule update --init --recursive --depth 1 ${ROOT_DIR}/*


.PHONY: save_docker_images
save_docker_images:
	docker save -o "${EXTERNALS_DOCKER_ARCHIVE}" ${CPPZMQ_TAG} ${LIBZMQ_TAG} 2> /dev/null || true

.PHONY: load_docker_images
load_docker_images:
	@docker load --input "${EXTERNALS_DOCKER_ARCHIVE}" 2>/dev/null || true

.PHONY: docker_pull_fast
docker_pull_fast:
	@[ -n "$$(docker images -q ${CPPZMQ_TAG})" ] || make docker_pull
	@[ -n "$$(docker images -q ${LIBZMQ_TAG})" ] || make docker_pull

.PHONY: docker_pull
docker_pull:
	docker pull "${DOCKER_REPOSITORY}:${CPPZMQ_PROJECT}_${CPPZMQ_VERSION}"
	docker tag "${DOCKER_REPOSITORY}:${CPPZMQ_PROJECT}_${CPPZMQ_VERSION}" "${CPPZMQ_TAG}"
	docker rmi "${DOCKER_REPOSITORY}:${CPPZMQ_PROJECT}_${CPPZMQ_VERSION}"

	docker pull "${DOCKER_REPOSITORY}:${LIBZMQ_PROJECT}_${LIBZMQ_VERSION}"
	docker tag "${DOCKER_REPOSITORY}:${LIBZMQ_PROJECT}_${LIBZMQ_VERSION}" "${LIBZMQ_TAG}"
	docker rmi "${DOCKER_REPOSITORY}:${LIBZMQ_PROJECT}_${LIBZMQ_VERSION}"

.PHONY: docker_publish
docker_publish:
	docker tag "${CPPZMQ_TAG}" "${DOCKER_REPOSITORY}:${CPPZMQ_PROJECT}_${CPPZMQ_VERSION}"
	docker push "${DOCKER_REPOSITORY}:${CPPZMQ_PROJECT}_${CPPZMQ_VERSION}"

	docker tag "${LIBZMQ_TAG}" "${DOCKER_REPOSITORY}:${LIBZMQ_PROJECT}_${LIBZMQ_VERSION}"
	docker push "${DOCKER_REPOSITORY}:${LIBZMQ_PROJECT}_${LIBZMQ_VERSION}"


.PHONY: build_libzmq 
build_libzmq: update_submodules
	cd libzmq && make

.PHONY: build_fast_libzmq
build_fast_libzmq:
	@if [ -n "$$(docker images -q ${LIBZMQ_TAG})" ]; then \
        echo "Docker image: ${LIBZMQ_TAG} already build, skipping build."; \
    else \
        make build_libzmq;\
    fi

.PHONY: build_cppzmq
build_cppzmq: update_submodules 
	cd cppzmq && make

.PHONY: build_fast_cppzmq
build_fast_cppzmq:
	@if [ -n "$$(docker images -q ${CPPZMQ_TAG})" ]; then \
        echo "Docker image: ${CPPZMQ_TAG} already build, skipping build."; \
    else \
        make build_cppzmq;\
    fi


.PHONY: build_fast
build_fast:
	make clean
	make load_docker_images
	make docker_pull_fast
	make build_fast_libzmq
	make build_fast_cppzmq
	make save_docker_images

.PHONY: clean
clean:
	cd cppzmq && make clean
	cd libzmq && make clean
