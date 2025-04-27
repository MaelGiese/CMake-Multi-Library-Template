add_executable(opencv_app main.cpp)

# Link with OpenCV using the central linking function
target_link_with_external(opencv_app opencv)