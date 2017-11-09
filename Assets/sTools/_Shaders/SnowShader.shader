﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "sTools/SnowShader"
{
	Properties
	{
		//Shader Variables
		_SnowVector("SnowVector", vector) = (0,1,0,0)
		_SnowThreshold("Threshold", Range(0,1)) = 0.0
		_SnowAmount("Amount", Range(0,0.2)) = 0.0

		//Snow Texture
		_snowColor("Color", Color) = (1,1,1,1)
		_snowTex("Snow Texture", 2D) = "white" {}
		_snowGlossiness("Snow Smoothness", Range(0,1)) = 0.5
		_snowMetallic("Snow Metallic", Range(0,1)) = 0.0
		_snowMet("Snow Metallic Map", 2D) = "white" {}
		_snowBumpMap("Snow Normal Map", 2D) = "bump" {}

		//Other Texture
		_otherColor("Color", Color) = (1,1,1,1)
		_otherTex("Other Texture", 2D) = "white" {}
		_otherGlossiness("Other Smoothness", Range(0,1)) = 0.5
		_otherMetallic("Other Metallic", Range(0,1)) = 0.0
		_otherMet("Other Metallic Map", 2D) = "white" {}
		_otherBumpMap("Other Normal Map", 2D) = "bump" {}

		//Glitter Map
		_glitterScreenSpace("Screen Glitter Map", 2D) = "black" {}
		_glitterWorldSpace("World Glitter Map", 2D) = "black" {}

		//Noise
		_noiseTex("Noise Map", 2D) = "white" {}
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 5.0

		struct Input
		{
			float2 uv_snowTex;
			float2 uv_otherTex;
			float2 uv_noiseTex;
			float4 screenPos;
			float _SnowMask;
		};

		float3 _SnowVector;
		float _SnowAmount;
		float _SnowThreshold;

		//Snow Texture
		float4 _snowColor;
		sampler2D _snowTex;
		sampler2D _snowMet;
		sampler2D _snowBumpMap;
		half _snowGlossiness;
		half _snowMetallic;

		//Other Texture
		float4 _otherColor;
		sampler2D _otherTex;
		sampler2D _otherMet;
		sampler2D _otherBumpMap;
		half _otherGlossiness;
		half _otherMetallic;

		//Glitter Texture
		sampler2D _glitterScreenSpace;
		sampler2D _glitterWorldSpace;

		sampler2D _noiseTex;
		float _SnowMask;

		UNITY_INSTANCING_CBUFFER_START(Props)
		UNITY_INSTANCING_CBUFFER_END

			void vert(inout appdata_full v, out Input o)
		{
			//Enable input save in Vertex Edit.
			UNITY_INITIALIZE_OUTPUT(Input, o);

			//Generate worldNormal & SnowMask
			_SnowVector = normalize(_SnowVector);
			float3 worldNormal = UnityObjectToWorldNormal(v.normal);
			_SnowMask = saturate(saturate(dot(_SnowVector, worldNormal)) * _SnowThreshold);

			//Add bump to Vertex
			v.vertex.xyz = mul(unity_ObjectToWorld, v.vertex);
			v.vertex.xyz += float3(0.0, 1.0, 0.0) * _SnowAmount * _SnowMask;
			v.vertex.xyz = mul(unity_WorldToObject, v.vertex);

			//Save SnowMask
			o._SnowMask = _SnowMask;

		}

		void surf(Input IN, inout SurfaceOutputStandard o)
		{
			//Glitter
			float w = max(0.0001, IN.screenPos.w);
			float2 ScreenUV = IN.screenPos.xy / w;
			fixed4 glitterScreen = tex2D(_glitterScreenSpace, ScreenUV);
			fixed4 glitterWorld = tex2D(_glitterWorldSpace, IN.uv_snowTex);
			o.Emission = glitterScreen * glitterWorld;

			//Albedo
			fixed4 snowAlbedo = tex2D(_snowTex, IN.uv_snowTex) *_snowColor;
			fixed4 otherAlbedo = tex2D(_otherTex, IN.uv_otherTex) *_otherColor;
			fixed4 noiseTex = tex2D(_noiseTex, IN.uv_noiseTex);
			o.Albedo = lerp(otherAlbedo, snowAlbedo, IN._SnowMask * noiseTex);

			//Metallic && Glossiness
			fixed4 snowMetallic = tex2D(_snowMet, IN.uv_snowTex) * _snowMetallic;
			fixed4 otherMetallic = tex2D(_otherMet, IN.uv_otherTex) * _otherMetallic;
			o.Metallic = lerp(otherMetallic, snowMetallic, IN._SnowMask);
			o.Smoothness = lerp(otherMetallic.a, otherMetallic.a, IN._SnowMask);

			//Normal
			fixed4 snowNormal = tex2D(_snowBumpMap, IN.uv_snowTex);
			fixed4 otherNormal = tex2D(_otherBumpMap, IN.uv_otherTex);
			o.Normal = UnpackNormal(lerp(otherNormal, snowNormal, IN._SnowMask));

			o.Alpha = _snowColor.a;
		}
		ENDCG
	}
		FallBack "Diffuse"
}
