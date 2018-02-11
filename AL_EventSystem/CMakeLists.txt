####################################################################################################
# Setup 
####################################################################################################
cmake_minimum_required(VERSION 2.8.12)
include(RezBuild)
rez_find_packages(PREFIX pkgs AUTO)

set(EVENTS_INCLUDE_LOCATION ${CMAKE_CURRENT_LIST_DIR}/src)

list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/defaults
)

set(CMAKE_CXX_FLAGS
    -std=c++11
)

####################################################################################################
# General
####################################################################################################
add_subdirectory(src)

add_custom_target(all_tests
    COMMAND echo -e "\n 'all_tests' : AL_EventSystem has no tests\n"
)

####################################################################################################
# Install
####################################################################################################
rez_install_cmake(DESTINATION cmake
    INCLUDE_DIRS include
    LIBRARY_DIRS lib
    LIBRARIES ${LIBRARY_NAME}
    )

