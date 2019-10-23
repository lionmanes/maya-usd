# -*- coding: utf-8 -*-
name = 'AL_USDTransaction'

version = '0.2.0'

private_build_requires = [
    'cmake-2.8+',
    'gcc-6.3.1+<7',
    'googletest',
    'tbb',
]

requires = [
    'usdBase-0.19.7',
    'AL_boost_python-1.66',
    'python-2.7',
]

def commands():
    prependenv('LD_LIBRARY_PATH', '{root}/lib')
    prependenv('CMAKE_MODULE_PATH', '{root}/cmake')
    prependenv('PYTHONPATH', '{root}/lib/python')
    prependenv('PXR_PLUGINPATH_NAME', '{root}/lib/usd')
