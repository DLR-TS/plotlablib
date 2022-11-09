# This Makefile contains useful targets that can be included in downstream projects.

#ifndef plotlablib_MAKEFILE_PATH

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
plotlablib_project:=plotlablib
PLOTLABLIB_PROJECT:=${plotlablib_project}

plotlablib_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")
make_gadgets_PATH:=${plotlablib_MAKEFILE_PATH}/make_gadgets
REPO_DIRECTORY:=${plotlablib_MAKEFILE_PATH}

plotlablib_tag:=$(shell cd ${make_gadgets_PATH} && make get_sanitized_branch_name REPO_DIRECTORY=${REPO_DIRECTORY})
PLOTLABLIB_TAG:=${plotlablib_tag}

plotlablib_image:=${plotlablib_project}:${plotlablib_tag}
PLOTLABLIB_IMAGE:=${plotlablib_image}

plotlablib_CMAKE_BUILD_PATH="${plotlablib_project}/build"
PLOTLABLIB_CMAKE_BUILD_PATH=${plotlablib_CMAKE_BULID_PATH}!

plotlablib_CMAKE_INSTALL_PATH="${plotlablib_CMAKE_BUILD_PATH}/install"
PLOTLABLIB_CMAKE_INSTALL_PATH=${plotlablib_CMAKE_INSTALL_PATH}


.PHONY: build_plotlablib 
build_plotlablib: ## Build plotlablib
	cd "${plotlablib_MAKEFILE_PATH}" && make

.PHONY: clean_plotlablib
clean_plotlablib: ## Clean plotlablib build artifacts
	cd "${plotlablib_MAKEFILE_PATH}" && make clean

.PHONY: branch_plotlablib
branch_plotlablib: ## Returns the current docker safe/sanitized branch for plotlablib
	@printf "%s\n" ${plotlablib_tag}

.PHONY: image_plotlablib
image_plotlablib: ## Returns the current docker image name for plotlablib
	@printf "%s\n" ${plotlablib_image}

.PHONY: update_plotlablib
update_plotlablib:
	cd "${plotlablib_MAKEFILE_PATH}" && git pull

#endif
