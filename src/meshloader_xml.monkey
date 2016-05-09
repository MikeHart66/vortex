Strict

Private
Import brl.filepath
Import mojo.app
Import vortex.src.bone
Import vortex.src.cache
Import vortex.src.material
Import vortex.src.math3d
Import vortex.src.mesh
Import vortex.src.renderer
Import vortex.src.surface
Import vortex.src.texture
Import vortex.src.xml

Public
Class MeshLoader_XML Final
Public
	Function Load:Mesh(filename$, texFilter%)
		'Parse XML mesh
		Local xmlString$ = LoadString(filename)
		If xmlString = "" Then Return Null
		Local parser:XMLParser = New XMLParser(xmlString)
		If Not parser.Parse() Then DebugLog parser.GetError(); Return Null
		If parser.GetRootNode().GetName() <> "mesh" Then Return Null

		'Get arrays
		Local brushesNode:XMLNode = parser.GetRootNode().GetChild("brushes")
		Local surfacesNode:XMLNode = parser.GetRootNode().GetChild("surfaces")
		Local lastFrameNode:XMLNode = parser.GetRootNode().GetChild("last_frame")
		Local bonesNode:XMLNode = parser.GetRootNode().GetChild("bones")
		If Not surfacesNode Then Return Null

		'Parse materials
		Local materialsMap:StringMap<Material> = New StringMap<Material>
		If brushesNode <> Null
			For Local i% = 0 Until brushesNode.GetNumChildren()
				Local brushNode:XMLNode = brushesNode.GetChild(i)
				If brushNode.GetName() <> "brush"
					DebugLog "Unexpected node '" + brushNode.GetName() + "' found in brushes section. Ignoring..."
					Continue
				End

				'Get brush data
				Local nameStr$ = brushNode.GetChildValue("name", "")
				Local blendStr$ = brushNode.GetChildValue("blend", "alpha")
				Local baseColorStr$[] = brushNode.GetChildValue("base_color", "1,1,1").Split(",")
				Local opacity# = Float(brushNode.GetChildValue("opacity", "1"))
				Local shininess# = Float(brushNode.GetChildValue("shininess", "0"))
				Local cullingStr$ = brushNode.GetChildValue("culling", "true")
				Local depthWriteStr$ = brushNode.GetChildValue("depth_write", "true")
				Local baseTexStr$ = brushNode.GetChildValue("base_tex", "")
				Local culling:Bool = True
				Local depthWrite:Bool = True
				Local baseColor#[3]
				If cullingStr = "0" Or cullingStr.ToLower() = "false" Then culling = False
				If depthWriteStr = "0" Or depthWriteStr.ToLower() = "false" Then depthWrite = False
				baseColor[0] = Float(baseColorStr[0])
				If baseColorStr.Length() > 1 Then baseColor[1] = Float(baseColorStr[1])
				If baseColorStr.Length() > 2 Then baseColor[2] = Float(baseColorStr[2])

				'Load texture
				Local diffuseTex:Texture = Null
				If baseTexStr <> ""
					If ExtractDir(filename) <> "" Then baseTexStr = ExtractDir(filename) + "/" + baseTexStr
					diffuseTex = Cache.GetTexture(baseTexStr, texFilter)
				End

				'Create material
				Local material:Material = Material.Create(diffuseTex)
				If blendStr.ToLower() = "alpha" Then material.SetBlendMode(Renderer.BLEND_ALPHA)
				If blendStr.ToLower() = "add" Then material.SetBlendMode(Renderer.BLEND_ADD)
				If blendStr.ToLower() = "mul" Then material.SetBlendMode(Renderer.BLEND_MUL)
				material.SetDiffuseColor(baseColor[0], baseColor[1], baseColor[2])
				material.SetAlpha(opacity)
				material.SetShininess(shininess)
				material.SetCulling(culling)
				material.SetDepthWrite(depthWrite)
				materialsMap.Set(nameStr, material)
			Next
		End

		'Create mesh object
		Local mesh:Mesh = Mesh.Create()
		mesh.SetFilename(filename)

		'Parse surfaces
		For Local i% = 0 Until surfacesNode.GetNumChildren()
			Local surfaceNode:XMLNode = surfacesNode.GetChild(i)
			If surfaceNode.GetName() <> "surface"
				DebugLog "Unexpected node '" + surfaceNode.GetName() + "' found in surfaces section. Ignoring..."
				Continue
			end

			'Get surface data
			Local brushStr$ = surfaceNode.GetChildValue("brush", "")
			Local indicesStr$[] = surfaceNode.GetChildValue("indices", "").Split(",")
			Local coordsStr$[] = surfaceNode.GetChildValue("coords", "").Split(",")
			Local normalsStr$[] = surfaceNode.GetChildValue("normals", "").Split(",")
			Local tangentsStr$[] = surfaceNode.GetChildValue("tangents", "").Split(",")
			Local colorsStr$[] = surfaceNode.GetChildValue("colors", "").Split(",")
			Local texcoordsStr$[] = surfaceNode.GetChildValue("texcoords", "").Split(",")
			Local boneIndicesStr$[] = surfaceNode.GetChildValue("bone_indices", "").Split(",")
			Local boneWeightsStr$[] = surfaceNode.GetChildValue("bone_weights", "").Split(",")

			'Create surface
			Local surf:Surface = Surface.Create(materialsMap.Get(brushStr))
			Local indicesLen% = indicesStr.Length()
			For Local j% = 0 Until indicesLen Step 3
				surf.AddTriangle(Int(indicesStr[j]), Int(indicesStr[j+1]), Int(indicesStr[j+2]))
			Next
			Local coordsLenDiv3% = coordsStr.Length()/3
			For Local j% = 0 Until coordsLenDiv3
				Local x#, y#, z#
				Local nx# = 0, ny# = 0, nz# = 0
				Local tx# = 0, ty# = 0, tz# = 0
				Local r# = 1, g# = 1, b# = 1, a# = 1
				Local u# = 0, v# = 0
				Local b0% = -1, b1% = -1, b2% = -1, b3% = -1
				Local w0# = 0, w1# = 0, w2# = 0, w3# = 0

				'Read coords
				x = Float(coordsStr[j*3])
				y = Float(coordsStr[j*3+1])
				z = Float(coordsStr[j*3+2])

				'Read normals
				If normalsStr.Length() > 1
					nx = Float(normalsStr[j*3])
					ny = Float(normalsStr[j*3+1])
					nz = Float(normalsStr[j*3+2])
				End
				
				'Read tangents
				If tangentsStr.Length() > 1
					tx = Float(tangentsStr[j*3])
					ty = Float(tangentsStr[j*3+1])
					tz = Float(tangentsStr[j*3+2])
				End

				'Read colors
				If colorsStr.Length() > 1
					r = Float(colorsStr[j*4])
					g = Float(colorsStr[j*4+1])
					b = Float(colorsStr[j*4+2])
					a = Float(colorsStr[j*4+3])
				End

				'Read tex coords
				If texcoordsStr.Length() > 1
					u = Float(texcoordsStr[j*2])
					v = Float(texcoordsStr[j*2+1])
				End
				
				'Read bone indices
				If boneIndicesStr.Length() > 1
					b0 = Int(boneIndicesStr[j*4])
					b1 = Int(boneIndicesStr[j*4+1])
					b2 = Int(boneIndicesStr[j*4+2])
					b3 = Int(boneIndicesStr[j*4+3])
				End
				
				'Read bone weights
				If boneWeightsStr.Length() > 1
					w0 = Float(boneWeightsStr[j*4])
					w1 = Float(boneWeightsStr[j*4+1])
					w2 = Float(boneWeightsStr[j*4+2])
					w3 = Float(boneWeightsStr[j*4+3])
				End

				'Add vertex
				Local vertex:Int = surf.AddVertex(x, y, z, nx, ny, nz, r, g, b, a, u, v)
				surf.SetVertexTangent(vertex, tx, ty, tz)
				
				
				'Set vertex bones and weights
				surf.SetVertexBone(vertex, 0, b0, w0)
				surf.SetVertexBone(vertex, 1, b1, w1)
				surf.SetVertexBone(vertex, 2, b2, w2)
				surf.SetVertexBone(vertex, 3, b3, w3)
			Next

			mesh.AddSurface(surf)
		Next

		'Parse last frame
		If lastFrameNode Then mesh.SetLastFrame(Int(lastFrameNode.GetValue()))

		'Parse bones
		If bonesNode
			For Local i% = 0 Until bonesNode.GetNumChildren()
				Local boneNode:XMLNode = bonesNode.GetChild(i)
				If boneNode.GetName() <> "bone"
					DebugLog "Unexpected node '" + boneNode.GetName() + "' found in bones section. Ignoring..."
					Continue
				End

				'Get bone data
				Local nameStr$ = boneNode.GetChildValue("name", "")
				Local parentStr$ = boneNode.GetChildValue("parent", "")
				Local defPositionStr$[] = boneNode.GetChildValue("def_position", "0,0,0").Split(",")
				Local defRotationStr$[] = boneNode.GetChildValue("def_rotation", "1,0,0,0").Split(",")
				Local defScaleStr$[] = boneNode.GetChildValue("def_scale", "1,1,1").Split(",")
				Local surfacesStr$[] = boneNode.GetChildValue("surfaces", "").Split(",")
				If defPositionStr.Length() <> 3 Or defRotationStr.Length() <> 4 Or defScaleStr.Length() <> 3 Then Return Null

				'Create bone
				Local bone:Bone = Bone.Create(nameStr)
				
				'Set parent
				If parentStr <> ""
					Local parent:Bone = mesh.FindBone(parentStr)
					If parent = Null Then Return Null	'Parent bone must exist
					bone.SetParent(parent)
				End
				
				'Set pose matrix
				mTempMatrix.SetTransform(Float(defPositionStr[0]), Float(defPositionStr[1]), Float(defPositionStr[2]), Float(defRotationStr[0]), Float(defRotationStr[1]), Float(defRotationStr[2]), Float(defRotationStr[3]), Float(defScaleStr[0]), Float(defScaleStr[1]), Float(defScaleStr[2]))
				bone.SetLocalPoseMatrix(mTempMatrix)
				
				'Add to mesh
				mesh.AddBone(bone)
				
				'Update mesh surfaces weights if needed
				If surfacesStr[0] <> ""
					For Local j:Int = 0 Until surfacesStr.Length()
						Local index:Int = Int(surfacesStr[j])
						Local surf:Surface = mesh.GetSurface(index)
						For Local v:Int = 0 Until surf.GetNumVertices()
							bone.GetGlobalPoseMatrix().Mul(surf.GetVertexX(v), surf.GetVertexY(v), surf.GetVertexZ(v), 1)
							surf.SetVertexPosition(v, bone.GetGlobalPoseMatrix().ResultVector().x, bone.GetGlobalPoseMatrix().ResultVector().y, bone.GetGlobalPoseMatrix().ResultVector().z)
							surf.SetVertexBone(v, 0, i, 1)
						Next
						surf.Rebuild()
					Next
				End

				'Add position frames
				Local positionsStr$[] = boneNode.GetChildValue("positions", "").Split(",")
				If positionsStr.Length() >= 4
					For Local k% = 0 Until positionsStr.Length() Step 4
						Local frame% = Int(positionsStr[k])
						Local x# = Float(positionsStr[k+1])
						Local y# = Float(positionsStr[k+2])
						Local z# = Float(positionsStr[k+3])
						bone.AddPositionKey(frame, x, y, z)
					Next
				End
				Local rotationsStr$[] = boneNode.GetChildValue("rotations", "").Split(",")
				If rotationsStr.Length() >= 5
					For Local k% = 0 Until rotationsStr.Length() Step 5
						Local frame% = Int(rotationsStr[k])
						Local w# = Float(rotationsStr[k+1])
						Local x# = Float(rotationsStr[k+2])
						Local y# = Float(rotationsStr[k+3])
						Local z# = Float(rotationsStr[k+4])
						bone.AddRotationKey(frame, w, x, y, z)
					Next
				End
				Local scalesStr$[] = boneNode.GetChildValue("scales", "").Split(",")
				If scalesStr.Length() >= 4
					For Local k% = 0 Until scalesStr.Length() Step 4
						Local frame% = Int(scalesStr[k])
						Local x# = Float(scalesStr[k+1])
						Local y# = Float(scalesStr[k+2])
						Local z# = Float(scalesStr[k+3])
						bone.AddScaleKey(frame, x, y, z)
					Next
				End
			Next
		End

		Return mesh
	End
Private
	Method New()
	End
	
	'Used to calculate pose matrix
	Global mTempMatrix:Mat4 = Mat4.Create()
End
