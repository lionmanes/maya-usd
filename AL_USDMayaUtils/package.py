# -*- coding: utf-8 -*-

name = 'AL_USDMayaUtils'

version = '0.0.8'

private_build_requires = [
    'AL_CMakeLib',
    'cmake-2.8+',
    'gcc-4.8.3',
    'gdb-7.10'
]

requires = [
    'AL_EventSystem-0.0.3+<0.1',
    'AL_MayaUtils-0.0.5+<0.1',
    'AL_USDUtils-0.0.6+<0.1',
    'usdBase-0.8.al6'
]

variants = [
    ['CentOS-6.2+<7', 'mayaDevKit-2017.0'],
    ['CentOS-6.2+<7', 'mayaDevKit-2018.0'],
    ['CentOS-6.6+<7', 'mayaDevKit-2019.b92']
]

def commands():
    prependenv('LD_LIBRARY_PATH', '{root}/lib')
    prependenv('CMAKE_MODULE_PATH', '{root}/cmake')
