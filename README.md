This page is part of the internal Animal Logic Repository, but not the Open Source distribution [here](https://github.com/AnimalLogic/AL_USDMay)  which is subtree'd from the "src" folder in the root of this repository.

The main project README.md is [here](src/README.md)

This Animal Logic specific part of the repo contains:
+ Rez package files
+ Other build related files

Every time a push is made to the _develop_ branch of this repository, the Jenkins job will run an extra [step](https://github.al.com.au/rnd/AL_USDMaya/blob/develop/Jenkinsfile#L48): it will extract the commits made in **src** and push that to an [internal repo](https://github.al.com.au/rnd/AL_USDMaya_oss_ready.git) (a clone of the opensource one). This means the develop branch of this internal repo will always be ready to be pushed to the opensource repo.
([more details](https://github.al.com.au/rnd/AL_USDMaya/wiki/Synchronizing-with-the-open-source-project))

> Only a few people have the permissions and machine authorized to push to the opensource repository.
