#!/bin/bash

echo "Cleaning build directory..."
rm -rf build
mkdir -p build

echo "Phase 1: Building external dependencies..."
cd build
cmake .. -DBUILD_PHASE=BUILD_DEPS
if [ $? -ne 0 ]; then
  echo "CMake configuration for external dependencies failed."
  exit 1
fi

# Build with appropriate parallelism
num_processors=$(nproc)
cmake --build . --config Release -- -j${num_processors}
if [ $? -ne 0 ]; then
  echo "External dependencies build failed."
  exit 1
fi

echo "Phase 2: Building main project..."
cmake .. -DBUILD_PHASE=MAIN
if [ $? -ne 0 ]; then
  echo "CMake configuration for main project failed."
  exit 1
fi

cmake --build . --config Release -- -j${num_processors}
if [ $? -ne 0 ]; then
  echo "Main project build failed."
  exit 1
fi

cd ..

echo ""
echo "Build complete. To run the application, execute:"
echo "  ./build/src/opencv_app"

exit 0