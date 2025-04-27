# Register the library as an external dependency
register_external_library(NAME library_name)

# Define the library's build configuration
add_external_library_phase(
    NAME library_name
    PHASE build
    CMAKE_ARGS
        # Library-specific build options go here
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        # Add more options as needed for this specific library
)

# Function to find and configure the library after it's built
# This is called during the MAIN build phase
function(configure_library_name)
    # Set variables needed to help find_package locate the library (platform specific)
    if(WIN32)
        set(Library_DIR ${library_name_INSTALL_DIR}/lib/cmake/Library CACHE PATH "Path to LibraryConfig.cmake")
    else()
        # Linux path - may need adjustment based on the specific library
        set(Library_DIR ${library_name_INSTALL_DIR}/lib/cmake/Library CACHE PATH "Path to LibraryConfig.cmake")
    endif()

    # Find the built library package
    find_package(Library REQUIRED)
    message(STATUS "Found Library ${Library_VERSION}")

    # Update the imported target with actual include dirs and libraries
    update_external_library(
        NAME library_name
        INCLUDES "${Library_INCLUDE_DIRS}"
        LIBRARIES "${Library_LIBRARIES}"
    )
endfunction()