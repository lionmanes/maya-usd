//
// Copyright 2017 Animal Logic
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.//
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
#pragma once
#include "AL/usdmaya/Common.h"
#include "AL/maya/MayaEventManager.h"

namespace AL {
namespace usdmaya {

//----------------------------------------------------------------------------------------------------------------------
/// \brief  This class wraps all of the global state/mechanisms needed to integrate USD and Maya.
///         This mainly handles things such as onFileNew, preFileSave, etc.
/// \ingroup usdmaya
//----------------------------------------------------------------------------------------------------------------------
class Global
{
public:

  /// \brief  initialise the global state
  static void onPluginLoad();

  /// \brief  uninitialise the global state
  static void onPluginUnload();

  /// pre save callback
  static maya::CallbackId preSave()
    { return m_preSave; }

  /// post save callback
  static maya::CallbackId postSave()
    { return m_postSave; }

  /// pre open callback
  static maya::CallbackId preOpen()
    { return m_preOpen; }

  /// post open callback
  static maya::CallbackId postOpen()
    { return m_postOpen; }

  /// callback used to flush the USD caches after a file new
  static maya::CallbackId fileNew()
    { return m_fileNew; }

private:
  static maya::CallbackId m_preSave;  ///< callback prior to saving the scene (so we can store the session layer)
  static maya::CallbackId m_postSave; ///< callback after saving
  static maya::CallbackId m_preOpen;  ///< callback executed before opening a maya file
  static maya::CallbackId m_postOpen; ///< callback executed after opening a maya file - needed to re-hook up the UsdPrims
  static maya::CallbackId m_fileNew;  ///< callback used to flush the USD caches after a file new
};

} // usdmaya
//----------------------------------------------------------------------------------------------------------------------
} // al
//----------------------------------------------------------------------------------------------------------------------

