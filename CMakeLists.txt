cmake_minimum_required(VERSION 3.15)
project(opencv_template VERSION 1.0)

# Set C++ standard
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Platform-specific settings
if(WIN32)
    # Set static runtime (/MT) for Windows
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
else()
    # Linux settings
    set(CMAKE_POSITION_INDEPENDENT_CODE ON)
endif()

# Define build phase (BUILD_DEPS or MAIN)
set(BUILD_PHASE "BUILD_DEPS" CACHE STRING "Build phase: BUILD_DEPS or MAIN")

# Include the external libraries manager
include(cmake/ExternalLibraries.cmake)

if(BUILD_PHASE STREQUAL "BUILD_DEPS")
    # In phase 1, only build external dependencies
    message(STATUS "Phase 1: Building external dependencies...")
    # Nothing else to do - dependencies will be built via ExternalProject
else()
    # In phase 2, configure using the built dependencies
    message(STATUS "Phase 2: Building main project...")

    # Configure OpenCV
    configure_opencv()
    
    # Add the source code directory
    add_subdirectory(src)
endif()