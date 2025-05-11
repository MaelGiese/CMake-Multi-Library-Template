add_executable(multilibs_app main.cpp)

# Link with external libraries
target_link_with_external(multilibs_app opencv)
target_link_with_external(multilibs_app glfw)
target_link_with_external(multilibs_app imgui)

# Add additional system dependencies needed by OpenGL/GLFW
if(WIN32)
    # Windows needs these libraries
    target_link_libraries(multilibs_app PRIVATE opengl32 gdi32)
elseif(UNIX AND NOT APPLE)
    # Linux needs these additional libraries for GLFW
    find_package(X11 REQUIRED)
    target_link_libraries(multilibs_app PRIVATE ${X11_LIBRARIES})
    
    # OpenGL
    find_package(OpenGL REQUIRED)
    target_link_libraries(multilibs_app PRIVATE OpenGL::GL)
    
    # Threading
    find_package(Threads REQUIRED)
    target_link_libraries(multilibs_app PRIVATE Threads::Threads)
    
    # Additional libraries that might be needed
    target_link_libraries(multilibs_app PRIVATE dl)
endif()


# CRITICAL: Disable Boost auto-linking feature in MSVC by defining this preprocessor variable
target_compile_definitions(multilibs_app PRIVATE 
    BOOST_ALL_NO_LIB  # This disables Boost's auto-linking feature
)

# Set the include directories first
target_include_directories(multilibs_app PRIVATE 
    ${CMAKE_BINARY_DIR}/boost_install/include
)

# Find all Boost libraries in both install and stage directories
file(GLOB ALL_BOOST_LIBS 
    "${CMAKE_BINARY_DIR}/boost_install/lib/libboost_*.lib"
    "${CMAKE_BINARY_DIR}/boost_install/lib/boost_*.lib"
    "${CMAKE_SOURCE_DIR}/external/boost/stage/lib/libboost_*.lib"
    "${CMAKE_SOURCE_DIR}/external/boost/stage/lib/boost_*.lib")

# Print found libraries for debugging
message(STATUS "Found these Boost libraries:")
foreach(LIB ${ALL_BOOST_LIBS})
    message(STATUS "  ${LIB}")
endforeach()

# Define the list of required Boost libraries
set(REQUIRED_LIBS filesystem system thread date_time)

# Create local links to the libraries with the correct version number
# This is needed to avoid mismatches between header version info and actual library names
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/fixed_libs")

# Process each library
foreach(LIB_PATH ${ALL_BOOST_LIBS})
    get_filename_component(LIB_FILE ${LIB_PATH} NAME)
    
    # Only process x64 libraries to avoid duplication
    string(FIND "${LIB_FILE}" "x64" X64_POS)
    if(${X64_POS} GREATER_EQUAL 0)
        # Extract the library base name by removing version and architecture info
        string(REGEX REPLACE "(libboost_[a-z_]+)-.*" "\\1" LIB_BASE_NAME "${LIB_FILE}")
        
        # Create a fixed version with both 1_88 and 1_89 version numbers to be safe
        foreach(VERSION_NUM "1_88" "1_89")
            set(FIXED_LIB_NAME "${LIB_BASE_NAME}-vc143-mt-s-x64-${VERSION_NUM}.lib")
            set(FIXED_LIB_PATH "${CMAKE_BINARY_DIR}/fixed_libs/${FIXED_LIB_NAME}")
            
            # Copy the library to the fixed name
            message(STATUS "Creating fixed version: ${FIXED_LIB_PATH}")
            configure_file(${LIB_PATH} ${FIXED_LIB_PATH} COPYONLY)
        endforeach()
    endif()
endforeach()

# Add the fixed_libs directory to the link directories
link_directories(${CMAKE_BINARY_DIR}/fixed_libs)

# Find and link each required library directly based on a partial match
foreach(LIB_NAME ${REQUIRED_LIBS})
    # Find libraries matching this name pattern
    set(FOUND_LIB FALSE)
    foreach(LIB_PATH ${ALL_BOOST_LIBS})
        # Get just the filename part
        get_filename_component(LIB_FILE ${LIB_PATH} NAME)
        # Check if the filename contains the required library name
        string(FIND "${LIB_FILE}" "boost_${LIB_NAME}" POS)
        if(${POS} GREATER_EQUAL 0)
            # We want the 64-bit version if available
            string(FIND "${LIB_FILE}" "x64" X64_POS)
            if(${X64_POS} GREATER_EQUAL 0)
                message(STATUS "Linking with ${LIB_PATH} for Boost.${LIB_NAME}")
                target_link_libraries(multilibs_app PRIVATE ${LIB_PATH})
                set(FOUND_LIB TRUE)
                break()
            endif()
        endif()
    endforeach()
    
    # If we didn't find the 64-bit lib, try any version of the lib
    if(NOT FOUND_LIB)
        foreach(LIB_PATH ${ALL_BOOST_LIBS})
            get_filename_component(LIB_FILE ${LIB_PATH} NAME)
            string(FIND "${LIB_FILE}" "boost_${LIB_NAME}" POS)
            if(${POS} GREATER_EQUAL 0)
                message(STATUS "Linking with ${LIB_PATH} for Boost.${LIB_NAME}")
                target_link_libraries(multilibs_app PRIVATE ${LIB_PATH})
                set(FOUND_LIB TRUE)
                break()
            endif()
        endforeach()
    endif()
    
    if(NOT FOUND_LIB)
        message(FATAL_ERROR "Could not find any library for Boost.${LIB_NAME}")
    endif()
endforeach()

# Also explicitly link against any additional Boost dependencies
# that might be needed (like chrono and atomic for thread)
foreach(LIB_PATH ${ALL_BOOST_LIBS})
    get_filename_component(LIB_FILE ${LIB_PATH} NAME)
    foreach(ADDITIONAL_LIB chrono atomic)
        string(FIND "${LIB_FILE}" "boost_${ADDITIONAL_LIB}" POS)
        if(${POS} GREATER_EQUAL 0)
            string(FIND "${LIB_FILE}" "x64" X64_POS)
            if(${X64_POS} GREATER_EQUAL 0)
                message(STATUS "Linking with additional dependency ${LIB_PATH}")
                target_link_libraries(multilibs_app PRIVATE ${LIB_PATH})
                break()
            endif()
        endif()
    endforeach()
endforeach()

# Also, get additional diagnostics info
message(STATUS "Checking final library linkage:")
get_target_property(FINAL_LIBS multilibs_app LINK_LIBRARIES)
message(STATUS "multilibs_app link libraries: ${FINAL_LIBS}")