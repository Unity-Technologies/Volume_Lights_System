Shader "Unlit/VolumeLight"
{
    Properties
    {
        [HDR] _Color ("Color", Color) = (1,1,1,0)
        _Flicker ("Flicker Intensity", Range(0, 1)) = 1.0
        _NormalsInfluence ("Normals Influence", Range(0, 1)) = 0.75
    }

    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent-100"
            "DisableBatching"="True"
        }

        Pass
        {
            Lighting Off
            Blend One One
            ZWrite Off
            ZTest Always
            Cull Front

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            // The Core.hlsl file contains definitions of frequently used HLSL
            // macros and functions, and also contains #include references to other
            // HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            // The DeclareDepthTexture.hlsl file contains utilities for sampling the
            // Camera depth texture.
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareNormalsTexture.hlsl"


            struct Attributes
            {
                float3 positionOS : POSITION;
                half3 normalOS : NORMAL;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                half flicker : TANGENT;
            };

            // The square root of 3 is the distance from the center of a 2x2x2
            // box to any of its corners; essentially, the magnitude of (1, 1, 1).
            static const float sqrtOf3 = 1.73205080757;

            // Use CBUFFER to ensure SRP Batcher compatibility
            CBUFFER_START(UnityPerMaterial)
            half3 _Color;
            float _Flicker;
            float _NormalsInfluence;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;

                OUT.positionHCS = TransformObjectToHClip(IN.positionOS);

                float3 centerPosWS = TransformObjectToWorld(float3(0.0, 0.0, 0.0));

                float time = _Time.y * 1.5;
                time += centerPosWS.x + centerPosWS.y + centerPosWS.z;
                half flicker = sin(time * 2.0 + sin(time * 3.0) + sin(time * 16.0)) * 0.5 + 0.5;
                flicker = 1.0 - (flicker * _Flicker);

                OUT.flicker = flicker;

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // To calculate the UV coordinates for sampling the depth buffer,
                // divide the pixel location by the render target resolution
                // _ScaledScreenParams.
                float2 UV = IN.positionHCS.xy / _ScaledScreenParams.xy;

                // Sample the depth from the Camera depth texture.
                #if UNITY_REVERSED_Z
                real depth = SampleSceneDepth(UV);
                #else
                    // Adjust Z to match NDC for OpenGL ([-1, 1])
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(UV));
                #endif

                // Reconstruct the world space positions.
                float3 worldPos = ComputeWorldSpacePosition(UV, depth, UNITY_MATRIX_I_VP);

                // Get the scene's position in this object's space
                float3 objectPos = TransformWorldToObject(worldPos);

                float falloff = length(objectPos);
                falloff = 1.0 - min(1.0, falloff);
                falloff = pow(falloff, 2.6);

                float intensity = falloff * IN.flicker;

                float3 normalWS = SampleSceneNormals(UV);
                float3 centerPosWS = TransformObjectToWorld(float3(0, 0, 0));
                float3 lightDir = normalize(centerPosWS - worldPos);
                float lambert = saturate(dot(normalWS, lightDir));

                float lambertBlend = lerp(1, lambert, _NormalsInfluence);\

                half3 color = _Color * intensity * lambertBlend;

                return half4(color, 1.0);
            }
            ENDHLSL
        }
    }
}