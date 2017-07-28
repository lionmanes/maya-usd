def gitHubRepo = "https://github.al.com.au/rnd/AL_USDMaya.git"

// The list of packages that will be executed, the mode will determine if the stages can be executed in parallel or in serial.
def packages = []

// the root folder where the package will be built
def rootFolder = "/film/rndbuilddata/usd/builds"


// write here the name of the jenkins jobs that we want to chain to this one
// def dependentJobs = ["dependentTest1","dependent test 2"],
// you can define dependent jobs either as a list of simple strings (the dependent job) or
// or, if you need to override some parameters of the dependent job you can pass a list like
// [ 'jobname', 'JOBPARM1=value;JOBPARM2=value2']
// so in the end it looks like
//def dependentJobs = [["dependentTest1",'JOBPARM1=value;JOBPARM2=value2'] ,
//                    "dependent test 2"],



def dependentJobs = [["USDIntegration"],
                    ]
                    
// flags passed to the rez build -- -- all_tests
def rezBuildOptions = ""

timeout(time: 30)
{
    node ('CentOS-6.6&&!restricted&&graphicsTest')
    {
        ansiColor('xterm')
        {
            testing.runRepositoryTests(gitHubRepo, packages, dependentJobs, rootFolder, rezBuildOptions, "all_tests")
        }
    }
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*  THIS WILL NEED SPECIAL USER/MACHINE WITH PERMISSIONS  *
*  WHEN USED IN PRODUCTION                               *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * */
node('CentOS-6.6&&!restricted'){
    // Previous checkout has been cleared.
    checkout scm

    // This script will update the external repository 'develop' branch by
    // subtree-pushing to it.
    if(env.BRANCH_NAME == "develop"){
      stage('Update opensource develop branch'){
        ansiColor('xterm') {
          sh "./sync_scripts/push_develop_to_opensource.sh"
        }
      }
    }

    // This script will update the external wiki and doxygen docs.
    if(env.BRANCH_NAME == "master"){
      stage('Update opensource docs'){
        ansiColor('xterm') {
          sh "./sync_scripts/push_docs_to_opensource.sh"
        }
      }
    }

} // End of Node
