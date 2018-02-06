####################################################################################################
# Setup 
####################################################################################################
cmake_minimum_required(VERSION 2.8.12)
include(RezBuild)
rez_find_packages(PREFIX pkgs AUTO)

set(MAYAUTILS_INCLUDE_LOCATION ${CMAKE_CURRENT_LIST_DIR}/src)

set(MAYA_Foundation_LIBRARY Foundation)
set(MAYA_OpenMaya_LIBRARY OpenMaya)
set(MAYA_OpenMayaAnim_LIBRARY OpenMayaAnim)
set(MAYA_OpenMayaUI_LIBRARY OpenMayaUI)
  
set(CMAKE_CXX_FLAGS
    -std=c++11
)

####################################################################################################
# General
####################################################################################################
add_subdirectory(src)
    

add_custom_target(all_tests
    ${CMAKE_CTEST_COMMAND}
)

####################################################################################################
# Install
####################################################################################################
rez_install_cmake(DESTINATION cmake
    INCLUDE_DIRS include
    LIBRARY_DIRS lib
    LIBRARIES ${LIBRARY_NAME}
    )
