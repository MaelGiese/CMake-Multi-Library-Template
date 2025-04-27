# CMake External Libraries Template

A lightweight, cross-platform CMake template for C++ projects that need to build and link against external libraries from source.

## What This Template Does

This template provides a clean and consistent way to:

1. Build external C++ libraries from source (as Git submodules)
2. Configure them with custom options
3. Make them available to your main project
4. All while keeping configuration modular and maintainable

It works on both Windows and Linux, using a two-phase build process that handles dependencies correctly.

## Key Features

- **Modular Design**: Each external library has its own isolated configuration file
- **Cross-Platform**: Works on both Windows and Linux
- **Two-Phase Build**: Handles the "dependency problem" in CMake
- **Git Submodules**: Tracks external libraries properly in your repository
- **Static Linking**: Configured for static builds by default to avoid runtime dependencies
- **Clean Structure**: Organized file layout that scales to multiple libraries

## Project Structure

```
your-project/
├── cmake/
│   ├── ExternalLibraries.cmake     # Core framework
│   ├── external/
│   │   └── opencv.cmake            # One file per external library
│   └── templates/
│       └── library.cmake.template  # Template for new libraries
├── external/
│   └── opencv/                     # Git submodules for libraries
├── src/
│   ├── CMakeLists.txt              # Your project's code
│   └── main.cpp
├── build_windows.bat                       # Windows build script
├── build_linux.sh                          # Linux build script
└── CMakeLists.txt                  # Main project file
```

## How to Use This Template

### Step 1: Clone and Initialize

```bash
# Clone this template
git clone https://github.com/MaelGiese/OpenCV-CMake-Template.git my-project --recursive
cd my-project
```

### Step 2: Build the Project

#### On Windows:
```batch
build_windows.bat
```

#### On Linux:
```bash
chmod +x build.sh
./build_linux.sh
```

### Step 3: Adding a New External Library

1. **Add the library as a submodule**:
   ```bash
   git submodule add https://github.com/example/library.git external/library_name
   ```

2. **Create the library configuration file**:
   - Copy the template: `cp cmake/templates/library.cmake.template cmake/external/library_name.cmake`
   - Edit the file, replacing all instances of:
     - `library_name` with your library's name (e.g., `boost`)
     - `Library` with capitalized name (e.g., `Boost`)
   - Customize the build options for your specific library

3. **Update the main CMakeLists.txt**:
   ```cmake
   # In the MAIN phase section:
   configure_opencv()
   configure_library_name()  # Add this line with your library's name
   ```

4. **Link with the library in your code**:
   ```cmake
   # In src/CMakeLists.txt:
   target_link_with_external(your_executable library_name)
   ```

## How It Works

The template uses a two-phase build process:

1. **BUILD_DEPS Phase**:
   - Builds all external libraries from source
   - Uses the options defined in each library's configuration file
   - Installs libraries to a local directory in the build folder

2. **MAIN Phase**:
   - Finds the built libraries using CMake's `find_package`
   - Makes them available to your main project
   - Builds your actual application

This approach solves the common CMake issue where libraries need to be built before they can be found and used.

## Example: Library Configuration

Here's what a typical library configuration file looks like:

```cmake
# Register the library
register_external_library(NAME boost)

# Define build options
add_external_library_phase(
    NAME boost
    PHASE build
    CMAKE_ARGS
        -DBUILD_SHARED_LIBS=OFF
        -DBOOST_BUILD_EXAMPLES=OFF
        -DBOOST_BUILD_TOOLS=OFF
        -DBOOST_INCLUDE_LIBRARIES=filesystem,system
)

# Define how to find and configure the library
function(configure_boost)
    # Platform-specific paths
    if(WIN32)
        set(Boost_ROOT ${boost_INSTALL_DIR})
    else()
        set(Boost_ROOT ${boost_INSTALL_DIR})
    endif()
    
    # Find the library
    set(Boost_USE_STATIC_LIBS ON)
    find_package(Boost REQUIRED COMPONENTS filesystem system)
    
    # Make it available to the main project
    update_external_library(
        NAME boost
        INCLUDES "${Boost_INCLUDE_DIRS}"
        LIBRARIES "${Boost_LIBRARIES}"
    )
endfunction()
```

## Tips & Best Practices

- **Keep Library Options Minimal**: Only enable the parts of libraries you actually need
- **Customize Installation Paths** if a library has non-standard CMake config locations
- **Handle Platform Differences** in the `configure_*` function for each library
- **Check Library Documentation** for the correct `find_package` usage
- **Consider Library Versions**: Pin specific versions in your Git submodules

## Troubleshooting

### Common Issues:

1. **Library Not Found**: Make sure the `find_package` path is correct for your platform
2. **Build Errors**: Check that you've added all necessary dependencies
3. **Linking Errors**: Ensure you're linking against the correct components

## License

This template is available under the MIT License.
