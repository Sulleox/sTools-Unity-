﻿Shader "sTools/MirrorShader[Not Finished]" 
{
	Properties 
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	}
	SubShader 
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		#pragma surface surf Standard fullforwardshadows
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input 
		{
			float2 uv_MainTex;
		};

		UNITY_INSTANCING_CBUFFER_START(Props)
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			float2 mirrorUV;
			mirrorUV.x = 1 - IN.uv_MainTex.x;
			mirrorUV.y = IN.uv_MainTex.y;
			o.Albedo = tex2D (_MainTex, mirrorUV);
			o.Alpha = 1.0f;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
