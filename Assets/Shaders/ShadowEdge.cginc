if(_EnableDiffraction)
				{
					 float4 shadowCoordShiftedRight = TransformWorldToShadowCoord( float3 (i.worldCoord.x+_EdgeWidth,i.worldCoord.y,i.worldCoord.z ));
					 light = GetMainLight(shadowCoordShiftedRight);
					 float attenuationShiftedRight = light.shadowAttenuation;

					 float4 shadowCoordShiftedLeft = TransformWorldToShadowCoord( float3 (i.worldCoord.x-_EdgeWidth,i.worldCoord.y,i.worldCoord.z ));
					 light = GetMainLight(shadowCoordShiftedLeft);
					 float attenuationShiftedLeft = light.shadowAttenuation;

					 float lightMask = saturate(attenuation*10);
					 float lightMaskShiftedRight = saturate(attenuationShiftedRight*10);
					 float lightMaskShiftedLeft = saturate(attenuationShiftedLeft*10);

					 diffractionMask = saturate (saturate(lightMaskShiftedRight - lightMask) + saturate(lightMaskShiftedLeft - lightMask));

					 //diffractionMask = lerp(0,diffractionMask,noiseText);
				}