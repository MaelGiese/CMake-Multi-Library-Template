# Register OpenCV as an external library
register_external_library(NAME opencv)

# Define OpenCV build configuration for the 'build' phase
add_external_library_phase(
    NAME opencv
    PHASE build
    CMAKE_ARGS
        # Disable unwanted modules
        -DBUILD_opencv_calib3d=OFF
        -DBUILD_opencv_features2d=OFF
        -DBUILD_opencv_flann=OFF
        -DBUILD_opencv_dnn=OFF
        -DBUILD_opencv_ml=OFF
        -DBUILD_opencv_photo=OFF
        -DBUILD_opencv_python_bindings_generator=OFF
        -DBUILD_opencv_python2=OFF
        -DBUILD_opencv_python3=OFF
        -DBUILD_opencv_gapi=OFF
        -DBUILD_opencv_objdetect=OFF
        -DBUILD_opencv_stitching=OFF
        -DBUILD_opencv_ts=OFF
        -DBUILD_opencv_video=OFF
        -DBUILD_opencv_videoio=OFF
        -DBUILD_opencv_world=OFF
        # Build configuration
        -DBUILD_SHARED_LIBS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_PERF_TESTS=OFF
        -DBUILD_PROTOBUF=OFF
        -DBUILD_opencv_apps=OFF
        -DBUILD_DOCS=OFF
        # Performance options
        -DWITH_EIGEN=OFF
        -DCPU_BASELINE=NONE
        -DCPU_DISPATCH=NONE
        -DWITH_IPP=OFF
        -DWITH_ADE=OFF
        # Miscellaneous options
        -DOPENCV_DISABLE_FILESYSTEM_SUPPORT=ON
        -DOPENCV_GENERATE_PKGCONFIG=OFF
)

# Function to find and configure OpenCV after it's built
# This is called during the MAIN build phase
function(configure_opencv)
    # Set OpenCV_DIR to help find_package locate the built OpenCV (platform specific)
    if(WIN32)
        set(OpenCV_DIR ${opencv_INSTALL_DIR}/x64/vc17/staticlib CACHE PATH "Path to OpenCVConfig.cmake")
    else()
        # Linux path
        set(OpenCV_DIR ${opencv_INSTALL_DIR}/lib/cmake/opencv4 CACHE PATH "Path to OpenCVConfig.cmake")
    endif()

    # Find the built OpenCV package
    find_package(OpenCV REQUIRED)
    message(STATUS "Found OpenCV ${OpenCV_VERSION}")
    message(STATUS "OpenCV libraries: ${OpenCV_LIBS}")
    message(STATUS "OpenCV include dirs: ${OpenCV_INCLUDE_DIRS}")

    # Update the imported target with actual include dirs and libraries
    update_external_library(
        NAME opencv
        INCLUDES "${OpenCV_INCLUDE_DIRS}"
        LIBRARIES "${OpenCV_LIBS}"
    )
endfunction()