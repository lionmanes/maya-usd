from __future__ import print_function

import unittest
import sys

class TestMerge(unittest.TestCase):
    """
    Test AL_USDMaya and AL_USDSchemas are merged.
    """

    def runTest(self):
        import AL.usd.schemas.opensource as opensource
        import AL.usd.schemas.internal as internal
        import AL.usd.schemas as schemas

        for p in sys.path:
            if 'schemas' in p.lower() or 'al_usdmaya' in p.lower():
                print(p)

        def getTokens(module):
            return [t for t in dir(module.Tokens) if not t.startswith('__')]

        # Compound tokens count
        compoundCount = len(set(getTokens(opensource) + getTokens(internal)))

        # Merged tokens counts
        mergedCount = len(getTokens(schemas))

        print('{} combined schemas tokens'.format(compoundCount))
        print('{} merged schemas tokens'.format(mergedCount))

        self.assertEquals(compoundCount, mergedCount)
