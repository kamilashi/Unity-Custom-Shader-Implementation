Shader "Unlit/S_Floor"
{
    Properties
    {	
        _MainTex ("Texture", 2D) = "white" {}
		_NoiseTex ("Noise", 2D) = "white" {}
		_ColorBaseClose("Color Lit (White) Close", Color) = (1,1,1,1)
		_ColorBaseFar("Color lit (White) Far", Color) = (1,1,1,1)
		_ColorPatternClose("Color Shade (Black) Close", Color) = (1,1,1,1)
		_ColorPatternFar("Color Shade (Black) Far", Color) = (1,1,1,1)

		[Toggle] _EnableTexture("Enable Main Texture", Float) = 1
		_ColorMTextWhite("Color Main Texture (White)", Color) = (1,1,1,1)
		_ColorMTextBlack("Color Main Texture (Black)", Color) = (1,1,1,1)
		[Toggle] _TextureClip("Clip Texture In Lit Areas", Float) = 0
		_TextureFadeInRadius ("Texture Fade-In Radius", Range(0.5,1.5)) = 0
		_TextureFadeInStrength("Testure Fade-In Strength", Range(0.1,3)) = 1
		_TextureScale("Main Texture Scale", Range(0.1,10)) = 1
		_TextureOffsetX("Main Texture X Offset", Range(-10,10)) = 0
		_TextureOffsetY("Main Texture Y Offset", Range(-10,10)) = 0
		[Toggle] _SampleInClipSpace("Sample In Clip Space", Float) = 0
		_RotationAngle("Texture Rotation Angle",Range(-3.2,3.2)) = 0

		[Toggle] _EnableDiffraction("Diffraction", Float) = 0
		_ColorLightDiffraction("Edge Color", Color) = (1,0.6,0,1)
		_EdgeWidth ("Edge Width",Range(0.01,0.5)) = 0.037

		[Toggle] _EnableGlobalShadow("Global Shadow", Float) = 1
		//[Toggle] _FlipShadowValues("Flip Shadow Values", Float) = 0
        _BleachingOffset ("Bleach Intensity", Range(1,4)) = 2.5
		_ColorShadow("Color Shadow", Color) = (1,1,1,1)
		//[Toggle] _EnableAddPassLights("Additional Lights", Float) = 1
		_ColorTint("Color Lit Area", Color) = (1,1,1,1)

		[Toggle] _FakeShadowEnable("Fake Shadow", Float) = 1
		_FakeShadowIntensity("Fake Shadow Intensity", Range(-1,1)) = 0
        _FakeShadowDirection("Direction: (x,y,z,NA)", Vector) = (0,1,0,1)

		[Toggle] _EnableNoise("Noise", Float) = 0
		_NoiseTextureScale("Noise Texture Scale", Range(0.1,20)) = 1
		_NoiseTextureOffsetX("Noise Texture X Offset", Range(-10,10)) = 0
		_NoiseTextureOffsetY("Noise Texture Y Offset", Range(-10,10)) = 0
		_NoiseContrast("Noise Contrast", Range(0,1)) = 0.5
         [Toggle] _PatternFadeIn("Pattern Fade-In", Float) = 0
		_OffsetPFadeIn("Pattern Fade-In Strength", Range(0,5)) = 1
		_RadiusPFadeIn("Pattern Fade-In Radius", Range(0,1)) = 0

		_OffsetPFadeOut("Pattern Fade-Out Offset", Range(0,3)) = 0.5
		_ProximityThreshold("Proximity Threshold", Range(1,150)) = 8
		_ProximityThreshold2("Lit Gradient Proximity Offset", Range(1,150)) = 8
		_ThresholdB("Proximity Gradient Start", Range(0,1)) = 1
		_ThresholdA("Proximity Gradient End", Range(0,1)) = 0
    }
    SubShader
    {
		Tags{ "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" "Queue" = "Geometry" "IgnoreProjector" = "True"}

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
			#pragma multi_compile _ _SHADOWS_SOFT
			#define InBasePass

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			 #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
  			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			 
			// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


            //start of cginc
            //UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
            CBUFFER_START(UnityPerMaterial)

			
			float4 _ColorBaseClose; 
			float4 _ColorBaseFar;
			float4 _ColorPatternClose;
			float4 _ColorPatternFar;

            
            //float _FlipShadowValues;
            float _BleachingOffset;
			float4 _ColorShadow;
            float4 _ColorTint;

			float _EnableTexture;
			float4 _ColorMTextWhite;
			float4 _ColorMTextBlack;

			float _EnableDiffraction;
			float4 _ColorLightDiffraction;
			float _EdgeWidth;

			float _FakeShadowEnable;
			float _FakeShadowIntensity;
            float4 _FakeShadowDirection;

			float _TextureClip;
			float _TextureFadeInRadius;
			float _TextureFadeInStrength;
			float _TextureScale; 
            float _TextureOffsetX;
            float _TextureOffsetY;
			float _SampleInClipSpace;
			float _RotationAngle;

			float _EnableNoise;
            float _NoiseContrast;
            float _NoiseTextureScale; 
            float _NoiseTextureOffsetX;
            float _NoiseTextureOffsetY;
            float _PatternFadeIn;
            float _OffsetPFadeIn;
             float _RadiusPFadeIn;

			float _ProximityThreshold;
			float _ProximityThreshold2;
            float _ThresholdA;
			float _ThresholdB;
            float _EnableAddPassLights;
            float _EnableGlobalShadow;
            
            float _OffsetPFadeOut;
            float4 _FinalColor;

            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 texcoord     : TEXCOORD0;
				float3 normalOS : NORMAL;
                float4 tangentOS  : TANGENT;
                float2 lightmapUV   : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                //DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
				float2 lightmapUV : TEXCOORD1;
				float3 worldCoord : TEXCOORD2;
				float3 normal : TEXCOORD3;
				float3 tangentWS : TEXCOORD4;
				float3 bitangentWS : TEXCOORD5;
                float3 posOS : TEXCOORD6;
                float4 posCS : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
                UNITY_VERTEX_OUTPUT_STEREO
            };

            	float4 customLerp(float thresholdA, float thresholdB, float4 ColorA, float4 ColorB, float t)
			{
				return float4 ((1 - (t - thresholdA) / (thresholdB - thresholdA)) * ColorA + (((t - thresholdA) / (thresholdB - thresholdA)) * ColorB));
			}
            float4 customLerpSat(float thresholdA, float thresholdB, float4 ColorA, float4 ColorB, float t)
			{
				return float4 (saturate(1 - (t - thresholdA) / (thresholdB - thresholdA)) * ColorA + saturate(((t - thresholdA) / (thresholdB - thresholdA)) * ColorB));
			}
			float2 rotateUV(float2 uv, float rotation)
			{
    			float mid = 0.5;
    			return float2(
        		cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid,
        		cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid  );
			}
			
           float2 triplanarAlign(float2 uv, float3 iWorldCoord, float3 iNormal)
            {
                    int axis = int(dot(abs(iWorldCoord.x),abs(iNormal.x)));
                if (axis > 0)
                {
                     uv = iWorldCoord.yz; //align with x
                }else{
                    axis = int(dot(abs(iWorldCoord.z),abs(iNormal.z)));
                    if (axis > 0)
                     {
                    uv = iWorldCoord.xy; //align with z 
                     
                    }
                    else
                    {
                    uv = iWorldCoord.xz;//align with y (for carpets)
                    }
                }
                return uv;
            }


            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            Varyings vert(Attributes v)
            {
                Varyings o;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.lightmapUV = v.lightmapUV;

                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.positionOS.xyz);
                o.posCS = TransformObjectToHClip(v.positionOS.xyz);
                o.posOS = v.positionOS.xyz;
                o.worldCoord =  vertexInput.positionWS;

                VertexNormalInputs normalInput = GetVertexNormalInputs(v.normalOS, v.tangentOS);
                o.normal = normalInput.normalWS;
                o.tangentWS = normalInput.tangentWS.xyz;
                o.bitangentWS = normalInput.bitangentWS.xyz;
                return o;
            }

            float4 frag(Varyings i): SV_Target
            {
                //get proximity mask
				float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldCoord);
				float distToCamera = distance(i.worldCoord, _WorldSpaceCameraPos);
				float proximityMaskI = 1-3*(distToCamera /( _ProximityThreshold));
                float proximityMaskRaw = (customLerp(_ThresholdA,_ThresholdB,float4(0,0,0,1), float4(1,1,1,1),proximityMaskI)).x;
                float proximityMask = saturate(proximityMaskRaw);

				float proximityMaskI2 = 1-3*(distToCamera /( _ProximityThreshold2));
                float proximityMaskRaw2 = (customLerp(_ThresholdA,_ThresholdB,float4(0,0,0,1), float4(1,1,1,1),proximityMaskI2)).x;
                float proximityMask2 = saturate(proximityMaskRaw2);
				
				float proximityMaskA = proximityMask;
				float proximityMaskRawA = proximityMaskRaw;

                //align coords
                float2 globalUv = triplanarAlign(globalUv,i.worldCoord,i.normal);
				
				float text = 1; //old
				float4 mainText = float4 (1,1,1,1); //current
                //scale and sample the main pattern texture
				if(_SampleInClipSpace)
				{
					
				float2 rotatedUV = rotateUV(i.posCS.xy,_RotationAngle);
                 mainText = tex2D(_MainTex, float2 (rotatedUV.x+_TextureOffsetX*10,rotatedUV.y+_TextureOffsetY*10)/(_TextureScale*100));}
				else{
					
				float2 rotatedUV = rotateUV(globalUv.xy,_RotationAngle);
                 mainText = tex2D(_MainTex, float2 (rotatedUV.x+_TextureOffsetX,rotatedUV.y+_TextureOffsetY)/(_TextureScale));}

                //apply tint
                float4 diffuse = float4 (1,1,1,1);

                //apply noise 
                float4 noiseText;
                if(_EnableNoise)
               {    noiseText = 1.5*tex2D(_NoiseTex, float2 (globalUv.x+_NoiseTextureOffsetX,globalUv.y+_NoiseTextureOffsetY)/_NoiseTextureScale);
                    noiseText = lerp(float4(1,1,1,1),1-noiseText,saturate(proximityMaskRawA+0.5));
               }
               else{  noiseText = float4 (1,1,1,1);}

                
                float attenuation = 1;
                float globalShadow = 1;
                float additionalShadow = 0;
				float diffractionMask = 0;
				float4 mainTextColor = float4(1,1,1,1);

                //add global shadow if enabled
                #ifdef InBasePass
                
                if(_EnableGlobalShadow)
                {
                 float4 shadowCoord = TransformWorldToShadowCoord(i.worldCoord.xyz );
                Light light = GetMainLight(shadowCoord);
                float4 lambert = float4 (LightingLambert(light.color+5, light.direction, i.normal),1);
                attenuation = light.shadowAttenuation;
                
                diffuse = lerp(_ColorShadow*diffuse, _ColorTint*(_BleachingOffset+(diffuse+(1-diffuse)))*0.5,lambert*attenuation); //Tints of lit and shaded areas controlled separately

                 /* if(_FlipShadowValues) //self shadows + cast shadows from directional light unified
                 {  diffuse = lerp(diffuse, 2.5+(diffuse+(1-diffuse))*0.5,lambert*attenuation); //normal in light, darkened in shade }
                 else
                 { diffuse = lerp(_ColorShadow, diffuse,lambert*attenuation);  //bleached light, normal in shade } */
                
				#include "ShadowEdge.cginc"
				
				}
                #else
                #endif

				//fake shadows
				if(_FakeShadowEnable)
				{
                     
                    diffuse = diffuse*( (1+(dot(_FakeShadowDirection.xyz, (i.normal.xyz)))/2) - _FakeShadowIntensity);}

				//apply gradients
				float4 baseGradient = lerp( _ColorBaseFar, _ColorBaseClose, (proximityMask2+_OffsetPFadeOut)*attenuation);
				float4 patternGradient = lerp(_ColorPatternFar, _ColorPatternClose, text*proximityMask*(1-attenuation));
				noiseText = lerp(noiseText,1,attenuation);//no noise in lit areas
				//return noiseText;

                float bandPassMask = min(proximityMaskA - saturate((proximityMaskRawA-1)*5),0.6);
                float4 noiseMap = lerp ((baseGradient+0.5)*diffuse*0.5,(patternGradient+0.1)*diffuse*0.5,(proximityMaskRaw-0.5)*(1-proximityMaskRaw+0.5));
                float4 mainGrad = lerp(patternGradient*diffuse  , max(saturate(baseGradient*diffuse)+0.7,_ColorBaseClose), attenuation*text*(proximityMaskA+(1))*(noiseText-_NoiseContrast));
                float4 combined = lerp (mainGrad,noiseMap,(1-saturate(noiseText+_NoiseContrast))*saturate(bandPassMask));
				//return mainGrad;

               // float4 noiseMap = lerp ((baseGradient+0.5)*diffuse*0.5,(patternGradient+0.1)*diffuse*0.5,(proximityMaskRaw-0.5)*(1-proximityMaskRaw+0.5));
               // float4 mainGrad = lerp(patternGradient* diffuse , baseGradient* diffuse, text*(proximityMask+(1-_OffsetPFadeOut))*(noiseText-_NoiseContrast));
               // float4 combined = lerp (mainGrad,noiseMap,(1-saturate(noiseText+_NoiseContrast))*saturate(bandPassMask));

                if(_PatternFadeIn)
                {
                float PFadeInMask = saturate(text- saturate((1-(proximityMaskRaw-(1-_RadiusPFadeIn))*_OffsetPFadeIn))).x;
                _FinalColor = lerp (baseGradient* diffuse,combined,saturate(1-PFadeInMask));
                }
                else
                {
                _FinalColor = combined;}

				if(_EnableTexture)
				{
					mainTextColor = lerp(_ColorMTextBlack,_ColorMTextWhite,mainText);
					if(_TextureClip)
					{_FinalColor = _FinalColor*lerp(1,mainTextColor,saturate(_TextureFadeInStrength*customLerp((1-_TextureFadeInRadius),1,float4(0,0,0,0),float4(1,1,1,1),bandPassMask)*(1-attenuation)));}
					else
					{_FinalColor = _FinalColor*lerp(1,mainTextColor,saturate(_TextureFadeInStrength*customLerp((1-_TextureFadeInRadius),1,float4(0,0,0,0),float4(1,1,1,1),bandPassMask)));}
				}
				//else{_FinalColor = combined;}

			return  lerp (_FinalColor,_ColorLightDiffraction,saturate(diffractionMask*noiseText));}
            
            ENDHLSL
        }

		
    }//FallBack "VertexLit"
}