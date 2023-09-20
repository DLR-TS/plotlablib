# This Makefile contains useful targets that can be included in downstream projects.

ifeq ($(filter plotlablib.mk, $(notdir $(MAKEFILE_LIST))), plotlablib.mk)

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
PLOTLABLIB_PROJECT:=plotlablib

PLOTLABLIB_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")
PLOTLABLIB_MAKE_GADGETS_PATH:=${PLOTLABLIB_MAKEFILE_PATH}/make_gadgets
ifeq ($(SUBMODULES_PATH),)
    PLOTLABLIB_SUBMODULES_PATH:=${PLOTLABLIB_MAKEFILE_PATH}
else
    PLOTLABLIB_SUBMODULES_PATH:=$(shell realpath ${SUBMODULES_PATH})
endif
MAKE_GADGETS_PATH:=${PLOTLABLIB_SUBMODULES_PATH}/make_gadgets
ifeq ($(wildcard $(MAKE_GADGETS_PATH)/*),)
    $(info INFO: To clone submodules use: 'git submodule update --init --recursive')
    $(info INFO: To specify alternative path for submodules use: SUBMODULES_PATH="<path to submodules>" make build')
    $(info INFO: Default submodule path is: ${PLOTLABLIB_MAKEFILE_PATH}')
    $(error "ERROR: ${MAKE_GADGETS_PATH} does not exist. Did you clone the submodules?")
endif

PLOTLABLIB_REPO_DIRECTORY:=${PLOTLABLIB_MAKEFILE_PATH}

PLOTLABLIB_TAG:=$(shell cd ${MAKE_GADGETS_PATH} && make get_sanitized_branch_name REPO_DIRECTORY=${PLOTLABLIB_REPO_DIRECTORY})
PLOTLABLIB_IMAGE:=${PLOTLABLIB_PROJECT}:${PLOTLABLIB_TAG}

PLOTLABLIB_CMAKE_BUILD_PATH="${PLOTLABLIB_PROJECT}/build"
PLOTLABLIB_CMAKE_INSTALL_PATH="${PLOTLABLIB_CMAKE_BUILD_PATH}/install"

include ${MAKE_GADGETS_PATH}/make_gadgets.mk
include ${MAKE_GADGETS_PATH}/docker/docker-tools.mk

.PHONY: build_plotlablib 
build_plotlablib: ## Build plotlablib
	cd "${PLOTLABLIB_MAKEFILE_PATH}" && make build

.PHONY: clean_plotlablib
clean_plotlablib: ## Clean plotlablib build artifacts
	cd "${PLOTLABLIB_MAKEFILE_PATH}" && make clean

.PHONY: clean_external_library_cache
clean_external_library_cache: ## Clean/delete plotlab system wide cache in /var/tmp/docker. Note: this is never done automatically and must be manually invoked. 
	cd "${PLOTLABLIB_MAKEFILE_PATH}" && make clean_external_library_cache


.PHONY: branch_plotlablib
branch_plotlablib: ## Returns the current docker safe/sanitized branch for plotlablib
	@printf "%s\n" ${PLOTLABLIB_TAG}

.PHONY: image_plotlablib
image_plotlablib: ## Returns the current docker image name for plotlablib
	@printf "%s\n" ${PLOTLABLIB_IMAGE}

endif
