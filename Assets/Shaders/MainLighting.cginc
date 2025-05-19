// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


            
            //UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
            CBUFFER_START(UnityPerMaterial)


                float4 _ColorBaseClose;
            float4 _ColorBaseFar;
            float4 _ColorPatternClose;
            float4 _ColorPatternFar;
            float4 _ColorShadow;
            float4 _ColorTint;

            float _FakeShadowEnable;
            float _FakeShadowIntensity;
            float4 _FakeShadowDirection;
            float _Ramp;
            float _RampThreshold;

            float _TextureScale;
            float _TextureOffsetX;
            float _TextureOffsetY;
            float _RotationAngle;

            float _PNEnable;
            float4 _ColorPNTextWhite;
            float4 _ColorPNTextBlack;
            float _PNTextureClip;
            float _PNTextureFadeInRadius;
            float _PNTextureFadeInStrength;
            float _PNTextureScale;
            float _PNTextureOffsetX;
            float _PNTextureOffsetY;
            float _PNSampleInClipSpace;
            float _PNRotationAngle;

            float _NoiseTextureScale;
            float _NoiseTextureOffsetX;
            float _NoiseTextureOffsetY;

            float _EnableDiffraction;
            float4 _ColorLightDiffraction;
            float _EdgeWidth;

            float _ProximityThreshold;
            float _ThresholdA;
            float _ThresholdB;
            float _EnableAddPassLights;
            float _EnableGlobalShadow;
            //float _FlipShadowValues;
            float _BleachingOffset;
            float _EnableNoise;
            float _OffsetPFadeOut;
            float _OffsetPFadeIn;
            float _RadiusPFadeIn;
            float _PatternFadeIn;
            float _NoiseContrast;
            float4 _FinalColor;
            static float _Attenuation;
            CBUFFER_END

            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 texcoord     : TEXCOORD0;
				float3 normalOS : NORMAL;
                float4 tangentOS    : TANGENT;
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
			float2 rotateUV(float2 uv, float rotation)
			{
    			float mid = 0.5;
    			return float2(
        		cos(rotation) * (uv.x - mid) + sin(rotation) * (uv.y - mid) + mid,
        		cos(rotation) * (uv.y - mid) - sin(rotation) * (uv.x - mid) + mid  );
			}

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            sampler2D  _PaintNoiseTex;
            float4 _PaintNoiseTex_ST;

            Varyings vert(Attributes v)
            {
                Varyings o;
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

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
				float3 viewVector = normalize(_WorldSpaceCameraPos - i.worldCoord);
				float distToCamera = distance(i.worldCoord, _WorldSpaceCameraPos);
				float proximityMaskI = 1-3*(distToCamera /( _ProximityThreshold));
                float proximityMaskRaw = (customLerp(_ThresholdA,_ThresholdB,float4(0,0,0,1), float4(1,1,1,1),proximityMaskI)).x;
                float proximityMask = saturate(proximityMaskRaw);

                //local variables
                float attenuation = 1;
                float globalShadow = 1;
                float additionalShadow = 0;
				float diffractionMask = 0;
                float4 noiseText;

                //align coords
                float2 globalUv = triplanarAlign(globalUv,i.worldCoord,i.normal); 
                globalUv = rotateUV(globalUv.xy,_RotationAngle);

                //scale and sample the main pattern texture
                float4 text = tex2D(_MainTex, float2 (globalUv.x+_TextureOffsetX,globalUv.y+_TextureOffsetY)/_TextureScale);

                

				//apply gradients
				float4 baseGradient = lerp( _ColorBaseFar, _ColorBaseClose, proximityMask);
				float4 patternGradient = lerp(_ColorPatternFar, _ColorPatternClose, proximityMask);
         
                //apply tint
                //float4 diffuse =_ColorTint;
                float4 diffuse =float4 (1,1,1,1);
    
                //apply noise 
                if(_EnableNoise)
               {    noiseText = 1.5*tex2D(_NoiseTex,  float2 (globalUv.x+_NoiseTextureOffsetX,globalUv.y+_NoiseTextureOffsetY)/_NoiseTextureScale);
                    noiseText = lerp(float4(1,1,1,1),1-noiseText,saturate(proximityMaskRaw+0.5));
               }
               else{  noiseText = float4 (1,1,1,1);}

                //add global shadow if enabled
                #ifdef InBasePass
                
                if(_EnableGlobalShadow)
                {
 
                 float4 shadowCoord = TransformWorldToShadowCoord(i.worldCoord.xyz);
                Light light = GetMainLight(shadowCoord);

                float4 lambert = float4 (LightingLambert(light.color+5, light.direction, i.normal),1);
                attenuation = light.shadowAttenuation;
                
                     diffuse = lerp(_ColorShadow*diffuse, _ColorTint*(_BleachingOffset+(diffuse+(1-diffuse)))*0.5,lambert*attenuation); //Tints of lit and shaded areas controlled separately
                
                #include "ShadowEdge.cginc"
                }
                #else
                #endif


                if (_FakeShadowEnable)
                {

                    float4 dotP = (dot(_FakeShadowDirection.xyz, (i.normal.xyz)));
                    if (_Ramp)
                    {
                        dotP = saturate((dotP - _RampThreshold) * 10);

                    }
                    diffuse = diffuse * ((1 + (dotP) / 2) - _FakeShadowIntensity);
                }
                

                float bandPassMask = min(proximityMask - saturate((proximityMaskRaw-1)*5),0.6);
                float4 noiseMap = lerp ((baseGradient+0.5)*diffuse*0.5,(patternGradient+0.1)*diffuse*0.5,(proximityMaskRaw-0.5)*(1-proximityMaskRaw+0.5));
                float4 mainGrad = lerp(patternGradient* diffuse , baseGradient* diffuse, text*(proximityMask+(1-_OffsetPFadeOut))*(noiseText-_NoiseContrast));
                float4 combined = lerp (mainGrad,noiseMap,(1-saturate(noiseText+_NoiseContrast))*saturate(bandPassMask));

                if(_PatternFadeIn)
                {
                float PFadeInMask = saturate(text- saturate((1-(proximityMaskRaw-(1-_RadiusPFadeIn))*_OffsetPFadeIn))).x;
                _FinalColor = lerp (baseGradient* diffuse,combined,saturate(1-PFadeInMask));
                }
                else
                {
                _FinalColor = combined;}

                if(_PNEnable)
				{   
                    float4 paintNoiseTex = float4 (1,1,1,1); 
                     float4 PNTextColor = float4 (1,1,1,1); 
                     //scale and sample the main pattern texture
				        if(_PNSampleInClipSpace)
				        {
				             float2 PNrotatedUV = rotateUV(i.posCS.xy ,_PNRotationAngle);
                             paintNoiseTex = tex2D(_PaintNoiseTex, float2 (PNrotatedUV.x + _PNTextureOffsetX*10, PNrotatedUV.y + _PNTextureOffsetY*10) / (_PNTextureScale*100));}
				         else{
				             float2 PNrotatedUV = rotateUV(globalUv.xy ,_PNRotationAngle);
                             paintNoiseTex = tex2D(_PaintNoiseTex, float2 (PNrotatedUV.x + _PNTextureOffsetX, PNrotatedUV.y + _PNTextureOffsetY) / (_PNTextureScale));}

					PNTextColor = lerp(_ColorPNTextBlack,_ColorPNTextWhite,paintNoiseTex);
					if(_PNTextureClip)
					{_FinalColor = _FinalColor*lerp(1,PNTextColor,saturate(_PNTextureFadeInStrength*customLerp((1-_PNTextureFadeInRadius),1,float4(0,0,0,0),float4(1,1,1,1),bandPassMask)*(1-attenuation)));}
					else
					{_FinalColor = _FinalColor*lerp(1,PNTextColor,saturate(_PNTextureFadeInStrength*customLerp((1-_PNTextureFadeInRadius),1,float4(0,0,0,0),float4(1,1,1,1),bandPassMask)));}
				}

                _FinalColor =  lerp (_FinalColor,_ColorLightDiffraction,diffractionMask);
               // #endif

				
            