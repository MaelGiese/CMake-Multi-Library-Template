# CMake Multi-Library Template

A modern C++ template project that builds multiple external libraries from source as Git submodules. Designed to provide a clean, maintainable foundation for cross-platform C++ projects with complex dependencies.

## Purpose

This template solves a common problem in C++ development: **managing external dependencies**. Instead of relying on pre-built binaries or package managers, it:

1. Uses Git submodules to include library source code
2. Builds libraries from source during the project build process
3. Makes them available to the main application through a consistent interface

## Project Setup

```bash
# Clone with all submodules
git clone --recursive https://github.com/MaelGiese/CMake-Multi-Library-Template.git

# OR clone and initialize submodules separately
git clone https://github.com/MaelGiese/CMake-Multi-Library-Template.git
cd CMake-multilibs-template
git submodule update --init --recursive
```

## Build Process

The template uses a two-phase build system:

1. **Phase 1**: Build all external libraries from source
2. **Phase 2**: Build the main application, linking against the built libraries

### Windows

Run the batch file **as administrator**:

```bash
build_windows.bat
```

### Linux

Run the shell script:

```bash
./build_linux.sh
```

### Manual Build

```bash
mkdir build && cd build

# Phase 1: Dependencies
cmake .. -DBUILD_PHASE=BUILD_DEPS
cmake --build . --config Release

# Phase 2: Main project
cmake .. -DBUILD_PHASE=MAIN
cmake --build . --config Release
```

> **Note**: On Windows, run these commands from an administrator command prompt.

## Project Structure

```
├── cmake/                     # CMake modules and configuration
│   ├── external/              # Library-specific configurations
│   ├── direct_boost.cmake     # Boost-specific build logic
│   └── ExternalLibraries.cmake # Central dependency manager
├── external/                  # External libraries (submodules)
├── src/                       # Application source code
├── build_windows.bat          # Windows build script
├── build_linux.sh             # Linux build script
└── CMakeLists.txt             # Root CMake configuration
```

## How It Works

The build system is based on these key components:

- **ExternalLibraries.cmake**: Central manager for all dependencies
- **Two-phase building**: Separates dependency building from application building
- **Git submodules**: Tracks specific versions of external libraries
- **Imported targets**: Makes libraries available to the main application

## Using as a Template

To use this project as a template for your own:

1. Fork or copy the repository structure
2. Modify `.gitmodules` to include your required libraries
3. Add/update library configuration files in `cmake/external/`
4. Update `src/CMakeLists.txt` and `src/main.cpp` for your application

### Adding a New Library

To add a new external library:

1. Add it as a Git submodule:
   ```bash
   git submodule add https://github.com/example/library.git external/library
   ```

2. Create a configuration file in `cmake/external/library.cmake`:
   ```cmake
   # Register the library
   register_external_library(NAME library)
   
   # Add build phase
   add_external_library_phase(
       NAME library
       PHASE build
       CMAKE_ARGS
           -DBUILD_SHARED_LIBS=OFF
   )
   
   # Configure function for MAIN phase
   function(configure_library)
       # Find the built library
       # Update the imported target
   endfunction()
   ```

3. Link your target with it in `src/CMakeLists.txt`:
   ```cmake
   target_link_with_external(your_app library)
   ```

## Troubleshooting

- **Administrator Access**: On Windows, run build scripts as administrator
- **Submodule Updates**: If libraries change, run `git submodule update --init --recursive`
- **Build Directory**: If build fails, try removing the build directory and starting fresh
- **Version Mismatches**: Some libraries (especially Boost) may have version detection issues

## Cross-Platform Support

The template is designed to work on both Windows and Linux with minimal configuration differences. Key cross-platform considerations are handled in the build scripts and CMake files.

## License

This template is provided under the MIT License.
