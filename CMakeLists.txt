cmake_minimum_required(VERSION 3.7.2)
project( midi2osc-ardour )
SET(CMAKE_CXX_FLAGS "-std=c++11")

# cmake --help-module-list
# else add modules to this path:
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

# ALSA dependency
find_package(ALSA REQUIRED)
include_directories(${ALSA_INCLUDE_DIRS})
set(LIBS ${LIBS} ${ALSA_LIBRARIES})

# Liblo dependency
find_package(Liblo REQUIRED)
include_directories(${LIBLO_INCLUDE_DIRS})
set(LIBS ${LIBS} ${LIBLO_LIBRARIES})

find_package(BISON 3.0.4 REQUIRED)
BISON_TARGET(MidiEventParser ${CMAKE_SOURCE_DIR}/src/parser.y ${CMAKE_CURRENT_BINARY_DIR}/parser.cpp)

file(GLOB_RECURSE SOURCES
    src/*.hpp
    src/*.cpp
)

add_executable( midi2osc-ardour ${SOURCES} ${BISON_MidiEventParser_OUTPUTS})
target_link_libraries( midi2osc-ardour ${LIBS})
