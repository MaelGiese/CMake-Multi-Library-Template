# Register GLFW as an external library
register_external_library(NAME glfw)

# Define GLFW build configuration for the 'build' phase
add_external_library_phase(
    NAME glfw
    PHASE build
    CMAKE_ARGS
        # Build configuration
        -DBUILD_SHARED_LIBS=OFF
        -DGLFW_BUILD_EXAMPLES=OFF
        -DGLFW_BUILD_TESTS=OFF
        -DGLFW_BUILD_DOCS=OFF
        -DGLFW_INSTALL=ON
        # Optional components - can be turned on if needed
        -DGLFW_USE_WAYLAND=OFF
)

# Function to find and configure GLFW after it's built
# This is called during the MAIN build phase
function(configure_glfw)
    # Set variables to help find_package locate the built GLFW (platform specific)
    if(WIN32)
        set(glfw3_DIR ${glfw_INSTALL_DIR}/lib/cmake/glfw3 CACHE PATH "Path to glfw3Config.cmake")
    else()
        # Linux path
        set(glfw3_DIR ${glfw_INSTALL_DIR}/lib/cmake/glfw3 CACHE PATH "Path to glfw3Config.cmake")
    endif()
    
    # Find the built GLFW package
    find_package(glfw3 REQUIRED)
    message(STATUS "Found GLFW3 ${glfw3_VERSION}")
    
    # Get the include directories
    get_target_property(GLFW_INCLUDE_DIRS glfw INTERFACE_INCLUDE_DIRECTORIES)
    
    # Update the imported target with actual include dirs and libraries
    update_external_library(
        NAME glfw
        INCLUDES "${GLFW_INCLUDE_DIRS}"
        LIBRARIES "glfw"
    )
endfunction()