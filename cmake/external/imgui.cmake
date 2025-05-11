# Register ImGui as an external library
register_external_library(NAME imgui)

# Nothing to build in the BUILD_DEPS phase - we'll build ImGui directly in the MAIN phase
# We just need to register it here so it's recognized by the system

# Function to configure ImGui in the MAIN phase
function(configure_imgui)
    # ImGui source directory
    set(IMGUI_SOURCE_DIR ${CMAKE_SOURCE_DIR}/external/imgui)
    
    # Verify that the ImGui directory exists
    if(NOT EXISTS ${IMGUI_SOURCE_DIR})
        message(FATAL_ERROR "ImGui source directory not found at ${IMGUI_SOURCE_DIR}")
    endif()
    
    # Create an interface library for ImGui
    add_library(imgui_internal STATIC
        ${IMGUI_SOURCE_DIR}/imgui.cpp
        ${IMGUI_SOURCE_DIR}/imgui_demo.cpp
        ${IMGUI_SOURCE_DIR}/imgui_draw.cpp
        ${IMGUI_SOURCE_DIR}/imgui_tables.cpp
        ${IMGUI_SOURCE_DIR}/imgui_widgets.cpp
        ${IMGUI_SOURCE_DIR}/backends/imgui_impl_opengl3.cpp
        ${IMGUI_SOURCE_DIR}/backends/imgui_impl_glfw.cpp
    )
    
    # Add include directories
    target_include_directories(imgui_internal PUBLIC
        ${IMGUI_SOURCE_DIR}
        ${IMGUI_SOURCE_DIR}/backends
    )
    
    # Set C++ standard
    set_target_properties(imgui_internal PROPERTIES
        CXX_STANDARD 14
        CXX_STANDARD_REQUIRED ON
    )
    
    # Link against GLFW - it should be already configured by now
    target_link_libraries(imgui_internal PRIVATE glfw)
    
    message(STATUS "Configured ImGui directly from sources")
    
    # Update the imported target with the actual library
    update_external_library(
        NAME imgui
        INCLUDES "${IMGUI_SOURCE_DIR};${IMGUI_SOURCE_DIR}/backends"
        LIBRARIES "imgui_internal"
    )
endfunction()