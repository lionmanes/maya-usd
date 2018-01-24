#This is a modified version of the cmake file from usd/sdk/maya/CMakeLists.txt 
cmake_minimum_required(VERSION 2.8.8)

SET(SUBTREE_DIRECTORY "src")

include ( RezBuild )
rez_find_packages ( PREFIX pkgs AUTO )

include(pxrConfig)

# Bake version
string(REPLACE "." ";" AL_USDMAYA_VERSION $ENV{REZ_BUILD_PROJECT_VERSION})
list(GET AL_USDMAYA_VERSION 0 AL_USDMAYA_VERSION_MAJOR)
list(GET AL_USDMAYA_VERSION 1 AL_USDMAYA_VERSION_MINOR)
list(GET AL_USDMAYA_VERSION 2 AL_USDMAYA_VERSION_PATCH)
configure_file(Version.h.in ${CMAKE_CURRENT_SOURCE_DIR}/src/lib/AL_USDMaya/AL/usdmaya/Version.h)

set(BOOST_ROOT ${boost_ROOT})

add_definitions("-DUSE_AL_DEFAULT=1")
add_definitions("-DAL_MAYA_ENABLE_SIMD=0")


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
    ${CMAKE_CURRENT_SOURCE_DIR}/${SUBTREE_DIRECTORY}/cmake/defaults
    ${CMAKE_CURRENT_SOURCE_DIR}/${SUBTREE_DIRECTORY}/cmake/macros
    ${CMAKE_CURRENT_SOURCE_DIR}/${SUBTREE_DIRECTORY}/cmake/modules
)

# to get PYTHON_EXECUTABLE

find_package(PythonInterp)

include(ProjectDefaults)
include(Public)
include(CXXDefaults)

add_definitions(${_PXR_CXX_DEFINITIONS})

find_package(Maya REQUIRED)
# tf has a baked requirement on python system's library.
# Because Maya has its own python lib replace it here to avoid
# CMake warnings. This is safe to do so for now as Maya 2017 and 2018
# use python 2.7(.11).
string(TOUPPER ${CMAKE_BUILD_TYPE} _BUILD_TYPE)
get_target_property(tflibs tf
IMPORTED_LINK_INTERFACE_LIBRARIES_${_BUILD_TYPE})
set(tmplibs)
foreach(tflib ${tflibs})
    if(NOT tflib MATCHES .*libpython.*)
        list(APPEND tmplibs ${tflib})
    endif()
endforeach(tflib)
set(tflibs ${tmplibs})
set_target_properties(
    tf
    PROPERTIES
        IMPORTED_LINK_INTERFACE_LIBRARIES_${_BUILD_TYPE} "${tflibs}"
)
set(PYTHON_LIBRARY $ENV{MAYA_LOCATION}/lib/libpython2.7.so CACHE STRING "" FORCE)
find_package(PythonLibs)

# FindBoost is particularly buggy, and doesn't like custom boost locations.
# Adding specific components forces calls to _Boost_find_library, which
# is the rationale for listing them here.
find_package(Boost COMPONENTS
                python # initialises Boost_PYTHON_LIBRARY
                thread # initialises Boost_THREAD_LIBRARY
                filesystem # initialises Boost_FILESYSTEM_LIBRARY
                REQUIRED
)

set(CMAKE_VERBOSE_MAKEFILE OFF)

set(CMAKE_CXX_FLAGS
    -std=c++11
    -msse3
    "${_PXR_CXX_WARNING_FLAGS}"
)
string(REPLACE ";" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")


# Path to the input schemas templates
set(USD_SCHEMA_PATH ${PXR_CMAKE_DIR}/schemas/usd/schema.usda)

# An intermediate python package is added (compared to the opensource cmake config)
# to be able to merge internal and opensource in the same AL.usd.schemas python package.
set(SCHEMAS_PYTHON_MODULE AL.usd.schemas.opensource)
set(SCHEMAS_PYTHON_PATH AL/usd/schemas/opensource)

# This will drive the schemas library and binding library names
set(SCHEMAS_PACKAGE AL_USDMayaSchemas)
set(SCHEMAS_PYTHON_PACKAGE _AL_USDMayaSchemas)
set(TRANSLATORS_PACKAGE AL_USDMayaTranslators_opensource)

# Use another token prefix (defined in the usd layer used to generate schemas source
# code) because AL_Schemas is already used by our internal schemas.
set(SCHEMAS_TOKENS_PREFIX AL_USDMayaSchemas) 

# Compare generated code
set(VALIDATE_GENERATED_SCHEMAS "Generate schemas code and compare." ON)

if(${MAYA_API_VERSION} STRLESS 2017)
    set(QT_QTGUI_LIBRARY QtGui)
endif()

set(AL_USDMAYA_LOCATION_NAME
    "AL_USDMAYA_LOCATION"
    CACHE
    STRING
    "Name of the environment variable used to store AL_USDMaya installation location"
)

# Build our plugs... non-standard as we're building from another source tree
add_subdirectory(${SUBTREE_DIRECTORY}/lib)
add_subdirectory(${SUBTREE_DIRECTORY}/plugin)
add_subdirectory(${SUBTREE_DIRECTORY}/schemas)
add_subdirectory(${SUBTREE_DIRECTORY}/translators)

# The opensource build has our these custom SdfMetadata in the schema plugInfo.json:
#   - al_usdmaya_transformType
#   - al_usdmaya_importAsNative
#   - al_usdmaya_excludeFromProxyShape
# Internally, these metadatas have been kept in AL_USDSchemas for the cases we want to access them
# without depending on AL_USDMaya therefore we're going to filter these metadatas out.
set(to_filter
    ${CMAKE_CURRENT_BINARY_DIR}/src/schemas/AL/usd/schemas/plugInfo.json
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

# Overwrite AL/usd/schemas/__init__.py to handle merging with our internal AL_USDSchemas.
file(REMOVE ${CMAKE_BINARY_DIR}/AL/usd/schemas/__init__.py)
file(GENERATE
    OUTPUT
    ${CMAKE_BINARY_DIR}/AL/usd/schemas/__init__.py
    INPUT
    ${CMAKE_CURRENT_SOURCE_DIR}/schemas/__init__.py
    )

IF ($ENV{REZ_BUILD_VARIANT_NUMBER} STREQUAL "0")
    set(doxygen_dirs
        ${CMAKE_CURRENT_SOURCE_DIR}/src/lib/AL_USDMaya/AL
        ${CMAKE_CURRENT_SOURCE_DIR}/src/doxygen
    )

    rez_install_doxygen(
        doc
        FILES             ${doxygen_dirs}
        DESTINATION       doc
        DOXYFILE          ${CMAKE_CURRENT_SOURCE_DIR}/src/doxygen/Doxyfile
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

rez_install_cmake(DESTINATION cmake
  INCLUDE_DIRS include
  LIBRARY_DIRS lib)
    

get_property(LIBRARY_LOCATION GLOBAL PROPERTY GLOBAL_LIBRARY_LOCATION)
get_property(PYTHON_LIBRARY_LOCATION GLOBAL PROPERTY GLOBAL_PYTHON_LIBRARY_LOCATION)
configure_file(src/ALUsdMayaConfig.cmake.in ${PROJECT_BINARY_DIR}/ALUsdMayaConfig.cmake @ONLY)

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
