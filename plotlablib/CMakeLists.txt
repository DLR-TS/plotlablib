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

project(plotlablib 
        VERSION 0.0.1
)

add_library(${PROJECT_NAME} INTERFACE)
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

set(PACKAGE_VENDOR "DLR TS-KOS-SAI")
set(PACKAGE_DESCRIPTION "plotlab")
set(PACKAGE_MAINTAINER "DLR TS-KOS-SAI")
set(PACKAGE_MAINTAINER_EMAIL "ts-kos-sai@dlr.de")

include(GNUInstallDirs)
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/external/libzmq/libzmq/build/install")
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_SOURCE_DIR}/external/cppzmq/cppzmq/build/install")
message("CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")

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

install(TARGETS ${PROJECT_NAME}
        EXPORT ${PROJECT_NAME}_Targets
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})


include(CMakePackageConfigHelpers)

configure_package_config_file(
  "${PROJECT_SOURCE_DIR}/cmake/LibraryConfig.cmake.in"
  "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
  INSTALL_DESTINATION
  ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}/cmake)

install(EXPORT ${PROJECT_NAME}_Targets
        COMPONENT ${PROJECT_NAME}
        FILE ${PROJECT_NAME}Targets.cmake
        NAMESPACE ${PROJECT_NAME}::
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}/cmake
)

install(FILES "${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
              # "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}/cmake
        COMPONENT ${PROJECT_NAME}
)

#install(DIRECTORY ${PROJECT_SOURCE_DIR}/include DESTINATION .)

install(DIRECTORY ${PROJECT_SOURCE_DIR}/include DESTINATION .)

#install(DIRECTORY ${PROJECT_SOURCE_DIR}/build/include DESTINATION .)

