@Library('AL@fabricem_USD_suite')

def config = [:]

config.dependencySuite = 'USD'
config.rezBuildOptions = '-i -- -- -j8'
config.cleanup = true
config.buildOnlyChanged = false
config.createBuildArtifacts = true
config.reuseArtifacts = true
config.nodeLabel = 'CentOS-7&&!restricted&&HeavyTests'
config.globalLogLevel = 'Debug'
config.useRezTest = false
config.hipChatCredentialId = 'HipChat-JenkinsUsdBuilds-Token'
config.hipChatRoom = 'JenkinsUsdBuilds'

def runConditionals(){
    if(env.BRANCH_NAME == "develop")
    {
        // Docker build
        node ('docker')
        {
            checkout scm

            // Sets the status as 'PENDING'
            algit.reportStatusToGitHub('PENDING', 'Docker build pending', "Docker_build_and_tests")

            try {
                ansiColor('xterm')
                {
                    def workspace = pwd() + "/src"
                    stage("Opensource Maya2017")
                    {
                        sh "sudo docker run --rm -e \"BUILD_PROCS=8\" -v $workspace:/tmp/usd-build/AL_USDMaya sydharbor01.al.com.au/usd/usd-docker/usd:0.8.5-centos7-maya2017 bash /tmp/usd-build/AL_USDMaya/docker/build_alusdmaya.sh"
                    }

                    algit.reportStatusToGitHub('SUCCESS', 'Docker build success', "Docker_build_and_tests")
                }
            }
            catch(Exception e) {
                currentBuild.result = 'UNSTABLE'
                global.notifyResult(currentBuild.result,
                                    'HipChat-JenkinsUsdBuilds-Token',
                                    'JenkinsUsdBuilds',
                                    '')
                algit.reportStatusToGitHub(currentBuild.result, 'Docker build error', "Docker_build_and_tests")
                throw e
            }
            finally {
                cleanWs notFailBuild: true
            }
        } // node
        
        // Windows build
        node ('ferry')
        {
            checkout scm

            // Sets the status as 'PENDING'
            algit.reportStatusToGitHub('PENDING', 'Windows build pending', "Windows_build")

            try {
                ansiColor('xterm')
                {
                    stage("Windows build")
                    {
                        bat "if not exist T: (net use T: \\\\al.com.au\\dfs)"
                        bat "build_scripts\\windows_build.bat"
                        algit.reportStatusToGitHub('SUCCESS', 'Windows build success', "Windows_build")
                    }
                }
            }
            catch(Exception e) {
                currentBuild.result = 'UNSTABLE'
                global.notifyResult(currentBuild.result,
                                    'HipChat-JenkinsUsdBuilds-Token',
                                    'JenkinsUsdBuilds',
                                    '')
                algit.reportStatusToGitHub(currentBuild.result, 'Windows build error', "Windows_build")
                throw e
            }
            finally {
                cleanWs notFailBuild: true
            }
        } // node
    } // if(env.BRANCH_NAME == "develop")
} // runConditionals()

runALPipeline config
runConditionals()
