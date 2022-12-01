Shader "Unlit/S_Wall"
{
	Properties
	{
		_MainTex("Pattern Texture", 2D) = "white" {}
		_NoiseTex("Noise", 2D) = "white" {}
		_PaintNoiseTex("Paint Noise", 2D) = "white" {}
		_ColorBaseClose("Color Base (White) Close", Color) = (1,0,0,1)
		_ColorBaseFar("Color Base (White) Far", Color) = (1,0,0,1)
		_ColorPatternClose("Color Pattern (Black) Close", Color) = (1,0,0,1)
		_ColorPatternFar("Color Pattern (Black) Far", Color) = (1,0,0,1)
		_TextureScale("Main Texture Scale", Range(0.1,10)) = 1
		_TextureOffsetX("Main Texture X Offset", Range(-10,10)) = 0
		_TextureOffsetY("Main Texture Y Offset", Range(-10,10)) = 0
		_RotationAngle("Texture Rotation Angle",Range(-3.2,3.2)) = 0

		[Toggle] _PNEnable("Enable Paint Noise Texture", Float) = 1
		_ColorPNTextWhite("Color (White)", Color) = (1,1,1,1)
		_ColorPNTextBlack("Color (Black)", Color) = (1,1,1,1)
		[Toggle] _PNTextureClip("Clip Texture In Lit Areas", Float) = 0
		_PNTextureFadeInRadius("PN Texture Fade-In Radius", Range(0.5,1.5)) = 0
		_PNTextureFadeInStrength("PN Testure Fade-In Strength", Range(0.1,3)) = 1
		_PNTextureScale("PN Texture Scale", Range(0.1,10)) = 1
		_PNTextureOffsetX("PN Texture X Offset", Range(-10,10)) = 0
		_PNTextureOffsetY("Pn Texture Y Offset", Range(-10,10)) = 0
		[Toggle] _PNSampleInClipSpace("Sample In Clip Space", Float) = 0
		_PNRotationAngle("PN Rotation Angle",Range(-3.2,3.2)) = 0

		[Toggle] _EnableGlobalShadow("Global Shadow", Float) = 1
			//[Toggle] _FlipShadowValues("Flip Shadow Values", Float) = 0
			_BleachingOffset("Bleach Intensity", Range(1,5)) = 2.5
			_ColorShadow("Color Shaded Area", Color) = (1,0,0,1)
			[Toggle] _EnableAddPassLights("Additional Lights", Float) = 1
			_ColorTint("Color Lit Area", Color) = (1,1,1,1)

			[Toggle] _FakeShadowEnable("Fake Shadow", Float) = 0
			[Toggle] _Ramp("Ramp", Float) = 0
			_RampThreshold("Ramp Threshold", Range(0,1)) = 0.5
			_FakeShadowIntensity("Fake Shadow Intensity", Range(-1,1)) = 0
			_FakeShadowDirection("Direction: (x,y,z,NA)", Vector) = (0,1,0,1)

			[Toggle] _EnableNoise("Noise", Float) = 1
			_NoiseTextureScale("Noise Texture Scale", Range(0.1,20)) = 1
			_NoiseTextureOffsetX("Noise Texture X Offset", Range(-10,10)) = 0
			_NoiseTextureOffsetY("Noise Texture Y Offset", Range(-10,10)) = 0
			_NoiseContrast("Noise Contrast", Range(0,1)) = 0.5

			[Toggle] _EnableDiffraction("Diffraction", Float) = 0
			_ColorLightDiffraction("Edge Color", Color) = (1,0.6,0,1)
			_EdgeWidth("Edge Width",Range(0.01,0.5)) = 0.1

			[Toggle] _PatternFadeIn("Pattern Fade-In", Float) = 1
			_OffsetPFadeIn("Pattern Fade-In Strength", Range(0,5)) = 1
			_RadiusPFadeIn("Pattern Fade-In Radius", Range(0,1)) = 0
			_OffsetPFadeOut("Pattern Fade-Out Offset", Range(0,1)) = 0.5
			_ProximityThreshold("Proximity Threshold", Range(1,150)) = 8
			_ThresholdB("Proximity Gradient Start", Range(0,1)) = 1
			_ThresholdA("Proximity Gradient End", Range(0,1)) = 0

			_Attenuation("global attenuation (do not set)",Float) = 0.0
	}
		SubShader
		{
			Tags{ "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "Geometry" "IgnoreProjector" = "True"}

			LOD 100

			Pass //Base Pass
			{
				Name "Forward"
				Tags {"LightMode" = "UniversalForward"}


				HLSLPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				 #pragma prefer_hlslcc gles
				#pragma exclude_renderers d3d11_9x
				 #pragma target 2.0
				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_SCREEN
				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
				#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
				#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
				#pragma multi_compile _ _SHADOWS_SOFT
				#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE


				#pragma multi_compile_instancing
				#define InBasePass

				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
				 #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"


			//float4 _FinalColor; 
			#include "MainLighting.cginc"



			return _FinalColor; }
			ENDHLSL
		}



			UsePass "Universal Render Pipeline/Lit/ShadowCaster"
}
//Fallback "VertexLit"
}