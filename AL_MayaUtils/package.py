# -*- coding: utf-8 -*-

name = 'AL_MayaUtils'

version = '0.1.0'

private_build_requires = [
    'AL_CMakeLib',
    'cmake-2.8+',
    'AL_CMakeLibPython-6.0.9+<7',
    'gcc-4.8.3',
    'AL_MTypeId-1.41+',
    'gdb-7.10',
    'doxygen-1',
    'googletest',
    'AL_maya_startup-1'
]

requires = [
    'stdlib-4.8.3+<5',
    'Qt_vfx-5.6',
    'AL_EventSystem-0.0.3+<0.1',
    'AL_boost-1.55',
    'AL_boost_python-1.55'
]

variants = [
    ['CentOS-6.2+<7', 'mayaDevKit-2017.0'],
    ['CentOS-6.2+<7', 'mayaDevKit-2018.0'],
    ['CentOS-6.6+<7', 'mayaDevKit-2019.b92']
]

def commands():
    prependenv('LD_LIBRARY_PATH', '{root}/lib')
    prependenv('CMAKE_MODULE_PATH', '{root}/cmake')
