
# run from the the AL_USDMaya directory
cd AL_EventSystem; rez build --build-target RelWithDebInfo --variants 0 --install -- -- -j 46; if [ $? -ge 1 ]; then exit 1; fi ; cd -
cd AL_MayaUtils; rez build --build-target RelWithDebInfo --variants 0 --install -- -- -j 46; if [ $? -ge 1 ]; then exit 1; fi ; cd -
cd AL_USDUtils; rez build --build-target RelWithDebInfo --variants 0 --install -- -- -j 46; if [ $? -ge 1 ]; then exit 1; fi ; cd -
cd AL_USDMayaUtils; rez build --build-target RelWithDebInfo --variants 0 --install -- -- -j 46; if [ $? -ge 1 ]; then exit 1; fi ; cd -
rez build --build-target RelWithDebInfo --variants 0 --install -- -- -j 46

