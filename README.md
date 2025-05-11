# CMake Multi-Library Template

A modern C++ template project that integrates multiple libraries (OpenCV, GLFW, ImGui, Boost) with a CMake-based build system. This template provides a solid foundation for graphics/GUI applications with a two-phase build approach for external dependencies.

## Features

- Integrates multiple commonly used C++ libraries:
  - **OpenCV**: Computer vision and image processing
  - **GLFW**: Window creation and input handling
  - **ImGui**: Immediate-mode GUI (docking branch)
  - **Boost**: Wide range of C++ utilities (filesystem, threading, etc.)
- Two-phase build system to manage dependencies cleanly
- Cross-platform compatibility (Windows, Linux)
- Modular CMake structure for easy expansion
- Pre-configured with working examples

## Prerequisites

- CMake 3.15 or higher
- C++ compiler with C++14 support
- Git
- Visual Studio 2022 (for Windows) or GCC (for Linux)

## Cloning the Repository

This repository uses Git submodules to include external libraries. To clone the repository with all submodules, use the following command:

```bash
# Clone with all submodules at once
git clone --recursive https://github.com/MaelGiese/CMake-multilibs-template.git

# OR, if you've already cloned the repo without --recursive:
git clone https://github.com/MaelGiese/CMake-multilibs-template.git
cd CMake-multilibs-template
git submodule update --init --recursive
```

### ImGui Docking Branch

The ImGui library is configured to use the "docking" branch for enhanced UI capabilities. This is automatically set up during clone if you use the `--recursive` flag. If you need to update or check the ImGui branch:

```bash
# Check current ImGui branch
cd external/imgui
git branch

# If needed, switch to docking branch
git checkout docking

# Go back to project root and update .gitmodules
cd ../..
git add external/imgui
git commit -m "Set ImGui to docking branch"
```

## Building the Project

The build process occurs in two phases:
1. Phase 1: Build all external dependencies
2. Phase 2: Build the main project using those dependencies

### Windows

Run the included batch file:

```bash
build_windows.bat
```

This will:
1. Create and clean the build directory
2. Configure and build external dependencies
3. Configure and build the main application

### Linux

Run the included shell script:

```bash
./build_linux.sh
```

### Manual Build

If you prefer to build manually:

```bash
# Create and enter build directory
mkdir build
cd build

# Phase 1: Build dependencies
cmake .. -DBUILD_PHASE=BUILD_DEPS
cmake --build . --config Release

# Phase 2: Build main project
cmake .. -DBUILD_PHASE=MAIN
cmake --build . --config Release

# Return to project root
cd ..
```

## Running the Application

After building, the executable will be located in:

- Windows: `build/src/Release/multilibs_app.exe`
- Linux: `build/src/multilibs_app`

## Project Structure

```
CMake-multilibs-template/
├── cmake/                     # CMake modules and configuration
│   ├── external/              # Library-specific configuration
│   ├── direct_boost.cmake     # Boost-specific build logic
│   └── ExternalLibraries.cmake # Central dependency manager
├── external/                  # External libraries (submodules)
│   ├── boost/                 # Boost library
│   ├── glfw/                  # GLFW library
│   ├── imgui/                 # ImGui library (docking branch)
│   └── opencv/                # OpenCV library
├── src/                       # Source code
│   ├── CMakeLists.txt         # Main project build configuration
│   └── main.cpp               # Main application code
├── .gitignore                 # Git ignore rules
├── .gitmodules                # Git submodule configuration
├── build_linux.sh             # Linux build script
├── build_windows.bat          # Windows build script
├── CMakeLists.txt             # Root CMake configuration
└── README.md                  # This file
```

## Adding New Dependencies

To add a new external library:

1. Add it as a Git submodule: `git submodule add https://github.com/example/library.git external/library`
2. Create a library configuration file in `cmake/external/library.cmake`
3. Register and configure the library in both build phases

## Customizing

- Modify `src/main.cpp` to build your own application
- Add more source files to `src/` and update `src/CMakeLists.txt` accordingly
- Adjust CMake options in the build scripts as needed

## Troubleshooting

- **Boost Build Errors**: If you encounter issues with Boost libraries, check that the version detected in headers matches the built libraries. The template includes version detection and library name fixes.
- **ImGui Docking**: If ImGui features like docking aren't working, verify that ImGui is on the docking branch.
- **Library Not Found**: Ensure all submodules are properly initialized and updated.

## License

This template is provided under the MIT License. See the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
