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
from AL.usd.transaction import TransactionManager
from pxr import Usd, Sdf
import unittest

class TestManger(unittest.TestCase):

    ## Test that TransactionManager reports transactions for multiple stages as expected
    def test_InProgress_Stage(self):
        stageA = Usd.Stage.CreateInMemory()
        stageB = Usd.Stage.CreateInMemory()
        layer = Sdf.Layer.CreateAnonymous()
        
        self.assertFalse(TransactionManager.InProgress(stageA))
        self.assertFalse(TransactionManager.InProgress(stageB))
        
        self.assertTrue(TransactionManager.Open(stageA, layer))
      
        self.assertTrue(TransactionManager.InProgress(stageA))
        self.assertFalse(TransactionManager.InProgress(stageB))
      
        self.assertTrue(TransactionManager.Open(stageB, layer))
      
        self.assertTrue(TransactionManager.InProgress(stageA))
        self.assertTrue(TransactionManager.InProgress(stageB))
      
        self.assertTrue(TransactionManager.Close(stageA, layer))
      
        self.assertFalse(TransactionManager.InProgress(stageA))
        self.assertTrue(TransactionManager.InProgress(stageB))
        
        self.assertTrue(TransactionManager.Close(stageB, layer))
      
        self.assertFalse(TransactionManager.InProgress(stageA))
        self.assertFalse(TransactionManager.InProgress(stageB))

    ## Test that TransactionManager reports transactions for multiple layers as expected
    def test_InProgress_Layer(self):
        stage = Usd.Stage.CreateInMemory()
        layerA = Sdf.Layer.CreateAnonymous()
        layerB = Sdf.Layer.CreateAnonymous()
        
        self.assertFalse(TransactionManager.InProgress(stage))
        self.assertFalse(TransactionManager.InProgress(stage, layerA))
        self.assertFalse(TransactionManager.InProgress(stage, layerB))
        
        self.assertTrue(TransactionManager.Open(stage, layerA))
    
        self.assertTrue(TransactionManager.InProgress(stage))
        self.assertTrue(TransactionManager.InProgress(stage, layerA))
        self.assertFalse(TransactionManager.InProgress(stage, layerB))
    
        self.assertTrue(TransactionManager.Open(stage, layerB))
    
        self.assertTrue(TransactionManager.InProgress(stage))
        self.assertTrue(TransactionManager.InProgress(stage, layerA))
        self.assertTrue(TransactionManager.InProgress(stage, layerB))
    
        self.assertTrue(TransactionManager.Close(stage, layerA))
    
        self.assertTrue(TransactionManager.InProgress(stage))
        self.assertFalse(TransactionManager.InProgress(stage, layerA))
        self.assertTrue(TransactionManager.InProgress(stage, layerB))
    
        self.assertTrue(TransactionManager.Close(stage, layerB))
    
        self.assertFalse(TransactionManager.InProgress(stage))
        self.assertFalse(TransactionManager.InProgress(stage, layerA))
        self.assertFalse(TransactionManager.InProgress(stage, layerB))


if __name__ == '__main__':
    unittest.main()
