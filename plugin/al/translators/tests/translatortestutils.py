#
# Copyright 2017 Animal Logic
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import tempfile
import maya.cmds as mc
from AL import usdmaya

def getStage():
    """
    Grabs the first stage from the cache
    """
    stageCache = usdmaya.StageCache.Get()
    stage = stageCache.GetAllStages()[0]
    return stage


class SceneWithSphere:
    stage = None
    sphereXformName = ""
    sphereShapeName = ""

def importStageWithSphere(proxyShapeName='AL_usdmaya_Proxy'):
    """
    Creates a USD scene containing a single sphere.
    """

    # Create sphere in Maya and export a .usda file
    sphereXformName, sphereShapeName = mc.polySphere()
    mc.select(sphereXformName)
    tempFile = tempfile.NamedTemporaryFile(suffix=".usda", prefix="test_MeshTranslator_", delete=False)
    mc.file(tempFile.name, exportSelected=True, force=True, type="AL usdmaya export")
    dir(tempFile)
    print "tempFile ", tempFile.name

    # clear scene
    mc.file(f=True, new=True)
    mc.AL_usdmaya_ProxyShapeImport(file=tempFile.name, name=proxyShapeName)

    data = SceneWithSphere()
    data.stage = getStage()
    data.sphereXformName = sphereXformName
    data.sphereShapeName = sphereShapeName
    return data

def importStageWithNurbsCircle():
    # Create nurbs circle in Maya and export a .usda file
    mc.CreateNURBSCircle()
    mc.select("nurbsCircle1")
    tempFile = tempfile.NamedTemporaryFile(suffix=".usda", prefix="test_NurbsCurveTranslator_", delete=True)
    mc.file(tempFile.name, exportSelected=True, force=True, type="AL usdmaya export")

    # clear scene
    mc.file(f=True, new=True)
    mc.AL_usdmaya_ProxyShapeImport(file=tempFile.name)
    return getStage()
