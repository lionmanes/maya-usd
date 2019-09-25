#This is a modified version of the cmake file from usd/sdk/maya/CMakeLists.txt
cmake_minimum_required(VERSION 2.8.8)

SET(SUBTREE_DIRECTORY "src/plugin/al")

include ( RezBuild )
rez_find_packages ( PREFIX pkgs AUTO )

# Bake version
string(REPLACE "." ";" AL_USDMAYA_VERSION $ENV{REZ_BUILD_PROJECT_VERSION})
list(GET AL_USDMAYA_VERSION 0 AL_USDMAYA_VERSION_MAJOR)
list(GET AL_USDMAYA_VERSION 1 AL_USDMAYA_VERSION_MINOR)
list(GET AL_USDMAYA_VERSION 2 AL_USDMAYA_VERSION_PATCH)
configure_file(Version.h.in ${CMAKE_CURRENT_SOURCE_DIR}/${SUBTREE_DIRECTORY}/lib/AL_USDMaya/AL/usdmaya/Version.h)

set(BOOST_ROOT ${boost_ROOT})

add_definitions("-DAL_MAYA_ENABLE_SIMD=1")

if(${MAYA_MAJOR_VERSION} GREATER 2018)
    set(UFE_VERSION 1.0.0)
    set(UFE_LIB_ROOT $ENV{REZ_MAYADEVKIT_ROOT}/maya/devkitBase/devkit/ufe)
    set(UFE_INCLUDE_ROOT $ENV{REZ_MAYADEVKIT_ROOT}/maya/devkitBase/devkit/ufe)

    list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/${SUBTREE_DIRECTORY}/cmake/modules)
    message("UFE_LIB_ROOT=${UFE_LIB_ROOT}")
    add_definitions(-DWANT_UFE_BUILD)
    message(STATUS "UFE Build Enabled")
    if (NOT UFE_VERSION)
        message(FATAL_ERROR "UFE_VERSION must be defined when WANT_UFE_BUILD is enabled")
    endif()
    message(STATUS "Using UFE version : ${UFE_VERSION}")
    string(REPLACE "." ";" UFE_VERSION_LIST ${UFE_VERSION})
    list(GET UFE_VERSION_LIST 0 UFE_MAJOR_VERSION)
    list(GET UFE_VERSION_LIST 1 UFE_MINOR_VERSION)
    list(GET UFE_VERSION_LIST 2 UFE_PATCH_LEVEL)
    find_package(UFE REQUIRED)
    include_directories(${UFE_INCLUDE_DIR})
    rez_install_files(ufe/maya-ufe-usd-plugin.py RELATIVE ufe DESTINATION plugin)
    rez_install_files(ufe/maya-ufe-cmd-plugin.py RELATIVE ufe DESTINATION plugin)
    rez_install_dirs(ufe/ufeScripts DESTINATION lib/python)
endif()

IF(DEFINED boost_NAMESPACE)
  add_definitions("-DBOOST_NAMESPACE=${boost_NAMESPACE}")
ELSE()
  add_definitions("-DBOOST_NAMESPACE=boost")
ENDIF()

IF(NOT DEFINED BOOST_LIBRARY_DIRS)
  IF(boost_LIBRARY_DIRS AND boost_python_LIBRARY_DIRS)
      set(Boost_LIBRARY_DIR ${boost_LIBRARY_DIRS} ${boost_python_LIBRARY_DIRS})
  ELSEIF(AL_boost_LIBRARY_DIRS AND AL_boost_python_LIBRARY_DIRS)
      set(Boost_LIBRARY_DIR ${AL_boost_LIBRARY_DIRS} ${AL_boost_python_LIBRARY_DIRS})
  ENDIF()
ENDIF()

#set cmake modules - ";" separated not ":"!
list(APPEND CMAKE_MODULE_PATH
    ${CMAKE_CURRENT_SOURCE_DIR}/src/cmake
    ${CMAKE_CURRENT_SOURCE_DIR}/src/cmake/defaults
    ${CMAKE_CURRENT_SOURCE_DIR}/src/cmake/modules
)

