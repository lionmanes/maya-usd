# -*- coding: utf-8 -*-
name = 'AL_USDMaya'

version = '0.31.2'

authors = ['eoinm']

description = 'USD to Maya Bridge'

private_build_requires = [
    'AL_CMakeLib',
    'cmake-3',
    'AL_CMakeLibPython-6.0.9+<7',
    'gcc-6.3.1',
    'AL_MTypeId-1.41+',
    'doxygen-1',
    'AL_USDCommonSchemas-0.4', # For the SdfMetadata only
    'AL_maya_startup-1+', # To get mayapy and make tests work
]

requires = [
    'usdBase-0.19.1.2+<0.19.2',
    'usdImaging-0.19.1.2+<0.19.2',
    'glew-2.0',
    'googletest-1.8',
    'python-2.7+<3',
    'zlib-1.2',
    'cppunit-1.12+<2',
    'AL_CMakeLibGitHub-0.1.0+<1',
    '~AL_USDCommonSchemas-0.4', # For the SdfMetadata only
    'AL_boost-1.66',
    'AL_boost_python-1.66',
    'usdMaya-0.19.1.1+<0.19.2',
    '!AL_USDSchemas',
    'CentOS-7.4+<8'
]

variants = [
    ['mayaDevKit-2018.0', 'tbb-4.4'],
    ['mayaDevKit-2019.0', 'tbb-2017']
]

help = [['API', '$BROWSER http://github.al.com.au/pages/documentation/AL_USDMaya']]

def commands():
    prependenv('PATH', '{root}/bin')
    prependenv('PYTHONPATH', '{root}/lib/python')
    prependenv('LD_LIBRARY_PATH', '{root}/lib')
    prependenv('MAYA_PLUG_IN_PATH', '{root}/plugin')
    prependenv('MAYA_SCRIPT_PATH', '{root}/lib:{root}/share/usd/plugins/usdMaya/resources')
    prependenv('PXR_PLUGINPATH_NAME', '{root}/lib/usd:{root}/plugin')
    prependenv('CMAKE_MODULE_PATH', '{root}/cmake')
    prependenv('DOXYGEN_TAGFILES', '{root}/doc/AL_USDMaya.tag=http://github.al.com.au/pages/documentation/AL_USDMaya')
    setenv('AL_USDMAYA_AUTOLOAD_MEL', '{root}/mel')
    prependenv('AL_MAYA_AUTO_LOADVERSIONEDTOOL', 'al_usdmaya_autoload')

    # workaround for tbb-4.4 warnings
    # maya initializes tbb before usd with a value which seems to be (available cores - 3)
    # usd then wants to initialize tbb with (available cores) which leads to the warnings
    # manually set usd's limit to this empirically observed value
    env.PXR_WORK_THREAD_LIMIT='-3'


