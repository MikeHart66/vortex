Strict

Private
Import vortex.src.renderer
Import vortex.src.texture
Import vortex

Public
Class Material Final
Public
	Function Create:Material(diffuseTex:Texture = Null)
		Local mat:Material = New Material
		mat.mDiffuseRed = 1
		mat.mDiffuseGreen = 1
		mat.mDiffuseBlue = 1
		mat.mDiffuseTex = diffuseTex
		mat.mAlpha = 1
		mat.mShininess = 0
		mat.mRefractCoef = 1
		mat.mBlendMode = Renderer.BLEND_ALPHA
		mat.mCulling = True
		mat.mDepthWrite = True
		Return mat
	End
	
	Method IsEqual:Bool(other:Material)
		If Self = other Then Return True
		If mDiffuseRed = other.mDiffuseRed And mDiffuseGreen = other.mDiffuseGreen And mDiffuseBlue = other.mDiffuseBlue And mDiffuseTex = other.mDiffuseTex And mNormalTex = other.mNormalTex And mReflectTex = other.mReflectTex And mRefractTex = other.mRefractTex And mAlpha = other.mAlpha And mShininess = other.mShininess And mRefractCoef = other.mRefractCoef And mBlendMode = other.mBlendMode And mCulling = other.mCulling And mDepthWrite = other.mDepthWrite
			Return True
		Else
			Return False
		End
	End

	Method Set:Void(other:Material)
		If Self.IsEqual(other) Then Return
		mDiffuseRed = other.mDiffuseRed
		mDiffuseGreen = other.mDiffuseGreen
		mDiffuseBlue = other.mDiffuseBlue
		mDiffuseTex = other.mDiffuseTex
		mNormalTex = other.mNormalTex
		mReflectTex = other.mReflectTex
		mRefractTex = other.mRefractTex
		mAlpha = other.mAlpha
		mShininess = other.mShininess
		mRefractCoef = other.mRefractCoef
		mBlendMode = other.mBlendMode
		mCulling = other.mCulling
		mDepthWrite = other.mDepthWrite
	End

	Method SetDiffuseColor:Void(r:Float, g:Float, b:Float)
		mDiffuseRed = r
		mDiffuseGreen = g
		mDiffuseBlue = b
	End

	Method GetDiffuseRed:Float()
		Return mDiffuseRed
	End

	Method GetDiffuseGreen:Float()
		Return mDiffuseGreen
	End

	Method GetDiffuseBlue:Float()
		Return mDiffuseBlue
	End
	
	Method SetDiffuseTexture:Void(tex:Texture)
		mDiffuseTex = tex
	End

	Method GetDiffuseTexture:Texture()
		Return mDiffuseTex
	End
	
	Method SetNormalTexture:Void(tex:Texture)
		mNormalTex = tex
	End
	
	Method GetNormalTexture:Texture()
		Return mNormalTex
	End
	
	Method SetReflectionTexture:Void(tex:Texture)
		mReflectTex = tex
	End
	
	Method GetReflectionTexture:Texture()
		Return mReflectTex
	End
	
	Method SetRefractionTexture:Void(tex:Texture)
		mRefractTex = tex
	End
	
	Method GetRefractionTexture:Texture()
		Return mRefractTex
	End

	Method SetAlpha:Void(alpha:Float)
		mAlpha = alpha
	End

	Method GetAlpha:Float()
		Return mAlpha
	End

	Method SetShininess:Void(shininess:Float)
		mShininess = shininess
	End

	Method GetShininess:Float()
		Return mShininess
	End
	
	Method SetRefractionCoef:Void(coef:Float)
		mRefractCoef = coef
	End
	
	Method GetRefractionCoef:Float()
		Return mRefractCoef
	End

	Method SetBlendMode:Void(mode:Int)
		mBlendMode = mode
	End

	Method GetBlendMode:Int()
		Return mBlendMode
	End

	Method SetCulling:Void(enable:Bool)
		mCulling = enable
	End

	Method GetCulling:Bool()
		Return mCulling
	End

	Method SetDepthWrite:Void(enable:Bool)
		mDepthWrite = enable
	End

	Method GetDepthWrite:Bool()
		Return mDepthWrite
	End

	Method Prepare:Void()
		Local diffuseHandle:Int = 0
		Local normalHandle:Int = 0
		Local reflectHandle:Int = 0
		Local refractHandle:Int = 0
		Local shininess:Int = 0
		If mShininess > 0 Then shininess = Int(mShininess * 128)
		Renderer.SetColor(mDiffuseRed, mDiffuseGreen, mDiffuseBlue, mAlpha)
		Renderer.SetShininess(shininess)
		Renderer.SetRefractCoef(mRefractCoef)
		Renderer.SetBlendMode(mBlendMode)
		Renderer.SetCulling(mCulling)
		Renderer.SetDepthWrite(mDepthWrite)
		If mDiffuseTex <> Null Then diffuseHandle = mDiffuseTex.GetHandle()
		If mNormalTex <> Null Then normalHandle = mNormalTex.GetHandle()
		If mReflectTex <> Null Then reflectHandle = mReflectTex.GetHandle()
		If mRefractTex <> Null Then refractHandle = mRefractTex.GetHandle()
		Renderer.SetTextures(diffuseHandle, normalHandle, reflectHandle, refractHandle, mDiffuseTex And mDiffuseTex.IsCubic())
		Renderer.SetPixelLighting(Vortex.GetGlobalPixelLighting())
	End
Private
	Method New()
	End

	Field mDiffuseRed	: Float
	Field mDiffuseGreen	: Float
	Field mDiffuseBlue	: Float
	Field mDiffuseTex	: Texture
	Field mNormalTex	: Texture
	Field mReflectTex	: Texture
	Field mRefractTex	: Texture
	Field mAlpha		: Float
	Field mShininess	: Float
	Field mRefractCoef	: Float
	Field mBlendMode	: Int
	Field mCulling		: Bool
	Field mDepthWrite	: Bool
End
