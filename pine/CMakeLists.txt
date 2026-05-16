cmake_minimum_required(VERSION 3.5)

project(pine)

add_subdirectory(vendor)

add_executable(pine ./src/pine.cpp)

target_link_libraries(pine raylib)
