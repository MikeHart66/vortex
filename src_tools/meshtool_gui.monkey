Strict

Private
Import brl.filepath
Import dialog
Import guifuncs
Import mesh
Import mojo.app
Import mojo.input

Public
Class Gui Final
Public
	Method New()
		'Load resources
		mFont = Font.Load("system.fnt")
		mCubeTex = Texture.Load("cube.png", Renderer.FILTER_NONE)
		mOpenTex = Texture.Load("folder.png", Renderer.FILTER_NONE)
		mSaveTex = Texture.Load("disk.png", Renderer.FILTER_NONE)
	
		mPanelRect = New Rect(8, 8, 64, 24)
		mCubeRect = New Rect(8 + 4, 8 + 4, 16, 16)
		mOpenRect = New Rect(8 + 24, 8 + 4, 16, 16)
		mSaveRect = New Rect(8 + 44, 8 + 4, 16, 16)
		
		mAnimationsRect = New Rect(76, 8, 150, 24)
		
		mPitchRect = New Rect(230, 8, 96, 24)
		mYawRect = New Rect(330, 8, 96, 24)
		mRollRect = New Rect(430, 8, 96, 24)
		
		mMaterialRect = New Rect(0, 8, 108, 748)
		mSelMatRect = New Rect(4, 4, 100, 24)
		mDiffuseColorRect = New Rect(4, 32, 100, 24)
		mDiffuseTexRect = New Rect(4, 60, 100, 100)
		mNormalTexRect = New Rect(4, 164, 100, 100)
		mLightmapRect = New Rect(4, 268, 100, 100)
		mReflectionTexRect = New Rect(4, 372, 100, 100)
		mRefractionTexRect = New Rect (4, 476, 100, 100)
		mRefractionCoefRect = New Rect(4, 580, 100, 24)
		mOpacityRect = New Rect(4, 608, 100, 24)
		mShininessRect = New Rect(4, 636, 100, 24)
		mBlendModeRect = New Rect(4, 664, 100, 24)
		mCullingRect = New Rect(4, 692, 100, 24)
		mDepthWriteRect = New Rect(4, 720, 100, 24)
		
		mExportAnimations = True
		mPitchFix = 0
		mYawFix = 0
		mRollFix = 0
	End
	
	Method Update:Mesh(currentMesh:Mesh)
		'Update material rect
		mMaterialRect.x = DeviceWidth() - 112
		
		'Update GUI controls
		If MouseHit(MOUSE_LEFT) And currentMesh
			'Save mesh
			If mSaveRect.IsPointInside(MouseX(), MouseY())
				Local filename:String = currentMesh.Filename
				If filename = ""
					'filename = RequestFile("Save mesh", "Mesh Files:msh.xml;All Files:*", True)
					filename = RequestFile("Save mesh", "Mesh Files:msh;All Files:*", True)
					currentMesh.Filename = filename
				Else
					'filename = StripExt(filename) + ".msh.xml"
					filename = StripExt(filename) + ".msh"
				End
				'If filename <> "" Then SaveMeshXML(currentMesh, filename, mExportAnimations)
				If filename <> ""
					'Save mesh
					If mExportAnimations And currentMesh.NumBones > 0
						SaveMesh(currentMesh, filename, True)
					Else
						SaveMesh(currentMesh, filename, False)
					End
					
					'Save skeleton and animations
					If mExportAnimations And currentMesh.NumBones > 0
						SaveSkeleton(currentMesh, StripExt(filename) + ".skl")
						SaveAnimation(currentMesh, StripExt(filename) + ".anm")
					End
				End
			'Export animations
			Elseif currentMesh.NumBones > 0 And mAnimationsRect.IsPointInside(MouseX(), MouseY())
				mExportAnimations = Not mExportAnimations
			#Rem
			'Pitch
			Elseif mPitchRect.IsPointInside(MouseX(), MouseY())
				mPitchFix = (mPitchFix + 90) Mod 360
				RotateMesh(currentMesh, 90, 0, 0)
			'Yaw
			Elseif mYawRect.IsPointInside(MouseX(), MouseY())
				mYawFix = (mYawFix + 90) Mod 360
				RotateMesh(currentMesh, 0, 90, 0)
			'Roll
			Elseif mRollRect.IsPointInside(MouseX(), MouseY())
				mRollFix = (mRollFix + 90) Mod 360
				RotateMesh(currentMesh, 0, 0, 90)
			#End
			'Material
			Elseif mSelMatRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				mSelMat += 1
				If mSelMat = currentMesh.NumSurfaces Then mSelMat = 0
			'Diffuse color
			Elseif mDiffuseColorRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				If RequestColor("Select diffuse color", currentMesh.Surface(mSelMat).Material.DiffuseRed * 255, currentMesh.Surface(mSelMat).Material.DiffuseGreen * 255, currentMesh.Surface(mSelMat).Material.DiffuseBlue * 255)
					currentMesh.Surface(mSelMat).Material.SetDiffuseColor(RequestedRed() / 255.0, RequestedGreen() / 255.0, RequestedBlue() / 255.0)
				End
			'Diffuse texture
			Elseif mDiffuseTexRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				Local filename:String = RequestFile("Select diffuse texture")
				If filename <> ""
					Local tex:Texture = Texture.Load(filename)
					If tex Then currentMesh.Surface(mSelMat).Material.DiffuseTexture = tex
				Else
					Local leftTex:String = RequestFile("Select left diffuse texture")
					If leftTex = ""
						currentMesh.Surface(mSelMat).Material.DiffuseTexture = Null
					Else
						Local rightTex:String = RequestFile("Select right diffuse texture")
						If rightTex = ""
							currentMesh.Surface(mSelMat).Material.DiffuseTexture = Null
						Else
							Local frontTex:String = RequestFile("Select front diffuse texture")
							If frontTex = ""
								currentMesh.Surface(mSelMat).Material.DiffuseTexture = Null
							Else
								Local backTex:String = RequestFile("Select back diffuse texture")
								If backTex = ""
									currentMesh.Surface(mSelMat).Material.DiffuseTexture = Null
								Else
									Local topTex:String = RequestFile("Select top diffuse texture")
									If topTex = ""
										currentMesh.Surface(mSelMat).Material.DiffuseTexture = Null
									Else
										Local bottomTex:String = RequestFile("Select bottom diffuse texture")
										If bottomTex = ""
											currentMesh.Surface(mSelMat).Material.DiffuseTexture = Null
										Else
											Local tex:Texture = Texture.Load(leftTex, rightTex, frontTex, backTex, topTex, bottomTex)
											If tex Then currentMesh.Surface(mSelMat).Material.DiffuseTexture = tex
										End
									End
								End
							End
						End
					End
				End
			'Normal texture
			Elseif mNormalTexRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				Local filename:String = RequestFile("Select normal texture")
				If filename <> ""
					Local tex:Texture = Texture.Load(filename)
					If tex Then currentMesh.Surface(mSelMat).Material.NormalTexture = tex
				Else
					currentMesh.Surface(mSelMat).Material.NormalTexture = Null
				End
			'Lightmap
			Elseif mLightmapRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				Local filename:String = RequestFile("Select lightmap")
				If filename <> ""
					Local tex:Texture = Texture.Load(filename)
					If tex Then currentMesh.Surface(mSelMat).Material.Lightmap = tex
				Else
					currentMesh.Surface(mSelMat).Material.Lightmap = Null
				End
			'Reflection texture
			Elseif mReflectionTexRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				Local leftTex:String = RequestFile("Select left reflection texture")
				If leftTex = ""
					currentMesh.Surface(mSelMat).Material.ReflectionTexture = Null
				Else
					Local rightTex:String = RequestFile("Select right reflection texture")
					If rightTex = ""
						currentMesh.Surface(mSelMat).Material.ReflectionTexture = Null
					Else
						Local frontTex:String = RequestFile("Select front reflection texture")
						If frontTex = ""
							currentMesh.Surface(mSelMat).Material.ReflectionTexture = Null
						Else
							Local backTex:String = RequestFile("Select back reflection texture")
							If backTex = ""
								currentMesh.Surface(mSelMat).Material.ReflectionTexture = Null
							Else
								Local topTex:String = RequestFile("Select top reflection texture")
								If topTex = ""
									currentMesh.Surface(mSelMat).Material.ReflectionTexture = Null
								Else
									Local bottomTex:String = RequestFile("Select bottom reflection texture")
									If bottomTex = ""
										currentMesh.Surface(mSelMat).Material.ReflectionTexture = Null
									Else
										Local tex:Texture = Texture.Load(leftTex, rightTex, frontTex, backTex, topTex, bottomTex)
										If tex Then currentMesh.Surface(mSelMat).Material.ReflectionTexture = tex
									End
								End
							End
						End
					End
				End
			'Refraction texture
			Elseif mRefractionTexRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				Local leftTex:String = RequestFile("Select left refraction texture")
				If leftTex = ""
					currentMesh.Surface(mSelMat).Material.RefractionTexture = Null
				Else
					Local rightTex:String = RequestFile("Select right refraction texture")
					If rightTex = ""
						currentMesh.Surface(mSelMat).Material.RefractionTexture = Null
					Else
						Local frontTex:String = RequestFile("Select front refraction texture")
						If frontTex = ""
							currentMesh.Surface(mSelMat).Material.RefractionTexture = Null
						Else
							Local backTex:String = RequestFile("Select back refraction texture")
							If backTex = ""
								currentMesh.Surface(mSelMat).Material.RefractionTexture = Null
							Else
								Local topTex:String = RequestFile("Select top refraction texture")
								If topTex = ""
									currentMesh.Surface(mSelMat).Material.RefractionTexture = Null
								Else
									Local bottomTex:String = RequestFile("Select bottom refraction texture")
									If bottomTex = ""
										currentMesh.Surface(mSelMat).Material.RefractionTexture = Null
									Else
										Local tex:Texture = Texture.Load(leftTex, rightTex, frontTex, backTex, topTex, bottomTex)
										If tex Then currentMesh.Surface(mSelMat).Material.RefractionTexture = tex
									End
								End
							End
						End
					End
				End
			'Refraction coef
			Elseif mRefractionCoefRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				Local iCoef:Int = Int(currentMesh.Surface(mSelMat).Material.RefractionCoef * 100)
				iCoef += 10
				If iCoef > 100 Then iCoef = 0
				currentMesh.Surface(mSelMat).Material.RefractionCoef = iCoef / 100.0
			'Opacity
			Elseif mOpacityRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				Local iOp:Int = Int(currentMesh.Surface(mSelMat).Material.Opacity * 100)
				iOp += 10
				If iOp > 100 Then iOp = 0
				currentMesh.Surface(mSelMat).Material.Opacity = iOp / 100.0
			'Shininess
			Elseif mShininessRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				Local iShininess:Int = Int(currentMesh.Surface(mSelMat).Material.Shininess * 100)
				iShininess += 10
				If iShininess > 100 Then iShininess = 0
				currentMesh.Surface(mSelMat).Material.Shininess = iShininess / 100.0
			'Blend
			Elseif mBlendModeRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				currentMesh.Surface(mSelMat).Material.BlendMode += 1
				If currentMesh.Surface(mSelMat).Material.BlendMode > Renderer.BLEND_MUL Then currentMesh.Surface(mSelMat).Material.BlendMode = 0
			'Culling
			Elseif mCullingRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				currentMesh.Surface(mSelMat).Material.Culling = Not currentMesh.Surface(mSelMat).Material.Culling
			'Depth write
			Elseif mDepthWriteRect.IsPointInside(MouseX() - mMaterialRect.x, MouseY() - mMaterialRect.y)
				currentMesh.Surface(mSelMat).Material.DepthWrite = Not currentMesh.Surface(mSelMat).Material.DepthWrite
			End
		End
		
		'This events can be responded if there is no loaded mesh
		If MouseHit(MOUSE_LEFT)
			'Create cube
			If mCubeRect.IsPointInside(MouseX(), MouseY())
				ResetProperties()
				Return CreateCube()
			'Load mesh
			Elseif mOpenRect.IsPointInside(MouseX(), MouseY())
				Local filename:String = RequestFile("Load mesh")', "Mesh Files:msh.xml;All Files:*", False)
				If filename <> ""
					filename = filename.Replace("\", "/")
					Local mesh:Mesh = LoadMesh(filename)
					If mesh <> Null
						ResetProperties()
						Return mesh
					Else
						Notify "Error", "Could not load mesh '" + filename + "'", True
					End
				End
			End
		End
		
		Return Null
	End
	
	Method Render:Void(currentMesh:Mesh)
		Renderer.Setup2D(0, 0, DeviceWidth(), DeviceHeight())
		Renderer.SetBlendMode(Renderer.BLEND_ALPHA)
		DrawPanel(mPanelRect)
		Renderer.SetColor(1, 1, 1)
		mCubeTex.Draw(mCubeRect.x, mCubeRect.y)
		mOpenTex.Draw(mOpenRect.x, mOpenRect.y)
		mSaveTex.Draw(mSaveRect.x, mSaveRect.y)
		If currentMesh
			If currentMesh.NumBones > 0 Then DrawCheckbox(mAnimationsRect, "Export Animations", mFont, mExportAnimations)
			'DrawPanel(mPitchRect, "Pitch: " + mPitchFix, mFont)
			'DrawPanel(mYawRect, "Yaw: " + mYawFix, mFont)
			'DrawPanel(mRollRect, "Roll: " + mRollFix, mFont)
			
			Renderer.SetColor(1, 1, 1)
			mFont.Draw(8, 34, "Num Surfaces: " + currentMesh.NumSurfaces)
			mFont.Draw(8, 50, "Num Frames: " + currentMesh.NumFrames)
			mFont.Draw(8, 66, "Num Bones: " + currentMesh.NumBones)
			
			DrawPanel(mMaterialRect)
			DrawPanel(mMaterialRect.x + mSelMatRect.x, mMaterialRect.y + mSelMatRect.y, mSelMatRect.width, mSelMatRect.height, "Material #" + mSelMat, mFont)
			DrawPanel(mMaterialRect.x + mDiffuseColorRect.x, mMaterialRect.y + mDiffuseColorRect.y, mDiffuseColorRect.width, mDiffuseColorRect.height, "Diffuse Color", mFont, currentMesh.Surface(mSelMat).Material.DiffuseRed, currentMesh.Surface(mSelMat).Material.DiffuseGreen, currentMesh.Surface(mSelMat).Material.DiffuseBlue)
			
			'Diffuse
			If currentMesh.Surface(mSelMat).Material.DiffuseTexture
				Renderer.SetColor(1, 1, 1)
				currentMesh.Surface(mSelMat).Material.DiffuseTexture.Draw(mMaterialRect.x + mDiffuseTexRect.x, mMaterialRect.y + mDiffuseTexRect.y, mDiffuseTexRect.width, mDiffuseTexRect.height)
			Else
				DrawPanel(mMaterialRect.x + mDiffuseTexRect.x, mMaterialRect.y + mDiffuseTexRect.y, mDiffuseTexRect.width, mDiffuseTexRect.height)
			End
			
			'Normal
			If currentMesh.Surface(mSelMat).Material.NormalTexture
				Renderer.SetColor(1, 1, 1)
				currentMesh.Surface(mSelMat).Material.NormalTexture.Draw(mMaterialRect.x + mNormalTexRect.x, mMaterialRect.y + mNormalTexRect.y, mNormalTexRect.width, mNormalTexRect.height)
			Else
				DrawPanel(mMaterialRect.x + mNormalTexRect.x, mMaterialRect.y + mNormalTexRect.y, mNormalTexRect.width, mNormalTexRect.height)
			End
			
			'Lightmap
			If currentMesh.Surface(mSelMat).Material.Lightmap
				Renderer.SetColor(1, 1, 1)
				currentMesh.Surface(mSelMat).Material.Lightmap.Draw(mMaterialRect.x + mLightmapRect.x, mMaterialRect.y + mLightmapRect.y, mLightmapRect.width, mLightmapRect.height)
			Else
				DrawPanel(mMaterialRect.x + mLightmapRect.x, mMaterialRect.y + mLightmapRect.y, mLightmapRect.width, mLightmapRect.height)
			End
			
			'Reflection
			If currentMesh.Surface(mSelMat).Material.ReflectionTexture
				Renderer.SetColor(1, 1, 1)
				currentMesh.Surface(mSelMat).Material.ReflectionTexture.Draw(mMaterialRect.x + mReflectionTexRect.x, mMaterialRect.y + mReflectionTexRect.y, mReflectionTexRect.width, mReflectionTexRect.height)
			Else
				DrawPanel(mMaterialRect.x + mReflectionTexRect.x, mMaterialRect.y + mReflectionTexRect.y, mReflectionTexRect.width, mReflectionTexRect.height)
			End
			
			'Refraction
			If currentMesh.Surface(mSelMat).Material.RefractionTexture
				Renderer.SetColor(1, 1, 1)
				currentMesh.Surface(mSelMat).Material.RefractionTexture.Draw(mMaterialRect.x + mRefractionTexRect.x, mMaterialRect.y + mRefractionTexRect.y, mRefractionTexRect.width, mRefractionTexRect.height)
			Else
				DrawPanel(mMaterialRect.x + mRefractionTexRect.x, mMaterialRect.y + mRefractionTexRect.y, mRefractionTexRect.width, mRefractionTexRect.height)
			End
	
			DrawPanel(mMaterialRect.x + mRefractionCoefRect.x, mMaterialRect.y + mRefractionCoefRect.y, mRefractionCoefRect.width, mRefractionCoefRect.height, "Refr. Coef: " + String(currentMesh.Surface(mSelMat).Material.RefractionCoef)[..4], mFont)
			DrawPanel(mMaterialRect.x + mOpacityRect.x, mMaterialRect.y + mOpacityRect.y, mOpacityRect.width, mOpacityRect.height, "Opacity: " + String(currentMesh.Surface(mSelMat).Material.Opacity)[..4], mFont)
			DrawPanel(mMaterialRect.x + mShininessRect.x, mMaterialRect.y + mShininessRect.y, mShininessRect.width, mShininessRect.height, "Shininess: " + String(currentMesh.Surface(mSelMat).Material.Shininess)[..4], mFont)
			Local blendStr:String = ""
			Select currentMesh.Surface(mSelMat).Material.BlendMode
			Case Renderer.BLEND_ALPHA
				blendStr = "Alpha"
			Case Renderer.BLEND_ADD
				blendStr = "Add"
			Case Renderer.BLEND_MUL
				blendStr = "Mul"
			End
			DrawPanel(mMaterialRect.x + mBlendModeRect.x, mMaterialRect.y + mBlendModeRect.y, mBlendModeRect.width, mBlendModeRect.height, "Blend: " + blendStr, mFont)
			DrawCheckbox(mMaterialRect.x + mCullingRect.x, mMaterialRect.y + mCullingRect.y, mCullingRect.width, mCullingRect.height, "Culling", mFont, currentMesh.Surface(mSelMat).Material.Culling)
			DrawCheckbox(mMaterialRect.x + mDepthWriteRect.x, mMaterialRect.y + mDepthWriteRect.y, mDepthWriteRect.width, mDepthWriteRect.height, "Depth Write", mFont, currentMesh.Surface(mSelMat).Material.DepthWrite)
		End
	End
	
	Method ResetProperties:Void()
		mSelMat = 0
		mPitchFix = 0
		mYawFix = 0
		mRollFix = 0
	End
Private
	'Resources
	Field mFont					: Font
	Field mCubeTex				: Texture
	Field mOpenTex				: Texture
	Field mSaveTex				: Texture
	
	'Widgets
	Field mPanelRect			: Rect
	Field mCubeRect				: Rect
	Field mOpenRect				: Rect
	Field mSaveRect				: Rect
	Field mAnimationsRect		: Rect
	Field mPitchRect			: Rect
	Field mYawRect				: Rect
	Field mRollRect				: Rect
	Field mMaterialRect			: Rect
	Field mSelMatRect			: Rect
	Field mDiffuseColorRect		: Rect
	Field mDiffuseTexRect		: Rect
	Field mNormalTexRect		: Rect
	Field mLightmapRect			: Rect
	Field mReflectionTexRect	: Rect
	Field mRefractionTexRect	: Rect
	Field mRefractionCoefRect	: Rect
	Field mOpacityRect			: Rect
	Field mShininessRect		: Rect
	Field mBlendModeRect		: Rect
	Field mCullingRect			: Rect
	Field mDepthWriteRect		: Rect
	
	'Logic
	Field mExportAnimations		: Bool
	Field mSelMat				: Int
	Field mPitchFix				: Int
	Field mYawFix				: Int
	Field mRollFix				: Int
End
