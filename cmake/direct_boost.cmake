# This is a direct approach to building Boost without using ExternalProject_Add
# It's designed to work with your existing template structure

# First verify that the Boost source directory exists
if(NOT EXISTS "${CMAKE_SOURCE_DIR}/external/boost")
    message(FATAL_ERROR "Boost source directory not found. Make sure you've cloned the repository with '--recursive' or run 'git submodule update --init --recursive'")
endif()

# Function to initialize a specific Boost submodule if needed
function(ensure_boost_submodule SUBMODULE)
    # Modified to check if directory exists instead of specific files
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/external/boost/${SUBMODULE}")
        message(STATUS "Initializing Boost submodule: ${SUBMODULE}")
        execute_process(
            COMMAND git submodule update --init "${SUBMODULE}"
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/external/boost"
            RESULT_VARIABLE RESULT
        )
        if(NOT RESULT EQUAL 0)
            message(WARNING "Failed to initialize Boost submodule: ${SUBMODULE}")
        endif()
    endif()
endfunction()

# Function to copy a single file safely without using symlinks
function(safe_copy_file SRC DEST)
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${SRC}" "${DEST}"
        RESULT_VARIABLE COPY_RESULT
    )
    if(NOT COPY_RESULT EQUAL 0)
        message(WARNING "Failed to copy file from ${SRC} to ${DEST}")
    endif()
endfunction()

# Function to copy a directory recursively without using symlinks
function(safe_copy_directory SRC_DIR DEST_DIR)
    # Create destination directory
    file(MAKE_DIRECTORY "${DEST_DIR}")
    
    # Get all files in the source directory
    file(GLOB_RECURSE FILES 
        "${SRC_DIR}/*.hpp" 
        "${SRC_DIR}/*.h" 
        "${SRC_DIR}/*.ipp"
        "${SRC_DIR}/*.inc"
    )
    
    # Copy each file individually
    foreach(FILE ${FILES})
        file(RELATIVE_PATH REL_PATH "${SRC_DIR}" "${FILE}")
        get_filename_component(REL_DIR "${REL_PATH}" DIRECTORY)
        
        # Create subdirectory if needed
        if(REL_DIR)
            file(MAKE_DIRECTORY "${DEST_DIR}/${REL_DIR}")
        endif()
        
        # Copy the file
        safe_copy_file("${FILE}" "${DEST_DIR}/${REL_PATH}")
    endforeach()
endfunction()

# Extract Boost version from the source directory
function(get_boost_version BOOST_SRC_DIR OUTPUT_VERSION_MAJOR OUTPUT_VERSION_MINOR OUTPUT_VERSION_PATCH)
    if(EXISTS "${BOOST_SRC_DIR}/boost/version.hpp")
        file(STRINGS "${BOOST_SRC_DIR}/boost/version.hpp" BOOST_VERSION_HPP REGEX "^#define BOOST_LIB_VERSION ")
        if(BOOST_VERSION_HPP)
            string(REGEX REPLACE ".*\"([0-9_]+)\".*" "\\1" BOOST_VERSION_STRING ${BOOST_VERSION_HPP})
            string(REPLACE "_" "." BOOST_VERSION_DOT ${BOOST_VERSION_STRING})
            string(REPLACE "_" "" BOOST_VERSION_CLEAN ${BOOST_VERSION_STRING})
            
            # Extract major, minor, patch
            string(SUBSTRING ${BOOST_VERSION_CLEAN} 0 1 VERSION_MAJOR)
            string(SUBSTRING ${BOOST_VERSION_CLEAN} 1 2 VERSION_MINOR)
            # Check if there's a patch version
            if(BOOST_VERSION_CLEAN MATCHES "^[0-9][0-9][0-9]$")
                string(SUBSTRING ${BOOST_VERSION_CLEAN} 3 1 VERSION_PATCH)
            else()
                set(VERSION_PATCH "0")
            endif()
            
            # Set the output variables
            set(${OUTPUT_VERSION_MAJOR} ${VERSION_MAJOR} PARENT_SCOPE)
            set(${OUTPUT_VERSION_MINOR} ${VERSION_MINOR} PARENT_SCOPE)
            set(${OUTPUT_VERSION_PATCH} ${VERSION_PATCH} PARENT_SCOPE)
            
            message(STATUS "Detected Boost version: ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH} (${BOOST_VERSION_STRING})")
        else()
            message(WARNING "Could not extract Boost version from version.hpp")
            set(${OUTPUT_VERSION_MAJOR} "1" PARENT_SCOPE)
            set(${OUTPUT_VERSION_MINOR} "82" PARENT_SCOPE)
            set(${OUTPUT_VERSION_PATCH} "0" PARENT_SCOPE)
        endif()
    else()
        message(WARNING "boost/version.hpp not found, using default version")
        set(${OUTPUT_VERSION_MAJOR} "1" PARENT_SCOPE)
        set(${OUTPUT_VERSION_MINOR} "82" PARENT_SCOPE)
        set(${OUTPUT_VERSION_PATCH} "0" PARENT_SCOPE)
    endif()