# to get PYTHON_EXECUTABLE

find_package(PythonInterp)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
include(CXXDefaults)

add_definitions(${_PXR_CXX_DEFINITIONS})

find_package(Maya REQUIRED)
set(PYTHON_LIBRARY $ENV{MAYA_LOCATION}/lib/libpython2.7.so CACHE STRING "" FORCE)
find_package(PythonLibs)

# FindBoost is particularly buggy, and doesn't like custom boost locations.
# Adding specific components forces calls to _Boost_find_library, which
# is the rationale for listing them here.
find_package(Boost COMPONENTS
                python # initialises Boost_PYTHON_LIBRARY
                thread # initialises Boost_THREAD_LIBRARY
                REQUIRED
)

if((CMAKE_COMPILER_IS_GNUCC AND (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5.3)) OR
    ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" AND (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 5)))
    set(NEED_BOOST_FILESYSTEM ON)
    find_package(Boost COMPONENTS
                    filesystem # initialises Boost_FILESYSTEM_LIBRARY
                    REQUIRED)
endif()

set(CMAKE_VERBOSE_MAKEFILE OFF)

set(CMAKE_CXX_FLAGS
    -std=c++11
    -msse3
    -Werror
    "${_PXR_CXX_WARNING_FLAGS}"
)
if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 6)
    list(APPEND CMAKE_CXX_FLAGS -D_GLIBCXX_USE_CXX11_ABI=0)
