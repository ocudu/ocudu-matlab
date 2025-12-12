#
# Copyright 2021-2025 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

#[=======================================================================[.rst:
FindOCUDU
-------

Finds the OCUDU exported libraries.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides access to the targets exported by OCUDU. They will be
available under the namespace ``ocudu::``.


Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``OCUDU_FOUND``
  True if the OCUDU libraries were found.
``OCUDU_SOURCE_DIR``
  Root source directory of OCUDU.
``OCUDU_INCLUDE_DIR``
  Include directory needed to use OCUDU.
``OCUDU_BINARY_DIR``
  Full path to the top level of the OCUDU build tree.

Cache Variables
^^^^^^^^^^^^^^^

The following cache variables may also be set:

``OCUDU_BINARY_DIR``
  Full path to the top level of the OCUDU build tree.

#]=======================================================================]

file(GLOB OCUDU_PATH LIST_DIRECTORIES true "$ENV{HOME}/OCUDU_Project" "$ENV{HOME}/*/OCUDU_Project" "$ENV{HOME}/*/*/OCUDU_Project")
message(STATUS "ocudu possible paths: ${OCUDU_PATH}.")

set(OCUDU_PATH_BUILD ${OCUDU_PATH})
list(TRANSFORM OCUDU_PATH_BUILD APPEND "/build")

set(OCUDU_PATH_BUILD_STAR ${OCUDU_PATH})
list(TRANSFORM OCUDU_PATH_BUILD_STAR APPEND "/build*")
file(GLOB OCUDU_PATH_BUILD_STAR LIST_DIRECTORIES true ${OCUDU_PATH_BUILD_STAR})

set(OCUDU_PATH_CMAKE_BUILD ${OCUDU_PATH})
list(TRANSFORM OCUDU_PATH_CMAKE_BUILD APPEND "/cmake-build-*")
file(GLOB OCUDU_PATH_CMAKE_BUILD LIST_DIRECTORIES true ${OCUDU_PATH_CMAKE_BUILD})

find_path(OCUDU_BINARY_DIR ocudu.cmake
    HINTS ${OCUDU_PATH_BUILD} ${OCUDU_PATH_BUILD_STAR} ${OCUDU_PATH_CMAKE_BUILD}
    NO_DEFAULT_PATH
)

if (OCUDU_BINARY_DIR)
    get_filename_component(OCUDU_SOURCE_DIR ${OCUDU_BINARY_DIR} DIRECTORY)
    set(OCUDU_INCLUDE_DIR ${OCUDU_SOURCE_DIR}/include)
endif (OCUDU_BINARY_DIR)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(OCUDU
    FOUND_VAR OCUDU_FOUND
    REQUIRED_VARS
        OCUDU_SOURCE_DIR
        OCUDU_INCLUDE_DIR
        OCUDU_BINARY_DIR
)
