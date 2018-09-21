if not exist T: (net use T: \\al.com.au\dfs & cd /D T:\depts\rnd\dev & C:)
@call "%VS140COMNTOOLS%VsDevCmd.bat"
set USD_VERSION=0.18.9
set USD_ROOT=T:\depts\rnd\dev\fabricem\Windows\USD\%USD_VERSION%
set USD_DEPENDENCIES_ROOT=T:\depts\rnd\dev\fabricem\Windows\USD_dependencies
set PYTHONPATH=%USD_ROOT%\lib\python;%PYTHONPATH%
set PATH=%USD_ROOT%\lib;%USD_ROOT%\bin;%USD_DEPENDENCIES_ROOT%\lib;%USD_DEPENDENCIES_ROOT%\bin;%$USD_ROOT%\lib;%PATH%
set PXR_PLUGINPATH_NAME=%USD_ROOT%\lib\usd
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=%WORKSPACE%\install ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DBOOST_ROOT=%USD_DEPENDENCIES_ROOT% ^
      -DMAYA_LOCATION="C:\Program Files\Autodesk\Maya2017" ^
      -DUSD_ROOT=%USD_ROOT% ^
      -DUSD_MAYA_ROOT=%USD_ROOT% ^
      -DGTEST_ROOT=T:\depts\rnd\dev\fabricem\Windows\googletest_install ^
      -G "Visual Studio 14 2015 Win64" ^
      ../src

cmake --build . --target install --config Release -- /M:16
