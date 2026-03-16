# SPDX-FileCopyrightText: Copyright (C) 2021-2026 Software Radio Systems Limited
# SPDX-License-Identifier: BSD-3-Clause-Open-MPI

########################################################################
# Prevent in-tree builds
########################################################################
if(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})
    message(FATAL_ERROR "Prevented in-tree build. This is bad practice.")
endif(${CMAKE_SOURCE_DIR} STREQUAL ${CMAKE_BINARY_DIR})

########################################################################
# Project setup
########################################################################
cmake_minimum_required(VERSION 3.14)
project(OCUDU-matlab VERSION 0.1)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall")

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
    message(STATUS "Build type not specified: defaulting to Release.")
endif(NOT CMAKE_BUILD_TYPE)
set(CMAKE_BUILD_TYPE ${CMAKE_BUILD_TYPE} CACHE STRING "Build type" FORCE)
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release")

########################################################################
# Options
########################################################################

option(ASSERTS_ENABLED "Enable OCUDU asserts" ON)

if (ASSERTS_ENABLED)
    add_definitions(-DASSERTS_ENABLED)
endif()

########################################################################
# Compiler specific setup
########################################################################
macro(ADD_CXX_COMPILER_FLAG_IF_AVAILABLE flag have)
    include(CheckCXXCompilerFlag)
    check_cxx_compiler_flag(${flag} ${have})
    if (${have})
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${flag}")
    endif (${have})
endmacro(ADD_CXX_COMPILER_FLAG_IF_AVAILABLE)

# Make sure no instance of abstract class is left without a destructor
ADD_CXX_COMPILER_FLAG_IF_AVAILABLE(-Wnon-virtual-dtor HAVE_NON_VIRTUAL_DTOR)

# Make sure all overridden methods are marked as override
ADD_CXX_COMPILER_FLAG_IF_AVAILABLE(-Wsuggest-override HAVE_SUGGEST_OVERRIDE)

# Avoid shadow variables which can be caused due to C code ported into C++
ADD_CXX_COMPILER_FLAG_IF_AVAILABLE(-Wshadow HAVE_SHADOW)

# Avoid extra (stray) semicolons
ADD_CXX_COMPILER_FLAG_IF_AVAILABLE(-Wextra-semi HAVE_EXTRA_SEMI)

# Disable RTTI
ADD_CXX_COMPILER_FLAG_IF_AVAILABLE(-fno-rtti HAVE_NO_RTTI)

# Set compiler flags for different build types.
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -ggdb -O0 -DDEBUG_MODE -DBUILD_TYPE_DEBUG")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -fno-trapping-math -fno-math-errno -DBUILD_TYPE_RELEASE")

########################################################################
# Requirements
########################################################################
# MATLAB
list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules")

find_package(Matlab REQUIRED)

# OCUDU
find_package(OCUDU MODULE REQUIRED)

include(${OCUDU_BINARY_DIR}/ocudu.cmake)

get_property(OCUDU_BUILD_TYPE TARGET ocudu::ocudu_support PROPERTY IMPORTED_CONFIGURATIONS)
if ((${CMAKE_BUILD_TYPE} STREQUAL "Release") AND (${OCUDU_BUILD_TYPE} STREQUAL "DEBUG"))
    message(FATAL_ERROR "Cannot compile with build type RELEASE if OCUDU is exported with build type DEBUG!")
endif ((${CMAKE_BUILD_TYPE} STREQUAL "Release") AND (${OCUDU_BUILD_TYPE} STREQUAL "DEBUG"))


################################################################################
# Global includes
################################################################################
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${OCUDU_INCLUDE_DIR}
    ${OCUDU_SOURCE_DIR}/external/fmt/include
    ${OCUDU_SOURCE_DIR}/external
)

################################################################################
# Install setup
################################################################################
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set_property(CACHE CMAKE_INSTALL_PREFIX PROPERTY VALUE "${CMAKE_SOURCE_DIR}/../")
endif()

# Add default RPATH to the installed targets.
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

################################################################################
# Project subdirectories to be built
################################################################################
add_subdirectory(lib)
add_subdirectory(unittests)
add_subdirectory(docs)
