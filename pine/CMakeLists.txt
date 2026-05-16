cmake_minimum_required(VERSION 3.5)

project(pine)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON CACHE INTERNAL "") # works

add_subdirectory(vendor)

add_executable(pine ./src/pine.cpp)

target_link_libraries(pine raylib)
