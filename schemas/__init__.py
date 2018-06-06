""" AL.usd.schemas python package ("opensource" side)

We have two usd schemas libraries:
    * one in AL_USDSchemas
    * one in AL_USDMaya

Each one with its own dynamic library and python package init wrapper:
    AL_USDMaya
        |
        |---- AL
        |      |
        |      |---- usd
        |      |      |
        |      |      |---- schemas
        |      |      |        |
        |      |      |        |---- __init__.py
        |      |      |        |
        |      |      |        |---- opensource
        |      |      |        |        |
        |      |      |        |        |---- _AL_USDSchemas_opensource.so
        |      |      |        |        |
        |      |      |        |        |---- __init__.py (loads and initializes the dynamic
                                                           library)

    AL_USDSchemas
        |
        |---- AL
        |      |
        |      |---- usd
        |      |      |
        |      |      |---- schemas
        |      |      |        |
        |      |      |        |---- __init__.py
        |      |      |        |
        |      |      |        |---- internal
        |      |      |        |        |
        |      |      |        |        |---- _AL_USDSchemas.so
        |      |      |        |        |
        |      |      |        |        |---- __init__.py (loads and initializes the dynamic
                                                           library)

We want to be able to call any schemas using the same python package.

    >>> from AL.usd.schemas import Bindings
    >>> from AL.usd.schemas import MayaReference

Tokens will also all be accessible via AL.usd.schemas.Tokens wether one or both schemas packages
are present.

Each dynamic library carries one Tokens class whose name is hardcoded and part of the schemas
generated code. This prevent us from doing a simple `from XXX import *`.
We also have to take care of the eventual loading order.

"""

import imp
import os
import sys

from . import opensource

if 'AL.usd.schemas.internal' in sys.modules:
    """ AL_USDSchemas has already been loaded and has brought everything
        from AL.usd.schemas.opensource.
    """
    pass

else:
    if not os.environ.get('REZ_AL_USDSCHEMAS_ROOT'):
        """ AL_USDSchemas is not here at all, just load everything into this scope.
        """
        from opensource import *

    else:
        """ AL_USDSchemas is available but not loaded yet. Fetch AL.usd.schemas.internal content.
            here and merge its content.
        """
        internal = None
        path = os.path.join(os.environ.get('REZ_AL_USDSCHEMAS_ROOT'),
                            'lib/python/AL/usd/schemas')
        # We're not using namespace packages, so a `import AL.usd.schemas.utils` won't work here.
        utils = imp.load_source('AL.usd.schemas.utils',
                                os.path.join(path, 'utils.py'))
        # To find the dynamic module imported by AL.usd.schemas.internal .
        sys.path.append(os.path.join(path, 'internal'))
        internal = imp.load_source('AL.usd.schemas.internal',
                                    os.path.join(path, 'internal', '__init__.py'))

        # Import the schema classes.
        utils.import_schemas_classes(opensource, globals())
        utils.import_schemas_classes(internal, globals())

        # It has been brought in by imp.load_source, we don't need it anymore.
        del sys.modules['_AL_USDSchemas']

        # Merge tokens.
        @utils.bind_schemas_tokens(opensource, internal)
        class Tokens(object):
            pass
