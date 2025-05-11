#include <iostream>
#include <string>

// OpenCV includes
#include <opencv2/core.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>

// GLFW include - must come before ImGui
#include <GLFW/glfw3.h>

// ImGui includes
#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"

// Print Boost configuration first
#include <boost/config.hpp>

// Boost includes
#include <boost/version.hpp>
#include <boost/filesystem.hpp>
#include <boost/system/error_code.hpp>
#include <boost/thread.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>

// On Windows, we need to include Windows.h for OpenGL functions
#ifdef _WIN32
#include <Windows.h>
#include <GL/gl.h>
#endif

// Function to convert OpenCV Mat to OpenGL texture
GLuint matToTexture(const cv::Mat &mat) {
    // Convert BGR to RGB for OpenGL (OpenGL uses RGB)
    cv::Mat temp;
    cv::cvtColor(mat, temp, cv::COLOR_BGR2RGB);
    
    // Generate a texture ID
    GLuint textureID;
    glGenTextures(1, &textureID);
    
    // Bind to the texture
    glBindTexture(GL_TEXTURE_2D, textureID);
    
    // Set texture parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    // Set texture data - use GL_RGB format since we converted the image
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, temp.cols, temp.rows, 0, GL_RGB, GL_UNSIGNED_BYTE, temp.data);
    
    return textureID;
}

namespace fs = boost::filesystem;

int main() {
	
	    // Print detailed Boost version information
    std::cout << "=========================" << std::endl;
    std::cout << "Boost Version Information" << std::endl;
    std::cout << "=========================" << std::endl;
    std::cout << "Using Boost version: " 
              << BOOST_VERSION / 100000 << "." 
              << BOOST_VERSION / 100 % 1000 << "." 
              << BOOST_VERSION % 100 
              << std::endl;
    std::cout << "Boost LIB_VERSION: " << BOOST_LIB_VERSION << std::endl;
              
    // Print compiler information
    std::cout << "Compiler: ";
#if defined(_MSC_VER)
    std::cout << "MSVC " << _MSC_VER;
#elif defined(__GNUC__)
    std::cout << "GCC " << __GNUC__ << "." << __GNUC_MINOR__;
#else
    std::cout << "Unknown";
#endif
    std::cout << std::endl;

#ifdef BOOST_ALL_NO_LIB
    std::cout << "BOOST_ALL_NO_LIB is defined (auto-linking disabled)" << std::endl;
#else
    std::cout << "BOOST_ALL_NO_LIB is NOT defined (auto-linking enabled)" << std::endl;
#endif
    std::cout << "=========================" << std::endl;
    
    // Test Boost Filesystem
    std::cout << "Current path: " << fs::current_path() << std::endl;
    
    // Test Boost System
    boost::system::error_code ec;
    fs::directory_iterator dir_iter(fs::current_path(), ec);
    if (ec) {
        std::cout << "Error: " << ec.message() << std::endl;
    }
    
    // Test Boost Thread
    std::cout << "Sleeping for 1 second..." << std::endl;
    boost::this_thread::sleep_for(boost::chrono::seconds(1));
    
    // Test Boost Date/Time
    boost::posix_time::ptime now = boost::posix_time::second_clock::local_time();
    std::cout << "Current time: " << now << std::endl;
	
	
	
	
	
	
	
	
    std::cout << "OpenCV version: " << CV_VERSION << std::endl;
    
    // Initialize GLFW
    if (!glfwInit()) {
        std::cerr << "Failed to initialize GLFW" << std::endl;
        return -1;
    }
    
    // GL 3.0 + GLSL 130
    const char* glsl_version = "#version 130";
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);
    
    // Create window with graphics context
    GLFWwindow* window = glfwCreateWindow(1280, 720, "OpenCV + ImGui + GLFW + Boost Example", NULL, NULL);
    if (window == NULL) {
        std::cerr << "Failed to create GLFW window" << std::endl;
        glfwTerminate();
        return -1;
    }
    glfwMakeContextCurrent(window);
    glfwSwapInterval(1); // Enable vsync
    
    // Initialize ImGui
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO();
    
    // Enable docking
    io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;
    // Optionally enable multi-viewport support
    // io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;
    
    // Setup Platform/Renderer backends
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init(glsl_version);
    
    // Setup style
    ImGui::StyleColorsDark();
    if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
        ImGui::GetStyle().WindowRounding = 0.0f;
        ImGui::GetStyle().Colors[ImGuiCol_WindowBg].w = 1.0f;
    }
    
    // Create a simple test image using OpenCV
    cv::Mat image(300, 300, CV_8UC3, cv::Scalar(255, 255, 255));
    cv::circle(image, cv::Point(150, 150), 100, cv::Scalar(0, 0, 255), 3);
    
    // Convert the OpenCV image to an OpenGL texture
    GLuint textureID = matToTexture(image);
    
    // Main loop
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
        
        // Start the ImGui frame
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();
        
        // Create the dockspace
        // ImGui::DockSpaceOverViewport(ImGui::GetMainViewport());
        
        // Create Image window
        ImGui::Begin("OpenCV Image");
        
        // Display the image in ImGui - properly cast the texture ID to ImTextureID
        ImGui::Image((ImTextureID)(intptr_t)textureID, ImVec2(300, 300));
        
        // Add some controls
        static float circleRadius = 100.0f;
        if (ImGui::SliderFloat("Circle Radius", &circleRadius, 10.0f, 150.0f)) {
            // Update the image when the slider changes
            image = cv::Scalar(255, 255, 255);
            cv::circle(image, cv::Point(150, 150), (int)circleRadius, cv::Scalar(0, 0, 255), 3);
            
            // Update the texture - convert BGR to RGB first
            cv::Mat temp;
            cv::cvtColor(image, temp, cv::COLOR_BGR2RGB);
            glBindTexture(GL_TEXTURE_2D, textureID);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, temp.cols, temp.rows, 0, GL_RGB, GL_UNSIGNED_BYTE, temp.data);
        }
        
        ImGui::End();
        
        // Create a settings window to demonstrate docking functionality
        ImGui::Begin("Settings");
        ImGui::Text("Application Settings");
        ImGui::Separator();
        
        static bool enableFeatureX = false;
        ImGui::Checkbox("Enable Feature X", &enableFeatureX);
        
        static float value = 0.5f;
        ImGui::SliderFloat("Value", &value, 0.0f, 1.0f);
        
        static int counter = 0;
        if (ImGui::Button("Button")) {
            counter++;
        }
        ImGui::SameLine();
        ImGui::Text("Counter = %d", counter);
        
        ImGui::End();
        
        // Rendering
        ImGui::Render();
        int display_w, display_h;
        glfwGetFramebufferSize(window, &display_w, &display_h);
        glViewport(0, 0, display_w, display_h);
        glClearColor(0.45f, 0.55f, 0.60f, 1.00f);
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
        
        // Update and Render additional Platform Windows
        if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable) {
            ImGui::UpdatePlatformWindows();
            ImGui::RenderPlatformWindowsDefault();
            glfwMakeContextCurrent(window);
        }
        
        glfwSwapBuffers(window);
    }
    
    // Cleanup
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();
    
    glDeleteTextures(1, &textureID);
    glfwDestroyWindow(window);
    glfwTerminate();
    
    return 0;
}