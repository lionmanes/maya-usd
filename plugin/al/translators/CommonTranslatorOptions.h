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
#pragma once

namespace AL {
namespace usdmaya {
namespace fileio {
namespace translators {

//----------------------------------------------------------------------------------------------------------------------
namespace GeometryExportOptions
{
static constexpr const char* const kMeshes = "Meshes"; ///< export mesh geometry option name
static constexpr const char* const kMeshConnects = "Mesh Face Connects"; ///< export mesh face connects
static constexpr const char* const kMeshPoints = "Mesh Points"; ///< export mesh points
static constexpr const char* const kMeshNormals = "Mesh Normals"; ///< export mesh normals
static constexpr const char* const kMeshVertexCreases = "Mesh Vertex Creases"; ///< export mesh vertex creases
static constexpr const char* const kMeshEdgeCreases = "Mesh Edge Creases"; ///< export mesh edge creases
static constexpr const char* const kMeshUvs = "Mesh UVs"; ///< export mesh UV coordinates
static constexpr const char* const kMeshUvOnly = "Mesh UV Only"; ///< export mesh UV coordinates
static constexpr const char* const kMeshPointsAsPref = "Mesh Points as PRef"; ///< export mesh Points as PRef, duplicating "P"
static constexpr const char* const kMeshColours = "Mesh Colours"; ///< export mesh Colour Sets
static constexpr const char* const kMeshHoles = "Mesh Holes"; ///< export mesh face holes
static constexpr const char* const kNormalsAsPrimvars = "Write Normals as Primvars"; ///< if true, allow indexed normals to be written as primvars
static constexpr const char* const kReverseOppositeNormals = "Reverse Opposite Normals"; ///< if true, normals will be reversed when the opposite flag is enabled
static constexpr const char* const kCompactionLevel = "Compaction Level"; ///< export mesh face holes
static constexpr const char* const kNurbsCurves = "Nurbs Curves"; ///< export nurbs curves option name
}

//----------------------------------------------------------------------------------------------------------------------
namespace GeometryImportOptions
{
static constexpr const char* const kMeshes = "Import Meshes"; ///< the import meshes option name
static constexpr const char* const kNurbsCurves = "Import Curves"; ///< the import curves option name
}

//----------------------------------------------------------------------------------------------------------------------
} // translators
} // fileio
} // usdmaya
} // AL
//----------------------------------------------------------------------------------------------------------------------
