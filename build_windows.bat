@echo off
setlocal enabledelayedexpansion

echo Cleaning build directory...
if exist build rmdir /s /q build
mkdir build

echo Phase 1: Building external dependencies...
cd build
cmake .. -DBUILD_PHASE=BUILD_DEPS
if %ERRORLEVEL% neq 0 (
  echo CMake configuration for external dependencies failed.
  goto error
)

cmake --build . --config Release -- /m:%NUMBER_OF_PROCESSORS%
if %ERRORLEVEL% neq 0 (
  echo External dependencies build failed.
  goto error
)

echo Phase 2: Building main project...
cmake .. -DBUILD_PHASE=MAIN
if %ERRORLEVEL% neq 0 (
  echo CMake configuration for main project failed.
  goto error
)

cmake --build . --config Release -- /m:%NUMBER_OF_PROCESSORS%
if %ERRORLEVEL% neq 0 (
  echo Main project build failed.
  goto error
)

cd ..

echo.
echo Build complete. To run the application, execute:
echo   .\build\src\Release\opencv_app.exe
goto end

:error
echo Build failed! Check the errors above.
pause
exit /b 1

:end
pause