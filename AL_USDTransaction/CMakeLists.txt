####################################################################################################
# Setup 
####################################################################################################
cmake_minimum_required(VERSION 2.8.12)
include(RezBuild)
rez_find_packages(PREFIX pkgs AUTO)
enable_testing()

set(USDTRANSACTION_INCLUDE_LOCATION ${CMAKE_CURRENT_LIST_DIR}/src)

list(APPEND CMAKE_MODULE_PATH
  ${CMAKE_CURRENT_SOURCE_DIR}/cmake/defaults
)

include(CXXDefaults)
add_definitions(${_PXR_CXX_DEFINITIONS})

if(DEFINED boost_NAMESPACE)
  add_definitions("-DBOOST_NAMESPACE=${boost_NAMESPACE}")
else()
  add_definitions("-DBOOST_NAMESPACE=ALboost")
endif()

set(CMAKE_CXX_FLAGS
  -std=c++11 -msse3
)
string(REPLACE ";" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

####################################################################################################
# General
####################################################################################################
add_custom_target(all_tests
  ${CMAKE_CTEST_COMMAND} --output-on-failure
)

add_subdirectory(src)

####################################################################################################
# Install
####################################################################################################
rez_install_cmake(DESTINATION cmake
  INCLUDE_DIRS include
  LIBRARY_DIRS lib
  LIBRARIES ${LIBRARY_NAME}
)
