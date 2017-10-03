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



def dependentJobs = [
    "AL_USDMayaTranslators"
]

// flags passed to the rez build -- -- all_tests
def rezBuildOptions = "-i --variants 0 1 -- -- -j8"

// test only Maya 2017 and 2018 variants
// (Maya 2016 variant will hang because of the tbb USD issue)
def rezTestOptions = "--variants 0 1 -- --"

def testingParams = new al.TestingParameters()
testingParams.gitHubRepo = gitHubRepo
testingParams.packagesList = packages
testingParams.dependentJobs = dependentJobs
testingParams.rootFolder = rootFolder
testingParams.buildOptions = rezBuildOptions
testingParams.testTargetName = "all_tests"
testingParams.cleanup = true
testingParams.testOptions = rezTestOptions

def notifyError() {
  def subject = "FAILED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"
  def details = """Check console output at ${env.BUILD_URL}"""

  hipchatSend (
      color: 'RED',
      credentialId: 'HipChat-JenkinsUsdBuilds-Token',
      room: 'JenkinsUsdBuilds',
      sendAs: 'AL_USDMaya Test Jenkins',
      server: '',
      v2enabled: true,
      notify: true,
      message: summary
  )

  emailext (
      subject: subject,
      body: details,
      recipientProviders: [
          [$class: 'CulpritsRecipientProvider'],
          [$class: 'DevelopersRecipientProvider'],
          [$class: 'RequesterRecipientProvider'],
          [$class: 'UpstreamComitterRecipientProvider']
      ]
    )
}

timeout(time: 45)
{
    node ('CentOS-6.6&&!restricted')
    {
        try {
            ansiColor('xterm')
            {
                testing.runRepositoryTests(testingParams)
            }

            stage ('Clean Workspace') {
                cleanWs notFailBuild: true
            } // End stage ('Clean Workspace')
        }
        catch(Exception e) {
            notifyError()
            currentBuild.result = 'FAILURE'
            throw e
        }
        finally {
            algit.reportCurrentStatusToGitHub()
        }
    }

    node ('CentOS-6.6&&!restricted&&devbuild10')
    {
        checkout scm

        // Sets the status as 'PENDING'
        algit.reportStatusToGitHub('PENDING', '')

        try {
            ansiColor('xterm')
            {
                def workspace = pwd() + "/src"
                stage("Opensource Maya2016")
                {
                    sh "sudo docker run --rm -e \"BUILD_PROCS=4\" -v $workspace:/tmp/usd-build/AL_USDMaya knockout:5000/usd-docker/usd:latest-centos6-maya2016 bash /tmp/usd-build/AL_USDMaya/docker/build_alusdmaya.sh"
                }
                stage("Opensource Maya2017")
                {
                    sh "sudo docker run --rm -e \"BUILD_PROCS=4\" -v $workspace:/tmp/usd-build/AL_USDMaya knockout:5000/usd-docker/usd:latest-centos6-maya2017 bash /tmp/usd-build/AL_USDMaya/docker/build_alusdmaya.sh"
                }

                currentBuild.result = 'SUCCESS'
            }
        }
        catch(Exception e) {
            notifyError()
            currentBuild.result = 'FAILURE'
            throw e
        }
        finally {
            algit.reportCurrentStatusToGitHub()
            cleanWs notFailBuild: true
        }
    }

} // End timeout
