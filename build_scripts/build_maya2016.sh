#!/usr/bin/env bash
mkdir build
cd build

cmake -Wno-dev \
      -DCMAKE_INSTALL_PREFIX='/home/users/danielbar/packages' \
      -DCMAKE_MODULE_PATH='/film/tools/packages/AL_boost_python/1.55.0/CentOS-6.2_thru_7/python-2.7/cmake;/film/tools/packages/usdBase/0.7.al1.1.3/cmake' \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DBOOST_ROOT='/film/tools/packages/AL_boost_python/1.55.0/CentOS-6.2_thru_7/python-2.7' \
      -DMAYA_LOCATION='/film/tools/packages/mayaDevKit/2016.0.201602230657/CentOS-6.2_thru_7/autodesk/maya2016' \
      -DOPENEXR_LOCATION='/film/tools/packages/OpenEXR/2.2.0/CentOS-6.2_thru_7'\
      -DOPENGL_gl_LIBRARY='/film/tools/packages/glfw/3.1.2/CentOS-6.2_thru_7/lib/libglfw.so'\
      -DGLEW_LOCATION='/film/tools/packages/glew/2.0.0/CentOS-6.2_thru_7'\
      -DSPLIT_USD_LOCATIONS='/film/tools/packages/usdBase/0.7.al1.1.3;/film/tools/packages/usdImaging/0.7.al1.1.1'\
      -DSPLIT_USD_LIBRARY_NAMES='usdBase;usdImaging'\
      -DBoost_LIBRARY_DIR='/film/tools/packages/AL_boost/1.55.0/CentOS-6.2_thru_7/lib;/film/tools/packages/AL_boost_python/1.55.0/CentOS-6.2_thru_7/python-2.7/lib'\
      -Dboost_NAMESPACE='ALboost'\
      -DNO_TESTS=true\
      ..

make -j 46 install