endfunction()

# Create a custom target for bootstrapping Boost
# This will be called in the MAIN phase only
function(configure_boost)
    # Get Boost version
    get_boost_version("${CMAKE_SOURCE_DIR}/external/boost" BOOST_VERSION_MAJOR BOOST_VERSION_MINOR BOOST_VERSION_PATCH)
    set(BOOST_VERSION_STRING "${BOOST_VERSION_MAJOR}_${BOOST_VERSION_MINOR}")

    # Get Visual Studio version for library names
    if(MSVC)
        if(MSVC_VERSION GREATER_EQUAL 1930)
            set(BOOST_TOOLSET "vc143")
        elseif(MSVC_VERSION GREATER_EQUAL 1920)
            set(BOOST_TOOLSET "vc142")
        elseif(MSVC_VERSION GREATER_EQUAL 1910)
            set(BOOST_TOOLSET "vc141")
        elseif(MSVC_VERSION GREATER_EQUAL 1900)
            set(BOOST_TOOLSET "vc140")
        else()
            set(BOOST_TOOLSET "vc")
        endif()
    else()
        set(BOOST_TOOLSET "gcc")
    endif()

    message(STATUS "Using Boost toolset: ${BOOST_TOOLSET}")
    message(STATUS "Using Boost version: ${BOOST_VERSION_STRING}")

    # Initialize essential Boost submodules
    ensure_boost_submodule("tools/build")
    ensure_boost_submodule("libs/config")
    ensure_boost_submodule("libs/headers")
    ensure_boost_submodule("libs/system")
    ensure_boost_submodule("libs/filesystem")
    ensure_boost_submodule("libs/thread")
    ensure_boost_submodule("libs/date_time")
    
    # Additional dependencies that are definitely required
    ensure_boost_submodule("libs/core")
    ensure_boost_submodule("libs/assert")
    ensure_boost_submodule("libs/throw_exception")
    ensure_boost_submodule("libs/type_traits")
    ensure_boost_submodule("libs/smart_ptr")
    ensure_boost_submodule("libs/predef")
    ensure_boost_submodule("libs/winapi")
    ensure_boost_submodule("libs/move")
    ensure_boost_submodule("libs/mpl")
    ensure_boost_submodule("libs/preprocessor")
    ensure_boost_submodule("libs/utility")
    ensure_boost_submodule("libs/integer")
    ensure_boost_submodule("libs/static_assert")
    ensure_boost_submodule("libs/iterator")
    ensure_boost_submodule("libs/chrono")
    ensure_boost_submodule("libs/atomic")
    ensure_boost_submodule("libs/bind")
    ensure_boost_submodule("libs/concept_check")
    ensure_boost_submodule("libs/container")
    ensure_boost_submodule("libs/intrusive")
    ensure_boost_submodule("libs/function")
    ensure_boost_submodule("libs/io")
    ensure_boost_submodule("libs/algorithm")
    ensure_boost_submodule("libs/range")
    ensure_boost_submodule("libs/type_index")
    ensure_boost_submodule("libs/lexical_cast")
    
    # Added missing exception submodule to fix the exception_ptr.hpp error
    ensure_boost_submodule("libs/exception")
    
    # Added to fix the missing numeric/conversion error
    ensure_boost_submodule("libs/numeric/conversion")
    ensure_boost_submodule("libs/numeric")
    
    # Other potentially needed dependencies
    ensure_boost_submodule("libs/detail")
    ensure_boost_submodule("libs/optional")
    ensure_boost_submodule("libs/ratio")
    ensure_boost_submodule("libs/tokenizer")
    ensure_boost_submodule("libs/fusion")
    ensure_boost_submodule("libs/typeof")
    ensure_boost_submodule("libs/array")
    ensure_boost_submodule("libs/tuple")
    ensure_boost_submodule("libs/functional")
    
    # Set platform-specific variables
    if(WIN32)
        set(BOOST_BOOTSTRAP_COMMAND bootstrap.bat)
        set(BOOST_B2_COMMAND b2.exe)
    else()
        set(BOOST_BOOTSTRAP_COMMAND ./bootstrap.sh)
        set(BOOST_B2_COMMAND ./b2)
    endif()
    
    # Define our imported library for Boost
    add_library(boost_lib INTERFACE IMPORTED GLOBAL)
    
    # We'll actually build Boost here in the MAIN phase
    message(STATUS "Bootstrapping and building Boost...")
    
    # Bootstrap Boost (generate b2/bjam)
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/external/boost/b2.exe" AND WIN32)
        message(STATUS "Running Boost bootstrap...")
        execute_process(
            COMMAND ${BOOST_BOOTSTRAP_COMMAND}
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/external/boost"
            RESULT_VARIABLE BOOTSTRAP_RESULT
            ERROR_VARIABLE BOOTSTRAP_ERROR
            OUTPUT_VARIABLE BOOTSTRAP_OUTPUT
        )
        
        # Output the bootstrap results for diagnostics
        message(STATUS "Bootstrap output: ${BOOTSTRAP_OUTPUT}")
        if(NOT BOOTSTRAP_RESULT EQUAL 0)
            message(STATUS "Bootstrap error: ${BOOTSTRAP_ERROR}")
            message(FATAL_ERROR "Boost bootstrap failed with exit code: ${BOOTSTRAP_RESULT}")
        endif()
    endif()
    
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/external/boost/b2" AND NOT WIN32)
        message(STATUS "Running Boost bootstrap...")
        execute_process(
            COMMAND ${BOOST_BOOTSTRAP_COMMAND}
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/external/boost"
            RESULT_VARIABLE BOOTSTRAP_RESULT
            ERROR_VARIABLE BOOTSTRAP_ERROR
            OUTPUT_VARIABLE BOOTSTRAP_OUTPUT
        )
        
        # Output the bootstrap results for diagnostics
        message(STATUS "Bootstrap output: ${BOOTSTRAP_OUTPUT}")
        if(NOT BOOTSTRAP_RESULT EQUAL 0)
            message(STATUS "Bootstrap error: ${BOOTSTRAP_ERROR}")
            message(FATAL_ERROR "Boost bootstrap failed with exit code: ${BOOTSTRAP_RESULT}")
        endif()
    endif()
    
    # Set up installation directories
    set(BOOST_INSTALL_DIR "${CMAKE_BINARY_DIR}/boost_install")
    file(MAKE_DIRECTORY "${BOOST_INSTALL_DIR}")
    file(MAKE_DIRECTORY "${BOOST_INSTALL_DIR}/include")
    file(MAKE_DIRECTORY "${BOOST_INSTALL_DIR}/include/boost")
    file(MAKE_DIRECTORY "${BOOST_INSTALL_DIR}/lib")
    
    # On Windows, we'll handle copying headers differently to avoid symlink issues
    message(STATUS "Setting up Boost headers...")
    
    # Method 1: Copy all Boost headers from the main boost directory to install directory
    # This avoids symlinks by copying files individually
    file(GLOB BOOST_HEADER_DIRS "${CMAKE_SOURCE_DIR}/external/boost/boost/*")
    
    foreach(HEADER_PATH ${BOOST_HEADER_DIRS})
        get_filename_component(HEADER_NAME ${HEADER_PATH} NAME)
        
        if(IS_DIRECTORY ${HEADER_PATH})
            message(STATUS "  Copying header dir: ${HEADER_NAME}")
            # Create the destination directory
            file(MAKE_DIRECTORY "${BOOST_INSTALL_DIR}/include/boost/${HEADER_NAME}")
            
            # Safe copy directory contents
            safe_copy_directory("${HEADER_PATH}" "${BOOST_INSTALL_DIR}/include/boost/${HEADER_NAME}")
        else()
            # Copy individual header files in the root boost directory
            message(STATUS "  Copying header file: ${HEADER_NAME}")
            safe_copy_file("${HEADER_PATH}" "${BOOST_INSTALL_DIR}/include/boost/${HEADER_NAME}")
        endif()
    endforeach()
    
    # Method 2: Explicitly copy headers from libs directories
    # This addresses the exception library and other libraries that might not be correctly symlinked
    
    # List of important library header locations to check
    set(IMPORTANT_LIBS
        "exception"
        "numeric/conversion"
        "utility/detail"
    )
    
    foreach(LIB ${IMPORTANT_LIBS})
        # For libs with multiple levels, we need to create parent directories
        string(REPLACE "/" ";" LIB_PARTS ${LIB})
        set(CURRENT_DIR "${BOOST_INSTALL_DIR}/include/boost")
        foreach(PART ${LIB_PARTS})
            set(CURRENT_DIR "${CURRENT_DIR}/${PART}")
            file(MAKE_DIRECTORY "${CURRENT_DIR}")
        endforeach()
        
        # Check possible locations for headers
        set(POSSIBLE_PATHS
            "${CMAKE_SOURCE_DIR}/external/boost/boost/${LIB}"
            "${CMAKE_SOURCE_DIR}/external/boost/libs/${LIB}/include/boost/${LIB}"
        )
        
        # Handle the case where LIB has a slash
        string(REPLACE "/" ";" LIB_PATH_PARTS ${LIB})
        list(GET LIB_PATH_PARTS 0 LIB_FIRST_PART)
        if(LIB_PATH_PARTS)
            list(APPEND POSSIBLE_PATHS "${CMAKE_SOURCE_DIR}/external/boost/libs/${LIB_FIRST_PART}/include/boost/${LIB}")
        endif()
        
        set(FOUND_PATH FALSE)
        foreach(PATH ${POSSIBLE_PATHS})
            if(EXISTS "${PATH}")
                message(STATUS "  Explicitly copying ${LIB} headers from ${PATH}")
                safe_copy_directory("${PATH}" "${BOOST_INSTALL_DIR}/include/boost/${LIB}")
                set(FOUND_PATH TRUE)
                break()
            endif()
        endforeach()
        
        if(NOT FOUND_PATH)
            message(WARNING "Could not find headers for ${LIB} in any of the checked locations")
        endif()
    endforeach()
    
    # Special handling for exception detail directory 
    if(EXISTS "${CMAKE_SOURCE_DIR}/external/boost/libs/exception/include/boost/exception/detail")
        file(MAKE_DIRECTORY "${BOOST_INSTALL_DIR}/include/boost/exception/detail")
        safe_copy_directory(
            "${CMAKE_SOURCE_DIR}/external/boost/libs/exception/include/boost/exception/detail"
            "${BOOST_INSTALL_DIR}/include/boost/exception/detail"
        )
    endif()
    
    # Build Boost libraries
    message(STATUS "Building Boost libraries...")
    
    # Set common build options
    set(BOOST_BUILD_OPTIONS
        link=static
        variant=release
        threading=multi
        runtime-link=static
        --build-dir=${CMAKE_BINARY_DIR}/boost_build_output
    )
    
    if(WIN32)
        list(APPEND BOOST_BUILD_OPTIONS
            address-model=64
            toolset=msvc
        )
    endif()
    
    # Build specific libraries
    set(BOOST_LIBRARIES_TO_BUILD filesystem system thread date_time)
    
    # Build each library separately to better handle errors
    foreach(LIB ${BOOST_LIBRARIES_TO_BUILD})
        message(STATUS "Building Boost.${LIB}...")
        
        execute_process(
            COMMAND "${CMAKE_SOURCE_DIR}/external/boost/${BOOST_B2_COMMAND}"
                --with-${LIB}
                ${BOOST_BUILD_OPTIONS}
                --stagedir=${BOOST_INSTALL_DIR}
                stage
            WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/external/boost"
            RESULT_VARIABLE BUILD_RESULT
            ERROR_VARIABLE BUILD_ERROR
            OUTPUT_VARIABLE BUILD_OUTPUT
        )
        
        if(NOT BUILD_RESULT EQUAL 0)
            message(STATUS "Build error for ${LIB}: ${BUILD_ERROR}")
            message(WARNING "Failed to build Boost.${LIB}, continuing with other libraries...")
        else()
            message(STATUS "Successfully built Boost.${LIB}")
        endif()
    endforeach()
    
    # Check if we have any libraries built
    if(WIN32)
        file(GLOB BOOST_LIBS 
            "${BOOST_INSTALL_DIR}/lib/libboost_*.lib"
            "${BOOST_INSTALL_DIR}/lib/boost_*.lib")
    else()
        file(GLOB BOOST_LIBS 
            "${BOOST_INSTALL_DIR}/lib/libboost_*.a"
            "${BOOST_INSTALL_DIR}/lib/libboost_*.so")
    endif()
    
    if(NOT BOOST_LIBS)
        message(STATUS "No libraries found in ${BOOST_INSTALL_DIR}/lib, checking stage directory...")
        
        # Sometimes libraries are built to stage/lib instead
        if(WIN32)
            file(GLOB BOOST_STAGE_LIBS 
                "${CMAKE_SOURCE_DIR}/external/boost/stage/lib/libboost_*.lib"
                "${CMAKE_SOURCE_DIR}/external/boost/stage/lib/boost_*.lib")
        else()
            file(GLOB BOOST_STAGE_LIBS 
                "${CMAKE_SOURCE_DIR}/external/boost/stage/lib/libboost_*.a"
                "${CMAKE_SOURCE_DIR}/external/boost/stage/lib/libboost_*.so")
        endif()
        
        if(BOOST_STAGE_LIBS)
            message(STATUS "Found libraries in stage directory, copying to installation directory...")
            foreach(LIB ${BOOST_STAGE_LIBS})
                get_filename_component(LIB_NAME ${LIB} NAME)
                message(STATUS "  Copying ${LIB_NAME}")
                safe_copy_file("${LIB}" "${BOOST_INSTALL_DIR}/lib/${LIB_NAME}")
            endforeach()
        else()
            message(WARNING "No Boost libraries found in stage directory either. This might cause issues with find_package.")
        endif()
    endif()
    
    # Set up our own imported library target directly
    # Here we set the include directories
    set_target_properties(boost_lib PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${BOOST_INSTALL_DIR}/include"
    )

    # We won't add any specific libraries here - we'll do that in src/CMakeLists.txt
    # which gives us more flexibility to handle version mismatches

    # Make sure target include directories are set
    get_target_property(INCLUDES boost_lib INTERFACE_INCLUDE_DIRECTORIES)
    if(NOT INCLUDES)
        message(WARNING "boost_lib target has no include directories set!")
    else()
        message(STATUS "boost_lib include directories: ${INCLUDES}")
    endif()
    
    # Make sure target link libraries are set
    get_target_property(LIBS boost_lib INTERFACE_LINK_LIBRARIES)
    if(NOT LIBS)
        message(WARNING "boost_lib target has no libraries set! This will cause linker errors.")
    else()
        message(STATUS "boost_lib libraries: ${LIBS}")
    endif()
    
    message(STATUS "Boost configuration complete")
endfunction()