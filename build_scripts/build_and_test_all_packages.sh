
# run the build script that builds all packages
./build_all_packages.sh

# run all the tests
cd AL_EventSystem; rez build -- -- all_tests ; if [ $? -ge 1 ]; then exit 1; fi ; cd -
cd AL_MayaUtils; rez build -- -- all_tests ; if [ $? -ge 1 ]; then exit 1; fi ; cd -
cd AL_USDUtils; rez build -- -- all_tests ; if [ $? -ge 1 ]; then exit 1; fi ; cd -
cd AL_USDMayaUtils; rez build -- -- all_tests ; if [ $? -ge 1 ]; then exit 1; fi ; cd -
rez build -- -- all_tests 
