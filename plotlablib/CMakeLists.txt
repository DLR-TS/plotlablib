#********************************************************************************
#* Copyright (C) 2017-2020 German Aerospace Center (DLR). 
#* Eclipse ADORe, Automated Driving Open Research https://eclipse.org/adore
#*
#* This program and the accompanying materials are made available under the 
#* terms of the Eclipse Public License 2.0 which is available at
#* http://www.eclipse.org/legal/epl-2.0.
#*
#* SPDX-License-Identifier: EPL-2.0 
#*
#* Contributors: 
#*   Thomas Lobig - initial API and implementation
#********************************************************************************
cmake_minimum_required(VERSION 3.13)

project(
    plotlablib 
    VERSION 0.0.1
)

add_library(${PROJECT_NAME} INTERFACE)
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

set(PACKAGE_VENDOR "DLR TS-KOS-SAI")
set(PACKAGE_DESCRIPTION "plotlab")
set(PACKAGE_MAINTAINER "DLR TS-KOS-SAI")
set(PACKAGE_MAINTAINER_EMAIL "ts-kos-sai@dlr.de")

include(GNUInstallDirs)

list(APPEND CMAKE_PREFIX_PATH "$ENV{CMAKE_PREFIX_PATH}")

#list(APPEND CMAKE_PREFIX_PATH "$ENV{CMAKE_PREFIX_PATH}")
#list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/external/libzmq/libzmq/build/install")
#list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/external/cppzmq/cppzmq/build/install")
message("CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")


set(libzmq_CMAKE_INSTALL_PATH "${CMAKE_CURRENT_SOURCE_DIR}/build/install")
list(APPEND CMAKE_PREFIX_PATH "${libzmq_CMAKE_INSTALL_PATH}")

set(cppzmq_CMAKE_INSTALL_PATH "${CMAKE_CURRENT_SOURCE_DIR}/build/install")
list(APPEND CMAKE_PREFIX_PATH "${cppzmq_CMAKE_INSTALL_PATH}")



find_package(ZeroMQ CONFIG REQUIRED)
find_package(cppzmq CONFIG REQUIRED)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(Packing)


set_directory_properties(PROPERTIES EXCLUDE_FROM_ALL YES)

#include(external/zmq.cmake)
#include_directories(external/cppzmq)

get_directory_property(PLOTLABLIB_PARENT_DIR PARENT_DIRECTORY)

message(STATUS " plotlab: building plotlab lib...")


#set(zmqlib_include  ${CMAKE_CURRENT_SOURCE_DIR}/external/cppzmq/
#  ${CMAKE_CURRENT_SOURCE_DIR}/external/libzmq/build/bin/usr/local/include
#)

target_include_directories(
  ${PROJECT_NAME}
  INTERFACE 
    $<BUILD_INTERFACE:${${PROJECT_NAME}_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

#target_link_libraries(plotlablib INTERFACE ${CMAKE_CURRENT_SOURCE_DIR}/external/libzmq/build/bin/usr/local/lib/libzmq.a)
target_link_libraries(plotlablib INTERFACE libzmq-static cppzmq)

target_compile_options(${PROJECT_NAME} INTERFACE "-Wall")

target_compile_features(${PROJECT_NAME} INTERFACE cxx_std_17)

include(PackagingInstallTargets)
