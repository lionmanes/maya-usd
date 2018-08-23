name = "AL_USDMayaIntegrationTests"

version = "1.0.0"

private_build_requires = [
    'cmake'
]

def commands():
    prependenv('PATH', '{root}/tests')


tests = {
    # AL_USDSchemas python module before AL_USDMaya in PYTHONPATH
    'schemas_merge_schemas_first': {
        'command': 'python -m unittest schemas_merge.test_merge',
        'requires': [
            'AL_USDMaya',
            'AL_USDSchemas',
        ]
    },
    # AL_USDMaya's schemas python module before AL_USDSchemas in PYTHONPATH
    'schemas_merge_al_usdmaya_first': {
        'command': 'python -m unittest schemas_merge.test_merge',
        'requires': [
            'AL_USDSchemas',
            'AL_USDMaya',
        ]
    }
}
