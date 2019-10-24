//
// Copyright 2017 Animal Logic
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
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
#include "CommonTranslatorOptions.h"
#include "AL/maya/utils/PluginTranslatorOptions.h"
#include "pxr/base/tf/registryManager.h"
#include "pxr/base/tf/type.h"

namespace AL {
namespace usdmaya {
namespace fileio {
namespace translators {

PXR_NAMESPACE_USING_DIRECTIVE


AL::maya::utils::PluginTranslatorOptions* g_exportOptions = 0;
AL::maya::utils::PluginTranslatorOptions* g_importOptions = 0;

//----------------------------------------------------------------------------------------------------------------------
static const char* const g_compactionLevels[] = {
    "None",
    "Basic",
    "Medium",
    "Extensive",
    0
};

//----------------------------------------------------------------------------------------------------------------------
void registerCommonTranslatorOptions()
{
  auto context = AL::maya::utils::PluginTranslatorOptionsContextManager::find("ExportTranslator");
  if(context)
  {
    g_exportOptions = new AL::maya::utils::PluginTranslatorOptions(*context, "Geometry Export");
    g_exportOptions->addBool(GeometryExportOptions::kNurbsCurves, true);
    g_exportOptions->addBool(GeometryExportOptions::kMeshes, true);
    g_exportOptions->addBool(GeometryExportOptions::kMeshConnects, true);
    g_exportOptions->addBool(GeometryExportOptions::kMeshPoints, true);
    g_exportOptions->addBool(GeometryExportOptions::kMeshNormals, true);
    g_exportOptions->addBool(GeometryExportOptions::kMeshVertexCreases, true);
    g_exportOptions->addBool(GeometryExportOptions::kMeshEdgeCreases, true);
    g_exportOptions->addBool(GeometryExportOptions::kMeshUvs, true);
    g_exportOptions->addBool(GeometryExportOptions::kMeshUvOnly, false);
    g_exportOptions->addBool(GeometryExportOptions::kMeshPointsAsPref, false);
    g_exportOptions->addBool(GeometryExportOptions::kMeshColours, true);
    g_exportOptions->addBool(GeometryExportOptions::kMeshHoles, true);
    g_exportOptions->addBool(GeometryExportOptions::kNormalsAsPrimvars, false);
    g_exportOptions->addBool(GeometryExportOptions::kReverseOppositeNormals, false);
    g_exportOptions->addEnum(GeometryExportOptions::kCompactionLevel, g_compactionLevels, 3);
  }

  context = AL::maya::utils::PluginTranslatorOptionsContextManager::find("ImportTranslator");
  if(context)
  {
    g_importOptions = new AL::maya::utils::PluginTranslatorOptions(*context, "Geometry Import");
    g_importOptions->addBool(GeometryImportOptions::kNurbsCurves, true);
    g_importOptions->addBool(GeometryImportOptions::kMeshes, true);
  }
}

//----------------------------------------------------------------------------------------------------------------------
struct RegistrationHack
{
  RegistrationHack()
  {
    registerCommonTranslatorOptions();
  }
};

//----------------------------------------------------------------------------------------------------------------------
RegistrationHack g_registration;

//----------------------------------------------------------------------------------------------------------------------
} // translators
} // fileio
} // usdmaya
} // AL
//----------------------------------------------------------------------------------------------------------------------
