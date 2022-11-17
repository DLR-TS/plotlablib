# This Makefile contains useful targets that can be included in downstream projects.

#ifndef PLOTLABLIB_MAKEFILE_PATH

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
PLOTLABLIB_PROJECT:=plotlablib

PLOTLABLIB_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")
MAKE_GADGETS_PATH:=${PLOTLABLIB_MAKEFILE_PATH}/make_gadgets
REPO_DIRECTORY:=${PLOTLABLIB_MAKEFILE_PATH}

PLOTLABLIB_TAG:=$(shell cd ${MAKE_GADGETS_PATH} && make get_sanitized_branch_name REPO_DIRECTORY=${REPO_DIRECTORY})
PLOTLABLIB_IMAGE:=${PLOTLABLIB_PROJECT}:${PLOTLABLIB_TAG}

PLOTLABLIB_CMAKE_BUILD_PATH="${PLOTLABLIB_PROJECT}/build"
PLOTLABLIB_CMAKE_INSTALL_PATH="${PLOTLABLIB_CMAKE_BUILD_PATH}/install"


.PHONY: build_plotlablib 
build_plotlablib: ## Build plotlablib
	cd "${PLOTLABLIB_MAKEFILE_PATH}" && make

.PHONY: clean_plotlablib
clean_plotlablib: ## Clean plotlablib build artifacts
	cd "${PLOTLABLIB_MAKEFILE_PATH}" && make clean

.PHONY: branch_plotlablib
branch_plotlablib: ## Returns the current docker safe/sanitized branch for plotlablib
	@printf "%s\n" ${PLOTLABLIB_TAG}

.PHONY: image_plotlablib
image_plotlablib: ## Returns the current docker image name for plotlablib
	@printf "%s\n" ${PLOTLABLIB_IMAGE}

.PHONY: update_plotlablib
update_plotlablib:
	cd "${PLOTLABLIB_MAKEFILE_PATH}" && git pull

#endif
