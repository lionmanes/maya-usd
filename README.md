This page is part of the internal Animal Logic Repository, but not the Open Source distribution [here](https://github.com/AnimalLogic/AL_USDMaya)  which is subtree'd from the "src" folder in the root of this repository.

The main project README.md is [here](src/README.md)

This Animal Logic specific part of the repo contains:
+ Rez package files
+ Other build related files
+ An additional organisation of the libraries which symlinks to the "real" files

Every time a push is made to the _develop_ branch of this repository, the Jenkins job will run an extra [step](https://github.al.com.au/rnd/AL_USDMaya/blob/develop/Jenkinsfile#L48): it will extract the commits made in **src** and push that to an [internal repo](https://github.al.com.au/rnd/AL_USDMaya_oss_ready.git) (a clone of the opensource one). This means the develop branch of this internal repo will always be ready to be pushed to the opensource repo.
([more details](https://github.al.com.au/rnd/AL_USDMaya/wiki/Synchronizing-with-the-open-source-project))

> Only a few people have the permissions and machine authorized to push to the opensource repository.

# Animal-Specific build additions
Our internal, rez-driven build uses [this CMake file](https://github.al.com.au/rnd/AL_USDMaya/blob/develop/CMakeLists.txt), whereas the opensource build uses [this](https://github.al.com.au/rnd/AL_USDMaya/blob/develop/src/CMakeLists.txt)

What are some of the differences? (This is not exhaustive, please add to this)
+ To avoid having a dependency on AL_USDMaya when working with USD files, some of the schema metadata defined [here](https://github.al.com.au/rnd/AL_USDMaya/blob/04d93c252459788deb36e90af76d2407530fe1d8/src/schemas/AL/usd/schemas/maya/plugInfo.json.in#L8)  is filtered out of the relevant pluginInfo.json file, and is expected to be part of the AL_USDCommonSchemas. See [here](https://github.al.com.au/rnd/AL_USDMaya/blob/04d93c252459788deb36e90af76d2407530fe1d8/CMakeLists.txt#L153). AL_USDCommonSchemas is included by our tests, but not when running a standard environment, so please be aware of this when attempting to use functionality which relies on ths metadata (There is an argument for adding this dependency) 

