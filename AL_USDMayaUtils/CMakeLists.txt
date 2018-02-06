####################################################################################################
# Setup 
####################################################################################################
cmake_minimum_required(VERSION 2.8.12)
include(RezBuild)
rez_find_packages(PREFIX pkgs AUTO)

set(USDMAYAUTILS_INCLUDE_LOCATION ${CMAKE_CURRENT_LIST_DIR}/src)

set(MAYA_Foundation_LIBRARY Foundation)
set(MAYA_OpenMaya_LIBRARY OpenMaya)

list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/defaults
)

include(CXXDefaults)
add_definitions(${_PXR_CXX_DEFINITIONS})

set(CMAKE_CXX_FLAGS
    -std=c++11
)

####################################################################################################
# General
####################################################################################################
add_subdirectory(src)

add_custom_target(all_tests
    COMMAND echo -e "\n 'all_tests' : AL_USDMayaUtils has no tests\n"
)

####################################################################################################
# Install
####################################################################################################
rez_install_cmake(DESTINATION cmake
    INCLUDE_DIRS include
    LIBRARY_DIRS lib
    LIBRARIES ${LIBRARY_NAME}
    )
