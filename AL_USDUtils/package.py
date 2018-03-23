# -*- coding: utf-8 -*-
name = 'AL_USDUtils'

version = '0.0.4'

private_build_requires = [
    'AL_CMakeLib',
    'cmake-2.8+',
    'gcc-4.8',
    'gdb-7.10'
]

requires = [
    'usdBase-0.8.al5',
    'AL_boost-1.55',
    'AL_boost_python-1.55'
]

variants = \
    [['CentOS-6.2+<7']]

def commands():
    prependenv('LD_LIBRARY_PATH', '{root}/lib')
    prependenv('CMAKE_MODULE_PATH', '{root}/cmake')