endif()
string(REPLACE ";" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

option(SKIP_USDMAYA_TESTS "Skip test building" OFF)

if(NOT SKIP_USDMAYA_TESTS)
    enable_testing()
endif()

# Path to the input schemas templates
set(USD_SCHEMA_PATH ${PXR_CMAKE_DIR}/schemas/usd/schema.usda)

# This will drive the schemas library and binding library names
set(TRANSLATORS_PACKAGE AL_USDMayaTranslators_opensource)

set(AL_USDMAYA_LOCATION_NAME
    "AL_USDMAYA_LOCATION"
    CACHE
    STRING
    "Name of the environment variable used to store AL_USDMaya installation location"
)

# Build our plugs... non-standard as we're building from another source tree
set(EVENTS_INCLUDE_LOCATION ${CMAKE_CURRENT_LIST_DIR}/${SUBTREE_DIRECTORY}/utils)
set(USDUTILS_INCLUDE_LOCATION ${CMAKE_CURRENT_LIST_DIR}/${SUBTREE_DIRECTORY}/usdutils)
set(MAYAUTILS_INCLUDE_LOCATION ${CMAKE_CURRENT_LIST_DIR}/${SUBTREE_DIRECTORY}/mayautils)
set(USDMAYAUTILS_INCLUDE_LOCATION ${CMAKE_CURRENT_LIST_DIR}/${SUBTREE_DIRECTORY}/usdmayautils)
set(MAYATEST_INCLUDE_LOCATION ${CMAKE_CURRENT_LIST_DIR}/${SUBTREE_DIRECTORY}/mayatest)

# pxrUsd translator uses this
set(PROJECT_SOURCE_DIR "${CMAKE_SOURCE_DIR}/${SUBTREE_DIRECTORY}")
# Build usdMaya pxr translator
set(USD_MAYA_ROOT ${usdMaya_ROOT})
set(USD_ROOT ${usdBase_ROOT})
find_package(USD)

add_subdirectory(${SUBTREE_DIRECTORY}/utils)
add_subdirectory(${SUBTREE_DIRECTORY}/usdutils)
if(NOT SKIP_USDMAYA_TESTS)
	add_subdirectory(${SUBTREE_DIRECTORY}/mayatest)
endif()
add_subdirectory(${SUBTREE_DIRECTORY}/mayautils)
add_subdirectory(${SUBTREE_DIRECTORY}/usdmayautils)
add_subdirectory(${SUBTREE_DIRECTORY}/lib)
add_subdirectory(${SUBTREE_DIRECTORY}/plugin)
add_subdirectory(${SUBTREE_DIRECTORY}/schemas)
add_subdirectory(${SUBTREE_DIRECTORY}/translators)

# The opensource build has our these custom SdfMetadata in the schema plugInfo.json:

#   - al_usdmaya_mergedTransform
#   - al_usdmaya_selectability
#   - al_usdmaya_lock
#   - al_usdmaya_importAsNative
#   - al_usdmaya_excludeFromProxyShape
#   - al_usdmaya_transformType
#   - al_usdmaya_*
# Internally, these metadatas have been kept in AL_USDCommonSchemas for the cases we want to access them
# without depending on AL_USDMaya therefore we're going to filter these metadatas out.
set(to_filter
    ${CMAKE_CURRENT_BINARY_DIR}/${SUBTREE_DIRECTORY}/schemas/AL/usd/schemas/maya/plugInfo.json
)

message(
    STATUS
    "Removing opensource metadatas from ${to_filter}"
)
execute_process(
    COMMAND
        python
        ${CMAKE_CURRENT_SOURCE_DIR}/schemas/filter_pluginfo.py
        ${to_filter}
    RESULT_VARIABLE
        filter_pluginfo
)

if(filter_pluginfo)
    message(
        FATAL_ERROR
        "An error occured while filtering ${to_filter}"
    )
endif()

IF ($ENV{REZ_BUILD_VARIANT_NUMBER} STREQUAL "0")
    set(doxygen_dirs
        ${CMAKE_CURRENT_SOURCE_DIR}/${SUBTREE_DIRECTORY}/lib/AL_USDMaya/AL
        ${CMAKE_CURRENT_SOURCE_DIR}/${SUBTREE_DIRECTORY}/doxygen
    )

    rez_install_doxygen(
        doc
        FILES             ${doxygen_dirs}
        DESTINATION       doc
        DOXYFILE          ${CMAKE_CURRENT_SOURCE_DIR}/${SUBTREE_DIRECTORY}/doxygen/Doxyfile
        GENERATE_TAGFILE
        USE_TAGFILES
        INSTALL_DOXYFILE
        SKIP_INSTALL
    )
    push_docs_to_gh_pages(
    	REPOSITORY AL_USDMaya
    )
ELSE()
  add_custom_target(doc)
ENDIF()

install(FILES cmake/AL_USDMaya.cmake DESTINATION cmake)

get_property(LIBRARY_LOCATION GLOBAL PROPERTY GLOBAL_LIBRARY_LOCATION)
get_property(PYTHON_LIBRARY_LOCATION GLOBAL PROPERTY GLOBAL_PYTHON_LIBRARY_LOCATION)
configure_file(${SUBTREE_DIRECTORY}/ALUsdMayaConfig.cmake.in ${PROJECT_BINARY_DIR}/ALUsdMayaConfig.cmake @ONLY)

install(FILES ${PROJECT_BINARY_DIR}/ALUsdMayaConfig.cmake
  DESTINATION ${CMAKE_INSTALL_PREFIX}
  COMPONENT dev
)

if(MAYA_API_VERSION STRLESS 201700)
    # AL_usdmaya_UnitTestHarness will hang maya 2016 (see PXR_MAYA_TBB_WORKAROUND)
    # Exclude it for now for maya 2016 variant
    message(STATUS
        "Skipping AL_USDMayaTestPlugin for maya 2016 tests because of tbb bug"
    )
    add_custom_target(all_tests
        ${CMAKE_CTEST_COMMAND} --output-on-failure -E "TestAL_USDMaya"
    )
else()
    add_custom_target(all_tests
        ${CMAKE_CTEST_COMMAND} --output-on-failure
    )
endif()

rez_install_files(mel/${MAYA_MAJOR_VERSION}/al_usdmaya_autoload.mel RELATIVE mel/${MAYA_MAJOR_VERSION} DESTINATION mel)
