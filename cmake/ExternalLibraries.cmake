# ExternalLibraries.cmake - Central manager for all external dependencies
include(ExternalProject)

# Global variables
set(EXTERNAL_LIBS_DIR ${CMAKE_SOURCE_DIR}/external)
set(EXTERNAL_BUILD_DIR ${CMAKE_BINARY_DIR}/external)
set(EXTERNAL_INSTALL_DIR ${CMAKE_BINARY_DIR}/installed)

# Detect platform
if(WIN32)
    set(PLATFORM_IS_WINDOWS TRUE)
else()
    set(PLATFORM_IS_LINUX TRUE)
endif()

# Function to register a new external library
# Usage: register_external_library(NAME library_name)
function(register_external_library)
    # Parse arguments
    set(options "")
    set(oneValueArgs NAME)
    set(multiValueArgs "")
    cmake_parse_arguments(LIBRARY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Validate arguments
    if(NOT LIBRARY_NAME)
        message(FATAL_ERROR "register_external_library: NAME parameter is required")
    endif()

    # Set library-specific directories
    set(${LIBRARY_NAME}_SOURCE_DIR ${EXTERNAL_LIBS_DIR}/${LIBRARY_NAME} CACHE INTERNAL "")
    set(${LIBRARY_NAME}_BUILD_DIR ${EXTERNAL_BUILD_DIR}/${LIBRARY_NAME} CACHE INTERNAL "")
    set(${LIBRARY_NAME}_INSTALL_DIR ${EXTERNAL_INSTALL_DIR}/${LIBRARY_NAME} CACHE INTERNAL "")

    # Create imported target
    if(NOT TARGET ${LIBRARY_NAME}_lib)
        add_library(${LIBRARY_NAME}_lib INTERFACE IMPORTED GLOBAL)
    endif()

    message(STATUS "Registered external library: ${LIBRARY_NAME}")
endfunction()

# Function to add a build phase for an external library
# Usage: add_external_library_phase(NAME library_name PHASE phase_name DEPENDS dep1 dep2 ...)
function(add_external_library_phase)
    # Parse arguments
    set(options "")
    set(oneValueArgs NAME PHASE)
    set(multiValueArgs CMAKE_ARGS DEPENDS)
    cmake_parse_arguments(PHASE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Validate arguments
    if(NOT PHASE_NAME OR NOT PHASE_PHASE)
        message(FATAL_ERROR "add_external_library_phase: NAME and PHASE parameters are required")
    endif()

    # Only proceed if we're in the BUILD_DEPS phase
    if(NOT "${BUILD_PHASE}" STREQUAL "BUILD_DEPS")
        return()
    endif()

    # Verify the library source directory exists
    if(NOT EXISTS ${${PHASE_NAME}_SOURCE_DIR})
        message(FATAL_ERROR "Library source directory does not exist: ${${PHASE_NAME}_SOURCE_DIR}")
    endif()

    # Create a target for this phase
    set(TARGET_NAME ${PHASE_NAME}_${PHASE_PHASE})

    # Set platform-specific CMake arguments
    set(PLATFORM_CMAKE_ARGS)
    if(PLATFORM_IS_WINDOWS)
        # Windows-specific arguments
        list(APPEND PLATFORM_CMAKE_ARGS
            -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded$<$<CONFIG:Debug>:Debug>
        )
    else()
        # Linux-specific arguments
        list(APPEND PLATFORM_CMAKE_ARGS
            -DCMAKE_POSITION_INDEPENDENT_CODE=ON
        )
    endif()

    # Configure ExternalProject_Add for this phase
    ExternalProject_Add(
        ${TARGET_NAME}
        SOURCE_DIR ${${PHASE_NAME}_SOURCE_DIR}
        CMAKE_ARGS
            -DCMAKE_INSTALL_PREFIX=${${PHASE_NAME}_INSTALL_DIR}
            ${PLATFORM_CMAKE_ARGS}
            ${PHASE_CMAKE_ARGS}
        BINARY_DIR ${${PHASE_NAME}_BUILD_DIR}/${PHASE_PHASE}
        INSTALL_DIR ${${PHASE_NAME}_INSTALL_DIR}
        ${PHASE_DEPENDS}
        BUILD_ALWAYS OFF
    )

    # Add dependency to the main imported target
    add_dependencies(${PHASE_NAME}_lib ${TARGET_NAME})

    message(STATUS "Added build phase '${PHASE_PHASE}' for library '${PHASE_NAME}'")
endfunction()

# Function to link a target with an external library
# Usage: target_link_with_external(target library_name)
function(target_link_with_external TARGET LIBRARY_NAME)
    # Verify the library exists
    if(NOT TARGET ${LIBRARY_NAME}_lib)
        message(FATAL_ERROR "Library '${LIBRARY_NAME}' not registered. Make sure register_external_library(NAME ${LIBRARY_NAME}) is called before using this function.")
    endif()

    # Link the target with the library
    target_link_libraries(${TARGET} PRIVATE ${LIBRARY_NAME}_lib)

    message(STATUS "Linked target '${TARGET}' with external library '${LIBRARY_NAME}'")
endfunction()

# Function to update an external library with actual includes and libraries after it's built
# Usage: update_external_library(NAME library_name INCLUDES dir1 dir2 ... LIBRARIES lib1 lib2 ...)
function(update_external_library)
    # Parse arguments
    set(options "")
    set(oneValueArgs NAME)
    set(multiValueArgs INCLUDES LIBRARIES)
    cmake_parse_arguments(UPDATE "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # Validate arguments
    if(NOT UPDATE_NAME)
        message(FATAL_ERROR "update_external_library: NAME parameter is required")
    endif()

    # Verify the target exists
    if(NOT TARGET ${UPDATE_NAME}_lib)
        message(FATAL_ERROR "Library '${UPDATE_NAME}' not registered. Make sure register_external_library(NAME ${UPDATE_NAME}) is called before using this function.")
    endif()

    # Update the imported target properties
    if(UPDATE_INCLUDES)
        set_target_properties(${UPDATE_NAME}_lib PROPERTIES
            INTERFACE_INCLUDE_DIRECTORIES "${UPDATE_INCLUDES}"
        )
    endif()

    if(UPDATE_LIBRARIES)
        set_target_properties(${UPDATE_NAME}_lib PROPERTIES
            INTERFACE_LINK_LIBRARIES "${UPDATE_LIBRARIES}"
        )
    endif()

    message(STATUS "Updated external library '${UPDATE_NAME}' with actual includes and libraries")
endfunction()

# Include all library configuration files
file(GLOB LIBRARY_FILES ${CMAKE_SOURCE_DIR}/cmake/external/*.cmake)
foreach(LIBRARY_FILE ${LIBRARY_FILES})
    include(${LIBRARY_FILE})
endforeach()