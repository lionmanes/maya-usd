if not exist T: (net use T: \\al.com.au\dfs & cd /D T:\depts\rnd\dev & C:)
@call "%VS140COMNTOOLS%VsDevCmd.bat"
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=%WORKSPACE%\install ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DBOOST_ROOT=T:\depts\rnd\dev\fabricem\Windows\USD_dependencies ^
      -DMAYA_LOCATION="C:\Program Files\Autodesk\Maya2017" ^
      -DUSD_ROOT="T:\depts\rnd\dev\fabricem\Windows\USD\0.8.4" ^
      -DGTEST_ROOT=T:\depts\rnd\dev\fabricem\Windows\googletest_install ^
      -G "Visual Studio 14 2015 Win64" ^
      ../src

cmake --build . --target install --config Release -- /M:16
